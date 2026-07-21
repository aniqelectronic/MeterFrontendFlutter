class BroadbandBillException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  const BroadbandBillException({
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    return 'BroadbandBillException('
        'message: $message, '
        'statusCode: $statusCode'
        ')';
  }
}