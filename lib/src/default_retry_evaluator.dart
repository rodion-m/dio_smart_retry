import 'dart:async';

import 'package:dio/dio.dart';

class DefaultRetryEvaluator {
  DefaultRetryEvaluator(this._retryableStatuses);

  final Set<int> _retryableStatuses;
  int currentAttempt = 0;

  /// Returns true only if the response hasn't been cancelled
  ///   or got a bad status code.
  // ignore: avoid-unused-parameters
  FutureOr<bool> evaluate(DioError error, int attempt) {
    bool shouldRetry;
    if (error.type == DioErrorType.badResponse) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        shouldRetry = isRetryable(statusCode);
      } else {
        shouldRetry = true;
      }
    } else {
      shouldRetry =
          error.type != DioErrorType.cancel && error.error is! FormatException;
    }
    currentAttempt = attempt;
    return shouldRetry;
  }

  bool isRetryable(int statusCode) => _retryableStatuses.contains(statusCode);
}
