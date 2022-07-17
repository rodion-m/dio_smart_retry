@TestOn('vm')
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:test/test.dart';

void main() {
  test('Request with disabledRetry option is not retried', () async {
    final dio = Dio();
    var retryEvaluatorCalled = false, exceptionThrown = false;
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print,
        retryEvaluator: (_, __) => retryEvaluatorCalled = true,
      ),
    );
    final request = RequestOptions(path: 'https://mock.codes/500')
      ..disableRetry = true;

    try {
      await dio.fetch<dynamic>(request);
    } catch (_) {
      exceptionThrown = true;
    }

    expect(retryEvaluatorCalled, false);
    expect(exceptionThrown, true);
  });
}
