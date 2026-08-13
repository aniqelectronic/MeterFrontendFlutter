class TelcoBillModel {
  final bool success;

  final String productCode;
  final String accountNumber;

  final String message;
  final String billerName;
  final String customerName;

  final double outstanding;
  final double balance;

  final String address;
  final String eBill;
  final String customField;
  final String dueDate;

  final String lastUpdated;

  const TelcoBillModel({
    required this.success,
    required this.productCode,
    required this.accountNumber,
    required this.message,
    required this.billerName,
    required this.customerName,
    required this.outstanding,
    required this.balance,
    required this.address,
    required this.eBill,
    required this.customField,
    required this.dueDate,
    required this.lastUpdated,
  });

  factory TelcoBillModel.fromApi({
    required String productCode,
    required String accountNumber,
    required Map<String, dynamic> response,
  }) {
    final dynamic rawData = response['data'];

    final Map<String, dynamic> data =
        rawData is Map
            ? Map<String, dynamic>.from(rawData)
            : <String, dynamic>{};

    final dynamic rawMetadata = response['metadata'];

    final Map<String, dynamic> metadata =
        rawMetadata is Map
            ? Map<String, dynamic>.from(rawMetadata)
            : <String, dynamic>{};

    final bool transactionValidity =
        response['transaction_validity'] == true;

    final int statusCode =
        int.tryParse(
          metadata['status_code']?.toString() ?? '',
        ) ??
        0;

    final String message =
        data['message']?.toString().trim() ?? '';

    return TelcoBillModel(
      success:
          transactionValidity &&
          statusCode >= 200 &&
          statusCode < 300,

      productCode:
          metadata['product_code']
              ?.toString()
              .trim()
              .toUpperCase() ??
          productCode.toUpperCase(),

      accountNumber: accountNumber,

      message: message,

      billerName:
          _clean(data['BillerName']),

      customerName:
          _clean(data['CustomerName']),

      outstanding:
          _toDouble(data['Outstanding']),

      balance:
          _toDouble(data['Balance']),

      address:
          _clean(data['Address']),

      eBill:
          _clean(data['E-Bill']),

      customField:
          _clean(data['CustomField']),

      dueDate:
          _clean(data['DueDate']),

      lastUpdated:
          _clean(metadata['last_updated']),
    );
  }

  static String _clean(dynamic value) {
    if (value == null) {
      return '';
    }

    final String text =
        value.toString().trim();

    if (text.toLowerCase() == 'null') {
      return '';
    }

    return text;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }
}