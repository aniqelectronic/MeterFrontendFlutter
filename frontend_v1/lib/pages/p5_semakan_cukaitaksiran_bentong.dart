import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/taksiran/semakan_cukai_taksiran_bentong_service.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/p4.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

class P5SemakanCukaiTaksiranBentongScreen extends StatefulWidget {
  const P5SemakanCukaiTaksiranBentongScreen({super.key});

  @override
  State<P5SemakanCukaiTaksiranBentongScreen> createState() =>
      _P5SemakanCukaiTaksiranBentongScreenState();
}

class _P5SemakanCukaiTaksiranBentongScreenState
    extends State<P5SemakanCukaiTaksiranBentongScreen> {
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> paymentList = [];

  @override
  void initState() {
    super.initState();
    paymentList = SemakanCukaiTaksiranBentongService.paymentList;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _value(Map<String, dynamic> item, String key) {
    final value = item[key];
    if (value == null || value.toString().trim().isEmpty) return "-";
    return value.toString();
  }

  String _money(Map<String, dynamic> item, String key) {
    final raw = item[key]?.toString().replaceAll(",", "") ?? "0";
    final value = double.tryParse(raw) ?? 0.0;
    return value.toStringAsFixed(2);
  }

  String _date(String raw) {
    if (raw == "-" || raw.trim().isEmpty) return "-";

    try {
      final dt = DateTime.parse(raw);
      return "${dt.day.toString().padLeft(2, '0')}/"
          "${dt.month.toString().padLeft(2, '0')}/"
          "${dt.year} "
          "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (paymentList.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            loc.noPaymentRecordsFound,
            style: const TextStyle(fontSize: 30),
          ),
        ),
      );
    }

    final rowTextSize =
        MediaQuery.of(context).size.width >= 900 ? 22.0 : 12.0;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Text(
                    loc.semakancukaititle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 3, 89, 210),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Text(
                    loc.assessmentTaxPaymentTransactionList,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 50),
                  _tableHeader(rowTextSize, loc),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 180),
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        thickness: 20,
                        radius: const Radius.circular(10),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 30),
                          itemCount: paymentList.length,
                          itemBuilder: (_, i) =>
                              _paymentRow(paymentList[i], rowTextSize, loc),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 200,
            right: 200,
            child: KioskBackButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => P4PAGE(
                      title: loc.semakancukaititle,
                      type: "PBT",
                      hint: loc.inputTaxHint,
                      biz: "SEMAKAN CUKAI",
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(double fontSize, AppLocalizations loc) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0359D2).withOpacity(0.85),
            const Color(0xFF0359D2).withOpacity(0.65),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          _fixedHeader(loc.account, 300, fontSize),
          _fixedHeader(loc.transactionNo, 300, fontSize),
          _fixedHeader(loc.amount, 300, fontSize),
          _fixedHeader(loc.info, 100, fontSize),
        ],
      ),
    );
  }

  Widget _paymentRow(
    Map<String, dynamic> item,
    double fontSize,
    AppLocalizations loc,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 16),
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _fixedCell(_value(item, "account_number"), 300, fontSize),
          _fixedCell(_value(item, "bank_trx_no"), 300, fontSize),
          _fixedCell(
            "RM ${_money(item, "amount")}",
            300,
            fontSize + 2,
            bold: true,
          ),
          SizedBox(
            width: 100,
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => _showDetailPopup(item, loc),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0359D2), Color(0xFF4A90E2)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailPopup(Map<String, dynamic> item, AppLocalizations loc) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: 900,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0359D2), Color(0xFF4A90E2)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            loc.transactionInformation,
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _modernDetailRow(
                            loc.id,
                            _value(item, "id"),
                            Icons.numbers,
                          ),
                          _modernDetailRow(
                            loc.registrationNo,
                            _value(item, "no_pendaftaran"),
                            Icons.badge,
                          ),
                          _modernDetailRow(
                            loc.accountNo,
                            _value(item, "account_number"),
                            Icons.confirmation_number,
                          ),
                          _modernDetailRow(
                            loc.ownerName,
                            _value(item, "owner_name"),
                            Icons.person,
                          ),
                          _modernDetailRow(
                            loc.propertyAddress,
                            _value(item, "property_address"),
                            Icons.home,
                          ),
                          _modernDetailRow(
                            loc.orderNo,
                            _value(item, "order_no"),
                            Icons.receipt,
                          ),
                          _modernDetailRow(
                            loc.bankTransactionNo,
                            _value(item, "bank_trx_no"),
                            Icons.account_balance,
                          ),
                          _modernDetailRow(
                            loc.paymentMethod,
                            _value(item, "payment_method"),
                            Icons.payment,
                          ),
                          _modernDetailRow(
                            loc.paidDate,
                            _date(_value(item, "paid_date")),
                            Icons.calendar_month,
                          ),
                          _modernDetailRow(
                            loc.amount,
                            "RM ${_money(item, "amount")}",
                            Icons.payments,
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.close),
                        label: Text(
                          loc.close,
                          style: const TextStyle(fontSize: 22),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _fixedHeader(String text, double width, double size) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _fixedCell(
    String text,
    double width,
    double size, {
    bool bold = false,
  }) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: size,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _modernDetailRow(
    String label,
    String value,
    IconData icon, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF0359D2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0359D2), size: 24),
          ),
          const SizedBox(width: 15),
          SizedBox(
            width: 300,
            child: Text(
              "$label :",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: bold ? Colors.redAccent : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}