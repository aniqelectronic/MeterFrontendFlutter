class PaymentUtils {
  /// Validates if the amount is in a valid format
  /// Accepts: "RM 10.50", "RM10.50", "10.50", "10", "RM 10.5" (auto-formats to 2 decimals)
  static bool isValidAmount(String? raw) {
    if (raw == null || raw.trim().isEmpty) return false;
    
    String cleaned = raw.trim().replaceAll('RM', '').trim();
    
    // Check if it's a valid number (with optional decimal)
    try {
      double value = double.parse(cleaned);
      return value > 0; // Amount must be positive
    } catch (_) {
      return false;
    }
  }

  /// Parses amount string to double
  /// Handles both "RM 10.50" and "10.50" formats
  static double parseAmountToDouble(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0.0;
    
    try {
      String cleaned = raw.trim().replaceAll('RM', '').trim();
      double value = double.parse(cleaned);
      return value > 0 ? value : 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  /// Parses amount to string with 2 decimal places
  static String parseAmountToString(String? raw) {
    return parseAmountToDouble(raw).toStringAsFixed(2);
  }

  /// Formats amount for PAX transaction (converts to cents as integer string)
  /// Example: "10.50" or "RM 10.50" -> "1050"
  static String formatForPaxTransaction(String? raw) {
    double value = parseAmountToDouble(raw);
    int cents = (value * 100).round();
    return cents.toString().padLeft(3, '0');
  }

  /// Adds RM label to amount
  static String addRMLabel(double value) => 'RM ${value.toStringAsFixed(2)}';

  /// Formats amount for receipt display
  static String formatForReceipt(String? raw) =>
      'Amount Paid: ${addRMLabel(parseAmountToDouble(raw))}';
  
  /// Normalizes amount input to standard "RM X.XX" format
  /// Useful for displaying consistent format in UI
  static String normalizeAmount(String? raw) {
    return addRMLabel(parseAmountToDouble(raw));
  }
}