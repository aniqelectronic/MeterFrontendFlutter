class ElectricBillException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  const ElectricBillException({
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    return 'ElectricBillException('
        'message: $message, '
        'statusCode: $statusCode'
        ')';
  }
}