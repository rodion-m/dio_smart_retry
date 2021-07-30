import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/src/http_status_codes.dart';

void main() async {
  final dio = Dio();

// Add the interceptor with optional options
  dio.interceptors.add(RetryInterceptor(
    dio: dio,
    logPrint: print, // specify log function
    retries: 3, // retry count
    retryDelays: const [
      Duration(seconds: 1), // wait 1 sec before first retry
      Duration(seconds: 2), // wait 2 sec before second retry
      Duration(seconds: 3), // wait 3 sec before third retry
    ],
  ));
  final request = RequestOptions(path: '...')..disableRetry = true;

  /// Sending a failing request for 3 times with a 1s, then 2s, then 3s interval
  await dio.get('https://mock.codes/$status500InternalServerError');
}
