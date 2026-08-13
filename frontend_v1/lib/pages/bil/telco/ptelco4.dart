import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/controllers/telco/telco_bill_exception.dart';
import 'package:frontend_v1/controllers/telco/telco_bill_service.dart';
import 'package:frontend_v1/model/pricing/catalog_pricing.dart';
import 'package:frontend_v1/pages/bil/telco/postpaid/p5_telco_bill_result.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

// ============================================================================
// TELCO PAGE 4 - NUMBER INPUT
// ============================================================================
//
// Used by:
// - Telco Bill Payment
// - Mobile PIN
//
// TELCO BILL PAYMENT:
// 1. User enters account / mobile number.
// 2. Calls IIMMPACT bill-presentment API.
// 3. Invalid account -> show localized popup.
// 4. Valid account -> navigate to Telco Bill Result page.
//
// MOBILE PIN:
// - API is NOT connected yet.
// - The entered number and provider information are printed using debugPrint.
// ============================================================================

enum TelcoInputType {
  billPayment,
  mobilePin,
}

class PTELCO4PAGE extends StatefulWidget {
  final String productCode;
  final String providerName;
  final String providerImageUrl;
  final TelcoInputType inputType;

  const PTELCO4PAGE({
    super.key,
    required this.productCode,
    required this.providerName,
    required this.providerImageUrl,
    required this.inputType,
  });

  @override
  State<PTELCO4PAGE> createState() => _PTELCO4PAGEState();
}

class _PTELCO4PAGEState extends State<PTELCO4PAGE> {
  final TextEditingController _controller = TextEditingController();

  String? _activeKey;

  bool _isLoading = false;

  // ==========================================================================
  // THEME
  // ==========================================================================

  bool get _isBillPayment =>
      widget.inputType == TelcoInputType.billPayment;

  Color get _primaryColor {
    return _isBillPayment
        ? const Color(0xFF15946B)
        : const Color(0xFF1769D2);
  }

  Color get _darkColor {
    return _isBillPayment
        ? const Color(0xFF087456)
        : const Color(0xFF0D47A1);
  }

  Color get _lightColor {
    return _isBillPayment
        ? const Color(0xFF32B88A)
        : const Color(0xFF42A5F5);
  }

  IconData get _serviceIcon {
    return _isBillPayment
        ? Icons.receipt_long_rounded
        : Icons.phone_android_rounded;
  }

  // ==========================================================================
  // INPUT
  // ==========================================================================

  int get _maximumLength => 15;

  void _addNumber(String number) {
    if (_isLoading) {
      return;
    }

    if (_controller.text.length >= _maximumLength) {
      return;
    }

    setState(() {
      _controller.text += number;
    });
  }

  void _backspace() {
    if (_isLoading) {
      return;
    }

    if (_controller.text.isEmpty) {
      return;
    }

    setState(() {
      _controller.text = _controller.text.substring(
        0,
        _controller.text.length - 1,
      );
    });
  }

  void _clearAll() {
    if (_isLoading) {
      return;
    }

    setState(() {
      _controller.clear();
    });
  }

  // ==========================================================================
  // ALERT
  // ==========================================================================

