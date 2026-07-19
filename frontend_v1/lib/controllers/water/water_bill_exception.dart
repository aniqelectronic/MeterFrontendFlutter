class WaterBillException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  const WaterBillException({
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    return 'WaterBillException(message: $message, statusCode: $statusCode)';
  }
}
