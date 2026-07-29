import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/taksiran/taksiran_service_bentong.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';
import 'package:frontend_v1/pages/payment/payment.dart';
import 'package:frontend_v1/model/taksiran/taksiran_payment_item.dart';

enum TaksiranPaymentPeriod { sepenggal, setahun }

class P5TaksiranBentongScreen extends StatefulWidget {
  const P5TaksiranBentongScreen({super.key});

  @override
  State<P5TaksiranBentongScreen> createState() =>
      _P5TaksiranBentongScreenState();
}

class _P5TaksiranBentongScreenState extends State<P5TaksiranBentongScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _detailScrollController = ScrollController();

  List<Map<String, dynamic>> taksiranList = [];
  Set<String> selectedAccounts = {};
  double total = 0.0;
  TaksiranPaymentPeriod selectedPeriod = TaksiranPaymentPeriod.setahun;

  String get _selectedAmountKey =>
      selectedPeriod == TaksiranPaymentPeriod.sepenggal
          ? "jumlah_sepenggal"
          : "jumlah_setahun";

  @override
  void initState() {
    super.initState();
    taksiranList = TaksiranServiceBentong.taksiranList;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _detailScrollController.dispose();
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
        .fold(0.0, (sum, item) => sum + _amount(item, _selectedAmountKey));
  }

  void _changePaymentPeriod(TaksiranPaymentPeriod period) {
    if (selectedPeriod == period) return;

    setState(() {
      selectedPeriod = period;
      _updateTotal();
    });
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
          noPendaftaran: _value(item, "pdaftaran"),
          accountNo: _value(item, "account_no"),
          amount: _amount(item, _selectedAmountKey),
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
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Alert",
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration:
          const Duration(milliseconds: 250),
      pageBuilder: (
        dialogContext,
        animation,
        secondaryAnimation,
      ) {
        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 800,
                padding: const EdgeInsets.fromLTRB(
                  50,
                  45,
                  50,
                  45,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: const Color(0xFF1976D2)
                        .withOpacity(0.25),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.30),
                      blurRadius: 35,
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
                        Icons.info_outline_rounded,
                        size: 82,
                        color: Color(0xFF1976D2),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF143B67),
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Container(
                      width: 115,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF525E6D),
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 38),

                    SizedBox(
                      width: double.infinity,
                      height: 95,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 40,
                        ),
                        label: const Text(
                          "OK",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.88,
              end: 1,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

    @override
    Widget build(BuildContext context) {
      final loc = AppLocalizations.of(context)!;

      if (taksiranList.isEmpty) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                width: 750,
                padding: const EdgeInsets.symmetric(
                  horizontal: 45,
                  vertical: 55,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: const Color(0xFFBBD9FF),
                    width: 3,
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
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0359D2)
                            .withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 75,
                        color: Color(0xFF0359D2),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      loc.taksiranNoData,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF163A65),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

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
                  image: AssetImage("lib/images/pnew.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // =====================================================
            // MAIN PAGE
            // =====================================================

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  35,
                  40,
                  35,
                  470,
                ),
                child: Column(
                  children: [
                    // ===============================================
                    // MODERN HEADER
                    // ===============================================

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
                              Icons.home_work_rounded,
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
                                  loc.taksiranTitle,
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
                                  loc.taksiranSelectPayment,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                        Colors.white.withOpacity(0.90),
                                    fontSize: 29,
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
                              horizontal: 25,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "${selectedAccounts.length}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  loc.total,
                                  style: TextStyle(
                                    color:
                                        Colors.white.withOpacity(0.90),
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _paymentPeriodSelector(),

                    const SizedBox(height: 24),

                    // ===============================================
                    // TABLE CARD
                    // ===============================================

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
                              _tableHeader(rowTextSize),

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
                                    itemCount: taksiranList.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 14),
                                    itemBuilder: (_, index) {
                                      return _taksiranRow(
                                        taksiranList[index],
                                        rowTextSize,
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
            // BOTTOM SUMMARY PANEL
            // =====================================================

            Positioned(
              left: 35,
              right: 35,
              bottom: 120,
              child: Container(
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
                child: Column(
                  children: [
                    // =============================================
                    // TOTAL DISPLAY
                    // =============================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF1F8F4),
                            Color(0xFFE3F5E9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 62,
                            height: 62,
                            decoration: const BoxDecoration(
                              color: Color(0xFF16813B),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),

                          const SizedBox(width: 20),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.amountPayable,
                                  style: const TextStyle(
                                    color: Color(0xFF567064),
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                Text(
                                  loc.selectedAccountCount(
                                    selectedAccounts.length,
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF273E34),
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            "RM ${total.toStringAsFixed(2)}",
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Color(0xFF16813B),
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =============================================
                    // BACK AND CONTINUE BUTTONS
                    // =============================================

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 105,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => P4PAGE(
                                      title: loc.taksiranTitle,
                                      type: "PBT",
                                      hint: loc.inputTaxHint,
                                      biz: "CUKAI",
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 42,
                              ),
                              label: Text(
                                loc.back,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  height: 1.05,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFE0E0E0),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 50),

                        Expanded(
                          child: SizedBox(
                            height: 105,
                            child: ElevatedButton(
                              onPressed: _proceed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF16813B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      loc.continueText,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.bold,
                                        height: 1.05,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 42,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ============================================================
            // FOOTER
            // ============================================================
            Positioned(
              bottom: 45,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    Data.copyrightText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF26364A),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

  Widget _paymentPeriodSelector() {
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            loc.taksiranPaymentPeriodQuestion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF163A65),
              fontSize: 29,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _periodButton(
                  label: loc.taksiranHalfYearAmount,
                  icon: Icons.receipt_long_rounded,
                  selected:
                      selectedPeriod == TaksiranPaymentPeriod.sepenggal,
                  onTap: () => _changePaymentPeriod(
                    TaksiranPaymentPeriod.sepenggal,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _periodButton(
                  label: loc.taksiranAnnualAmount,
                  icon: Icons.calendar_month_rounded,
                  selected:
                      selectedPeriod == TaksiranPaymentPeriod.setahun,
                  onTap: () => _changePaymentPeriod(
                    TaksiranPaymentPeriod.setahun,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _periodButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 88,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF16813B) : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? const Color(0xFF16813B) : Colors.black,
          width: selected ? 3 : 2,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFF16813B).withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? Icons.check_circle_rounded : icon,
                  color: selected ? Colors.white : const Color(0xFF263238),
                  size: 34,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF263238),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _tableHeader(double fontSize) {
  final loc = AppLocalizations.of(context)!;

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
        const SizedBox(
          width: 90,
          child: Center(
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),

        Expanded(
          flex: 17,
          child: _responsiveHeader(
            loc.accountNo,
            fontSize,
          ),
        ),

        Expanded(
          flex: 10,
          child: _responsiveHeader(
            loc.startDate,
            fontSize,
          ),
        ),

        Expanded(
          flex: 15,
          child: _responsiveHeader(
            loc.endDate,
            fontSize,
          ),
        ),

        Expanded(
          flex: 10,
          child: _responsiveHeader(
            loc.total,
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

  Widget _taksiranRow(
    Map<String, dynamic> item,
    double fontSize,
  ) {
    final accountNo = _value(item, "account_no");
    final selected = selectedAccounts.contains(accountNo);
    final amount = _amount(item, _selectedAmountKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          _toggleTaksiran(
            accountNo,
            !selected,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(
            minHeight: 120,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE7F2FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1565C0)
                  : Colors.black,
              width: selected ? 3 : 2,
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
              // =========================================
              // SELECT
              // =========================================

              SizedBox(
                width: 90,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 180,
                    ),
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF1976D2)
                          : const Color(0xFFF1F4F8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF1976D2)
                            : const Color(0xFFB8C4D1),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      selected
                          ? Icons.check_rounded
                          : Icons.circle_outlined,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF7A8A9A),
                      size: 36,
                    ),
                  ),
                ),
              ),

              // =========================================
              // ACCOUNT NUMBER
              // =========================================

              Expanded(
                flex: 24,
                child: _responsiveCell(
                  accountNo,
                  fontSize,
                  bold: true,
                ),
              ),

              // =========================================
              // START DATE
              // =========================================

              Expanded(
                flex: 18,
                child: _responsiveCell(
                  _value(item, "start_date"),
                  fontSize,
                ),
              ),

              // =========================================
              // END DATE
              // =========================================

              Expanded(
                flex: 18,
                child: _responsiveCell(
                  _value(item, "end_date"),
                  fontSize,
                ),
              ),

              // =========================================
              // AMOUNT
              // =========================================

              Expanded(
                flex: 20,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE2F3E8)
                          : const Color(0xFFF1F7F3),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "RM ${amount.toStringAsFixed(2)}",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: fontSize + 2,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF16813B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // =========================================
              // INFO
              // =========================================

              Expanded(
                flex: 10,
                child: Center(
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(50),
                    onTap: () {
                      _showDetailPopup(item);
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF1976D2)
                                    .withOpacity(0.25),
                            blurRadius: 10,
                            offset:
                                const Offset(0, 5),
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
        ),
      ),
    );
  }

  Widget _responsiveCell(
  String text,
  double fontSize, {
  bool bold = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 5,
    ),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
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

  void _showDetailPopup(Map<String, dynamic> item) {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 45,
          ),
          child: Center(
            child: Container(
              width: 900,
              constraints: const BoxConstraints(
                maxHeight: 1080,
              ),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.home_work,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            loc.taksiranDetailsTitle,
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

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF90CAF9),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.swipe_up_alt_rounded,
                          color: Color(0xFF1976D2),
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.scrollForMoreInformation,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Expanded(
                    child: Scrollbar(
                      controller: _detailScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 16,
                      radius: const Radius.circular(20),
                      child: SingleChildScrollView(
                        controller: _detailScrollController,
                        padding: const EdgeInsets.only(right: 22),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F8FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              _modernDetailRow(
                                loc.accountNo,
                                _value(item, 'account_no'),
                                Icons.confirmation_number,
                              ),
                              _modernDetailRow(
                                loc.oldAccountNo,
                                _value(item, 'old_account_no'),
                                Icons.history,
                              ),
                              _modernDetailRow(
                                loc.invoiceNo,
                                _value(item, 'invoice_no'),
                                Icons.receipt,
                              ),
                              _modernDetailRow(
                                loc.name,
                                _value(item, 'name'),
                                Icons.person,
                              ),
                              _modernDetailRow(
                                loc.icNo,
                                _value(item, 'pdaftaran'),
                                Icons.badge,
                              ),
                              _modernDetailRow(
                                loc.startDate,
                                _value(item, 'start_date'),
                                Icons.calendar_month,
                              ),
                              _modernDetailRow(
                                loc.endDate,
                                _value(item, 'end_date'),
                                Icons.event,
                              ),
                              _modernDetailRow(
                                loc.propertyAddress,
                                _joinValues(item, [
                                  'no_rumah',
                                  'lorong_name',
                                  'jalan_name',
                                ]),
                                Icons.home,
                              ),
                              _modernDetailRow(
                                loc.propertyPostcode,
                                _value(item, 'postcode'),
                                Icons.markunread_mailbox,
                              ),
                              _modernDetailRow(
                                loc.propertyCity,
                                _value(item, 'prop_pekan_name'),
                                Icons.location_city,
                              ),
                              _modernDetailRow(
                                loc.state,
                                _value(item, 'negeri'),
                                Icons.map,
                              ),
                              _modernDetailRow(
                                loc.mukim,
                                _value(item, 'mukim'),
                                Icons.location_on,
                              ),
                              _modernDetailRow(
                                loc.lotNo,
                                _value(item, 'no_lot'),
                                Icons.place,
                              ),
                              _modernDetailRow(
                                loc.titleNo,
                                _value(item, 'no_hakmilik'),
                                Icons.article,
                              ),
                              _modernDetailRow(
                                loc.ownerAddress,
                                _joinValues(item, [
                                  'address1',
                                  'address2',
                                  'address3',
                                ]),
                                Icons.person_pin_circle,
                              ),
                              _modernDetailRow(
                                loc.telephone,
                                _value(item, 'telephone'),
                                Icons.phone,
                              ),
                              _modernDetailRow(
                                loc.email,
                                _value(item, 'email'),
                                Icons.email,
                              ),
                              _modernDetailRow(
                                loc.annualValue,
                                _moneyDisplay(item, 'nilai_tahunan'),
                                Icons.payments,
                              ),
                              _modernDetailRow(
                                loc.rate,
                                _percentDisplay(item, 'kadar'),
                                Icons.percent,
                              ),
                              _modernDetailRow(
                                loc.annualTax,
                                _moneyDisplay(item, 'cukai_setahun'),
                                Icons.calendar_today,
                              ),
                              _modernDetailRow(
                                loc.halfYearTax,
                                _moneyDisplay(item, 'cukai_sepenggal'),
                                Icons.receipt_long,
                              ),
                              _modernDetailRow(
                                loc.currentTax,
                                _moneyDisplay(item, 'cukai_semasa'),
                                Icons.payments,
                              ),
                              _modernDetailRow(
                                loc.taxArrears,
                                _moneyDisplay(item, 'tunggakan_cukai'),
                                Icons.warning_amber,
                              ),
                              _modernDetailRow(
                                loc.noticeE,
                                _moneyDisplay(item, 'notis_e'),
                                Icons.notifications,
                              ),
                              _modernDetailRow(
                                loc.waranLod,
                                _value(item, 'waran_lod'),
                                Icons.gavel,
                              ),
                              _modernDetailRow(
                                loc.halfYearTotal,
                                _moneyDisplay(item, 'jumlah_sepenggal'),
                                Icons.receipt,
                                bold: selectedPeriod ==
                                    TaksiranPaymentPeriod.sepenggal,
                              ),
                              _modernDetailRow(
                                loc.annualTotal,
                                _moneyDisplay(item, 'jumlah_setahun'),
                                Icons.calendar_month,
                                bold: selectedPeriod ==
                                    TaksiranPaymentPeriod.setahun,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: 250,
                    height: 65,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
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
        );
      },
    );
  }

  Widget _responsiveHeader(
  String text,
  double fontSize,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 5,
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

  Widget _fixedHeader(
    String text,
    double width,
    double size,
  ) {
    return SizedBox(
      width: width,
      child: Padding(
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
              fontSize: size,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
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
      child: Padding(
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
              fontSize: size,
              fontWeight:
                  bold ? FontWeight.w800 : FontWeight.w600,
              color: const Color(0xFF2D3743),
              height: 1.15,
            ),
          ),
        ),
      ),
    );
  }

  bool _isMissingValue(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized.isEmpty ||
        normalized == '-' ||
        normalized == 'null' ||
        normalized == 'n/a' ||
        normalized == 'none') {
      return true;
    }

    final cleaned = normalized
        .replaceAll('rm', '')
        .replaceAll('%', '')
        .replaceAll('-', '')
        .trim();

    return cleaned.isEmpty || cleaned == 'null';
  }

  String _joinValues(
    Map<String, dynamic> item,
    List<String> keys,
  ) {
    final parts = keys
        .map((key) => _value(item, key).trim())
        .where((value) => !_isMissingValue(value))
        .toList();

    return parts.isEmpty ? '-' : parts.join(' ');
  }

  String _moneyDisplay(Map<String, dynamic> item, String key) {
    final raw = item[key]?.toString().trim() ?? '';
    if (_isMissingValue(raw)) return '-';

    final parsed = double.tryParse(raw.replaceAll(',', ''));
    if (parsed == null) return '-';

    return 'RM ${parsed.toStringAsFixed(2)}';
  }

  String _percentDisplay(Map<String, dynamic> item, String key) {
    final raw = item[key]?.toString().trim() ?? '';
    if (_isMissingValue(raw)) return '-';

    return '$raw%';
  }

  Widget _modernDetailRow(
    String label,
    String value,
    IconData icon, {
    bool bold = false,
  }) {
    if (_isMissingValue(value)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF0359D2).withOpacity(0.1),
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
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.normal,
                color: bold
                    ? const Color(0xFF16813B)
                    : Colors.black87,
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