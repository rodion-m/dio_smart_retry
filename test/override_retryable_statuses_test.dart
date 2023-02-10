@TestOn('vm')
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:test/test.dart';

void main() {
  test('Retryable statuses overridden', () async {
    final dio = Dio();
    const retries = 2;
    final evaluator = DefaultRetryEvaluator({status400BadRequest});
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print,
        retries: retries,
        retryDelays: const [Duration(seconds: 1), Duration(seconds: 1)],
        retryEvaluator: evaluator.evaluate,
      ),
    );

    try {
      await dio.get<dynamic>('https://mock.codes/400');
    } on DioError catch (error) {
      if (error.type != DioErrorType.badResponse ||
          error.response?.statusCode != 400) {
        rethrow;
      }
    }
    expect(evaluator.currentAttempt, retries);
  });
}
