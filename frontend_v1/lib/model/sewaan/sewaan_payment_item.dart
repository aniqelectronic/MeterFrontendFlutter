class SewaanPaymentItem {
  final String tenantName;
   final String accountNo;        // Account Number
  final String registrationNo;   // Registration Number
  final String noPendaftaran;    // No Pendaftaran
  final String startDate;
  final String endDate;
  final String premiseAddress;
  final String mailingAddress;
  final double outstandingRent;
  final double currentRent;
  final double amount;

  SewaanPaymentItem({
    required this.noPendaftaran,
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