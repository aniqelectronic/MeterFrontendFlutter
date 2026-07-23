import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/taksiran/semakan_cukai_taksiran_bentong_service.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

class P5SemakanCukaiTaksiranBentongScreen extends StatefulWidget {
  const P5SemakanCukaiTaksiranBentongScreen({
    super.key,
  });

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

    paymentList =
        SemakanCukaiTaksiranBentongService.paymentList;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _value(
    Map<String, dynamic> item,
    String key,
  ) {
    final value = item[key];

    if (value == null ||
        value.toString().trim().isEmpty) {
      return "-";
    }

    return value.toString();
  }

  String _money(
    Map<String, dynamic> item,
    String key,
  ) {
    final raw =
        item[key]?.toString().replaceAll(",", "") ??
            "0";

    final value = double.tryParse(raw) ?? 0.0;

    return value.toStringAsFixed(2);
  }

  String _date(String raw) {
    if (raw == "-" || raw.trim().isEmpty) {
      return "-";
    }

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

  void _goBack(
    AppLocalizations loc,
  ) {
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
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (paymentList.isEmpty) {
      return Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "lib/images/pnew.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  35,
                  40,
                  35,
                  250,
                ),
                child: Center(
                  child: Container(
                    width: 760,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 60,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.97),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.16),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 135,
                          height: 135,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2)
                                .withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 78,
                            color: Color(0xFF1976D2),
                          ),
                        ),

                        const SizedBox(height: 30),

                        Text(
                          loc.noPaymentRecordsFound,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF163A65),
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 35,
              right: 35,
              bottom: 70,
              child: _bottomBackPanel(loc),
            ),
          ],
        ),
      );
    }

    final screenWidth =
        MediaQuery.of(context).size.width;

    final rowTextSize =
        screenWidth >= 900 ? 25.0 : 14.0;

    return Scaffold(
      body: Stack(
        children: [
          // =====================================================
          // BACKGROUND
          // =====================================================

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "lib/images/pnew.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // =====================================================
          // MAIN PAGE
          // Extra bottom padding prevents the table from going
          // behind the back button.
          // =====================================================

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                35,
                40,
                35,
                275,
              ),
              child: Column(
                children: [
                  // =================================================
                  // MODERN HEADER
                  // =================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 38,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0D47A1),
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D47A1)
                              .withOpacity(0.25),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            color: Colors.white,
                            size: 58,
                          ),
                        ),

                        const SizedBox(width: 28),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.semakancukaititle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                loc.assessmentTaxPaymentTransactionList,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      Colors.white.withOpacity(0.90),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "${paymentList.length}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              Text(
                                loc.transactionNo,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: TextStyle(
                                  color:
                                      Colors.white.withOpacity(0.90),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =================================================
                  // TABLE CARD
                  // =================================================

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.96),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Column(
                          children: [
                            _tableHeader(
                              rowTextSize,
                              loc,
                            ),

                            Expanded(
                              child: Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                thickness: 16,
                                radius: const Radius.circular(20),
                                child: ListView.separated(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    20,
                                    30,
                                    25,
                                  ),
                                  itemCount: paymentList.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (_, index) {
                                    return _paymentRow(
                                      paymentList[index],
                                      rowTextSize,
                                      loc,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =====================================================
          // BOTTOM BACK PANEL
          // =====================================================

          Positioned(
            left: 35,
            right: 35,
            bottom: 70,
            child: _bottomBackPanel(loc),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM BACK PANEL
  // =========================================================

  Widget _bottomBackPanel(
    AppLocalizations loc,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        30,
        24,
        30,
        28,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: SizedBox(
        height: 105,
        child: KioskBackButton(
          onPressed: () {
            _goBack(loc);
          },
        ),
      ),
    );
  }

  // =========================================================
  // TABLE HEADER
  // Uses responsive Expanded columns instead of fixed widths.
  // =========================================================

  Widget _tableHeader(
    double fontSize,
    AppLocalizations loc,
  ) {
    return Container(
      height: 105,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 23,
            child: _responsiveHeader(
              loc.account,
              fontSize,
            ),
          ),

          Expanded(
            flex: 28,
            child: _responsiveHeader(
              loc.transactionNo,
              fontSize,
            ),
          ),

          Expanded(
            flex: 22,
            child: _responsiveHeader(
              loc.amount,
              fontSize,
            ),
          ),

          Expanded(
            flex: 10,
            child: _responsiveHeader(
              loc.info,
              fontSize,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TRANSACTION ROW
  // =========================================================

  Widget _paymentRow(
    Map<String, dynamic> item,
    double fontSize,
    AppLocalizations loc,
  ) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 120,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 23,
            child: _responsiveCell(
              _value(
                item,
                "account_number",
              ),
              fontSize,
              bold: true,
            ),
          ),

          Expanded(
            flex: 28,
            child: _responsiveCell(
              _value(
                item,
                "bank_trx_no",
              ),
              fontSize,
            ),
          ),

          Expanded(
            flex: 22,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F7F3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "RM ${_money(item, "amount")}",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: const Color(0xFF16813B),
                      fontSize: fontSize + 2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            flex: 10,
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  _showDetailPopup(
                    item,
                    loc,
                  );
                },
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1976D2),
                        Color(0xFF42A5F5),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1976D2)
                            .withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 31,
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

  // =========================================================
  // RESPONSIVE HEADER
  // =========================================================

  Widget _responsiveHeader(
    String text,
    double fontSize,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // RESPONSIVE CELL
  // =========================================================

  Widget _responsiveCell(
    String text,
    double fontSize, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold
                ? FontWeight.w800
                : FontWeight.w600,
            color: const Color(0xFF2D3743),
            height: 1.15,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // DETAILS POPUP
  // =========================================================

  void _showDetailPopup(
    Map<String, dynamic> item,
    AppLocalizations loc,
  ) {
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
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0359D2),
                            Color(0xFF4A90E2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            size: 40,
                            color: Colors.white,
                          ),

                          const SizedBox(width: 10),

                          Flexible(
                            child: Text(
                              loc.transactionInformation,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
                            _date(
                              _value(
                                item,
                                "paid_date",
                              ),
                            ),
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
                      height: 70,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.close,
                          size: 30,
                        ),
                        label: Text(
                          loc.close,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
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

  // =========================================================
  // DETAIL ROW
  // =========================================================

  Widget _modernDetailRow(
    String label,
    String value,
    IconData icon, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF0359D2)
                  .withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0359D2),
              size: 24,
            ),
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
                fontWeight: bold
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: bold
                    ? Colors.redAccent
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}