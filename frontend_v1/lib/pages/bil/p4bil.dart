import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:frontend_v1/controllers/electric/electric_bill_controller.dart';
import 'package:frontend_v1/controllers/electric/electric_bill_exception.dart';
import 'package:frontend_v1/controllers/electric/electric_bill_service.dart';

import 'package:frontend_v1/controllers/water/water_bill_controller.dart';
import 'package:frontend_v1/controllers/water/water_bill_exception.dart';
import 'package:frontend_v1/controllers/water/water_bill_service.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/services/iimmpact_catalog_service.dart';
import 'package:frontend_v1/pages/bil/electric/p5_electric_bill_result.dart';
import 'package:frontend_v1/pages/bil/water/p5_water_bill_result.dart';

import 'package:frontend_v1/controllers/broadband/broadband_bill_controller.dart';
import 'package:frontend_v1/controllers/broadband/broadband_bill_exception.dart';
import 'package:frontend_v1/controllers/broadband/broadband_bill_service.dart';

import 'package:frontend_v1/pages/bil/broadband/p5_broadband_bill_result.dart';

import 'package:frontend_v1/controllers/entertainment/entertainment_bill_controller.dart';
import 'package:frontend_v1/controllers/entertainment/entertainment_bill_exception.dart';
import 'package:frontend_v1/controllers/entertainment/entertainment_bill_service.dart';
import 'package:frontend_v1/pages/bil/entertainment/p5_astro_bill_result.dart';


enum BillServiceType {
  electric,
  water,
  broadband,
  entertainment,
}

class P4BILPAGE extends StatefulWidget {
  final String title;
  final String hint;
  final String productCode;
  final String billerName;
  final BillServiceType serviceType;

  P4BILPAGE({
    super.key,
    required String title,
    required String hint,
    required String productCode,
    required String billerName,
    required this.serviceType,
  })  : title = title.toUpperCase(),
        hint = hint.toUpperCase(),
        productCode = productCode.toUpperCase(),
        billerName = billerName.toUpperCase();

  @override
  State<P4BILPAGE> createState() => _P4BILPAGEState();
}

class _P4BILPAGEState extends State<P4BILPAGE> {
  final TextEditingController _controller =
      TextEditingController();

  String? _activeKey;
  Offset? _activeKeyPosition;

  bool _isLoading = false;

  // =========================================================
  // THEME BY SERVICE TYPE
  // =========================================================

    bool get _isWater =>
        widget.serviceType == BillServiceType.water;

    bool get _isBroadband =>
        widget.serviceType == BillServiceType.broadband;

    Color get _primaryColor {
      switch (widget.serviceType) {
        case BillServiceType.electric:
          return const Color(0xFF1976D2);

        case BillServiceType.water:
          return const Color(0xFF00838F);

        case BillServiceType.broadband:
          return const Color(0xFF6A1B9A);

        case BillServiceType.entertainment:
          return const Color(0xFFD81B60);
      }
    }

    Color get _darkColor {
      switch (widget.serviceType) {
        case BillServiceType.electric:
          return const Color(0xFF0D47A1);

        case BillServiceType.water:
          return const Color(0xFF006064);

        case BillServiceType.broadband:
          return const Color(0xFF4A148C);

        case BillServiceType.entertainment:
          return const Color(0xFF880E4F);
      }
    }

    Color get _lightColor {
      switch (widget.serviceType) {
        case BillServiceType.electric:
          return const Color(0xFF42A5F5);

        case BillServiceType.water:
          return const Color(0xFF26C6DA);

        case BillServiceType.broadband:
          return const Color(0xFFAB47BC);

        case BillServiceType.entertainment:
          return const Color(0xFFF06292);
      }
    }

    IconData get _serviceIcon {
      switch (widget.serviceType) {
        case BillServiceType.electric:
          return Icons.electric_bolt_rounded;

        case BillServiceType.water:
          return Icons.water_drop_rounded;

        case BillServiceType.broadband:
          return Icons.router_rounded;

        case BillServiceType.entertainment:
          return Icons.live_tv_rounded;
      }
    }

  // =========================================================
  // ACCOUNT NUMBER LENGTH
  // =========================================================

