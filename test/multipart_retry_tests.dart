@TestOn('vm')
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:dio_smart_retry/src/retry_not_supported_exception.dart';
import 'package:test/test.dart';

void main() {
  test('Retry for MultipartFile throws RetryNotSupportedException', () async {
    final dio = Dio();
    dynamic exception;
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print,
      ),
    );

    final formData =
        FormData.fromMap({'file': MultipartFile.fromFileSync('README.md')});
    try {
      await dio.post<dynamic>(
        'https://multipart.free.beeceptor.com/post500',
        data: formData,
      );
    } on DioError catch (error) {
      exception = error.error;
    }

    expect(exception is RetryNotSupportedException, true);
  });

  test('Retry for MultipartFileRecreatable is retrying', () async {
    final dio = Dio();
    const retries = 2;
    final evaluator = DefaultRetryEvaluator(defaultRetryableStatuses);
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print,
        retries: retries,
        retryDelays: const [Duration(seconds: 1), Duration(seconds: 1)],
        retryEvaluator: evaluator.evaluate,
      ),
    );

    final formData = FormData.fromMap({
      'file': MultipartFileRecreatable.fromFileSync('README.md'),
    });
    try {
      await dio.post<dynamic>(
        'https://multipart.free.beeceptor.com/post500',
        data: formData,
      );
    } on DioError catch (error) {
      if (error.type != DioErrorType.response) {
        rethrow;
      }
    }

    expect(evaluator.currentAttempt, retries);
  });
}
