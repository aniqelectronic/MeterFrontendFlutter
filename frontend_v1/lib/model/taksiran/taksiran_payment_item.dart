class TaksiranPaymentItem {
  final String noPendaftaran;
  final String accountNo;
  final double amount;
  final String ownerName;
  final String propertyAddress;

  TaksiranPaymentItem({
    required this.noPendaftaran,
    required this.accountNo,
    required this.amount,
    required this.ownerName,
    required this.propertyAddress,
  });
}