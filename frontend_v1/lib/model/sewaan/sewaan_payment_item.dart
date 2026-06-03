class SewaanPaymentItem {
  final String accountNo;
  final String tenantName;
  final String registrationNo;
  final String startDate;
  final String endDate;
  final String premiseAddress;
  final String mailingAddress;
  final double outstandingRent;
  final double currentRent;
  final double amount;

  SewaanPaymentItem({
    required this.accountNo,
    required this.tenantName,
    required this.registrationNo,
    required this.startDate,
    required this.endDate,
    required this.premiseAddress,
    required this.mailingAddress,
    required this.outstandingRent,
    required this.currentRent,
    required this.amount,
  });
}