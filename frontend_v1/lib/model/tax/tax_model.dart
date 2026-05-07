class TaxModel {
  final int propertyId;
  final int ownerId;
  final String ownerName;
  final double annualValue;
  final double ratePercent;
  final double halfYearAmount;
  final int year;
  final String cycle;
  final String billNo;
  final String issueDate;
  final String dueDate;
  final double totalPayable;
  final String propertyType;

  /// Shared total amount (same as static in Java)
  static double totalAmount = 0.0;

  TaxModel({
    required this.propertyId,
    required this.ownerId,
    required this.ownerName,
    required this.annualValue,
    required this.ratePercent,
    required this.halfYearAmount,
    required this.year,
    required this.cycle,
    required this.billNo,
    required this.issueDate,
    required this.dueDate,
    required this.totalPayable,
    required this.propertyType,
  });

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      propertyId: json['property_id'],
      ownerId: json['owner_id'],
      ownerName: json['owner_name'],
      annualValue: (json['annual_value'] as num).toDouble(),
      ratePercent: (json['rate_percent'] as num).toDouble(),
      halfYearAmount: (json['half_year_amount'] as num).toDouble(),
      year: json['year'],
      cycle: json['cycle'],
      billNo: json['bill_no'],
      issueDate: json['issue_date'],
      dueDate: json['due_date'],
      totalPayable: (json['half_year_amount'] as num).toDouble(),
      propertyType: json['property_type'],
    );
  }

  static void clearTotal() {
    totalAmount = 0.0;
  }
}
