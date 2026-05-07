import 'package:flutter/material.dart';

class SelectedTaxProvider extends ChangeNotifier {
  final List<String> _selectedBills = [];

  List<String> get selectedBills => List.unmodifiable(_selectedBills);

  void setBills(List<String> bills) {
    _selectedBills
      ..clear()
      ..addAll(bills);
    notifyListeners();
  }

  void addBill(String billNo) {
    if (!_selectedBills.contains(billNo)) {
      _selectedBills.add(billNo);
      notifyListeners();
    }
  }

  void removeBill(String billNo) {
    _selectedBills.remove(billNo);
    notifyListeners();
  }

  void clear() {
    _selectedBills.clear();
    notifyListeners();
  }
}
