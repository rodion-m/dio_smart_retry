@TestOn('vm')
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:test/test.dart';

void main() {
  test('Retry for MultipartFile is retrying', () async {
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
      'file': MultipartFile.fromFileSync('README.md'),
    });
    try {
      await dio.post<dynamic>(
        'https://rodion-m.ru/mock/post500.php',
        data: formData,
      );
    } on DioException catch (error) {
      if (error.type != DioExceptionType.badResponse) {
        rethrow;
      }
    }

    expect(evaluator.currentAttempt, retries);
  });
}