  void _showAlert(
    String title,
    String message, {
    IconData icon = Icons.info_outline_rounded,
    Color? color,
  }) {
    final Color effectiveColor = color ?? _primaryColor;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Alert',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 220),
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
                width: 820,
                padding: const EdgeInsets.fromLTRB(
                  50,
                  45,
                  50,
                  40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(
                    color: effectiveColor.withValues(alpha: 0.30),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 35,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ========================================================
                    // ICON
                    // ========================================================

                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: effectiveColor.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        icon,
                        size: 78,
                        color: effectiveColor,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ========================================================
                    // TITLE
                    // ========================================================

                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF17283E),
                        fontSize: 45,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ========================================================
                    // MESSAGE
                    // ========================================================

                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF536272),
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // ========================================================
                    // OK
                    // ========================================================

                    SizedBox(
                      width: double.infinity,
                      height: 85,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 34,
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.telcoOkButton,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: effectiveColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
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

  // ==========================================================================
  // CONTINUE
  // ==========================================================================

  Future<void> _handleContinue() async {
    if (_isLoading) {
      return;
    }

    final loc = AppLocalizations.of(context)!;

    final String number = _controller.text.trim();

    // ========================================================================
    // EMPTY
    // ========================================================================

    if (number.isEmpty) {
      _showAlert(
        loc.telcoInputAlertTitle,
        _isBillPayment
            ? loc.telcoBillNumberRequired
            : loc.mobilePinNumberRequired,
        icon: _serviceIcon,
      );

      return;
    }

    // ========================================================================
    // LOCAL FORMAT VALIDATION
    // ========================================================================

    if (!RegExp(r'^[0-9]{8,15}$').hasMatch(number)) {
      _showAlert(
        loc.telcoInputAlertTitle,
        loc.telcoNumberInvalid,
        icon: Icons.warning_amber_rounded,
        color: Colors.orange,
      );

      return;
    }

    // ========================================================================
    // MOBILE PIN
    // DEBUG ONLY FOR NOW
    // ========================================================================

    if (!_isBillPayment) {
      debugPrint('');
      debugPrint('========================================');
      debugPrint('MOBILE PIN - DEBUG ONLY');
      debugPrint('========================================');
      debugPrint('Provider     : ${widget.providerName}');
      debugPrint('Product Code : ${widget.productCode}');
      debugPrint('Mobile Number: $number');
      debugPrint('========================================');
      debugPrint('');

      return;
    }

    // ========================================================================
    // TELCO BILL PAYMENT
    // ========================================================================

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('');
      debugPrint('========================================');
      debugPrint('TELCO BILL INQUIRY');
      debugPrint('========================================');
      debugPrint('Provider     : ${widget.providerName}');
      debugPrint('Product Code : ${widget.productCode}');
      debugPrint('Account      : $number');
      debugPrint('========================================');
      debugPrint('');

      final result = await TelcoBillService.inquiryBill(
        productCode: widget.productCode,
        accountNumber: number,
      );

      if (!mounted) {
        return;
      }

      // ======================================================================
      // API RETURNED FAILURE
      // ======================================================================

      if (!result.success || result.bill == null) {
        final String apiMessage = result.message.trim().toLowerCase();

        debugPrint('');
        debugPrint('========================================');
        debugPrint('TELCO BILL INQUIRY FAILED');
        debugPrint('========================================');
        debugPrint('Provider : ${widget.providerName}');
        debugPrint('Product  : ${widget.productCode}');
        debugPrint('Account  : $number');
        debugPrint('Message  : ${result.message}');
        debugPrint('========================================');
        debugPrint('');

        // ====================================================================
        // INVALID ACCOUNT
        // ====================================================================

        if (apiMessage.contains('invalid account no') ||
            apiMessage.contains('invalid account')) {
          _showAlert(
            loc.telcoInputAlertTitle,
            loc.telcoInvalidAccount,
            icon: Icons.person_search_rounded,
            color: Colors.orange,
          );

          return;
        }

        // ====================================================================
        // OTHER API FAILURE
        // ====================================================================

        _showAlert(
          loc.telcoInputAlertTitle,
          loc.telcoServiceUnavailable,
          icon: Icons.cloud_off_rounded,
          color: Colors.red,
        );

        return;
      }

      // ======================================================================
      // VALID ACCOUNT
      // ======================================================================

      final bill = result.bill!;

      debugPrint('');
      debugPrint('========================================');
      debugPrint('TELCO BILL INQUIRY SUCCESS');
      debugPrint('========================================');
      debugPrint('Provider     : ${widget.providerName}');
      debugPrint('Product Code : ${bill.productCode}');
      debugPrint('Account      : ${bill.accountNumber}');
      debugPrint('Biller       : ${bill.billerName}');
      debugPrint('Customer     : ${bill.customerName}');
      debugPrint('Outstanding  : ${bill.outstanding}');
      debugPrint('Balance      : ${bill.balance}');
      debugPrint('Due Date     : ${bill.dueDate}');
      debugPrint('Last Updated : ${bill.lastUpdated}');
      debugPrint('========================================');
      debugPrint('');

      // Load the selected telco product's latest pricing from /v2/catalog.
      // If the catalog cannot be loaded, continue without an adjustment.
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
          'Telco catalog pricing loaded for '
          '${widget.productCode}: '
          'discount='
          '${catalogPricing.providerDiscount?.displayValue ?? '-'}, '
          'adjustment='
          '${catalogPricing.priceAdjustment?.displayValue ?? '-'}',
        );
      } on IimmpactCatalogException catch (error) {
        debugPrint(
          'Telco catalog pricing unavailable for '
          '${widget.productCode}: ${error.message}',
        );
      } catch (error, stackTrace) {
        debugPrint(
          'Unexpected telco catalog pricing error for '
          '${widget.productCode}: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }

      if (!mounted) {
        return;
      }

      // ======================================================================
      // PAGE 5
      // ======================================================================

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => P5TelcoBillResultPage(
            bill: bill,
            providerImageUrl: widget.providerImageUrl,
            catalogPricing: catalogPricing,
          ),
        ),
      );
    }

