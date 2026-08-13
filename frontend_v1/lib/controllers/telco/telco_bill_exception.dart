class TelcoBillException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  const TelcoBillException({
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    return 'TelcoBillException: $message';
  }
}