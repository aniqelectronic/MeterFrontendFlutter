class AmountFormatter {
  static String formatRM(String? amountString) {
    if (amountString == null || amountString.trim().isEmpty) return "RM0.00";
    try {
      int cents = int.parse(amountString.trim());
      double ringgit = cents / 100.0;
      return "RM${ringgit.toStringAsFixed(2)}";
    } catch (_) {
      return "RM0.00";
    }
  }

  static double parseAsDouble(String? amountString) {
    if (amountString == null || amountString.trim().isEmpty) return 0.0;
    try {
      return int.parse(amountString.trim()) / 100.0;
    } catch (_) {
      return 0.0;
    }
  }
}
