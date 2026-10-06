import 'package:flutter/material.dart';

import 'package:frontend_v1/pages/resit/bill/digital_voucher_receipt_page.dart';

// ============================================================================
// FOOD & BEVERAGE RECEIPT ADAPTER
//
// Food & Beverage has the same voucher fulfilment result structure as the
// existing Digital Voucher receipt (PIN / link / SN / expiry).
//
// Keeping this adapter means the Food & Beverage payment flow is already
// separated by filename/class now. Later you can replace this widget with a
// dedicated orange Food & Beverage receipt UI without touching Page 4 or the
// payment page.
// ============================================================================

typedef FoodBeverageReceiptData = DigitalVoucherReceiptData;

class FoodBeverageReceiptPage extends StatelessWidget {
  final FoodBeverageReceiptData data;

  const FoodBeverageReceiptPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return DigitalVoucherReceiptPage(
      data: data,
    );
  }
}
