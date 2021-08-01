[![Pub Version](https://img.shields.io/pub/v/dio_smart_retry?logo=dart&logoColor=white)](https://pub.dev/packages/dio_smart_retry/)
[![Dart SDK Version](https://badgen.net/pub/sdk-version/dio_smart_retry)](https://pub.dev/packages/dio_smart_retry/)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License](https://img.shields.io/github/license/rodion-m/dio_smart_retry)](https://github.com/rodion-m/dio_smart_retry/blob/master/LICENSE)

## Dio Smart Retry
Flexible retry library for Dio package. This is a next generation of an abandoned `dio_retry` package. \
By default, the request will be retried only for appropriate retryable http statuses. \
Also, it supports dynamic delay between retries. \
**Null Safety.**

## Getting started

1. Add package to pubspec.yaml: `dio_smart_retry: ^1.0.2`
2. Import package: `import 'package:dio_smart_retry/dio_smart_retry.dart'`

## Usage

Just add an interceptor to your dio:
```dart
final dio = Dio();
// Add the interceptor
dio.interceptors.add(RetryInterceptor(
  dio: dio,
  logPrint: print, // specify log function (optional)
  retries: 3, // retry count (optional)
  retryDelays: const [ // set delays between retries (optional)
    Duration(seconds: 1), // wait 1 sec before first retry
    Duration(seconds: 2), // wait 2 sec before second retry
    Duration(seconds: 3), // wait 3 sec before third retry
  ],
));

/// Sending a failing request for 3 times with 1s, then 2s, then 3s interval
await dio.get('https://mock.codes/500');
```
[See `example/dio_smart_retry_example.dart`](https://github.com/rodion-m/dio_smart_retry/blob/master/example/dio_smart_retry_example.dart).

## Default retryable status codes list
Responses with this http status codes will be retried by default:
* 408: RequestTimeout
* 429: TooManyRequests
* 500: InternalServerError
* 502: BadGateway
* 503: ServiceUnavailable
* 504: GatewayTimeout
* 440: LoginTimeout (IIS)
* 460: ClientClosedRequest (AWS Elastic Load Balancer)
* 499: ClientClosedRequest (ngnix)
* 520: WebServerReturnedUnknownError
* 521: WebServerIsDown
* 522: ConnectionTimedOut
* 523: OriginIsUnreachable
* 524: TimeoutOccurred
* 525: SSLHandshakeFailed
* 527: RailgunError
* 598: NetworkReadTimeoutError
* 599: NetworkConnectTimeoutError

## Disable retry
It's possible to manually disable retry for a specified request. Use `disableRetry` extension for that:
```dart
final request = RequestOptions(path: '/')..disableRetry = true;
```