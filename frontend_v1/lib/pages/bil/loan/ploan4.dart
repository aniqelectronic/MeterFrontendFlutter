import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

import 'package:frontend_v1/pages/bil/loan/ptptn/ptptpn5.dart';
import 'package:frontend_v1/pages/bil/loan/services/ptptn_subproduct_service.dart';

// ============================================================================
// PTPTN PAGE 4
// ============================================================================
//
// FLOW:
//
// Loan & Education
//      ↓
// PTPTN
//      ↓
// PAGE 4
// Enter 12-digit NRIC
//      ↓
// Confirm NRIC
//      ↓
// GET /v2/subproducts
//      ↓
// IF ACCOUNT FOUND:
//      PLOAN5PAGE
//
// IF NO ACCOUNT:
//      Stay on this page
//      Show popup
//
// ============================================================================

class PLOAN4PAGE extends StatefulWidget {
  final String productCode;
  final String providerName;
  final String providerImageUrl;

  const PLOAN4PAGE({
    super.key,
    required this.productCode,
    required this.providerName,
    required this.providerImageUrl,
  });

  @override
  State<PLOAN4PAGE> createState() => _PLOAN4PAGEState();
}

class _PLOAN4PAGEState extends State<PLOAN4PAGE> {
  // ==========================================================================
  // STATE
  // ==========================================================================

  bool _isLoading = true;

  String? _errorMessage;

  Map<String, dynamic>? _product;

  final TextEditingController _nricController = TextEditingController();

  String? _activeKey;

  bool _isNavigating = false;

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor = Color(0xFF3F51B5);

  static const Color _darkColor = Color(0xFF303F9F);

  static const Color _lightColor = Color(0xFF7986CB);

  static const Color _greenColor = Color(0xFF16813B);

  static const Color _redColor = Color(0xFFD93A3A);

  // ==========================================================================
  // PRODUCT
  // ==========================================================================

  String get _code => widget.productCode.trim().toUpperCase();

  String get _productName {
    final String value = _product?['name']?.toString().trim() ?? '';

    if (value.isNotEmpty) {
      return value;
    }

    return widget.providerName;
  }

  String get _imageUrl {
    final String value = _product?['image_url']?.toString().trim() ?? '';

    if (value.isNotEmpty) {
      return value;
    }

    return widget.providerImageUrl;
  }

  bool get _isProductActive => _product?['is_active'] == true;

  // ==========================================================================
  // NRIC
  // ==========================================================================

  String get _nric => _nricController.text.trim();

  static const int _maximumNricLength = 12;

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
    _nricController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // LOAD PTPTN PRODUCT FROM CATALOG
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

      final dynamic productsRaw = catalog['products'];

      if (productsRaw is! Map) {
        throw Exception(
          'Catalog products object is missing.',
        );
      }

      final Map<String, dynamic> products =
          Map<String, dynamic>.from(productsRaw);

      final dynamic rawProduct = products[_code];

      if (rawProduct is! Map) {
        throw Exception(
          'PTPTN product $_code was not found.',
        );
      }

