class ElectricBillModel {
  final bool success;
  final String productCode;
  final String billerName;
  final String accountNumber;

  final String customerName;
  final String customerAddress;
  final String billNumber;

  final double amount;
  final double outstandingAmount;
  final double currentAmount;

  final String billDate;
  final String dueDate;

  final String message;

  /// Keeps the complete API response so that no provider-specific
  /// fields are lost.
  final Map<String, dynamic> rawData;

  const ElectricBillModel({
    required this.success,
    required this.productCode,
    required this.billerName,
    required this.accountNumber,
    required this.customerName,
    required this.customerAddress,
    required this.billNumber,
    required this.amount,
    required this.outstandingAmount,
    required this.currentAmount,
    required this.billDate,
    required this.dueDate,
    required this.message,
    required this.rawData,
  });

factory ElectricBillModel.fromApi({
  required String productCode,
  required String billerName,
  required String enteredAccountNumber,
  required Map<String, dynamic> response,
}) {
  final data = _extractData(response);

  final isSuccess =
      response['transaction_validity'] == true;

  final outstanding = _parseAmount(
    data['Outstanding'],
  );

  final balance = _parseAmount(
    data['Balance'],
  );

  return ElectricBillModel(
    success: isSuccess,

    productCode: productCode,

    billerName: _firstNonEmptyString(
      [
        data['BillerName'],
        billerName,
      ],
    ),

    accountNumber: enteredAccountNumber,

    customerName: _firstNonEmptyString(
      [
        data['CustomerName'],
      ],
    ),

    customerAddress: _firstNonEmptyString(
      [
        data['Address'],
      ],
    ),

    billNumber: '',

    amount: outstanding,

    outstandingAmount: outstanding,

    currentAmount: balance,

    billDate: '',

    dueDate: _firstNonEmptyString(
      [
        data['DueDate'],
      ],
    ),

    message: _firstNonEmptyString(
      [
        data['message'],
        response['transaction_message'],
        response['error_message'],
      ],
    ),

    rawData: response,
  );
}

  static Map<String, dynamic> _extractData(
    Map<String, dynamic> response,
  ) {
    final possibleData = response['data'];

    if (possibleData is Map<String, dynamic>) {
      return possibleData;
    }

    if (possibleData is Map) {
      return Map<String, dynamic>.from(possibleData);
    }

    final possibleResult = response['result'];

    if (possibleResult is Map<String, dynamic>) {
      return possibleResult;
    }

    if (possibleResult is Map) {
      return Map<String, dynamic>.from(possibleResult);
    }

    final possibleBill = response['bill'];

    if (possibleBill is Map<String, dynamic>) {
      return possibleBill;
    }

    if (possibleBill is Map) {
      return Map<String, dynamic>.from(possibleBill);
    }

    return response;
  }

  static dynamic _firstValue(List<dynamic> values) {
    for (final value in values) {
      if (value != null) {
        return value;
      }
    }

    return null;
  }

  static String _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;

      final text = value.toString().trim();

      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }

    return '';
  }

  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    final cleaned = value
        .toString()
        .replaceAll('RM', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(cleaned) ?? 0.0;
  }

  static bool _parseSuccess(dynamic value) {
    if (value == null) {
      return true;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value == 0 || value == 1 || value == 200;
    }

    final text = value.toString().trim().toLowerCase();

    return text == 'true' ||
        text == 'success' ||
        text == 'successful' ||
        text == 'ok' ||
        text == '00' ||
        text == '0' ||
        text == '200';
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'productCode': productCode,
      'billerName': billerName,
      'accountNumber': accountNumber,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'billNumber': billNumber,
      'amount': amount,
      'outstandingAmount': outstandingAmount,
      'currentAmount': currentAmount,
      'billDate': billDate,
      'dueDate': dueDate,
      'message': message,
      'rawData': rawData,
    };
  }
}