    // ========================================================================
    // TELCO SERVICE ERROR
    // ========================================================================

    on TelcoBillException catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('');
      debugPrint('========================================');
      debugPrint('TELCO BILL SERVICE ERROR');
      debugPrint('========================================');
      debugPrint('Provider : ${widget.providerName}');
      debugPrint('Product  : ${widget.productCode}');
      debugPrint('Account  : $number');
      debugPrint('Error    : ${error.message}');
      debugPrint('========================================');
      debugPrint('');

      _showAlert(
        loc.telcoInputAlertTitle,
        loc.telcoServiceUnavailable,
        icon: Icons.cloud_off_rounded,
        color: Colors.red,
      );
    }

    // ========================================================================
    // UNKNOWN ERROR
    // ========================================================================

    catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

      debugPrint('');
      debugPrint('========================================');
      debugPrint('UNEXPECTED TELCO BILL ERROR');
      debugPrint('========================================');
      debugPrint('Provider : ${widget.providerName}');
      debugPrint('Product  : ${widget.productCode}');
      debugPrint('Account  : $number');
      debugPrint('Error    : $error');
      debugPrint('========================================');
      debugPrint('');

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showAlert(
        loc.telcoInputAlertTitle,
        loc.telcoServiceUnavailable,
        icon: Icons.error_outline_rounded,
        color: Colors.red,
      );
    }

    // ========================================================================
    // FINISH
    // ========================================================================

    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================================================
  // NUMBER KEY
  // ==========================================================================

  Widget _buildNumberKey(String value) {
    final bool pressed = _activeKey == value;

    return Listener(
      onPointerDown: (_) {
        if (_isLoading) {
          return;
        }

        setState(() {
          _activeKey = value;
        });
      },
      onPointerUp: (_) {
        if (_isLoading) {
          return;
        }

        setState(() {
          _activeKey = null;
        });

        _addNumber(value);
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
        duration: const Duration(milliseconds: 110),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          height: 125,
          decoration: BoxDecoration(
            color: pressed
                ? _primaryColor.withValues(alpha: 0.15)
                : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: pressed
                  ? _primaryColor
                  : const Color(0xFFB8C7D6),
              width: pressed ? 4 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: pressed ? 0.08 : 0.15,
                ),
                blurRadius: pressed ? 6 : 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: pressed
                    ? _darkColor
                    : const Color(0xFF15253A),
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
        onTap: _isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 125,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _lightColor,
                _darkColor,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _darkColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
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
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  // ==========================================================================
  // UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================

          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),

          // ==================================================================
          // HEADER
          // ==================================================================

          Positioned(
            top: 80,
            left: 65,
            right: 65,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: _primaryColor.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _serviceIcon,
                        color: _primaryColor,
                        size: 30,
                      ),

                      const SizedBox(width: 9),

                      Text(
                        (_isBillPayment
                                ? loc.telcoBillInputService
                                : loc.mobilePinInputService)
                            .toUpperCase(),
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  widget.providerName.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _darkColor,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================================
          // PROVIDER + INPUT PANEL
          // ==================================================================

          Positioned(
            top: 280,
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
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(
                  color: _primaryColor.withValues(alpha: 0.25),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF19375C)
                        .withValues(alpha: 0.14),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ==========================================================
                  // PROVIDER
                  // ==========================================================

                  Row(
                    children: [
                      Container(
                        width: 130,
                        height: 100,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _primaryColor.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Image.network(
                          widget.providerImageUrl,
                          fit: BoxFit.contain,

                          loadingBuilder: (
                            context,
                            child,
                            loadingProgress,
                          ) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: _primaryColor,
                              ),
                            );
                          },

                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Icon(
                              Icons.sim_card_rounded,
                              size: 55,
                              color: _primaryColor,
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.telcoSelectedProviderLabel.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF758399),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              widget.providerName.toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF17283E),
                                fontSize: 33,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ==========================================================
                  // NUMBER INPUT
                  // ==========================================================

                  Container(
                    height: 105,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFD),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: _primaryColor,
                        width: 3,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      readOnly: true,
                      showCursor: true,
                      cursorColor: _primaryColor,
                      cursorWidth: 4,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.none,
                      style: const TextStyle(
                        color: Color(0xFF17283E),
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: (_isBillPayment
                                ? loc.telcoBillNumberHint
                                : loc.mobilePinNumberHint)
                            .toUpperCase(),
                        hintStyle: const TextStyle(
                          color: Color(0xFF9AA6B4),
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==========================================================
                  // INSTRUCTION
                  // ==========================================================

                  Text(
                    _isBillPayment
                        ? loc.telcoBillInputInstruction
                        : loc.mobilePinInputInstruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF657386),
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      height: 1.30,
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),

          // ==================================================================
          // NUMERIC KEYPAD
          // ==================================================================

          Positioned(
            top: 780,
            left: 80,
            right: 80,
            child: AbsorbPointer(
              absorbing: _isLoading,
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

                  // ==========================================================
                  // CLEAR
                  // ==========================================================

                  _buildActionKey(
                    icon: Icons.delete_sweep_rounded,
                    onPressed: _clearAll,
                  ),

                  _buildNumberKey('0'),

                  // ==========================================================
                  // BACKSPACE
                  // ==========================================================

                  _buildActionKey(
                    icon: Icons.backspace_outlined,
                    onPressed: _backspace,
                  ),
                ],
              ),
            ),
          ),

          // ==================================================================
          // BACK + CONTINUE
          // ==================================================================

          Positioned(
            bottom: 180,
            left: 80,
            right: 80,
            child: Row(
              children: [
                // ============================================================
                // BACK
                // ============================================================

                Expanded(
                  child: SizedBox(
                    height: 108,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 40,
                      ),
                      label: Text(
                        loc.buttonBack,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.95),
                        foregroundColor: const Color(0xFF26364A),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 2.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 22),

                // ============================================================
                // CONTINUE
                // ============================================================

                Expanded(
                  child: SizedBox(
                    height: 108,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16813B),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.green.shade300,
                        elevation: 7,
                        shadowColor: const Color(0x5516813B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    loc.buttonContinue,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 40,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==================================================================
          // FOOTER
          // ==================================================================

          Positioned(
            bottom: 45,
            left: 0,
            right: 0,
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

          // ==================================================================
          // LOADING OVERLAY
          // ==================================================================

          if (_isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: const Color(0xFF07182E)
                      .withValues(alpha: 0.68),
                  child: Center(
                    child: Container(
                      width: 650,
                      padding: const EdgeInsets.all(45),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 40,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              strokeWidth: 8,
                              color: _primaryColor,
                            ),
                          ),

                          const SizedBox(height: 32),

                          Text(
                            loc.telcoProcessingTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF17283E),
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Text(
                            loc.telcoProcessingMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF657386),
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              height: 1.30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
