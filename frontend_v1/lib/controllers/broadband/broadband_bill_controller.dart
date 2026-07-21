import 'package:frontend_v1/model/broadband/broadband_bill_model.dart';

class BroadbandBillController {
  BroadbandBillController._();

  static BroadbandBillModel? selectedBill;

  static void setSelectedBill(
    BroadbandBillModel bill,
  ) {
    selectedBill = bill;
  }

  static void clear() {
    selectedBill = null;
  }
}