class RetryNotSupportedException implements Exception {
  RetryNotSupportedException([this.message]);

  final String? message;

  @override
  String toString() {
    if (message == null) return 'RetryNotSupportedException';
    return 'RetryNotSupportedException: $message';
  }
}
