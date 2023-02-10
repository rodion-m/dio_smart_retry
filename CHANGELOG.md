## 2.0.0-diox
- Add supporting of [DioX](https://pub.dev/packages/diox)

## 1.4.0
- Add supporting of retrying for requests with `multipart/form-data`, use `MultipartFileRecreatable` class for that ([details](https://github.com/rodion-m/dio_smart_retry#retry-requests-with-multipartform-data)).
- `DefaultRetryEvaluator` and status codes constants from the file `http_status_codes.dart` was made a part of the public API.

## 1.3.2
- Add a feature allowing to specify extra retryable status codes (parameter `retryableExtraStatuses`) (#11)
- Add a request's `CancelToken` checking
- Update dependencies

## 1.2.0

- Add properly an incorrect url scheme error handling in the default  retry evaluator (#2)

## 1.1.0

- A request catching is fixed (#1)
- Dependencies were updated

## 1.0.3

- Example updated

## 1.0.2

- Initial version.