  int get _maximumInputLength {
    switch (widget.productCode.toUpperCase()) {
      // ELECTRIC
      case 'TNB':
      case 'SESCO':
      case 'SESB':
      case 'NUR':
        return 20;

      // WATER
      case 'AKSB':
      case 'IW':
      case 'JBA':
      case 'KWB':
      case 'LAKU':
      case 'PAIP':
      case 'PWB':
      case 'SADA':
      case 'SAINS':
      case 'SAJ':
      case 'SAMB':
      case 'SAP':
      case 'SATU':
      case 'SWB':
      case 'SYABAS':
        return 30;

      // BROADBAND
      case 'TM':
      case 'UNB':
        return 30;

      // ENTERTAINMENT
      case 'ASB':
        return 20;

      default:
        return 30;
    }
  }

  // =========================================================
  // KEYBOARD FUNCTIONS
  // =========================================================

  void _addText(String value) {
    if (_isLoading) return;

    if (_controller.text.length >= _maximumInputLength) {
      return;
    }

    // if (widget.serviceType == BillServiceType.entertainment &&
    //     !RegExp(r'^[0-9]$').hasMatch(value)) {
    //   return;
    // }

    setState(() {
      _controller.text += value;
    });
  }

  void _backspace() {
    if (_isLoading) return;
    if (_controller.text.isEmpty) return;

    setState(() {
      _controller.text = _controller.text.substring(
        0,
        _controller.text.length - 1,
      );
    });
  }

  void _clearAll() {
    if (_isLoading) return;

    setState(() {
      _controller.clear();
    });
  }

  // =========================================================
  // ALERT DIALOG
  // =========================================================

