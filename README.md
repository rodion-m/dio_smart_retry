[![Pub Version](https://img.shields.io/pub/v/dio_smart_retry?logo=dart&logoColor=white)](https://pub.dev/packages/dio_smart_retry/)
[![Dart SDK Version](https://badgen.net/pub/sdk-version/dio_smart_retry)](https://pub.dev/packages/dio_smart_retry/)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License](https://img.shields.io/github/license/rodion-m/dio_smart_retry)](https://github.com/rodion-m/dio_smart_retry/blob/master/LICENSE)

# Dio Smart Retry
Flexible retry library for Dio package. This is a next generation of an abandoned `dio_retry` package. \
By default, the request will be retried only for appropriate retryable http statuses. \
Also, it supports dynamic delay between retries. \
**Null Safety.**

## Contents

- [Dio Smart Retry](#dio-smart-retry)
  - [Contents](#contents)
  - [Getting Started for Dio](#getting-started-for-dio)
  - [Usage](#usage)
  - [Default retryable status codes list](#default-retryable-status-codes-list)
  - [Disable retry](#disable-retry)
  - [Add extra retryable status codes](#add-extra-retryable-status-codes)
  - [Override retryable statuses](#override-retryable-statuses)
  - [Retry requests with `multipart/form-data`](#retry-requests-with-multipartform-data)

## Getting Started for Dio

1. Add package to pubspec.yaml: `dio_smart_retry: ^5.0.0` **
2. Import package: `import 'package:dio_smart_retry/dio_smart_retry.dart'`

** For the old dio (ver. 4.+) use `dio_smart_retry: ^1.4.0`

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
Responses with these http status codes will be retried by default:
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
[It's possible to override this list](#override-retryable-statuses)

## Disable retry
It's possible to manually disable retry for a specified request. Use `disableRetry` extension for that:
```dart
final request = RequestOptions(path: '/')
  ..disableRetry = true;
await dio.fetch<String>(request);
```
or
```dart
final options = Options()
  ..disableRetry = true;
await dio.get<String>('/', options: options);
```

## Add extra retryable status codes
It's possible to add you own retryable status codes. Use `retryableExtraStatuses` parameter for that. Here is an example:
```dart
RetryInterceptor(
  dio: dio,
  retryableExtraStatuses: { status401Unauthorized },
)
```
or:
```dart
RetryInterceptor(
  dio: dio,
  retryableExtraStatuses: { 401 },
)
```

## Override retryable statuses
It's possible to override default retryable status codes list. Just make new instance of `DefaultRetryEvaluator` and pass your status codes there. \
Here is an example:
```dart
final myStatuses = { status400BadRequest, status409Conflict };
dio.interceptors.add(
  RetryInterceptor(
    dio: dio,
    logPrint: print,
    retryEvaluator: DefaultRetryEvaluator(myStatuses).evaluate,
  ),
);

await dio.get<dynamic>('https://mock.codes/400');
```

## Retry requests with `multipart/form-data`
Because dio's class for multipart data `MultipartFile` doesn't support stream rewinding (recreation) to support retry for multipart data you should use a class `MultipartFileRecreatable` instead of `MultipartFile`. \
Here is an example:
```dart
final formData =
    FormData.fromMap({'file': MultipartFileRecreatable.fromFileSync('README.md')});
  await dio.post<dynamic>(
    'https://multipart.free.beeceptor.com/post500',
    data: formData,
  );
```
See the full example in the test: https://github.com/rodion-m/dio_smart_retry/blob/63a3bddae8b5a0581c35c4ae5e973996561d9100/test/multipart_retry_tests.dart#L32-L61

## Migrating to 6.0

Version 6.0 introduces 2 breaking changes:
- `MultipartFileRecreatable.filename` is now a named parameter
- `MultipartFileRecreatable.filePath` is now removed

To update to the latest version, if you were using the `MultipartFileRecreatable` constructor, remove the `filePath` parameter and change `filename` to a named parameter:

Old:
```dart
return MultipartFileRecreatable(
  stream,
  length,
  filename,
  filePath,
);
```
New:
```dart
return MultipartFileRecreatable(
  stream,
  length,
  filename: filename,
);
```