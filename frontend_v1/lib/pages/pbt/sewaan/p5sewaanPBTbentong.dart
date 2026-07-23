import 'package:flutter/material.dart';

import 'package:frontend_v1/controllers/sewaan/sewaan_service_bentong.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/sewaan/sewaan_payment_item.dart';
import 'package:frontend_v1/pages/payment/payment.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';

class P5SewaanPBTbentongScreen extends StatefulWidget {
  const P5SewaanPBTbentongScreen({
    super.key,
  });

  @override
  State<P5SewaanPBTbentongScreen> createState() =>
      _P5SewaanPBTbentongScreenState();
}

class _P5SewaanPBTbentongScreenState
    extends State<P5SewaanPBTbentongScreen> {
  final ScrollController _scrollController =
      ScrollController();

  Map<String, dynamic>? sewaan;

  bool selected = false;
  double total = 0.0;

  // =========================================================
  // INIT
  // =========================================================

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

  // =========================================================
  // VALUE HELPERS
  // =========================================================

  String _value(String key) {
    final value = sewaan?[key];

    if (value == null ||
        value.toString().trim().isEmpty) {
      return "-";
    }

    return value.toString();
  }

  String _money(String key) {
    final rawValue = sewaan?[key]
            ?.toString()
            .replaceAll(",", "") ??
        "0";

    final value =
        double.tryParse(rawValue) ?? 0.0;

    return value.toStringAsFixed(2);
  }

  double _amount(String key) {
    final rawValue = sewaan?[key]
            ?.toString()
            .replaceAll(",", "") ??
        "0";

    return double.tryParse(rawValue) ?? 0.0;
  }

  // =========================================================
  // SELECT RENTAL
  // =========================================================

  void _toggleSewaan(bool value) {
    setState(() {
      selected = value;
      total = selected ? _amount("jumlah") : 0.0;
    });
  }

  // =========================================================
  // PROCEED TO PAYMENT
  // ALL ORIGINAL PAYMENT DATA IS MAINTAINED
  // =========================================================

  void _proceed() {
    final loc = AppLocalizations.of(context)!;

    if (!selected) {
      _showAlert(
        loc.notice,
        loc.sewaanSelectAlert,
      );

      return;
    }

    if (total <= 0) {
      _showAlert(
        loc.notice,
        loc.sewaanNoArrearsAlert,
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(
          name: '/payment',
        ),
        builder: (_) => PAYMENTPAGE(
          biz: "SEWAAN",
          data: PaymentData(
            amount: total.toStringAsFixed(2),
            sewaanItems: [
              SewaanPaymentItem(
                accountNo: _value("account_no"),
                tenantName: _value("name"),
                registrationNo:
                    _value("rent_pdaftaran"),

                // Maintained from your original code.
                noPendaftaran:
                    _value("pdaftaran"),

                startDate: _value("start_date"),
                endDate: _value("end_date"),

                premiseAddress: [
                  _value("rent_alamatswn"),
                  _value("rent_jalanname"),
                  _value("rent_bandarnam"),
                ]
                    .where(
                      (value) =>
                          value != "-" &&
                          value.trim().isNotEmpty,
                    )
                    .join(" "),

                mailingAddress: [
                  _value("alamat1"),
                  _value("alamat2"),
                  _value("alamat3"),
                  _value("alamat4"),
                  _value("postcode"),
                  _value("pekan_name"),
                ]
                    .where(
                      (value) =>
                          value != "-" &&
                          value.trim().isNotEmpty,
                    )
                    .join(" "),

                outstandingRent:
                    _amount("tunggakan_sewa"),

                currentRent:
                    _amount("rental_fee"),

                amount: _amount("jumlah"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // MODERN ALERT
  // =========================================================

  void _showAlert(
    String title,
    String message,
  ) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Alert",
      barrierColor:
          Colors.black.withOpacity(0.65),
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
                padding:
                    const EdgeInsets.fromLTRB(
                  50,
                  45,
                  50,
                  45,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(36),
                  border: Border.all(
                    color:
                        const Color(0xFF1976D2)
                            .withOpacity(0.25),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.30),
                      blurRadius: 35,
                      offset:
                          const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Container(
                      width: 135,
                      height: 135,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF1976D2)
                                .withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons
                            .info_outline_rounded,
                        size: 82,
                        color:
                            Color(0xFF1976D2),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color:
                            Color(0xFF143B67),
                        fontSize: 48,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Container(
                      width: 115,
                      height: 6,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF1976D2),
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color:
                            Color(0xFF525E6D),
                        fontSize: 36,
                        fontWeight:
                            FontWeight.w600,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 38),

                    SizedBox(
                      width: double.infinity,
                      height: 95,
                      child:
                          ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                        icon: const Icon(
                          Icons
                              .check_circle_outline_rounded,
                          size: 40,
                        ),
                        label: const Text(
                          "OK",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton
                            .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF1976D2,
                          ),
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
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

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (sewaan == null) {
      return Scaffold(
        body: Container(
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
          child: Center(
            child: Container(
              width: 750,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 45,
                vertical: 55,
              ),
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(0.96),
                borderRadius:
                    BorderRadius.circular(35),
                border: Border.all(
                  color:
                      const Color(0xFFBBD9FF),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.16),
                    blurRadius: 30,
                    offset:
                        const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF0359D2)
                              .withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.store_outlined,
                      size: 75,
                      color: Color(0xFF0359D2),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    loc.sewaanNoData,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Color(0xFF163A65),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          // ===================================================
          // BACKGROUND
          // ===================================================

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration:
                const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "lib/images/pnew.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ===================================================
          // MAIN CONTENT
          // ===================================================

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                35,
                40,
                35,
                470,
              ),
              child: Column(
                children: [
                  // =============================================
                  // HEADER
                  // =============================================

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 38,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      gradient:
                          const LinearGradient(
                        begin:
                            Alignment.topLeft,
                        end: Alignment
                            .bottomRight,
                        colors: [
                          Color(0xFF0D47A1),
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        32,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(
                            0xFF0D47A1,
                          ).withOpacity(0.25),
                          blurRadius: 25,
                          offset:
                              const Offset(
                            0,
                            12,
                          ),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(
                              0.16,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              25,
                            ),
                            border: Border.all(
                              color: Colors.white
                                  .withOpacity(
                                0.25,
                              ),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.store_rounded,
                            color: Colors.white,
                            size: 58,
                          ),
                        ),

                        const SizedBox(
                          width: 28,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                loc.sewaanInfoTitle,
                                maxLines: 2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 48,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                  height: 1.05,
                                ),
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Text(
                                loc.sewaanSelectPayment,
                                maxLines: 2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(
                                    0.90,
                                  ),
                                  fontSize: 29,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 20,
                        ),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 25,
                            vertical: 18,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(
                              0.14,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                selected
                                    ? "1"
                                    : "0",
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 42,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),

                              Text(
                                loc.total,
                                style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(
                                    0.90,
                                  ),
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =============================================
                  // TABLE CARD
                  // =============================================

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.96),
                        borderRadius:
                            BorderRadius.circular(
                          28,
                        ),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                              0.10,
                            ),
                            blurRadius: 22,
                            offset:
                                const Offset(
                              0,
                              10,
                            ),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          26,
                        ),
                        child: Column(
                          children: [
                            _tableHeader(
                              rowTextSize,
                            ),

                            Expanded(
                              child: Scrollbar(
                                controller:
                                    _scrollController,
                                thumbVisibility:
                                    true,
                                trackVisibility:
                                    true,
                                thickness: 16,
                                radius:
                                    const Radius
                                        .circular(
                                  20,
                                ),
                                child: ListView(
                                  controller:
                                      _scrollController,
                                  padding:
                                      const EdgeInsets
                                          .fromLTRB(
                                    18,
                                    20,
                                    30,
                                    25,
                                  ),
                                  children: [
                                    _sewaanRow(
                                      rowTextSize,
                                    ),
                                  ],
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

          // ===================================================
          // BOTTOM SUMMARY PANEL
          // ===================================================

          Positioned(
            left: 35,
            right: 35,
            bottom: 80,
            child: Container(
              padding:
                  const EdgeInsets.fromLTRB(
                30,
                24,
                30,
                28,
              ),
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(
                  0.98,
                ),
                borderRadius:
                    BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.18),
                    blurRadius: 28,
                    offset:
                        const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // =============================================
                  // TOTAL
                  // =============================================

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    decoration:
                        BoxDecoration(
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xFFF1F8F4),
                          Color(0xFFE3F5E9),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        22,
                      ),
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
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(0xFF16813B),
                            shape:
                                BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons
                                .account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),

                        const SizedBox(
                          width: 20,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
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
                                selected ? 1 : 0,
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
                          textAlign:
                              TextAlign.right,
                          style:
                              const TextStyle(
                            color:
                                Color(0xFF16813B),
                            fontSize: 46,
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =============================================
                  // BACK AND CONTINUE
                  // =============================================

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 105,
                          child:
                              ElevatedButton.icon(
                            onPressed: () {
                              Navigator
                                  .pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      P4PAGE(
                                    title: loc
                                        .sewaanPbtTitle,
                                    type: "PBT",
                                    hint: loc
                                        .inputTaxHint,
                                    biz:
                                        "SEWAAN PBT",
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons
                                  .arrow_back_rounded,
                              size: 42,
                            ),
                            label: Text(
                              loc.back,
                              textAlign:
                                  TextAlign.center,
                              maxLines: 2,
                              style:
                                  const TextStyle(
                                fontSize: 38,
                                fontWeight:
                                    FontWeight.bold,
                                height: 1.05,
                              ),
                            ),
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                0xFFE0E0E0,
                              ),
                              foregroundColor:
                                  Colors.black,
                              elevation: 0,
                              side:
                                  const BorderSide(
                                color:
                                    Colors.black,
                                width: 2,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 50),

                      Expanded(
                        child: SizedBox(
                          height: 105,
                          child:
                              ElevatedButton(
                            onPressed: _proceed,
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                0xFF16813B,
                              ),
                              foregroundColor:
                                  Colors.white,
                              elevation: 0,
                              side:
                                  const BorderSide(
                                color:
                                    Colors.black,
                                width: 2,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  18,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Flexible(
                                  child: Text(
                                    loc.continueText,
                                    textAlign:
                                        TextAlign
                                            .center,
                                    maxLines: 2,
                                    style:
                                        const TextStyle(
                                      fontSize: 38,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      height: 1.05,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 15,
                                ),

                                const Icon(
                                  Icons
                                      .arrow_forward_rounded,
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
        ],
      ),
    );
  }

  // =========================================================
  // TABLE HEADER
  // SAME LAYOUT AS TAKSIRAN
  // =========================================================

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
                Icons
                    .check_circle_outline_rounded,
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

  // =========================================================
  // SEWAAN ROW
  // =========================================================

  Widget _sewaanRow(double fontSize) {
    final amount = _amount("jumlah");

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(22),
        onTap: () {
          _toggleSewaan(!selected);
        },
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints:
              const BoxConstraints(
            minHeight: 120,
          ),
          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE7F2FF)
                : Colors.white,
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1565C0)
                  : Colors.black,
              width: selected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.12,
                ),
                blurRadius: 10,
                offset:
                    const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // =======================================
              // SELECT
              // =======================================

              SizedBox(
                width: 90,
                child: Center(
                  child: AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),
                    width: 58,
                    height: 58,
                    decoration:
                        BoxDecoration(
                      color: selected
                          ? const Color(
                              0xFF1976D2,
                            )
                          : const Color(
                              0xFFF1F4F8,
                            ),
                      shape:
                          BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? const Color(
                                0xFF1976D2,
                              )
                            : const Color(
                                0xFFB8C4D1,
                              ),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      selected
                          ? Icons.check_rounded
                          : Icons
                              .circle_outlined,
                      color: selected
                          ? Colors.white
                          : const Color(
                              0xFF7A8A9A,
                            ),
                      size: 36,
                    ),
                  ),
                ),
              ),

              // =======================================
              // ACCOUNT
              // =======================================

              Expanded(
                flex: 24,
                child: _responsiveCell(
                  _value("account_no"),
                  fontSize,
                  bold: true,
                ),
              ),

              // =======================================
              // START DATE
              // =======================================

              Expanded(
                flex: 18,
                child: _responsiveCell(
                  _value("start_date"),
                  fontSize,
                ),
              ),

              // =======================================
              // END DATE
              // =======================================

              Expanded(
                flex: 18,
                child: _responsiveCell(
                  _value("end_date"),
                  fontSize,
                ),
              ),

              // =======================================
              // AMOUNT
              // =======================================

              Expanded(
                flex: 20,
                child: Center(
                  child: Container(
                    margin:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 4,
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration:
                        BoxDecoration(
                      color: selected
                          ? const Color(
                              0xFFE2F3E8,
                            )
                          : const Color(
                              0xFFF1F7F3,
                            ),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: FittedBox(
                      fit:
                          BoxFit.scaleDown,
                      child: Text(
                        "RM ${amount.toStringAsFixed(2)}",
                        textAlign:
                            TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize:
                              fontSize + 2,
                          fontWeight:
                              FontWeight.w900,
                          color:
                              const Color(
                            0xFF16813B,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // =======================================
              // INFO
              // =======================================

              Expanded(
                flex: 10,
                child: Center(
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(
                      50,
                    ),
                    onTap:
                        _showDetailPopup,
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(
                              0xFF1976D2,
                            ),
                            Color(
                              0xFF42A5F5,
                            ),
                          ],
                        ),
                        shape:
                            BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(
                              0xFF1976D2,
                            ).withOpacity(
                              0.25,
                            ),
                            blurRadius: 10,
                            offset:
                                const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons
                            .info_outline_rounded,
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

  // =========================================================
  // RESPONSIVE HEADER
  // =========================================================

  Widget _responsiveHeader(
    String text,
    double fontSize,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow:
              TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight:
                FontWeight.w800,
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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow:
              TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold
                ? FontWeight.w800
                : FontWeight.w600,
            color:
                const Color(0xFF2D3743),
            height: 1.15,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // DETAILS POPUP
  // ORIGINAL SEWAAN INFORMATION MAINTAINED
  // =========================================================

  void _showDetailPopup() {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor:
              Colors.transparent,
          child: Center(
            child: Container(
              width: 900,
              padding:
                  const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.25),
                    blurRadius: 25,
                    offset:
                        const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 20,
                      ),
                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(
                              0xFF0359D2,
                            ),
                            Color(
                              0xFF4A90E2,
                            ),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          const Icon(
                            Icons.store,
                            size: 40,
                            color:
                                Colors.white,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                              loc.sewaanDetailsTitle,
                              textAlign:
                                  TextAlign
                                      .center,
                              style:
                                  const TextStyle(
                                fontSize: 38,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                color:
                                    Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Container(
                      padding:
                          const EdgeInsets.all(
                        25,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF5F8FF,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Column(
                        children: [
                          _modernDetailRow(
                            loc.accountNo,
                            _value(
                              "account_no",
                            ),
                            Icons
                                .confirmation_number,
                          ),

                          _modernDetailRow(
                            loc.name,
                            _value("name"),
                            Icons.person,
                          ),

                          _modernDetailRow(
                            loc.icNo,
                            _value(
                              "rent_pdaftaran",
                            ),
                            Icons.badge,
                          ),

                          _modernDetailRow(
                            loc.startDate,
                            _value(
                              "start_date",
                            ),
                            Icons
                                .calendar_month,
                          ),

                          _modernDetailRow(
                            loc.endDate,
                            _value(
                              "end_date",
                            ),
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
                            [
                              _value(
                                "rent_alamatswn",
                              ),
                              _value(
                                "rent_jalanname",
                              ),
                            ]
                                .where(
                                  (value) =>
                                      value !=
                                          "-" &&
                                      value
                                          .trim()
                                          .isNotEmpty,
                                )
                                .join(" "),
                            Icons.store,
                          ),

                          _modernDetailRow(
                            loc.rentalCity,
                            _value(
                              "rent_bandarnam",
                            ),
                            Icons
                                .location_city,
                          ),

                          _modernDetailRow(
                            loc.address,
                            [
                              _value(
                                "alamat1",
                              ),
                              _value(
                                "alamat2",
                              ),
                              _value(
                                "alamat3",
                              ),
                              _value(
                                "alamat4",
                              ),
                            ]
                                .where(
                                  (value) =>
                                      value !=
                                          "-" &&
                                      value
                                          .trim()
                                          .isNotEmpty,
                                )
                                .join(" "),
                            Icons.home,
                          ),

                          _modernDetailRow(
                            loc.postcode,
                            _value(
                              "postcode",
                            ),
                            Icons
                                .markunread_mailbox,
                          ),

                          _modernDetailRow(
                            loc.town,
                            _value(
                              "pekan_name",
                            ),
                            Icons.location_on,
                          ),

                          _modernDetailRow(
                            loc.rentalArrears,
                            "RM ${_money("tunggakan_sewa")}",
                            Icons.warning_amber,
                            bold: true,
                          ),

                          _modernDetailRow(
                            loc.waterArrears,
                            "RM ${_money("tunggakan_caj_air")}",
                            Icons.water_drop,
                          ),

                          _modernDetailRow(
                            loc.electricArrears,
                            "RM ${_money("tunggakan_caj_elektrik")}",
                            Icons
                                .electrical_services,
                          ),

                          _modernDetailRow(
                            loc.managementArrears,
                            "RM ${_money("tunggakan_caj_pengurusan")}",
                            Icons
                                .manage_accounts,
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
                            Icons
                                .calendar_today,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: 250,
                      height: 70,
                      child:
                          ElevatedButton.icon(
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              Colors.redAccent,
                          foregroundColor:
                              Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons.close,
                          size: 30,
                        ),
                        label: Text(
                          loc.close,
                          style:
                              const TextStyle(
                            fontSize: 26,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
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
      padding:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color:
                  const Color(0xFF0359D2)
                      .withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color:
                  const Color(0xFF0359D2),
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
                fontWeight:
                    FontWeight.w600,
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