  void _showAlert(
    String title,
    String message, {
    IconData icon = Icons.info_outline_rounded,
    Color? iconColor,
  }) {
    if (!mounted) return;

    final effectiveIconColor =
        iconColor ?? _primaryColor;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Alert',
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
                width: 850,
                constraints: const BoxConstraints(
                  minHeight: 520,
                  maxHeight: 1050,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 80,
                ),
                padding: const EdgeInsets.fromLTRB(
                  55,
                  45,
                  55,
                  45,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(
                    color:
                        effectiveIconColor.withOpacity(0.25),
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
                      width: 145,
                      height: 145,
                      decoration: BoxDecoration(
                        color: effectiveIconColor
                            .withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 90,
                        color: effectiveIconColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color.fromARGB(
                          255,
                          20,
                          45,
                          80,
                        ),
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 130,
                      height: 6,
                      decoration: BoxDecoration(
                        color: effectiveIconColor,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color.fromARGB(
                              255,
                              65,
                              72,
                              82,
                            ),
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 45),
                    SizedBox(
                      width: double.infinity,
                      height: 105,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        icon: const Icon(
                          Icons
                              .check_circle_outline_rounded,
                          size: 42,
                        ),
                        label: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              effectiveIconColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(22),
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
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.85,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // =========================================================
  // CONTINUE
  // =========================================================

  Future<void> _handleContinue() async {
    if (_isLoading) return;

    final loc = AppLocalizations.of(context)!;

    final accountNumber =
        _controller.text.trim().toUpperCase();

    if (accountNumber.isEmpty) {
      late final String message;

      switch (widget.serviceType) {
        case BillServiceType.electric:
          message = loc.electricAccountRequired;
          break;

        case BillServiceType.water:
          message = loc.waterAccountRequired;
          break;

        case BillServiceType.broadband:
          message = loc.broadbandAccountRequired;
          break;

        case BillServiceType.entertainment:
          message = loc.entertainmentAccountRequired;
          break;
      }

      _showAlert(
        loc.alertTitle,
        message,
        icon: _serviceIcon,
        iconColor: _primaryColor,
      );

      return;
    }

    if (widget.serviceType == BillServiceType.entertainment &&
        !RegExp(r'^[0-9]{8,20}$').hasMatch(accountNumber)) {
      _showAlert(
        loc.alertTitle,
        loc.entertainmentAccountInvalid,
        icon: _serviceIcon,
        iconColor: Colors.orange,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      switch (widget.serviceType) {
        case BillServiceType.electric:
          await _handleElectricInquiry(
            accountNumber: accountNumber,
            loc: loc,
          );
          break;

        case BillServiceType.water:
          await _handleWaterInquiry(
            accountNumber: accountNumber,
            loc: loc,
          );
          break;

        case BillServiceType.broadband:
          await _handleBroadbandInquiry(
            accountNumber: accountNumber,
            loc: loc,
          );
          break;

        case BillServiceType.entertainment:
          await _handleEntertainmentInquiry(
            accountNumber: accountNumber,
            loc: loc,
          );
          break;
      }
    } on WaterBillException catch (error) {
      if (!mounted) return;

      debugPrint(
        'WaterBillException: ${error.message}',
      );

      _showAlert(
        loc.alertTitle,
        error.message,
        icon: Icons.cloud_off_rounded,
        iconColor: Colors.red,
      );
    } on ElectricBillException catch (error) {
      if (!mounted) return;

      debugPrint(
        'ElectricBillException: ${error.message}',
      );

      _showAlert(
        loc.alertTitle,
        error.message,
        icon: Icons.cloud_off_rounded,
        iconColor: Colors.red,
      );
    } on BroadbandBillException catch (error) {
      if (!mounted) return;

      debugPrint(
        'BroadbandBillException: ${error.message}',
      );

      _showAlert(
        loc.alertTitle,
        error.message,
        icon: Icons.cloud_off_rounded,
        iconColor: Colors.red,
      );
    } on EntertainmentBillException catch (error) {
      if (!mounted) return;

      debugPrint(
        'EntertainmentBillException: ${error.message}',
      );

      _showAlert(
        loc.alertTitle,
        error.message,
        icon: Icons.cloud_off_rounded,
        iconColor: Colors.red,
      );
    } catch (error, stackTrace) {
      if (!mounted) return;

      debugPrint(
        'Unexpected bill inquiry error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showAlert(
        loc.alertTitle,
        loc.connectionFailed,
        icon: Icons.error_outline_rounded,
        iconColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleElectricInquiry({
    required String accountNumber,
    required AppLocalizations loc,
  }) async {
    final result =
        await ElectricBillService.inquiryBill(
      productCode: widget.productCode,
      billerName: widget.billerName,
      accountNumber: accountNumber,
      loc: loc,
    );

    if (!mounted) return;

    if (!result.success || result.bill == null) {
      _showAlert(
        loc.alertTitle,
        result.message.isNotEmpty
            ? result.message
            : loc.electricAccountNotFound,
        icon: Icons.search_off_rounded,
        iconColor: Colors.orange,
      );
      return;
    }

    final bill = result.bill!;

    ElectricBillController.setSelectedBill(bill);

    // Retrieve the latest pricing for this product from GET /v2/catalog.
    // If the catalog request fails, the bill page still opens safely
    // without applying a discount or price adjustment.
    CatalogPricing catalogPricing =
        const CatalogPricing.empty();

    try {
      final catalogJson =
          await IimmpactCatalogService.getCatalog();

      catalogPricing =
          CatalogPricing.fromCatalogResponse(
        catalogJson: catalogJson,
        productCode: widget.productCode,
      );

      debugPrint(
        'Catalog pricing loaded for ${widget.productCode}: '
        'discount=${catalogPricing.providerDiscount?.displayValue ?? '-'}, '
        'adjustment=${catalogPricing.priceAdjustment?.displayValue ?? '-'}',
      );
    } on IimmpactCatalogException catch (error) {
      debugPrint(
        'Catalog pricing unavailable for ${widget.productCode}: '
        '${error.message}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected catalog pricing error for '
        '${widget.productCode}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => P5ElectricBillResultPage(
          bill: bill,
          catalogPricing: catalogPricing,
        ),
      ),
    );
  }

  Future<void> _handleWaterInquiry({
    required String accountNumber,
    required AppLocalizations loc,
  }) async {
    final result =
        await WaterBillService.inquiryBill(
      productCode: widget.productCode,
      billerName: widget.billerName,
      accountNumber: accountNumber,
      loc: loc,
    );

    if (!mounted) return;

    if (!result.success || result.bill == null) {
      _showAlert(
        loc.alertTitle,
        result.message.isNotEmpty
            ? result.message
            : loc.waterAccountNotFound,
        icon: Icons.search_off_rounded,
        iconColor: Colors.orange,
      );
      return;
    }

    final bill = result.bill!;

    WaterBillController.setSelectedBill(bill);

    // Retrieve the latest water pricing from GET /v2/catalog.
    // If the catalog request fails, the result page still opens
    // without a provider discount or service adjustment.
    CatalogPricing catalogPricing =
        const CatalogPricing.empty();

    try {
      final catalogJson =
          await IimmpactCatalogService.getCatalog();

      catalogPricing =
          CatalogPricing.fromCatalogResponse(
        catalogJson: catalogJson,
        productCode: widget.productCode,
      );

      debugPrint(
        'Water catalog pricing loaded for ${widget.productCode}: '
        'discount=${catalogPricing.providerDiscount?.displayValue ?? '-'}, '
        'adjustment=${catalogPricing.priceAdjustment?.displayValue ?? '-'}',
      );
    } on IimmpactCatalogException catch (error) {
      debugPrint(
        'Water catalog pricing unavailable for ${widget.productCode}: '
        '${error.message}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected water catalog pricing error for '
        '${widget.productCode}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => P5WaterBillResultPage(
          bill: bill,
          catalogPricing: catalogPricing,
        ),
      ),
    );
  }

  Future<void> _handleBroadbandInquiry({
  required String accountNumber,
  required AppLocalizations loc,
}) async {
  final result =
      await BroadbandBillService.inquiryBill(
    productCode: widget.productCode,
    billerName: widget.billerName,
    accountNumber: accountNumber,
    loc: loc,
  );

  if (!mounted) return;

  if (!result.success || result.bill == null) {
    _showAlert(
      loc.alertTitle,
      result.message.isNotEmpty
          ? result.message
          : loc.broadbandAccountNotFound,
      icon: Icons.search_off_rounded,
      iconColor: Colors.orange,
    );

    return;
  }

  final bill = result.bill!;

  BroadbandBillController.setSelectedBill(
    bill,
  );

  CatalogPricing catalogPricing =
      const CatalogPricing.empty();

  try {
    final catalogJson =
        await IimmpactCatalogService.getCatalog();

    catalogPricing =
        CatalogPricing.fromCatalogResponse(
      catalogJson: catalogJson,
      productCode: widget.productCode,
    );

    debugPrint(
      'Broadband catalog pricing loaded for '
      '${widget.productCode}: '
      'discount='
      '${catalogPricing.providerDiscount?.displayValue ?? '-'}, '
      'adjustment='
      '${catalogPricing.priceAdjustment?.displayValue ?? '-'}',
    );
  } on IimmpactCatalogException catch (error) {
    debugPrint(
      'Broadband catalog pricing unavailable for '
      '${widget.productCode}: '
      '${error.message}',
    );
  } catch (error, stackTrace) {
    debugPrint(
      'Unexpected broadband catalog pricing error for '
      '${widget.productCode}: $error',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );
  }

  if (!mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          P5BroadbandBillResultPage(
        bill: bill,
        catalogPricing: catalogPricing,
      ),
    ),
  );
}


  Future<void> _handleEntertainmentInquiry({
    required String accountNumber,
    required AppLocalizations loc,
  }) async {
    final result =
        await EntertainmentBillService.inquiryBill(
      productCode: widget.productCode,
      billerName: widget.billerName,
      accountNumber: accountNumber,
      loc: loc,
    );

    if (!mounted) return;

    if (!result.success || result.bill == null) {
      _showAlert(
        loc.alertTitle,
        result.message.isNotEmpty
            ? result.message
            : loc.entertainmentAccountNotFound,
        icon: Icons.search_off_rounded,
        iconColor: Colors.orange,
      );
      return;
    }

    final bill = result.bill!;

    EntertainmentBillController.setSelectedBill(bill);

    CatalogPricing catalogPricing =
        const CatalogPricing.empty();

    try {
      final catalogJson =
          await IimmpactCatalogService.getCatalog();

      catalogPricing =
          CatalogPricing.fromCatalogResponse(
        catalogJson: catalogJson,
        productCode: widget.productCode,
      );

      debugPrint(
        'Entertainment catalog pricing loaded for '
        '${widget.productCode}: '
        'discount='
        '${catalogPricing.providerDiscount?.displayValue ?? '-'}, '
        'adjustment='
        '${catalogPricing.priceAdjustment?.displayValue ?? '-'}',
      );
    } on IimmpactCatalogException catch (error) {
      debugPrint(
        'Entertainment catalog pricing unavailable for '
        '${widget.productCode}: ${error.message}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected entertainment catalog pricing error for '
        '${widget.productCode}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => P5AstroResultPage(
          bill: bill,
          catalogPricing: catalogPricing,
        ),
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 80.0;
    const keySpacing = 15.0;
    const keyHeight = 135.0;
    const keyWidth = 135.0;

    final backspaceKey =
        AppLocalizations.of(context)!.keyboardBackspace;

    final clearAllKey =
        AppLocalizations.of(context)!.keyboardClearAll;

    final List<List<String>> keyboardRows = [
      ['A', 'B', 'C', 'D', 'E', 'F'],
      ['G', 'H', 'I', 'J', 'K', 'L'],
      ['M', 'N', 'O', 'P', 'Q', 'R'],
      ['S', 'T', 'U', 'V', 'W', 'X'],
      ['Y', 'Z', '-', backspaceKey, clearAllKey],
      ['0', '1', '2', '3', '4', '5'],
      ['6', '7', '8', '9'],
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('lib/images/pnew.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ===================================================
          // TITLE
          // ===================================================

          Positioned(
            top: 45,
            left: 90,
            right: 90,
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    _darkColor,
                    _primaryColor,
                    _lightColor,
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    left: 110,
                    right: 40,
                    child: Center(
                      child: AutoSizeText(
                        widget.billerName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        minFontSize: 18,
                        stepGranularity: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 28,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: Icon(
                        _serviceIcon,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===================================================
          // ACCOUNT NUMBER FIELD
          // ===================================================

          Positioned(
            top: 200,
            left: horizontalPadding,
            right: horizontalPadding,
            child: SizedBox(
              height: 130,
              child: TextField(
                controller: _controller,
                readOnly: true,
                showCursor: true,
                cursorColor: _primaryColor,
                cursorWidth: 4,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 30,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(40),
                    borderSide: BorderSide(
                      color: _primaryColor,
                      width: 3,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(40),
                    borderSide: BorderSide(
                      color: _darkColor,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ===================================================
          // KEYBOARD
          // ===================================================

          Positioned(
            top: 410,
            left: 20,
            right: 20,
            bottom: 380,
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: Opacity(
                opacity: _isLoading ? 0.5 : 1.0,
                child: SingleChildScrollView(
                  physics:
                      const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...keyboardRows.take(5).map((row) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: keySpacing,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: row.map((key) {
                              final bool isBackspace =
                                  key == backspaceKey;

                              final bool isClearAll =
                                  key == clearAllKey;

                              final bool isActionKey =
                                  isBackspace ||
                                      isClearAll;

                              double currentKeyWidth =
                                  keyWidth;

                              if (isBackspace) {
                                currentKeyWidth =
                                    keyWidth * 1.3;
                              }

                              if (isClearAll) {
                                currentKeyWidth =
                                    keyWidth * 1.8;
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.only(
                                  right: keySpacing,
                                ),
                                child: Builder(
                                  builder:
                                      (buttonContext) {
                                    return Listener(
                                      onPointerDown:
                                          (details) {
                                        if (_isLoading) {
                                          return;
                                        }

                                        final renderObject =
                                            buttonContext
                                                .findRenderObject();

                                        if (renderObject
                                            is! RenderBox) {
                                          return;
                                        }

                                        final position =
                                            renderObject
                                                .localToGlobal(
                                          Offset.zero,
                                        );

                                        setState(() {
                                          _activeKey = key;
                                          _activeKeyPosition =
                                              position;
                                        });
                                      },
                                      onPointerUp:
                                          (details) {
                                        if (_isLoading) {
                                          return;
                                        }

                                        setState(() {
                                          _activeKey =
                                              null;
                                        });

                                        if (isBackspace) {
                                          _backspace();
                                        } else if (isClearAll) {
                                          _clearAll();
                                        } else {
                                          _addText(key);
                                        }
                                      },
                                      onPointerCancel:
                                          (details) {
                                        if (_isLoading) {
                                          return;
                                        }

                                        setState(() {
                                          _activeKey =
                                              null;
                                        });
                                      },
                                      child:
                                          AnimatedContainer(
                                        duration:
                                            const Duration(
                                          milliseconds:
                                              80,
                                        ),
                                        width:
                                            currentKeyWidth,
                                        height: keyHeight,
                                        decoration:
                                            BoxDecoration(
                                          color: isActionKey
                                              ? _primaryColor
                                              : _activeKey ==
                                                      key
                                                  ? Colors
                                                      .grey[300]
                                                  : Colors
                                                      .white,
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            10,
                                          ),
                                          border:
                                              Border.all(
                                            color:
                                                Colors.black,
                                            width: 2,
                                          ),
                                          boxShadow:
                                              _activeKey ==
                                                      key
                                                  ? []
                                                  : const [
                                                      BoxShadow(
                                                        color:
                                                            Colors.black26,
                                                        offset:
                                                            Offset(0, 4),
                                                        blurRadius:
                                                            2,
                                                      ),
                                                    ],
                                        ),
                                        child: Center(
                                          child: isBackspace
                                              ? const Icon(
                                                  Icons
                                                      .backspace_outlined,
                                                  color:
                                                      Colors.white,
                                                  size: 45,
                                                )
                                              : isClearAll
                                                  ? Text(
                                                      clearAllKey,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          const TextStyle(
                                                        color:
                                                            Colors.white,
                                                        fontSize:
                                                            23,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : Text(
                                                      key,
                                                      style:
                                                          const TextStyle(
                                                        color:
                                                            Colors.black,
                                                        fontSize:
                                                            50,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),

                        const SizedBox(height: 35),

                        Container(
                          width: 850,
                          height: 2,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 35),

                     ...keyboardRows.skip(5).map((row) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: keySpacing,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: row.map((key) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(
                                  right: keySpacing,
                                ),
                                child: Builder(
                                  builder:
                                      (buttonContext) {
                                    return Listener(
                                      onPointerDown:
                                          (details) {
                                        if (_isLoading) {
                                          return;
                                        }

                                        final renderObject =
                                            buttonContext
                                                .findRenderObject();

                                        if (renderObject
                                            is! RenderBox) {
                                          return;
                                        }

                                        final position =
                                            renderObject
                                                .localToGlobal(
                                          Offset.zero,
                                        );

                                        setState(() {
                                          _activeKey = key;
                                          _activeKeyPosition =
                                              position;
                                        });
                                      },
                                      onPointerUp:
                                          (details) {
                                        if (_isLoading) {
                                          return;
                                        }

                                        setState(() {
                                          _activeKey =
                                              null;
                                        });

                                        _addText(key);
                                      },
                                      onPointerCancel:
                                          (details) {
                                        if (_isLoading) {
                                          return;
                                        }

                                        setState(() {
                                          _activeKey =
                                              null;
                                        });
                                      },
                                      child:
                                          AnimatedContainer(
                                        duration:
                                            const Duration(
                                          milliseconds:
                                              80,
                                        ),
                                        width: keyWidth,
                                        height: keyHeight,
                                        decoration:
                                            BoxDecoration(
                                          color: _activeKey ==
                                                  key
                                              ? Colors
                                                  .grey[300]
                                              : Colors
                                                  .white,
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            10,
                                          ),
                                          border:
                                              Border.all(
                                            color:
                                                Colors.black,
                                            width: 2,
                                          ),
                                          boxShadow:
                                              _activeKey ==
                                                      key
                                                  ? []
                                                  : const [
                                                      BoxShadow(
                                                        color:
                                                            Colors.black26,
                                                        offset:
                                                            Offset(0, 4),
                                                        blurRadius:
                                                            2,
                                                      ),
                                                    ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            key,
                                            style:
                                                const TextStyle(
                                              fontSize: 50,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===================================================
          // KEY PRESS PREVIEW
          // ===================================================

          if (_activeKey != null &&
              _activeKeyPosition != null &&
              !_isLoading)
            Positioned(
              left: _activeKeyPosition!.dx - 10,
              top: _activeKeyPosition!.dy - 130,
              child: IgnorePointer(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius:
                            BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.3),
                            blurRadius: 10,
                            offset:
                                const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _activeKey ==
                                backspaceKey
                            ? const Icon(
                                Icons
                                    .backspace_outlined,
                                color: Colors.white,
                                size: 50,
                              )
                            : Text(
                                _activeKey!,
                                textAlign:
                                    TextAlign.center,
                                style:
                                    const TextStyle(
                                  fontSize: 50,
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    CustomPaint(
                      size: const Size(30, 15),
                      painter:
                          DrawTriangle(_primaryColor),
                    ),
                  ],
                ),
              ),
            ),

          // ===================================================
          // BACK AND CONTINUE BUTTONS
          // ===================================================

          Positioned(
            bottom: 200,
            left: 100,
            right: 100,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 105,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 42,
                      ),
                      label: Text(
                        AppLocalizations.of(context)!
                            .buttonBack,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFE0E0E0),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                            Colors.grey[400],
                        disabledForegroundColor:
                            Colors.black54,
                        side: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                        shape:
                            RoundedRectangleBorder(
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
                      onPressed: _isLoading
                          ? null
                          : _handleContinue,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF16813B),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            Colors.green.shade300,
                        disabledForegroundColor:
                            Colors.white,
                        side: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 50,
                              height: 50,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 6,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .buttonContinue,
                                  style:
                                      const TextStyle(
                                    fontSize: 40,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 15),
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
          ),

            // ===================================================
            // LOADING OVERLAY
            // ===================================================

            if (_isLoading)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    color: Colors.black.withOpacity(0.72),
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.96, end: 1.0),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 760,
                          padding: const EdgeInsets.fromLTRB(
                            55,
                            55,
                            55,
                            50,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: _primaryColor.withOpacity(.20),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.35),
                                blurRadius: 45,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              // =====================================
                              // Animated Loader
                              // =====================================

                              Stack(
                                alignment: Alignment.center,
                                children: [

                                  Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _primaryColor.withOpacity(.08),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _primaryColor.withOpacity(.18),
                                          blurRadius: 30,
                                          spreadRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    width: 145,
                                    height: 145,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 9,
                                      strokeCap: StrokeCap.round,
                                      backgroundColor:
                                          _primaryColor.withOpacity(.15),
                                      color: _primaryColor,
                                    ),
                                  ),

                                  Container(
                                    width: 95,
                                    height: 95,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          _lightColor,
                                          _darkColor,
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      _serviceIcon,
                                      color: Colors.white,
                                      size: 54,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 38),

                              Text(
                                AppLocalizations.of(context)!
                                    .loadingTitle,
                                style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF123B70),
                                ),
                              ),

                              const SizedBox(height: 18),

                              Container(
                                width: 110,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _primaryColor,
                                  borderRadius:
                                      BorderRadius.circular(30),
                                ),
                              ),

                              const SizedBox(height: 28),

                              Text(
                                AppLocalizations.of(context)!
                                    .loadingMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5A6472),
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 35),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _primaryColor.withOpacity(.07),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [

                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2EBD59),
                                        shape: BoxShape.circle,
                                      ),
                                    ),

                                    const SizedBox(width: 15),

                                    Flexible(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .loadingStatusMessage,
                                        textAlign:
                                            TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight:
                                              FontWeight.w800,
                                          color: _darkColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 26),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [

                                  Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.grey.shade600,
                                    size: 28,
                                  ),

                                  const SizedBox(width: 10),

                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .loadingDoNotClose,
                                      textAlign:
                                          TextAlign.center,
                                      style: TextStyle(
                                        color:
                                            Colors.grey.shade700,
                                        fontWeight:
                                            FontWeight.w600,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

          // ===================================================
          // FOOTER
          // ===================================================

          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawTriangle extends CustomPainter {
  final Color color;

  DrawTriangle(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(
      path,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(
    covariant DrawTriangle oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}
