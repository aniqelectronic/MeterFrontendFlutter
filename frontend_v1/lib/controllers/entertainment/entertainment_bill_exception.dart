class EntertainmentBillException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  const EntertainmentBillException({
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() => message;
}
