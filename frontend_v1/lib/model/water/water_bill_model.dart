class WaterBillModel {
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
  final Map<String, dynamic> rawData;

  const WaterBillModel({
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

  factory WaterBillModel.fromApi({
    required String productCode,
    required String billerName,
    required String enteredAccountNumber,
    required Map<String, dynamic> response,
  }) {
    final data = _extractData(response);
    final outstanding = _parseAmount(data['Outstanding']);
    final balance = _parseAmount(data['Balance']);

    return WaterBillModel(
      success: response['transaction_validity'] == true,
      productCode: productCode.trim().toUpperCase(),
      billerName: _firstNonEmptyString([
        data['BillerName'],
        billerName,
      ]),
      accountNumber: _firstNonEmptyString([
        data['AccountNo'],
        data['AccountNumber'],
        enteredAccountNumber,
      ]),
      customerName: _firstNonEmptyString([
        data['CustomerName'],
        data['Name'],
      ]),
      customerAddress: _firstNonEmptyString([
        data['Address'],
        data['CustomerAddress'],
      ]),
      billNumber: _firstNonEmptyString([
        data['BillNo'],
        data['BillNumber'],
      ]),
      amount: outstanding,
      outstandingAmount: outstanding,
      currentAmount: balance,
      billDate: _firstNonEmptyString([
        data['BillDate'],
      ]),
      dueDate: _firstNonEmptyString([
        data['DueDate'],
      ]),
      message: _firstNonEmptyString([
        data['message'],
        response['transaction_message'],
        response['error_message'],
      ]),
      rawData: response,
    );
  }

  static Map<String, dynamic> _extractData(Map<String, dynamic> response) {
    for (final key in ['data', 'result', 'bill']) {
      final value = response[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return response;
  }

  static String _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return '';
  }

  static double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();

    final cleaned = value
        .toString()
        .replaceAll('RM', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(cleaned) ?? 0;
  }

  Map<String, dynamic> toJson() => {
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