      final Map<String, dynamic> product =
          Map<String, dynamic>.from(rawProduct);

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;
        _isLoading = false;
      });

      debugPrint('');
      debugPrint('========================================');
      debugPrint('PTPTN PAGE 4 PRODUCT LOADED');
      debugPrint('========================================');
      debugPrint('Product Code : $_code');
      debugPrint('Product      : $_productName');
      debugPrint('Active       : $_isProductActive');
      debugPrint('Image        : $_imageUrl');
      debugPrint('========================================');
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
        'PTPTN catalog error: $error',
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
  // NUMBER KEYPAD
  // ==========================================================================

  void _addNumber(
    String value,
  ) {
    if (_isNavigating) {
      return;
    }

    if (_nricController.text.length >= _maximumNricLength) {
      return;
    }

    setState(() {
      _nricController.text += value;
    });
  }

  void _backspace() {
    if (_isNavigating || _nricController.text.isEmpty) {
      return;
    }

    setState(() {
      _nricController.text = _nricController.text.substring(
        0,
        _nricController.text.length - 1,
      );
    });
  }

  void _clearAll() {
    if (_isNavigating) {
      return;
    }

    setState(() {
      _nricController.clear();
    });
  }

  // ==========================================================================
  // VALIDATE NRIC
  // ==========================================================================

  bool _isValidNric(
    String value,
  ) {
    return RegExp(
      r'^[0-9]{12}$',
    ).hasMatch(
      value,
    );
  }

  // ==========================================================================
  // NRIC CONFIRMATION
  // ==========================================================================

  Future<bool> _showNricConfirmation(
    String nric,
  ) async {
    final loc = AppLocalizations.of(context)!;

    final bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: loc.loanConfirmNricTitle,
      barrierColor: Colors.black.withOpacity(
        0.68,
      ),
      transitionDuration: const Duration(
        milliseconds: 230,
      ),
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
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
              color: Colors.transparent,
              child: Container(
                width: 790,
                margin: const EdgeInsets.symmetric(
                  horizontal: 60,
                ),
                padding: const EdgeInsets.fromLTRB(
                  42,
                  40,
                  42,
                  38,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    38,
                  ),
                  border: Border.all(
                    color: _primaryColor.withOpacity(
                      0.40,
                    ),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.32,
                      ),
                      blurRadius: 45,
                      offset: const Offset(
                        0,
                        20,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(
                          0.12,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.badge_rounded,
                        color: _primaryColor,
                        size: 62,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    Text(
                      loc.loanConfirmNricTitle.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(
                          0xFF17283E,
                        ),
                        fontSize: 45,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFF7FAFD,
                        ),
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                        border: Border.all(
                          color: _primaryColor,
                          width: 3,
                        ),
                      ),
                      child: Text(
                        nric,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(
                            0xFF17283E,
                          ),
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      loc.loanConfirmNricQuestion,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(
                          0xFF475B72,
                        ),
                        fontSize: 35,
                        fontWeight: FontWeight.w800,
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
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                  false,
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 34,
                              ),
                              label: Text(
                                loc.loanConfirmBack.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _redColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
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

                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 90,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                  true,
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 34,
                              ),
                              label: Text(
                                loc.loanConfirmContinue.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _greenColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
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
    final loc = AppLocalizations.of(context)!;

    if (_isNavigating) {
      return;
    }

    // ========================================================================
    // PRODUCT UNAVAILABLE
    // ========================================================================

    if (!_isProductActive) {
      _showMessage(
        loc.loanUnavailableTitle,
        loc.loanUnavailableMessage,
        Icons.cloud_off_rounded,
        const Color(
          0xFFD32F2F,
        ),
      );

      return;
    }

    final String nric = _nric;

    // ========================================================================
    // EMPTY NRIC
    // ========================================================================

    if (nric.isEmpty) {
      _showMessage(
        loc.loanNricRequiredTitle,
        loc.loanNricRequiredMessage,
        Icons.badge_rounded,
        _primaryColor,
      );

      return;
    }

    // ========================================================================
    // INVALID NRIC
    // ========================================================================

    if (!_isValidNric(
      nric,
    )) {
      _showMessage(
        loc.loanInvalidNricTitle,
        loc.loanInvalidNricMessage,
        Icons.warning_amber_rounded,
        const Color(
          0xFFE08A00,
        ),
      );

      return;
    }

    // ========================================================================
    // CONFIRM NRIC
    // ========================================================================

    final bool confirmed = await _showNricConfirmation(
      nric,
    );

    if (!confirmed || !mounted) {
      return;
    }

    // ========================================================================
    // START CHECKING ACCOUNT
    // ========================================================================

    setState(() {
      _isNavigating = true;
    });

    try {
      // ======================================================================
      // GET /v2/subproducts
      // ======================================================================

      final PtptnSubproductResult result =
          await PtptnSubproductService.getAccounts(
        nric: nric,
      );

      if (!mounted) {
        return;
      }

      // ======================================================================
      // NO ACCOUNT
      // ======================================================================

      if (result.products.isEmpty) {
        setState(() {
          _isNavigating = false;
        });

        await _showNoAccountMessage();

        return;
      }

      // ======================================================================
      // ACCOUNT FOUND
      // ======================================================================

      setState(() {
        _isNavigating = false;
      });

      debugPrint('');
      debugPrint('========================================');
      debugPrint('PTPTN ACCOUNTS FOUND');
      debugPrint('========================================');
      debugPrint('NRIC     : $nric');
      debugPrint(
        'Accounts : ${result.products.length}',
      );
      debugPrint('========================================');
      debugPrint('');

      // ======================================================================
      // OPEN ACCOUNT SELECTION PAGE
      // ======================================================================

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PTPTN5PAGE(
            productCode: _code,
            providerName: _productName,
            providerImageUrl: _imageUrl,
            nric: nric,
            initialAccounts: result.products,
          ),
        ),
      );
    } on PtptnSubproductException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isNavigating = false;
      });

      debugPrint(
        'PTPTN account check error: ${error.message}',
      );

      _showMessage(
        loc.loanAccountErrorTitle,
        error.message,
        Icons.cloud_off_rounded,
        const Color(
          0xFFD32F2F,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected PTPTN account check error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isNavigating = false;
      });

      _showMessage(
        loc.loanAccountErrorTitle,
        loc.loanAccountErrorMessage,
        Icons.cloud_off_rounded,
        const Color(
          0xFFD32F2F,
        ),
      );
    }
  }

  // ==========================================================================
  // NO ACCOUNT POPUP
  // ==========================================================================

  Future<void> _showNoAccountMessage() async {
    final loc = AppLocalizations.of(context)!;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: loc.loanNoAccountTitle,
      barrierColor: Colors.black.withOpacity(
        0.68,
      ),
      transitionDuration: const Duration(
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
              color: Colors.transparent,
              child: Container(
                width: 760,
                padding: const EdgeInsets.all(
                  42,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    38,
                  ),
                  border: Border.all(
                    color: const Color(
                      0xFFF1B95D,
                    ),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.28,
                      ),
                      blurRadius: 40,
                      offset: const Offset(
                        0,
                        18,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(
                          0xFFFFF3D9,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(
                          0xFFD87900,
                        ),
                        size: 68,
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    Text(
                      loc.loanNoAccountTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(
                          0xFF17283E,
                        ),
                        fontSize: 45,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    Text(
                      loc.loanNoAccountMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(
                          0xFF5F6F82,
                        ),
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 82,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              22,
                            ),
                          ),
                        ),
                        child: Text(
                          loc.loanOkButton,
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w900,
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
  // STANDARD MESSAGE
  // ==========================================================================

  void _showMessage(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    final loc = AppLocalizations.of(context)!;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: title,
      barrierColor: Colors.black.withOpacity(
        0.65,
      ),
      transitionDuration: const Duration(
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
              color: Colors.transparent,
              child: Container(
                width: 780,
                padding: const EdgeInsets.all(
                  42,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    38,
                  ),
                  border: Border.all(
                    color: color.withOpacity(
                      0.30,
                    ),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.28,
                      ),
                      blurRadius: 38,
                      offset: const Offset(
                        0,
                        16,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(
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
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(
                          0xFF17283E,
                        ),
                        fontSize: 45,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(
                          0xFF5F6F82,
                        ),
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 82,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              22,
                            ),
                          ),
                        ),
                        child: Text(
                          loc.loanOkButton,
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w900,
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
    final bool pressed = _activeKey == value;

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
        scale: pressed ? 0.93 : 1,
        duration: const Duration(
          milliseconds: 110,
        ),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 110,
          ),
          height: 125,
          decoration: BoxDecoration(
            color: pressed
                ? _primaryColor.withOpacity(
                    0.15,
                  )
                : Colors.white,
            borderRadius: BorderRadius.circular(
              28,
            ),
            border: Border.all(
              color: pressed
                  ? _primaryColor
                  : const Color(
                      0xFFB8C7D6,
                    ),
              width: pressed ? 4 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  pressed ? 0.08 : 0.15,
                ),
                blurRadius: pressed ? 6 : 14,
                offset: const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: pressed
                    ? _darkColor
                    : const Color(
                        0xFF15253A,
                      ),
                fontSize: 64,
                fontWeight: FontWeight.w900,
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
      color: Colors.transparent,
      child: InkWell(
        onTap: _isNavigating ? null : onPressed,
        borderRadius: BorderRadius.circular(
          28,
        ),
        child: Container(
          height: 125,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                _lightColor,
                _darkColor,
              ],
            ),
            borderRadius: BorderRadius.circular(
              28,
            ),
            border: Border.all(
              color: _darkColor,
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
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
    final loc = AppLocalizations.of(context)!;

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
              color: Colors.white.withOpacity(
                0.06,
              ),
            ),
          ),

          if (_isLoading)
            _buildLoading(
              loc,
            )
          else if (_errorMessage != null)
            _buildError(
              loc,
            )
          else
            _buildNricContent(
              loc,
            ),

          Positioned(
            bottom: 22,
            left: 0,
            right: 0,
            child: Text(
              Data.copyrightText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(
                  0xFF26364A,
                ),
                fontSize: 20,
                fontWeight: FontWeight.w800,
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
        padding: const EdgeInsets.all(
          45,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(
            0.97,
          ),
          borderRadius: BorderRadius.circular(
            36,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 95,
              height: 95,
              child: CircularProgressIndicator(
                strokeWidth: 7,
                color: _primaryColor,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            Text(
              loc.loanLoadingTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(
                  0xFF17283E,
                ),
                fontSize: 45,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              loc.loanLoadingMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(
                  0xFF657386,
                ),
                fontSize: 35,
                fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.all(
          45,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            38,
          ),
          border: Border.all(
            color: const Color(
              0xFFE57373,
            ),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(
                0xFFD32F2F,
              ),
              size: 90,
            ),

            const SizedBox(
              height: 25,
            ),

            Text(
              loc.loanCatalogErrorTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              loc.loanCatalogErrorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 35,
                color: Color(
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
                  child: OutlinedButton(
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
                  child: ElevatedButton.icon(
                    onPressed: _loadProduct,
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: Text(
                      loc.loanRetry,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
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
  // NRIC CONTENT
  // ==========================================================================

  Widget _buildNricContent(
    AppLocalizations loc,
  ) {
    return Stack(
      children: [
        // ====================================================================
        // HEADER
        // ====================================================================

        Positioned(
          top: 50,
          left: 65,
          right: 65,
          child: Column(
            children: [
              _buildServiceBadge(
                loc.loanNricStepLabel,
              ),

              const SizedBox(
                height: 14,
              ),

              Text(
                loc.loanEnterNricTitle.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _darkColor,
                  fontSize: 45,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                loc.loanEnterNricSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(
                    0xFF53677E,
                  ),
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // ====================================================================
        // PROVIDER + NRIC
        // ====================================================================

        Positioned(
          top: 300,
          left: 70,
          right: 70,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              28,
              25,
              28,
              28,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                0.96,
              ),
              borderRadius: BorderRadius.circular(
                34,
              ),
              border: Border.all(
                color: _primaryColor.withOpacity(
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
                      padding: const EdgeInsets.all(
                        15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                      ),
                      child: Image.network(
                        _imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons.school_rounded,
                            color: _primaryColor,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.loanSelectedProvider.toUpperCase(),
                            style: const TextStyle(
                              color: Color(
                                0xFF758399,
                              ),
                              fontSize: 35,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            _productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(
                                0xFF17283E,
                              ),
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
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

                Container(
                  height: 110,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF7FAFD,
                    ),
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                    border: Border.all(
                      color: _primaryColor,
                      width: 3,
                    ),
                  ),
                  child: TextField(
                    controller: _nricController,
                    readOnly: true,
                    showCursor: true,
                    cursorColor: _primaryColor,
                    cursorWidth: 4,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.none,
                    style: const TextStyle(
                      color: Color(
                        0xFF17283E,
                      ),
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: loc.loanNricHint.toUpperCase(),
                      hintStyle: const TextStyle(
                        color: Color(
                          0xFF9AA6B4,
                        ),
                        fontSize: 35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  loc.loanNricHintText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(
                      0xFF657386,
                    ),
                    fontSize: 35,
                    fontWeight: FontWeight.w600,
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
            physics: const NeverScrollableScrollPhysics(),
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
                icon: Icons.delete_sweep_rounded,
                onPressed: _clearAll,
              ),

              _buildNumberKey('0'),

              _buildActionKey(
                icon: Icons.backspace_outlined,
                onPressed: _backspace,
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
          child: _buildActions(
            loc,
          ),
        ),

        // ====================================================================
        // CHECKING OVERLAY
        // ====================================================================

        if (_isNavigating)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                0.28,
              ),
              child: Center(
                child: Container(
                  width: 520,
                  padding: const EdgeInsets.all(
                    40,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      32,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 75,
                        height: 75,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          color: _primaryColor,
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      Text(
                        loc.loanAccountLoadingTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(
                            0xFF17283E,
                          ),
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================================================
  // SERVICE BADGE
  // ==========================================================================

  Widget _buildServiceBadge(
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(
          0.10,
        ),
        borderRadius: BorderRadius.circular(
          100,
        ),
        border: Border.all(
          color: _primaryColor.withOpacity(
            0.25,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.badge_rounded,
            color: _primaryColor,
            size: 30,
          ),

          const SizedBox(
            width: 9,
          ),

          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: _primaryColor,
              fontSize: 35,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ACTIONS
  // ==========================================================================

  Widget _buildActions(
    AppLocalizations loc,
  ) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 94,
            child: OutlinedButton.icon(
              onPressed: _isNavigating
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
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(
                  0xFF17283E,
                ),
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(
                    0xFF17283E,
                  ),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
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
            child: ElevatedButton.icon(
              onPressed: _isNavigating ? null : _handleContinue,
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 36,
              ),
              label: Text(
                loc.loanContinue.toUpperCase(),
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
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