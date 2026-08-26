import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/bil/ewallet/pewallet5.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

// ============================================================================
// E-WALLET PAGE 4
// ============================================================================
//
// TNG:
// Provider
//   -> PAGE 4 choose PIN value
//   -> PAGE 5 enter phone/reference
//   -> Payment
//
// TNGD / TRUE:
// Provider
//   -> PAGE 4 enter phone number
//   -> CONFIRM PHONE NUMBER
//   -> PAGE 5 enter reload amount
//   -> Payment
//
// ============================================================================

class PEWALLET4PAGE extends StatefulWidget {
  final String productCode;
  final String providerName;
  final String providerImageUrl;

  const PEWALLET4PAGE({
    super.key,
    required this.productCode,
    required this.providerName,
    required this.providerImageUrl,
  });

  @override
  State<PEWALLET4PAGE> createState() =>
      _PEWALLET4PAGEState();
}

class _PEWALLET4PAGEState
    extends State<PEWALLET4PAGE> {
  // ==========================================================================
  // STATE
  // ==========================================================================

  bool _isLoading = true;

  String? _errorMessage;

  Map<String, dynamic>? _product;

  CatalogPricing _catalogPricing =
      CatalogPricing.empty();

  List<double> _denominations = [];

  double? _selectedAmount;

  final TextEditingController _phoneController =
      TextEditingController();

  String? _activeKey;

  bool _isNavigating = false;

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFFEF6C35);

  static const Color _darkColor =
      Color(0xFFD35400);

  static const Color _lightColor =
      Color(0xFFFFA264);

  static const Color _greenColor =
      Color(0xFF16813B);

  static const Color _redColor =
      Color(0xFFD93A3A);

  // ==========================================================================
  // PRODUCT TYPE
  // ==========================================================================

  String get _code =>
      widget.productCode
          .trim()
          .toUpperCase();

  bool get _isTngPin =>
      _code == 'TNG';

  bool get _isPinless =>
      _code == 'TNGD' ||
      _code == 'TRUE';

  // ==========================================================================
  // PRODUCT VALUES
  // ==========================================================================

  String get _productName {
    final String value =
        _product?['name']
                ?.toString()
                .trim() ??
            '';

    if (value.isNotEmpty) {
      return value;
    }

    return widget.providerName;
  }

  String get _imageUrl {
    final String value =
        _product?['image_url']
                ?.toString()
                .trim() ??
            '';

    if (value.isNotEmpty) {
      return value;
    }

    return widget.providerImageUrl;
  }

  String get _catalogNote {
    return _product?['note']
            ?.toString()
            .trim() ??
        '';
  }

  bool get _isProductActive =>
      _product?['is_active'] ==
      true;

  // ==========================================================================
  // TNG PIN PRICING
  // ==========================================================================

  double get _pinAmount =>
      _selectedAmount ?? 0.0;

  PriceAdjustmentResult get _pinAdjustment {
    final adjustment =
        _catalogPricing.priceAdjustment;

    if (adjustment == null) {
      return PriceAdjustmentResult.none(
        _pinAmount,
      );
    }

    return adjustment.apply(
      _pinAmount,
    );
  }

  double get _adjustmentAmount =>
      _pinAdjustment.adjustmentAmount;

  double get _totalAmount =>
      _pinAdjustment.amountAfter;

  bool get _hasAdjustment =>
      _adjustmentAmount.abs() >= 0.005;

  // ==========================================================================
  // PHONE
  // ==========================================================================

  String get _phoneNumber =>
      _phoneController.text.trim();

  int get _maximumPhoneLength =>
      11;

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _loadProduct();
  }

  @override
  void dispose() {
    _phoneController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // LOAD PRODUCT
  // ==========================================================================

  Future<void> _loadProduct() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final Map<String, dynamic> catalog =
          await IimmpactCatalogService
              .getCatalog();

      final dynamic productsRaw =
          catalog['products'];

      if (productsRaw is! Map) {
        throw Exception(
          'Catalog products object is missing.',
        );
      }

      final Map<String, dynamic> products =
          Map<String, dynamic>.from(
        productsRaw,
      );

      final dynamic rawProduct =
          products[_code];

      if (rawProduct is! Map) {
        throw Exception(
          'E-Wallet product $_code was not found.',
        );
      }

      final Map<String, dynamic> product =
          Map<String, dynamic>.from(
        rawProduct,
      );

      final CatalogPricing pricing =
          CatalogPricing
              .fromCatalogResponse(
        catalogJson: catalog,
        productCode: _code,
      );

      List<double> denominations = [];

      if (_isTngPin) {
        denominations =
            _parseDenominations(
          product['denomination']
                  ?.toString() ??
              '',
        );

        if (denominations.isEmpty) {
          throw Exception(
            'No TNG PIN denominations are available.',
          );
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;

        _catalogPricing = pricing;

        _denominations = denominations;

        if (_isTngPin &&
            denominations.isNotEmpty) {
          _selectedAmount =
              denominations.first;
        }

        _isLoading = false;
      });

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'E-WALLET PAGE 4 PRODUCT LOADED',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Product Code      : $_code',
      );
      debugPrint(
        'Product           : $_productName',
      );
      debugPrint(
        'TNG PIN           : $_isTngPin',
      );
      debugPrint(
        'Pinless           : $_isPinless',
      );
      debugPrint(
        'Denominations     : $_denominations',
      );
      debugPrint(
        'Provider Discount : '
        '${_catalogPricing.providerDiscount?.displayValue ?? '-'} '
        '(INTERNAL)',
      );
      debugPrint(
        'Price Adjustment  : '
        '${_catalogPricing.priceAdjustment?.displayValue ?? '-'}',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');
    } on IimmpactCatalogException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            error.message;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'E-Wallet catalog error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            error.toString();
      });
    }
  }

  // ==========================================================================
  // PARSE DENOMINATIONS
  // ==========================================================================

  List<double> _parseDenominations(
    String rawValue,
  ) {
    final String normalized =
        rawValue.trim();

    if (normalized.isEmpty) {
      return [];
    }

    final List<double> values =
        normalized
            .split(',')
            .map(
              (value) =>
                  double.tryParse(
                value.trim(),
              ),
            )
            .whereType<double>()
            .where(
              (value) =>
                  value > 0,
            )
            .toSet()
            .toList();

    values.sort();

    return values;
  }

  // ==========================================================================
  // MONEY
  // ==========================================================================

  String _formatMoney(
    double amount,
  ) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  String _formatButtonAmount(
    double amount,
  ) {
    if (amount ==
        amount.roundToDouble()) {
      return 'RM ${amount.toStringAsFixed(0)}';
    }

    return _formatMoney(
      amount,
    );
  }

  String _formatSignedMoney(
    double amount,
  ) {
    final sign =
        amount >= 0
            ? '+'
            : '-';

    return '$sign RM '
        '${amount.abs().toStringAsFixed(2)}';
  }

  // ==========================================================================
  // PHONE KEYPAD
  // ==========================================================================

  void _addNumber(
    String value,
  ) {
    if (_isNavigating) {
      return;
    }

    if (_phoneController.text.length >=
        _maximumPhoneLength) {
      return;
    }

    setState(() {
      _phoneController.text += value;
    });
  }

  void _backspace() {
    if (_isNavigating ||
        _phoneController.text.isEmpty) {
      return;
    }

    setState(() {
      _phoneController.text =
          _phoneController.text.substring(
        0,
        _phoneController.text.length -
            1,
      );
    });
  }

  void _clearAll() {
    if (_isNavigating) {
      return;
    }

    setState(() {
      _phoneController.clear();
    });
  }

  bool _isValidPhone(
    String number,
  ) {
    if (!RegExp(r'^[0-9]+$')
        .hasMatch(number)) {
      return false;
    }

    if (!number.startsWith('01')) {
      return false;
    }

    if (number.length < 9 ||
        number.length > 11) {
      return false;
    }

    return true;
  }

  // ==========================================================================
  // PINLESS PHONE CONFIRMATION
  // ==========================================================================

  Future<bool> _showPhoneConfirmation(
    String phoneNumber,
  ) async {
    final loc =
        AppLocalizations.of(context)!;

    final bool? confirmed =
        await showGeneralDialog<bool>(
      context: context,

      barrierDismissible: false,

      barrierLabel:
          loc.eWalletConfirmNumberTitle,

      barrierColor:
          Colors.black.withOpacity(
        0.68,
      ),

      transitionDuration:
          const Duration(
        milliseconds: 230,
      ),

      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curved =
            CurvedAnimation(
          parent: animation,
          curve:
              Curves.easeOutBack,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale:
                Tween<double>(
              begin: 0.86,
              end: 1,
            ).animate(
              curved,
            ),
            child: child,
          ),
        );
      },

      pageBuilder: (
        dialogContext,
        animation,
        secondaryAnimation,
      ) {
        return SafeArea(
          child: Center(
            child: Material(
              color:
                  Colors.transparent,
              child: Container(
                width: 790,

                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 60,
                ),

                padding:
                    const EdgeInsets.fromLTRB(
                  42,
                  40,
                  42,
                  38,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    38,
                  ),

                  border:
                      Border.all(
                    color:
                        _primaryColor
                            .withOpacity(
                      0.40,
                    ),
                    width: 3,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black
                              .withOpacity(
                        0.32,
                      ),
                      blurRadius: 45,
                      offset:
                          const Offset(
                        0,
                        20,
                      ),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    // ========================================================
                    // ICON
                    // ========================================================

                    Container(
                      width: 110,
                      height: 110,
                      decoration:
                          BoxDecoration(
                        color:
                            _primaryColor
                                .withOpacity(
                          0.12,
                        ),
                        shape:
                            BoxShape.circle,
                      ),
                      child:
                          const Icon(
                        Icons
                            .phone_android_rounded,
                        color:
                            _primaryColor,
                        size: 62,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // ========================================================
                    // TITLE
                    // ========================================================

                    Text(
                      loc.eWalletConfirmNumberTitle
                          .toUpperCase(),

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF17283E,
                        ),
                        fontSize: 37,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // ========================================================
                    // PHONE NUMBER
                    // ========================================================

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 24,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF7FAFD,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),

                        border:
                            Border.all(
                          color:
                              _primaryColor,
                          width: 3,
                        ),
                      ),

                      child: Text(
                        phoneNumber,

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF17283E,
                          ),

                          fontSize: 52,

                          fontWeight:
                              FontWeight
                                  .w900,

                          letterSpacing: 2.5,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ========================================================
                    // QUESTION
                    // ========================================================

                    Text(
                      loc.eWalletConfirmNumberQuestion,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF475B72,
                        ),

                        fontSize: 31,

                        fontWeight:
                            FontWeight
                                .w800,

                        height: 1.3,
                      ),
                    ),

                    const SizedBox(
                      height: 34,
                    ),

                    // ========================================================
                    // BUTTONS
                    // ========================================================

                    Row(
                      children: [
                        // ====================================================
                        // BACK / EDIT
                        // ====================================================

                        Expanded(
                          child: SizedBox(
                            height: 90,

                            child:
                                ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                  false,
                                );
                              },

                              icon:
                                  const Icon(
                                Icons
                                    .arrow_back_rounded,
                                size: 34,
                              ),

                              label: Text(
                                loc.eWalletConfirmBack
                                    .toUpperCase(),

                                maxLines: 1,

                                style:
                                    const TextStyle(
                                  fontSize: 28,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),

                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    _redColor,

                                foregroundColor:
                                    Colors.white,

                                elevation: 3,

                                shadowColor:
                                    _redColor
                                        .withOpacity(
                                  0.25,
                                ),

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 20,
                        ),

                        // ====================================================
                        // CONTINUE
                        // ====================================================

                        Expanded(
                          flex: 2,

                          child: SizedBox(
                            height: 90,

                            child:
                                ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                  true,
                                );
                              },

                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    _greenColor,

                                foregroundColor:
                                    Colors.white,

                                elevation: 4,

                                shadowColor:
                                    _greenColor
                                        .withOpacity(
                                  0.25,
                                ),

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
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
                                      loc.eWalletConfirmContinue
                                          .toUpperCase(),

                                      textAlign:
                                          TextAlign.center,

                                      maxLines: 1,

                                      overflow:
                                          TextOverflow
                                              .ellipsis,

                                      style:
                                          const TextStyle(
                                        fontSize: 29,

                                        fontWeight:
                                            FontWeight
                                                .w900,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                  const Icon(
                                    Icons
                                        .arrow_forward_rounded,
                                    size: 35,
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
          ),
        );
      },
    );

    return confirmed ?? false;
  }

  // ==========================================================================
  // CONTINUE
  // ==========================================================================

  Future<void> _handleContinue() async {
    final loc =
        AppLocalizations.of(context)!;

    if (_isNavigating) {
      return;
    }

    if (!_isProductActive) {
      _showMessage(
        loc.eWalletUnavailableTitle,
        loc.eWalletUnavailableMessage,
        Icons.cloud_off_rounded,
        const Color(
          0xFFD32F2F,
        ),
      );

      return;
    }

    // ========================================================================
    // TNG PIN
    // ========================================================================

    if (_isTngPin) {
      if (_selectedAmount == null) {
        _showMessage(
          loc.eWalletSelectAmountTitle,
          loc.eWalletSelectAmountMessage,
          Icons.payments_rounded,
          const Color(
            0xFFE08A00,
          ),
        );

        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PEWALLET5PAGE(
            productCode:
                _code,

            providerName:
                _productName,

            providerImageUrl:
                _imageUrl,

            selectedAmount:
                _pinAmount,

            selectedTotalAmount:
                _totalAmount,

            phoneNumber:
                null,
          ),
        ),
      );

      return;
    }

    // ========================================================================
    // TNGD / TRUE
    // ========================================================================

    final String phone =
        _phoneNumber;

    if (phone.isEmpty) {
      _showMessage(
        loc.eWalletPhoneRequiredTitle,
        loc.eWalletPhoneRequiredMessage,
        Icons.phone_android_rounded,
        _primaryColor,
      );

      return;
    }

    if (!_isValidPhone(
      phone,
    )) {
      _showMessage(
        loc.eWalletInvalidPhoneTitle,
        loc.eWalletInvalidPhoneMessage,
        Icons.warning_amber_rounded,
        const Color(
          0xFFE08A00,
        ),
      );

      return;
    }

    // ========================================================================
    // CONFIRM PHONE NUMBER
    // ========================================================================

    final bool confirmed =
        await _showPhoneConfirmation(
      phone,
    );

    if (!confirmed ||
        !mounted) {
      return;
    }

    // ========================================================================
    // OPEN PAGE 5
    // ========================================================================

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PEWALLET5PAGE(
          productCode:
              _code,

          providerName:
              _productName,

          providerImageUrl:
              _imageUrl,

          phoneNumber:
              phone,

          selectedAmount:
              null,

          selectedTotalAmount:
              null,
        ),
      ),
    );
  }

  // ==========================================================================
  // STANDARD MESSAGE
  // ==========================================================================

  void _showMessage(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    showGeneralDialog<void>(
      context: context,

      barrierDismissible: false,

      barrierLabel:
          title,

      barrierColor:
          Colors.black.withOpacity(
        0.65,
      ),

      transitionDuration:
          const Duration(
        milliseconds: 220,
      ),

      pageBuilder: (
        dialogContext,
        animation,
        secondaryAnimation,
      ) {
        return SafeArea(
          child: Center(
            child: Material(
              color:
                  Colors.transparent,

              child: Container(
                width: 780,

                padding:
                    const EdgeInsets.all(
                  42,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    38,
                  ),

                  border:
                      Border.all(
                    color:
                        color.withOpacity(
                      0.30,
                    ),

                    width: 3,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black
                              .withOpacity(
                        0.28,
                      ),

                      blurRadius: 38,

                      offset:
                          const Offset(
                        0,
                        16,
                      ),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Container(
                      width: 120,
                      height: 120,

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,

                        color:
                            color.withOpacity(
                          0.12,
                        ),
                      ),

                      child: Icon(
                        icon,
                        color: color,
                        size: 68,
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    Text(
                      title,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF17283E,
                        ),

                        fontSize: 44,

                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    Text(
                      message,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF5F6F82,
                        ),

                        fontSize: 29,

                        fontWeight:
                            FontWeight
                                .w600,

                        height: 1.4,
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    SizedBox(
                      width:
                          double.infinity,

                      height: 82,

                      child:
                          ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              color,

                          foregroundColor:
                              Colors.white,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              22,
                            ),
                          ),
                        ),

                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .eWalletOkButton,

                          style:
                              const TextStyle(
                            fontSize: 30,

                            fontWeight:
                                FontWeight
                                    .w900,
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
    );
  }

  // ==========================================================================
  // NUMBER KEY
  // ==========================================================================

  Widget _buildNumberKey(
    String value,
  ) {
    final bool pressed =
        _activeKey == value;

    return Listener(
      onPointerDown: (_) {
        if (_isNavigating) {
          return;
        }

        setState(() {
          _activeKey =
              value;
        });
      },

      onPointerUp: (_) {
        if (_isNavigating) {
          return;
        }

        setState(() {
          _activeKey =
              null;
        });

        _addNumber(
          value,
        );
      },

      onPointerCancel: (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _activeKey =
              null;
        });
      },

      child: AnimatedScale(
        scale:
            pressed
                ? 0.93
                : 1,

        duration:
            const Duration(
          milliseconds: 110,
        ),

        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 110,
          ),

          height: 125,

          decoration:
              BoxDecoration(
            color:
                pressed
                    ? _primaryColor
                        .withOpacity(
                        0.15,
                      )
                    : Colors.white,

            borderRadius:
                BorderRadius.circular(
              28,
            ),

            border:
                Border.all(
              color:
                  pressed
                      ? _primaryColor
                      : const Color(
                          0xFFB8C7D6,
                        ),

              width:
                  pressed
                      ? 4
                      : 2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black
                        .withOpacity(
                  pressed
                      ? 0.08
                      : 0.15,
                ),

                blurRadius:
                    pressed
                        ? 6
                        : 14,

                offset:
                    const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),

          child: Center(
            child: Text(
              value,

              style:
                  TextStyle(
                color:
                    pressed
                        ? _darkColor
                        : const Color(
                            0xFF15253A,
                          ),

                fontSize: 64,

                fontWeight:
                    FontWeight
                        .w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ACTION KEY
  // ==========================================================================

  Widget _buildActionKey({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color:
          Colors.transparent,

      child: InkWell(
        onTap:
            _isNavigating
                ? null
                : onPressed,

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        child: Container(
          height: 125,

          decoration:
              BoxDecoration(
            gradient:
                const LinearGradient(
              colors: [
                _lightColor,
                _darkColor,
              ],
            ),

            borderRadius:
                BorderRadius.circular(
              28,
            ),

            border:
                Border.all(
              color:
                  _darkColor,

              width: 2,
            ),
          ),

          child: Center(
            child: Icon(
              icon,

              color:
                  Colors.white,

              size: 50,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',

              fit:
                  BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color:
                  Colors.white
                      .withOpacity(
                0.06,
              ),
            ),
          ),

          if (_isLoading)
            _buildLoading(
              loc,
            )
          else if (_errorMessage !=
              null)
            _buildError(
              loc,
            )
          else if (_isTngPin)
            _buildTngPinContent(
              loc,
            )
          else
            _buildPinlessPhoneContent(
              loc,
            ),

          Positioned(
            bottom: 22,
            left: 0,
            right: 0,

            child: Text(
              Data.copyrightText,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF26364A,
                ),

                fontSize: 20,

                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // LOADING
  // ==========================================================================

  Widget _buildLoading(
    AppLocalizations loc,
  ) {
    return Center(
      child: Container(
        width: 620,

        padding:
            const EdgeInsets.all(
          45,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white
                  .withOpacity(
            0.97,
          ),

          borderRadius:
              BorderRadius.circular(
            36,
          ),
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const SizedBox(
              width: 95,
              height: 95,

              child:
                  CircularProgressIndicator(
                strokeWidth: 7,

                color:
                    _primaryColor,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            Text(
              loc.eWalletLoadingTitle,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),

                fontSize: 41,

                fontWeight:
                    FontWeight
                        .w900,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              loc.eWalletLoadingMessage,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF657386,
                ),

                fontSize: 28,

                fontWeight:
                    FontWeight
                        .w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // ERROR
  // ==========================================================================

  Widget _buildError(
    AppLocalizations loc,
  ) {
    return Center(
      child: Container(
        width: 700,

        padding:
            const EdgeInsets.all(
          45,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            38,
          ),

          border:
              Border.all(
            color:
                const Color(
              0xFFE57373,
            ),

            width: 2,
          ),
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const Icon(
              Icons.cloud_off_rounded,

              color:
                  Color(
                0xFFD32F2F,
              ),

              size: 90,
            ),

            const SizedBox(
              height: 25,
            ),

            Text(
              loc.eWalletCatalogErrorTitle,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 43,

                fontWeight:
                    FontWeight
                        .w900,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              loc.eWalletCatalogErrorMessage,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 28,

                color:
                    Color(
                  0xFF657386,
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },

                    child: Text(
                      loc.buttonBack,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 20,
                ),

                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        _loadProduct,

                    icon:
                        const Icon(
                      Icons
                          .refresh_rounded,
                    ),

                    label: Text(
                      loc.eWalletRetry,
                    ),

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          _primaryColor,

                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // TNG PIN CONTENT
  // ==========================================================================

  Widget _buildTngPinContent(
    AppLocalizations loc,
  ) {
    return Positioned(
      top: 55,
      left: 60,
      right: 60,
      bottom: 70,

      child:
          SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(
              loc.eWalletPinPurchaseTitle,
            ),

            const SizedBox(
              height: 40,
            ),

            _buildProviderCard(
              loc,
            ),

            const SizedBox(
              height: 20,
            ),

            if (_catalogNote
                .isNotEmpty) ...[
              _buildNote(
                loc.eWalletTngPinNote,
              ),

              const SizedBox(
                height: 20,
              ),
            ],

            _buildDenominationCard(
              loc,
            ),

            const SizedBox(
              height: 40,
            ),

            _buildTngSummary(
              loc,
            ),

            const SizedBox(
              height: 40,
            ),

            _buildActions(
              loc,
            ),

            const SizedBox(
              height: 70,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // PINLESS PHONE CONTENT
  // ==========================================================================

  Widget _buildPinlessPhoneContent(
    AppLocalizations loc,
  ) {
    return Stack(
      children: [
        Positioned(
          top: 50,
          left: 65,
          right: 65,

          child: Column(
            children: [
              _buildServiceBadge(
                loc.eWalletPhoneStepLabel,
              ),

              const SizedBox(
                height: 14,
              ),

              Text(
                loc.eWalletEnterPhoneTitle
                    .toUpperCase(),

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  color:
                      _darkColor,

                  fontSize: 45,

                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                loc.eWalletEnterPhoneSubtitle,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF53677E,
                  ),

                  fontSize: 27,

                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),
            ],
          ),
        ),

        // ====================================================================
        // PROVIDER + PHONE
        // ====================================================================

        Positioned(
          top: 300,
          left: 70,
          right: 70,

          child: Container(
            padding:
                const EdgeInsets.fromLTRB(
              28,
              25,
              28,
              28,
            ),

            decoration:
                BoxDecoration(
              color:
                  Colors.white
                      .withOpacity(
                0.96,
              ),

              borderRadius:
                  BorderRadius.circular(
                34,
              ),

              border:
                  Border.all(
                color:
                    _primaryColor
                        .withOpacity(
                  0.25,
                ),

                width: 2,
              ),
            ),

            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 130,
                      height: 100,

                      padding:
                          const EdgeInsets.all(
                        15,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius
                                .circular(
                          24,
                        ),
                      ),

                      child:
                          Image.network(
                        _imageUrl,

                        fit:
                            BoxFit.contain,

                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons
                                .account_balance_wallet_rounded,

                            color:
                                _primaryColor,

                            size: 55,
                          );
                        },
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
                            loc.eWalletSelectedProvider
                                .toUpperCase(),

                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF758399,
                              ),

                              fontSize: 21,

                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            _productName,

                            maxLines: 2,

                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF17283E,
                              ),

                              fontSize: 32,

                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 35,
                ),

                // ==========================================================
                // PHONE NUMBER
                // ==========================================================

                Container(
                  height: 110,

                  alignment:
                      Alignment.center,

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF7FAFD,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      28,
                    ),

                    border:
                        Border.all(
                      color:
                          _primaryColor,

                      width: 3,
                    ),
                  ),

                  child: TextField(
                    controller:
                        _phoneController,

                    readOnly: true,

                    showCursor: true,

                    cursorColor:
                        _primaryColor,

                    cursorWidth: 4,

                    textAlign:
                        TextAlign.center,

                    keyboardType:
                        TextInputType.none,

                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF17283E,
                      ),

                      fontSize: 50,

                      fontWeight:
                          FontWeight
                              .w900,

                      letterSpacing: 2,
                    ),

                    decoration:
                        InputDecoration(
                      border:
                          InputBorder.none,

                      hintText:
                          loc.eWalletPhoneHint
                              .toUpperCase(),

                      hintStyle:
                          const TextStyle(
                        color:
                            Color(
                          0xFF9AA6B4,
                        ),

                        fontSize: 28,

                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  loc.eWalletPinlessPhoneHint,

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF657386,
                    ),

                    fontSize: 24,

                    fontWeight:
                        FontWeight
                            .w600,

                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ====================================================================
        // KEYPAD
        // ====================================================================

        Positioned(
          top: 750,
          left: 80,
          right: 80,

          child: GridView.count(
            crossAxisCount: 3,

            shrinkWrap: true,

            physics:
                const NeverScrollableScrollPhysics(),

            mainAxisSpacing: 20,

            crossAxisSpacing: 20,

            childAspectRatio:
                1.72,

            children: [
              _buildNumberKey('1'),
              _buildNumberKey('2'),
              _buildNumberKey('3'),

              _buildNumberKey('4'),
              _buildNumberKey('5'),
              _buildNumberKey('6'),

              _buildNumberKey('7'),
              _buildNumberKey('8'),
              _buildNumberKey('9'),

              _buildActionKey(
                icon:
                    Icons
                        .delete_sweep_rounded,

                onPressed:
                    _clearAll,
              ),

              _buildNumberKey('0'),

              _buildActionKey(
                icon:
                    Icons
                        .backspace_outlined,

                onPressed:
                    _backspace,
              ),
            ],
          ),
        ),

        // ====================================================================
        // ACTIONS
        // ====================================================================

        Positioned(
          bottom: 190,
          left: 80,
          right: 80,

          child:
              _buildActions(
            loc,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader(
    String title,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 25,
      ),

      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            _darkColor,
            _primaryColor,
            _lightColor,
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          32,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,

            decoration:
                BoxDecoration(
              color:
                  Colors.white
                      .withOpacity(
                0.18,
              ),

              borderRadius:
                  BorderRadius.circular(
                22,
              ),
            ),

            child:
                const Icon(
              Icons
                  .account_balance_wallet_rounded,

              color:
                  Colors.white,

              size: 48,
            ),
          ),

          const SizedBox(
            width: 22,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  title.toUpperCase(),

                  style:
                      const TextStyle(
                    color:
                        Colors.white70,

                    fontSize: 22,

                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  _productName
                      .toUpperCase(),

                  style:
                      const TextStyle(
                    color:
                        Colors.white,

                    fontSize: 44,

                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SERVICE BADGE
  // ==========================================================================

  Widget _buildServiceBadge(
    String label,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 10,
      ),

      decoration:
          BoxDecoration(
        color:
            _primaryColor
                .withOpacity(
          0.10,
        ),

        borderRadius:
            BorderRadius.circular(
          100,
        ),

        border:
            Border.all(
          color:
              _primaryColor
                  .withOpacity(
            0.25,
          ),
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          const Icon(
            Icons
                .account_balance_wallet_rounded,

            color:
                _primaryColor,

            size: 30,
          ),

          const SizedBox(
            width: 9,
          ),

          Text(
            label.toUpperCase(),

            style:
                const TextStyle(
              color:
                  _primaryColor,

              fontSize: 21,

              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PROVIDER CARD
  // ==========================================================================

  Widget _buildProviderCard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        28,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          30,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFE7C8B8,
          ),

          width: 2,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 155,
            height: 120,

            padding:
                const EdgeInsets.all(
              18,
            ),

            child:
                Image.network(
              _imageUrl,

              fit:
                  BoxFit.contain,

              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons
                      .account_balance_wallet_rounded,

                  color:
                      _primaryColor,

                  size: 65,
                );
              },
            ),
          ),

          const SizedBox(
            width: 25,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  loc.eWalletSelectedProvider
                      .toUpperCase(),

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF718096,
                    ),

                    fontSize: 21,

                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  _productName,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF17283E,
                    ),

                    fontSize: 39,

                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  _isProductActive
                      ? loc.eWalletAvailable
                      : loc.eWalletUnavailable,

                  style:
                      TextStyle(
                    color:
                        _isProductActive
                            ? const Color(
                                0xFF08783E,
                              )
                            : const Color(
                                0xFFC62828,
                              ),

                    fontSize: 20,

                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // NOTE
  // ==========================================================================

  Widget _buildNote(
    String text,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        23,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFFFF8E8,
        ),

        borderRadius:
            BorderRadius.circular(
          24,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFFFC766,
          ),
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons
                .info_outline_rounded,

            color:
                Color(
              0xFFE07900,
            ),

            size: 50,
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Text(
              text,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF684E24,
                ),

                fontSize: 30,

                fontWeight:
                    FontWeight
                        .w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // DENOMINATION
  // ==========================================================================

  Widget _buildDenominationCard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        28,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          30,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFD1DEED,
          ),

          width: 2,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [
          Row(
            children: [
              const Icon(
                Icons
                    .payments_rounded,

                color:
                    _primaryColor,

                size: 34,
              ),

              const SizedBox(
                width: 13,
              ),

              Text(
                loc.eWalletSelectReloadValue,

                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFF17283E,
                  ),

                  fontSize: 34,

                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 22,
          ),

          Wrap(
            spacing: 16,
            runSpacing: 16,

            children:
                _denominations
                    .map(
                      (
                        amount,
                      ) =>
                          _buildAmountButton(
                        amount,
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountButton(
    double amount,
  ) {
    final bool selected =
        _selectedAmount ==
            amount;

    return SizedBox(
      width: 230,
      height: 105,

      child:
          ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedAmount =
                amount;
          });
        },

        style:
            ElevatedButton
                .styleFrom(
          elevation:
              selected
                  ? 3
                  : 0,

          backgroundColor:
              selected
                  ? const Color(
                      0xFFFFE8DD,
                    )
                  : Colors.white,

          foregroundColor:
              selected
                  ? _darkColor
                  : const Color(
                      0xFF17283E,
                    ),

          side:
              BorderSide(
            color:
                selected
                    ? _primaryColor
                    : const Color(
                        0xFFD4DEE9,
                      ),

            width:
                selected
                    ? 3
                    : 2,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
        ),

        child: Text(
          _formatButtonAmount(
            amount,
          ),

          style:
              const TextStyle(
            fontSize: 34,

            fontWeight:
                FontWeight
                    .w900,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // TNG SUMMARY
  // ==========================================================================

  Widget _buildTngSummary(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        30,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          30,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFE7C8B8,
          ),

          width: 2,
        ),
      ),

      child: Column(
        children: [
          _summaryRow(
            loc.eWalletPinValue,

            _formatMoney(
              _pinAmount,
            ),
          ),

          if (_hasAdjustment) ...[
            const Divider(
              height: 35,
            ),

            _summaryRow(
              loc.eWalletServiceAdjustment,

              _formatSignedMoney(
                _adjustmentAmount,
              ),
            ),
          ],

          const Divider(
            height: 35,

            thickness: 2,
          ),

          _summaryRow(
            loc.eWalletTotalPayment,

            _formatMoney(
              _totalAmount,
            ),

            bold: true,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SUMMARY ROW
  // ==========================================================================

  Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,

            style:
                TextStyle(
              color:
                  const Color(
                0xFF52667E,
              ),

              fontSize:
                  bold
                      ? 32
                      : 27,

              fontWeight:
                  bold
                      ? FontWeight
                          .w900
                      : FontWeight
                          .w700,
            ),
          ),
        ),

        Text(
          value,

          style:
              TextStyle(
            color:
                bold
                    ? _primaryColor
                    : const Color(
                        0xFF17283E,
                      ),

            fontSize:
                bold
                    ? 40
                    : 28,

            fontWeight:
                FontWeight
                    .w900,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ACTION BUTTONS
  // ==========================================================================

  Widget _buildActions(
    AppLocalizations loc,
  ) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 94,

            child:
                OutlinedButton.icon(
              onPressed:
                  _isNavigating
                      ? null
                      : () {
                          Navigator.pop(
                            context,
                          );
                        },

              icon:
                  const Icon(
                Icons
                    .arrow_back_rounded,

                size: 36,
              ),

              label: Text(
                loc.buttonBack,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 35,

                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),

              style:
                  OutlinedButton
                      .styleFrom(
                foregroundColor:
                    const Color(
                  0xFF17283E,
                ),

                backgroundColor:
                    Colors.white,

                side:
                    const BorderSide(
                  color:
                      Color(
                    0xFF17283E,
                  ),

                  width: 2,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    22,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(
          width: 22,
        ),

        Expanded(
          flex: 2,

          child: SizedBox(
            height: 94,

            child:
                ElevatedButton.icon(
              onPressed:
                  _isNavigating
                      ? null
                      : _handleContinue,

              icon:
                  const Icon(
                Icons
                    .arrow_forward_rounded,

                size: 36,
              ),

              label: Text(
                loc.eWalletContinue
                    .toUpperCase(),

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 40,

                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    const Color(
                  0xFF1769D2,
                ),

                foregroundColor:
                    Colors.white,

                elevation: 3,

                shadowColor:
                    const Color(
                  0x551769D2,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}