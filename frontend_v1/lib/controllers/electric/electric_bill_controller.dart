import 'package:frontend_v1/model/electric/electric_bill_model.dart';

class ElectricBillController {
  ElectricBillController._();

  static ElectricBillModel? selectedBill;

  static void setSelectedBill(ElectricBillModel bill) {
    selectedBill = bill;
  }

  static void clear() {
    selectedBill = null;
  }
}