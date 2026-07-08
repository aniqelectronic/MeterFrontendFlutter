import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/sewaan/sewaan_service_bentong.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/p4.dart';
import 'package:frontend_v1/pages/payment.dart';
import 'package:frontend_v1/model/sewaan/sewaan_payment_item.dart';

class P5SewaanPBTbentongScreen extends StatefulWidget {
  const P5SewaanPBTbentongScreen({super.key});

  @override
  State<P5SewaanPBTbentongScreen> createState() =>
      _P5SewaanPBTbentongScreenState();
}

class _P5SewaanPBTbentongScreenState
    extends State<P5SewaanPBTbentongScreen> {
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? sewaan;
  bool selected = false;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    sewaan = SewaanService.sewaanData;
    total = 0.0;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _value(String key) {
    final value = sewaan?[key];
    if (value == null || value.toString().trim().isEmpty) return "-";
    return value.toString();
  }

  String _money(String key) {
  final value =
      double.tryParse(sewaan?[key]?.toString().replaceAll(",", "") ?? "0") ??
          0.0;

  return value.toStringAsFixed(2);
}

  double _amount(String key) {
    return double.tryParse(sewaan?[key]?.toString() ?? "0") ?? 0.0;
  }

  void _toggleSewaan(bool value) {
    setState(() {
      selected = value;
      total = selected ? _amount("jumlah") : 0.0;
    });
  }

  void _proceed() {
    final loc = AppLocalizations.of(context)!;

    if (!selected) {
      _showAlert(loc.notice, loc.sewaanSelectAlert);
      return;
    }

    if (total <= 0) {
      _showAlert(loc.notice, loc.sewaanNoArrearsAlert);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/payment'),
        builder: (_) => PAYMENTPAGE(
          biz: "SEWAAN",
          data: PaymentData(
            amount: total.toStringAsFixed(2),
            sewaanItems: [
            SewaanPaymentItem(
              accountNo: _value("account_no"),
              tenantName: _value("name"),
              registrationNo: _value("rent_pdaftaran"),

              // use the correct key from API if different
              noPendaftaran: _value("pdaftaran"),

              startDate: _value("start_date"),
              endDate: _value("end_date"),
              premiseAddress:
                  "${_value("rent_alamatswn")} ${_value("rent_jalanname")} ${_value("rent_bandarnam")}",
              mailingAddress:
                  "${_value("alamat1")} ${_value("alamat2")} ${_value("alamat3")} ${_value("alamat4")} ${_value("postcode")} ${_value("pekan_name")}",
              outstandingRent: _amount("tunggakan_sewa"),
              currentRent: _amount("rental_fee"),
              amount: _amount("jumlah"),
            ),
            ],
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

    if (sewaan == null) {
      return Scaffold(
        body: Center(
          child: Text(
            loc.sewaanNoData,
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
                    loc.sewaanInfoTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 3, 89, 210),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    loc.sewaanSelectPayment,
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
                      child: ListView(
                        controller: _scrollController,
                        children: [
                          _sewaanRow(rowTextSize),
                        ],
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
                                title: loc.sewaanPbtTitle,
                                type: "PBT",
                                hint: AppLocalizations.of(context)!
                                    .inputTaxHint,
                                biz: "SEWAAN PBT",
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

  Widget _sewaanRow(double fontSize) {
    final tunggakan = _amount("jumlah");

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
                  onChanged: (v) => _toggleSewaan(v!),
                ),
              ),
            ),
          ),

          _fixedCell(_value("account_no"), 240, fontSize),
          _fixedCell(_value("start_date"), 180, fontSize),
          _fixedCell(_value("end_date"), 180, fontSize),
          _fixedCell(
            "RM ${tunggakan.toStringAsFixed(2)}",
            220,
            fontSize + 2,
            bold: true,
          ),

          SizedBox(
            width: 100,
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: _showDetailPopup,
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

  void _showDetailPopup() {
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  )
                ],
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
                            Icons.store,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            loc.sewaanDetailsTitle,
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
                            _value("account_no"),
                            Icons.confirmation_number,
                          ),
                          _modernDetailRow(
                            loc.name,
                            _value("name"),
                            Icons.person,
                          ),
                          _modernDetailRow(
                            loc.icNo,
                            _value("rent_pdaftaran"),
                            Icons.badge,
                          ),
                          _modernDetailRow(
                            loc.startDate,
                            _value("start_date"),
                            Icons.calendar_month,
                          ),
                          _modernDetailRow(
                            loc.endDate,
                            _value("end_date"),
                            Icons.event,
                          ),
                          _modernDetailRow(
                            loc.rentalMonthly,
                            "RM ${_money("rental_fee")}",
                            Icons.payments,
                            bold: true,
                          ),
                          _modernDetailRow(
                            loc.rentalPlace,
                            "${_value("rent_alamatswn")} ${_value("rent_jalanname")}",
                            Icons.store,
                          ),
                          _modernDetailRow(
                            loc.rentalCity,
                            _value("rent_bandarnam"),
                            Icons.location_city,
                          ),
                          _modernDetailRow(
                            loc.address,
                            "${_value("alamat1")} ${_value("alamat2")} ${_value("alamat3")} ${_value("alamat4")}",
                            Icons.home,
                          ),
                          _modernDetailRow(
                            loc.postcode,
                            _value("postcode"),
                            Icons.markunread_mailbox,
                          ),
                          _modernDetailRow(
                            loc.town,
                            _value("pekan_name"),
                            Icons.location_on,
                          ),
                          _modernDetailRow(
                            loc.rentalArrears,
                            "RM ${_value("tunggakan_sewa")}",
                            Icons.warning_amber,
                            bold: true,
                          ),
                          _modernDetailRow(
                            loc.waterArrears,
                            "RM ${_value("tunggakan_caj_air")}",
                            Icons.water_drop,
                          ),
                          _modernDetailRow(
                            loc.electricArrears,
                            "RM ${_value("tunggakan_caj_elektrik")}",
                            Icons.electrical_services,
                          ),
                          _modernDetailRow(
                            loc.managementArrears,
                            "RM ${_value("tunggakan_caj_pengurusan")}",
                            Icons.manage_accounts,
                          ),
                          _modernDetailRow(
                            loc.total,
                            "RM ${_money("jumlah")}",
                            Icons.receipt_long,
                            bold: true,
                          ),
                          _modernDetailRow(
                            loc.annualTotal,
                            "RM ${_money("jumlah_setahun")}",
                            Icons.calendar_today,
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
            letterSpacing: 1.2,
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