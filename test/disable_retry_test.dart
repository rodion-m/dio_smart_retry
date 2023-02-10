@TestOn('vm')
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:diox/diox.dart';
import 'package:test/test.dart';

void main() {
  const mockUrl = 'https://mock.codes/500';

  test('Request with disabledRetry option in RequestOptions is not retried',
      () async {
    final dio = Dio();
    var retryEvaluatorCalled = false;
    var exceptionThrown = false;
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print,
        retryEvaluator: (_, __) => retryEvaluatorCalled = true,
      ),
    );
    final request = RequestOptions(path: mockUrl)..disableRetry = true;

    try {
      await dio.fetch<dynamic>(request);
    } catch (_) {
      exceptionThrown = true;
    }

    expect(retryEvaluatorCalled, false);
    expect(exceptionThrown, true);
  });

  test('Request with disableRetry option in Options is not retried', () async {
    final dio = Dio();
    var retryEvaluatorCalled = false;
    var exceptionThrown = false;
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print,
        retryEvaluator: (_, __) => retryEvaluatorCalled = true,
      ),
    );
    final options = Options()..disableRetry = true;

    try {
      await dio.get<dynamic>(mockUrl, options: options);
    } catch (_) {
      exceptionThrown = true;
    }

    expect(retryEvaluatorCalled, false);
    expect(exceptionThrown, true);
  });
}
