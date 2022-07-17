import 'dart:async';

import 'package:dio/dio.dart';

import 'package:dio_smart_retry/src/default_retry_evaluator.dart';
import 'package:dio_smart_retry/src/http_status_codes.dart';

typedef RetryEvaluator = FutureOr<bool> Function(DioError error, int attempt);

/// An interceptor that will try to send failed request again
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.logPrint,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 3),
      Duration(seconds: 5),
    ],
    RetryEvaluator? retryEvaluator,
    this.ignoreRetryEvaluatorExceptions = false,
    this.retryableExtraStatuses = const {},
  }) : _retryEvaluator = retryEvaluator ?? DefaultRetryEvaluator({
        ...defaultRetryableStatuses,
        ...retryableExtraStatuses,
      }).evaluate {
    if(retryEvaluator != null && retryableExtraStatuses.isNotEmpty) {
      throw ArgumentError(
          '[retryableExtraStatuses] works only if [retryEvaluator] is null.'
              ' Set either [retryableExtraStatuses] or [retryEvaluator].'
              ' Not both.',
          'retryableExtraStatuses',
      );
    }
  }

  /// The original dio
  final Dio dio;

  /// For logging purpose
  final void Function(String message)? logPrint;

  /// The number of retry in case of an error
  final int retries;

  /// Ignore exception if [_retryEvaluator] throws it (not recommend)
  final bool ignoreRetryEvaluatorExceptions;

  /// The delays between attempts.
  /// Empty [retryDelays] means no delay.
  ///
  /// If [retries] count more than [retryDelays] count,
  ///   the last element value of [retryDelays] will be used.
  final List<Duration> retryDelays;

  /// Evaluating if a retry is necessary.regarding the error.
  ///
  /// It can be a good candidate for additional operations too, like
  ///   updating authentication token in case of a unauthorized error
  ///   (be careful with concurrency though).
  ///
  /// Defaults to [DefaultRetryEvaluator.evaluate]
  ///   with [defaultRetryableStatuses].
  final RetryEvaluator _retryEvaluator;

  /// Specifies an extra retryable statuses,
  ///   which will be taken into account with [defaultRetryableStatuses]
  /// IMPORTANT: THIS SETTING WORKS ONLY IF [_retryEvaluator] is null
  final Set<int> retryableExtraStatuses;

  /// Redirects to [DefaultRetryEvaluator.evaluate]
  ///   with [defaultRetryableStatuses]
  static final FutureOr<bool> Function(DioError error, int attempt)
    defaultRetryEvaluator =
      DefaultRetryEvaluator(defaultRetryableStatuses).evaluate;

  Future<bool> _shouldRetry(DioError error, int attempt) async {
    try {
      return await _retryEvaluator(error, attempt);
    } catch(e) {
      logPrint?.call('There was an exception in _retryEvaluator: $e');
      if(!ignoreRetryEvaluatorExceptions) {
        rethrow;
      }
    }
    return true;
  }

  @override
  Future<dynamic> onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.disableRetry) {
      return super.onError(err, handler);
    }

    final attempt = err.requestOptions._attempt + 1;
    final shouldRetry = attempt <= retries && await _shouldRetry(err, attempt);

    if (!shouldRetry) {
      return super.onError(err, handler);
    }

    err.requestOptions._attempt = attempt;
    final delay = _getDelay(attempt);
    logPrint?.call(
      '[${err.requestOptions.path}] An error occurred during request, '
      'trying again '
      '(attempt: $attempt/$retries, '
      'wait ${delay.inMilliseconds} ms, '
      'error: ${err.error})',
    );

    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }

    try {
      await dio.fetch<void>(err.requestOptions)
          .then((value) => handler.resolve(value));
    } on DioError catch (e) {
      super.onError(e, handler);
    }
  }

  Duration _getDelay(int attempt) {
    if (retryDelays.isEmpty) return Duration.zero;
    return attempt - 1 < retryDelays.length
        ? retryDelays[attempt - 1]
        : retryDelays.last;
  }
}

const _kDisableRetryKey = 'ro_disable_retry';

extension RequestOptionsX on RequestOptions {
  static const _kAttemptKey = 'ro_attempt';

  int get _attempt => (extra[_kAttemptKey] as int?) ?? 0;

  set _attempt(int value) => extra[_kAttemptKey] = value;

  bool get disableRetry => (extra[_kDisableRetryKey] as bool?) ?? false;

  set disableRetry(bool value) => extra[_kDisableRetryKey] = value;
}

extension OptionsX on Options {
  bool get disableRetry => (extra?[_kDisableRetryKey] as bool?) ?? false;

  set disableRetry(bool value) => extra?[_kDisableRetryKey] = value;
}
