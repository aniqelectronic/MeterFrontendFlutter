import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

// NEXT PAGE
import 'package:frontend_v1/pages/bil/telco/mobilereload/pmobilereload5.dart';

class PMOBILERELOAD4PAGE extends StatefulWidget {
  final String productCode;
  final String providerName;
  final String providerImageUrl;

  const PMOBILERELOAD4PAGE({
    super.key,
    required this.productCode,
    required this.providerName,
    required this.providerImageUrl,
  });

  @override
  State<PMOBILERELOAD4PAGE> createState() =>
      _PMOBILERELOAD4PAGEState();
}

class _PMOBILERELOAD4PAGEState
    extends State<PMOBILERELOAD4PAGE> {
  // ==========================================================================
  // STATE
  // ==========================================================================

  bool _isLoading = true;

  String? _errorMessage;

  Map<String, dynamic>? _product;

  final TextEditingController _phoneController =
      TextEditingController();

  String? _activeKey;

  bool _isNavigating = false;

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF7B4DCC);

  static const Color _darkColor =
      Color(0xFF56339B);

  static const Color _lightColor =
      Color(0xFFF1EAFF);

  static const Color _greenColor =
      Color(0xFF16813B);

  static const Color _redColor =
      Color(0xFFD93A3A);

  // ==========================================================================
  // PRODUCT
  // ==========================================================================

  String get _code =>
      widget.productCode.trim().toUpperCase();

  String get _productName {
    final String value =
        _product?['name']?.toString().trim() ?? '';

    return value.isNotEmpty
        ? value
        : widget.providerName;
  }

  String get _imageUrl {
    final String value =
        _product?['image_url']?.toString().trim() ?? '';

    return value.isNotEmpty
        ? value
        : widget.providerImageUrl;
  }

  bool get _isProductActive =>
      _product?['is_active'] == true;

  String get _phoneNumber =>
      _phoneController.text.trim();

  int get _maximumPhoneLength => 11;

  // ==========================================================================
  // INIT
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
  // LOAD PRODUCT FROM CATALOG
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
          await IimmpactCatalogService.getCatalog();

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
          'Mobile Reload product $_code was not found.',
        );
      }

      final Map<String, dynamic> product =
          Map<String, dynamic>.from(
        rawProduct,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;
        _isLoading = false;
      });

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'MOBILE RELOAD PAGE 4',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Product Code : $_code',
      );
      debugPrint(
        'Product      : $_productName',
      );
      debugPrint(
        'Active       : $_isProductActive',
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
        _errorMessage = error.message;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Mobile Reload Page 4 catalog error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  // ==========================================================================
  // PHONE
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
        _phoneController.text.length - 1,
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
  // CONFIRM NUMBER
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
          loc.mobileReloadConfirmNumberTitle,

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
          curve: Curves.easeOutBack,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale:
                Tween<double>(
              begin: 0.86,
              end: 1,
            ).animate(curved),
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
              color: Colors.transparent,
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
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    38,
                  ),

                  border:
                      Border.all(
                    color:
                        _primaryColor.withOpacity(
                      0.40,
                    ),
                    width: 3,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(
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
                    Container(
                      width: 110,
                      height: 110,
                      decoration:
                          BoxDecoration(
                        color:
                            _primaryColor.withOpacity(
                          0.12,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(
                        Icons
                            .phone_android_rounded,
                        color: _primaryColor,
                        size: 62,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    Text(
                      loc.mobileReloadConfirmNumberTitle
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
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    Container(
                      width: double.infinity,

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
                          color: _primaryColor,
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
                              FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      loc.mobileReloadConfirmNumberQuestion,
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
                            FontWeight.w800,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(
                      height: 34,
                    ),

                    Row(
                      children: [
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
                                loc.mobileReloadConfirmBack
                                    .toUpperCase(),
                                style:
                                    const TextStyle(
                                  fontSize: 28,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    _redColor,
                                foregroundColor:
                                    Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 20,
                        ),

                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 90,
                            child:
                                ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                  true,
                                );
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .arrow_forward_rounded,
                                size: 34,
                              ),
                              label: Text(
                                loc.mobileReloadConfirmContinue
                                    .toUpperCase(),
                                style:
                                    const TextStyle(
                                  fontSize: 29,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    _greenColor,
                                foregroundColor:
                                    Colors.white,
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
        loc.mobileReloadUnavailableTitle,
        loc.mobileReloadUnavailableMessage,
      );

      return;
    }

    final String phone =
        _phoneNumber;

    if (phone.isEmpty) {
      _showMessage(
        loc.mobileReloadPhoneRequiredTitle,
        loc.mobileReloadPhoneRequiredMessage,
      );

      return;
    }

    if (!_isValidPhone(
      phone,
    )) {
      _showMessage(
        loc.mobileReloadInvalidPhoneTitle,
        loc.mobileReloadInvalidPhoneMessage,
      );

      return;
    }

    final bool confirmed =
        await _showPhoneConfirmation(
      phone,
    );

    if (!confirmed ||
        !mounted) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PMOBILERELOAD5PAGE(
          productCode:
              _code,
          providerName:
              _productName,
          providerImageUrl:
              _imageUrl,
          phoneNumber:
              phone,
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _isNavigating = false;
      });
    }
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  Future<void> _showMessage(
    String title,
    String message,
  ) async {
    final loc =
        AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (
        BuildContext dialogContext,
      ) {
        return Dialog(
          backgroundColor:
              Colors.transparent,
          child: Container(
            width: 700,
            padding:
                const EdgeInsets.all(
              40,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                32,
              ),
              border:
                  Border.all(
                color:
                    _primaryColor.withOpacity(
                  0.30,
                ),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons
                      .info_outline_rounded,
                  color:
                      _primaryColor,
                  size: 80,
                ),

                const SizedBox(
                  height: 20,
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
                    fontSize: 38,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                Text(
                  message,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF657386,
                    ),
                    fontSize: 27,
                    fontWeight:
                        FontWeight.w600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 78,
                  child:
                      ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _primaryColor,
                      foregroundColor:
                          Colors.white,
                    ),
                    child: Text(
                      loc.mobileReloadOkButton,
                      style:
                          const TextStyle(
                        fontSize: 27,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // KEYPAD
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
          _activeKey = value;
        });
      },

      onPointerUp: (_) {
        if (_isNavigating) {
          return;
        }

        setState(() {
          _activeKey = null;
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
          _activeKey = null;
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

        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 110,
          ),

          height: 125,

          decoration:
              BoxDecoration(
            color:
                pressed
                    ? _primaryColor.withOpacity(
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
                    FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
                _primaryColor,
                _darkColor,
              ],
            ),
            borderRadius:
                BorderRadius.circular(
              28,
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
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color:
                  Colors.white.withOpacity(
                0.06,
              ),
            ),
          ),

          if (_isLoading)
            const Center(
              child:
                  CircularProgressIndicator(
                strokeWidth: 6,
                color: _primaryColor,
              ),
            )
          else if (_errorMessage != null)
            _buildError(
              loc,
            )
          else
            _buildPhoneContent(
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
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PHONE CONTENT
  // ==========================================================================

  Widget _buildPhoneContent(
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
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      _primaryColor.withOpacity(
                    0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    100,
                  ),
                  border:
                      Border.all(
                    color:
                        _primaryColor.withOpacity(
                      0.30,
                    ),
                  ),
                ),
                child: Text(
                  loc.mobileReloadPhoneStepLabel
                      .toUpperCase(),
                  style:
                      const TextStyle(
                    color:
                        _primaryColor,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                loc.mobileReloadEnterPhoneTitle
                    .toUpperCase(),
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      _darkColor,
                  fontSize: 45,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                loc.mobileReloadEnterPhoneSubtitle,
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
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // ====================================================================
        // PROVIDER + PHONE NUMBER
        // ====================================================================

        Positioned(
          top: 260,
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
                  Colors.white.withOpacity(
                0.96,
              ),
              borderRadius:
                  BorderRadius.circular(
                34,
              ),
              border:
                  Border.all(
                color:
                    _primaryColor.withOpacity(
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
                            BorderRadius.circular(
                          24,
                        ),
                      ),
                      child: Image.network(
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
                                .phone_android_rounded,
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
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.mobileReloadSelectedProvider
                                .toUpperCase(),
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF758399,
                              ),
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            _productName,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF17283E,
                              ),
                              fontSize: 32,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 30,
                ),

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
                          FontWeight.w900,
                      letterSpacing: 2,
                    ),
                    decoration:
                        InputDecoration(
                      border:
                          InputBorder.none,
                      hintText:
                          loc.mobileReloadPhoneHint
                              .toUpperCase(),
                      hintStyle:
                          const TextStyle(
                        color:
                            Color(
                          0xFF9AA6B4,
                        ),
                        fontSize: 28,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
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
          top: 650,
          left: 80,
          right: 80,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.72,
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
                    Icons.delete_sweep_rounded,
                onPressed:
                    _clearAll,
              ),

              _buildNumberKey('0'),

              _buildActionKey(
                icon:
                    Icons.backspace_outlined,
                onPressed:
                    _backspace,
              ),
            ],
          ),
        ),

        // ====================================================================
        // BUTTONS
        // ====================================================================

        Positioned(
          bottom: 120,
          left: 80,
          right: 80,
          child: Row(
            children: [
              // ==============================================================
              // BACK
              // ==============================================================

              Expanded(
                child: SizedBox(
                  height: 94,
                  child: OutlinedButton.icon(
                    onPressed:
                        _isNavigating
                            ? null
                            : () {
                                Navigator.pop(
                                  context,
                                );
                              },

                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 36,
                    ),

                    label: Text(
                      loc.buttonBack,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(0xFF17283E),

                      backgroundColor:
                          Colors.white,

                      side: const BorderSide(
                        color: Color(0xFF17283E),
                        width: 2,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 22),

              // ==============================================================
              // CONTINUE
              // ==============================================================

              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 94,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isNavigating
                            ? null
                            : _handleContinue,

                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 36,
                    ),

                    label: Text(
                      loc.buttonContinue.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF1769D2),

                      foregroundColor:
                          Colors.white,

                      elevation: 3,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
        width: 680,
        padding:
            const EdgeInsets.all(
          40,
        ),
        decoration:
            BoxDecoration(
          color:
              Colors.white,
          borderRadius:
              BorderRadius.circular(
            32,
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 85,
              color:
                  Color(
                0xFFD32F2F,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              loc.mobileReloadErrorTitle,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 38,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              loc.mobileReloadErrorMessage,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 26,
                color:
                    Color(
                  0xFF657386,
                ),
              ),
            ),

            const SizedBox(
              height: 28,
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
                      Icons.refresh_rounded,
                    ),
                    label: Text(
                      loc.mobileReloadRetry,
                    ),
                    style:
                        ElevatedButton.styleFrom(
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
}