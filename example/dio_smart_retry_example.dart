import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:dio_smart_retry/src/http_status_codes.dart';

Future<dynamic> main() async {
  final dio = Dio();

  // Add the interceptor
  dio.interceptors.add(
    RetryInterceptor(
      dio: dio,
      logPrint: print, // specify log function (optional)
      retries: 4, // retry count (optional)
      retryDelays: const [
        // set delays between retries (optional)
        Duration(seconds: 1), // wait 1 sec before the first retry
        Duration(seconds: 2), // wait 2 sec before the second retry
        Duration(seconds: 3), // wait 3 sec before the third retry
        Duration(seconds: 4), // wait 4 sec before the fourth retry
      ],
      retryableExtraStatuses: { status401Unauthorized },
    ),
  );

  /// Sending a failing request for 3 times with 1s, then 2s, then 3s interval
  await dio.get<dynamic>('https://mock.codes/401');
}
