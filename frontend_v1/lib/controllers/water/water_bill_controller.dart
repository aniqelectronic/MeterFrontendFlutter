import 'package:frontend_v1/model/water/water_bill_model.dart';

class WaterBillController {
  WaterBillController._();

  static WaterBillModel? selectedBill;

  static void setSelectedBill(WaterBillModel bill) {
    selectedBill = bill;
  }

  static void clear() {
    selectedBill = null;
  }
}
