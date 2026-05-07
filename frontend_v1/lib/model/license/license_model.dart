class LicenseModel {
  String licenseNo;
  String icNo;
  String startDate;
  String endDate;
  String licenseType;
  double amount;

  static double totalAmount = 0.0;

  LicenseModel({
    required this.licenseNo,
    required this.icNo,
    required this.startDate,
    required this.endDate,
    required this.licenseType,
    required this.amount,
  });

  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    return LicenseModel(
      licenseNo: json['licensenum'] ?? '',
      icNo: json['ic'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      licenseType: json['licensetype'] ?? '',
      amount: (json['amount'] as num).toDouble(),
    );
  }

  static void setTotalAmount(double value) {
    totalAmount = value;
  }

  static double getTotalAmount() {
    return totalAmount;
  }
}
