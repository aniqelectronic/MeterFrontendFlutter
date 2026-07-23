import 'package:frontend_v1/model/electric/electric_bill_model.dart';

class EntertainmentBillController {
  EntertainmentBillController._();

  static ElectricBillModel? selectedBill;

  static void setSelectedBill(
    ElectricBillModel bill,
  ) {
    selectedBill = bill;
  }

  static void clearSelectedBill() {
    selectedBill = null;
  }
}
