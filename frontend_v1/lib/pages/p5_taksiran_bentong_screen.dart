import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/taksiran/taksiran_service_bentong.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/p4.dart';
import 'package:frontend_v1/pages/payment.dart';
import 'package:frontend_v1/model/taksiran/taksiran_payment_item.dart';

class P5TaksiranBentongScreen extends StatefulWidget {
  const P5TaksiranBentongScreen({super.key});

  @override
  State<P5TaksiranBentongScreen> createState() =>
      _P5TaksiranBentongScreenState();
}

class _P5TaksiranBentongScreenState extends State<P5TaksiranBentongScreen> {
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> taksiranList = [];
  Set<String> selectedAccounts = {};
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    taksiranList = TaksiranServiceBentong.taksiranList;
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

  double _amount(Map<String, dynamic> item, String key) {
    final raw = item[key]?.toString().replaceAll(",", "") ?? "0";
    return double.tryParse(raw) ?? 0.0;
  }

  void _updateTotal() {
    total = taksiranList
        .where((item) => selectedAccounts.contains(_value(item, "account_no")))
        .fold(0.0, (sum, item) => sum + _amount(item, "jumlah_sepenggal"));
  }

  void _toggleTaksiran(String accountNo, bool value) {
    setState(() {
      if (value) {
        selectedAccounts.add(accountNo);
      } else {
        selectedAccounts.remove(accountNo);
      }
      _updateTotal();
    });
  }

void _proceed() {
  final loc = AppLocalizations.of(context)!;

  if (selectedAccounts.isEmpty) {
    _showAlert(loc.notice, loc.taksiranSelectAlert);
    return;
  }

  if (total <= 0) {
    _showAlert(loc.notice, loc.taksiranNoAmountAlert);
    return;
  }

  // ================================
  // BUILD SELECTED TAKSIRAN ITEMS
  // ================================
  final selectedItems = taksiranList
      .where(
        (item) =>
            selectedAccounts.contains(_value(item, "account_no")),
      )
      .map(
        (item) => TaksiranPaymentItem(
          accountNo: _value(item, "account_no"),
          amount: _amount(item, "jumlah_sepenggal"),
          ownerName: _value(item, "name"),
          propertyAddress: [
            _value(item, "no_rumah"),
            _value(item, "lorong_name"),
            _value(item, "jalan_name"),
            _value(item, "postcode"),
            _value(item, "prop_pekan_name"),
            _value(item, "negeri"),
          ].where((e) => e != "-" && e.trim().isNotEmpty).join(", "),
        ),
      )
      .toList();

  // ================================
  // GO TO PAYMENT PAGE
  // ================================
  Navigator.push(
    context,
    MaterialPageRoute(
      settings: const RouteSettings(name: '/payment'),
      builder: (_) => PAYMENTPAGE(
        biz: "CUKAI",
        data: PaymentData(
          amount: total.toStringAsFixed(2),
          taksiranItems: selectedItems,
        ),
      ),
    ),
  );
}

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: const TextStyle(fontSize: 28)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(fontSize: 25)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (taksiranList.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            loc.taksiranNoData,
            style: const TextStyle(fontSize: 30),
          ),
        ),
      );
    }

    const double bottomPanelHeight = 420;
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
                    loc.taksiranTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 3, 89, 210),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    loc.taksiranSelectPayment,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 50),

                  _tableHeader(rowTextSize),

                  SizedBox(
                    height: MediaQuery.of(context).size.height -
                        bottomPanelHeight -
                        250,
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 20,
                      radius: const Radius.circular(10),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: taksiranList.length,
                        itemBuilder: (_, i) =>
                            _taksiranRow(taksiranList[i], rowTextSize),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 200,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc.total,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "RM ${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: _bigButton(
                        loc.back,
                        Colors.grey.shade300,
                        rowTextSize,
                        () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => P4PAGE(
                                title: loc.taksiranTitle,
                                type: "PBT",
                                hint: AppLocalizations.of(context)!.inputTaxHint,
                                biz: "CUKAI",
                              ),
                            ),
                          );
                        },
                        textColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 100),
                    Expanded(
                      child: _bigButton(
                        loc.continueText,
                        Colors.green,
                        rowTextSize,
                        _proceed,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(double fontSize) {
    final loc = AppLocalizations.of(context)!;

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
          const SizedBox(width: 80),
          _fixedHeader(loc.accountNo, 240, fontSize),
          _fixedHeader(loc.startDate, 180, fontSize),
          _fixedHeader(loc.endDate, 180, fontSize),
          _fixedHeader(loc.total, 220, fontSize),
          _fixedHeader(loc.info, 100, fontSize),
        ],
      ),
    );
  }

  Widget _taksiranRow(Map<String, dynamic> item, double fontSize) {
    final accountNo = _value(item, "account_no");
    final selected = selectedAccounts.contains(accountNo);
    final amount = _amount(item, "jumlah_sepenggal");

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 16),
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8F1FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? const Color(0xFF0359D2) : Colors.black12,
          width: selected ? 2 : 1,
        ),
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
          SizedBox(
            width: 80,
            height: 80,
            child: Center(
              child: Transform.scale(
                scale: 2.2,
                child: Checkbox(
                  value: selected,
                  activeColor: const Color(0xFF0359D2),
                  onChanged: (v) => _toggleTaksiran(accountNo, v!),
                ),
              ),
            ),
          ),

          _fixedCell(accountNo, 240, fontSize),
          _fixedCell(_value(item, "start_date"), 180, fontSize),
          _fixedCell(_value(item, "end_date"), 180, fontSize),
          _fixedCell(
            "RM ${amount.toStringAsFixed(2)}",
            220,
            fontSize + 2,
            bold: true,
          ),

          SizedBox(
            width: 100,
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => _showDetailPopup(item),
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

  void _showDetailPopup(Map<String, dynamic> item) {
    final loc = AppLocalizations.of(context)!;

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
                            Icons.home_work,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            loc.taksiranDetailsTitle,
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
                            loc.accountNo,
                            _value(item, "account_no"),
                            Icons.confirmation_number,
                          ),
                          _modernDetailRow(
                            loc.oldAccountNo,
                            _value(item, "old_account_no"),
                            Icons.history,
                          ),
                          _modernDetailRow(
                            loc.invoiceNo,
                            _value(item, "invoice_no"),
                            Icons.receipt,
                          ),
                          _modernDetailRow(
                            loc.name,
                            _value(item, "name"),
                            Icons.person,
                          ),
                          _modernDetailRow(
                            loc.icNo,
                            _value(item, "pdaftaran"),
                            Icons.badge,
                          ),
                          _modernDetailRow(
                            loc.startDate,
                            _value(item, "start_date"),
                            Icons.calendar_month,
                          ),
                          _modernDetailRow(
                            loc.endDate,
                            _value(item, "end_date"),
                            Icons.event,
                          ),
                          _modernDetailRow(
                            loc.propertyAddress,
                            "${_value(item, "no_rumah")} ${_value(item, "lorong_name")} ${_value(item, "jalan_name")}",
                            Icons.home,
                          ),
                          _modernDetailRow(
                            loc.propertyPostcode,
                            _value(item, "postcode"),
                            Icons.markunread_mailbox,
                          ),
                          _modernDetailRow(
                            loc.propertyCity,
                            _value(item, "prop_pekan_name"),
                            Icons.location_city,
                          ),
                          _modernDetailRow(
                            loc.state,
                            _value(item, "negeri"),
                            Icons.map,
                          ),
                          _modernDetailRow(
                            loc.mukim,
                            _value(item, "mukim"),
                            Icons.location_on,
                          ),
                          _modernDetailRow(
                            loc.lotNo,
                            _value(item, "no_lot"),
                            Icons.place,
                          ),
                          _modernDetailRow(
                            loc.titleNo,
                            _value(item, "no_hakmilik"),
                            Icons.article,
                          ),
                          _modernDetailRow(
                            loc.ownerAddress,
                            "${_value(item, "address1")} ${_value(item, "address2")} ${_value(item, "address3")}",
                            Icons.person_pin_circle,
                          ),
                          _modernDetailRow(
                            loc.telephone,
                            _value(item, "telephone"),
                            Icons.phone,
                          ),
                          _modernDetailRow(
                            loc.email,
                            _value(item, "email"),
                            Icons.email,
                          ),
                          _modernDetailRow(
                            loc.annualValue,
                            "RM ${_value(item, "nilai_tahunan")}",
                            Icons.payments,
                          ),
                          _modernDetailRow(
                            loc.rate,
                            "${_value(item, "kadar")}%",
                            Icons.percent,
                          ),
                          _modernDetailRow(
                            loc.annualTax,
                            "RM ${_money(item, "cukai_setahun")}",
                            Icons.calendar_today,
                          ),
                          _modernDetailRow(
                            loc.halfYearTax,
                            "RM ${_money(item, "cukai_sepenggal")}",
                            Icons.receipt_long,
                          ),
                          _modernDetailRow(
                            loc.currentTax,
                            "RM ${_money(item, "cukai_semasa")}",
                            Icons.payments,
                            bold: true,
                          ),
                          _modernDetailRow(
                            loc.taxArrears,
                            "RM ${_money(item, "tunggakan_cukai")}",
                            Icons.warning_amber,
                            bold: true,
                          ),
                          _modernDetailRow(
                            loc.noticeE,
                            "RM ${_value(item, "notis_e")}",
                            Icons.notifications,
                            bold: true,
                          ),
                          _modernDetailRow(
                            loc.waranLod,
                            _value(item, "waran_lod"),
                            Icons.gavel,
                          ),
                          _modernDetailRow(
                            loc.halfYearTotal,
                            "RM ${_money(item, "jumlah_sepenggal")}",
                            Icons.receipt,
                            bold: true,
                          ),
                          _modernDetailRow(
                            loc.annualTotal,
                            "RM ${_money(item, "jumlah_setahun")}",
                            Icons.calendar_month,
                      
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

  Widget _bigButton(
    String text,
    Color color,
    double fontSize,
    VoidCallback onTap, {
    required Color textColor,
  }) {
    return SizedBox(
      height: 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          side: const BorderSide(color: Colors.black, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}