// https://github.com/rodion-m/dio_smart_retry/issues/2
@TestOn('vm')

import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:diox/diox.dart';
import 'package:test/test.dart';

void main() {
  test('#issue2', () async {
    final dio = Dio();
    dio.interceptors.add(RetryInterceptor(dio: dio, logPrint: print));
    expect(
      () => dio
          .get<dynamic>('http ://github.com')
          // ignore: argument_type_not_assignable_to_error_handler, avoid_dynamic_calls, only_throw_errors
          .catchError((dynamic e) => throw e.error as Object),
      throwsA(const TypeMatcher<FormatException>()),
    );
  });
}
