import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/services/pegepay_service.dart';
import 'package:frontend_v1/services/pegepay_webview_helper.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:window_manager/window_manager.dart';
import 'package:frontend_v1/pages/resit/bill_receipt_page.dart';

class BilQrPaymentResult {
  final String orderNo;
  final String bankTransactionNo;
  final String billType;
  final String billCode;
  final String accountNumber;
  final double billAmount;
  final double totalAmount;

  const BilQrPaymentResult({
    required this.orderNo,
    required this.bankTransactionNo,
    required this.billType,
    required this.billCode,
    required this.accountNumber,
    required this.billAmount,
    required this.totalAmount,
  });
}

class BilQrPaymentPage extends StatefulWidget {
  /// Display name, for example:
  /// TNB, NUR Power, Sabah Electricity or Sarawak Energy.
  final String billType;

  /// Provider/product code, for example:
  /// TNB, NUR, SESB or SESCO.
  final String billCode;

  final String accountNumber;

  /// Amount that should eventually be paid to the bill provider.
  final double billAmount;

  /// Final amount charged to the customer through PegePay.
  final double totalAmount;

  const BilQrPaymentPage({
    super.key,
    required this.billType,
    required this.billCode,
    required this.accountNumber,
    required this.billAmount,
    required this.totalAmount,
  });

  @override
  State<BilQrPaymentPage> createState() =>
      _BilQrPaymentPageState();
}

class _BilQrPaymentPageState extends State<BilQrPaymentPage> {
  bool _isCreatingOrder = false;
  bool _paymentCompleted = false;

  String? _errorMessage;

  String get _safeBillType {
    final value = widget.billType.trim();

    if (value.isNotEmpty) {
      return value;
    }

    final code = widget.billCode.trim();

    if (code.isNotEmpty) {
      return code;
    }

    return AppLocalizations.of(context)!.billPayment;
  }

  String get _safeBillCode {
    final value = widget.billCode.trim();

    if (value.isEmpty) {
      return '-';
    }

    return value.toUpperCase();
  }

  String get _safeAccountNumber {
    final value = widget.accountNumber.trim();

    if (value.isEmpty) {
      return '-';
    }

    return value;
  }

  String _formatAmount(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  Future<void> _startQrPayment() async {
    if (_isCreatingOrder || _paymentCompleted) {
      return;
    }

    if (widget.totalAmount <= 0) {
      final loc = AppLocalizations.of(context)!;

      _showMessage(
        title: loc.invalidAmount,
        message: loc.paymentAmountMustBeMoreThanZero,
        isError: true,
      );
      return;
    }

    setState(() {
      _isCreatingOrder = true;
      _errorMessage = null;
    });

    bool loadingDialogVisible = false;

    try {
      _showLoadingDialog();
      loadingDialogVisible = true;

      // ========================================
      // TESTING ONLY
      // Always generate a RM0.01 QR code.
      // ========================================

      // final double paymentAmount = widget.totalAmount;

      final double paymentAmount = 0.01;

      final result = await PegePayService.createOrder(
        paymentAmount,
        Config.storeId,
        Config.terminalId,
        Config.shiftId,
      );

      if (!mounted) {
        return;
      }

      if (loadingDialogVisible) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();

        loadingDialogVisible = false;
      }

      final dynamic rawIframeUrl = result['iframe_url'];
      final dynamic rawOrderNo = result['order_no'];

      final String iframeUrl =
          rawIframeUrl?.toString().trim() ?? '';

      final String orderNo =
          rawOrderNo?.toString().trim() ?? '';

      if (iframeUrl.isEmpty || orderNo.isEmpty) {
        throw Exception(
          'PegePay did not return a valid iframe URL or order number.',
        );
      }

      await PegePayWebViewHelper.open(
        iframeUrl: iframeUrl,
        orderNo: orderNo,
        onSuccess: (
          Map<String, dynamic> paymentResult,
        ) async {
          final String successfulOrderNo =
              paymentResult['order_no']
                      ?.toString()
                      .trim() ??
                  orderNo;

          final String bankTransactionNo =
              paymentResult['bank_trx_no']
                      ?.toString()
                      .trim() ??
                  '';

          if (!mounted) {
            return;
          }
        setState(() {
          _paymentCompleted = true;
          _isCreatingOrder = false;
        });

      await _restoreFlutterWindow();

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(
            name: '/receipt',
          ),
          builder: (_) => BillReceiptPage(
            data: BillReceiptData(
              billType: widget.billType,
              billCode: widget.billCode,
              accountNumber: widget.accountNumber,
              billAmount: widget.billAmount,
              totalAmount: widget.totalAmount,
              orderNo: successfulOrderNo,
              bankTransactionNo: bankTransactionNo,
              paymentMethod: 'DuitNow QR',
              paidAt: DateTime.now(),
            ),
          ),
        ),
      );
        },
        onCancel: () async {
          await _restoreFlutterWindow();

          if (!mounted) {
            return;
          }

          setState(() {
            _isCreatingOrder = false;
          });

          final loc = AppLocalizations.of(context)!;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.qrPaymentCancelled),
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[BilQrPaymentPage] Payment error: $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      if (loadingDialogVisible && mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();

        loadingDialogVisible = false;
      }

      if (!mounted) {
        return;
      }

      final loc = AppLocalizations.of(context)!;

      setState(() {
        _isCreatingOrder = false;
        _errorMessage = loc.unableToCreateQr;
      });

      _showMessage(
        title: loc.paymentError,
        message: loc.unableToCreateQr,
        isError: true,
      );
    }
  }

  Future<void> _restoreFlutterWindow() async {
    try {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setFullScreen(true);
    } catch (error) {
      debugPrint(
        '[BilQrPaymentPage] Window restore error: $error',
      );
    }
  }

  void _showLoadingDialog() {
    final loc = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Material(
            color:
                const Color(0xFF071A2F).withOpacity(0.82),
            child: Center(
              child: Container(
                width: 650,
                padding: const EdgeInsets.symmetric(
                  horizontal: 46,
                  vertical: 44,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFFB7CAE8),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.35),
                      blurRadius: 36,
                      spreadRadius: 4,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 138,
                      height: 138,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFE8F2FF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              const Color(0xFF1469E8),
                          width: 5,
                        ),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 88,
                        color: Color(0xFF1469E8),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      loc.preparingQrPayment,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF0359D2),
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 22,
                      ),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFF2F7FD),
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              const Color(0xFFB7CAE8),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${loc.paymentForBill(_safeBillType)}\n'
                        '${_formatAmount(widget.totalAmount)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF294A73),
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const SizedBox(
                      width: 72,
                      height: 72,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 7,
                        color: Color(0xFF1469E8),
                        backgroundColor:
                            Color(0xFFDCE9FA),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      loc.pleaseDoNotClose,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF647187),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
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

  Future<void> _showSuccessDialog({
    required String orderNo,
    required String bankTransactionNo,
  }) async {
    final loc = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 700,
              padding: const EdgeInsets.symmetric(
                horizontal: 45,
                vertical: 42,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFF9FD7B8),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.30),
                    blurRadius: 35,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFE7F8EE),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            const Color(0xFF169B62),
                        width: 5,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF169B62),
                      size: 100,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    loc.paymentSuccessful,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF087443),
                      fontSize: 43,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 26),
                  _buildSuccessDetail(
                    label: loc.billProvider,
                    value: _safeBillType,
                  ),
                  const SizedBox(height: 14),
                  _buildSuccessDetail(
                    label: loc.accountNumber,
                    value: _safeAccountNumber,
                  ),
                  const SizedBox(height: 14),
                  _buildSuccessDetail(
                    label: loc.amount,
                    value: _formatAmount(
                      widget.totalAmount,
                    ),
                    valueColor:
                        const Color(0xFF0359D2),
                  ),
                  const SizedBox(height: 14),
                  _buildSuccessDetail(
                    label: loc.orderNumber,
                    value: orderNo,
                  ),
                  if (bankTransactionNo.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildSuccessDetail(
                      label: loc.bankTransaction,
                      value: bankTransactionNo,
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 88,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);

                        Navigator.pop(
                          context,
                          BilQrPaymentResult(
                            orderNo: orderNo,
                            bankTransactionNo:
                                bankTransactionNo,
                            billType:
                                widget.billType,
                            billCode:
                                widget.billCode,
                            accountNumber:
                                widget.accountNumber,
                            billAmount:
                                widget.billAmount,
                            totalAmount:
                                widget.totalAmount,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 36,
                      ),
                      label: Text(
                        loc.continueButton.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF169B62),
                        foregroundColor: Colors.white,
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
        );
      },
    );
  }

  Widget _buildSuccessDetail({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4E1F5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF647187),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value.trim().isEmpty ? '-' : value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: valueColor ??
                  const Color(0xFF15253A),
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMessage({
    required String title,
    required String message,
    required bool isError,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final Color accentColor = isError
            ? const Color(0xFFC62828)
            : const Color(0xFF1976D2);

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 650,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError
                      ? Icons.error_outline_rounded
                      : Icons.info_outline_rounded,
                  color: accentColor,
                  size: 100,
                ),
                const SizedBox(height: 22),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF435166),
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.ok,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isCreatingOrder,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'lib/images/pnew.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        70,
                        50,
                        70,
                        24,
                      ),
                      child: Column(
                        children: [
                          _buildPaymentCard(),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 26),
                            _buildErrorCard(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      70,
                      18,
                      70,
                      40,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 640,
                          height: 105,
                          child: KioskBackButton(
                            onPressed: () {
                              if (_isCreatingOrder) {
                                return;
                              }

                              Navigator.pop(context);
                            },
                          ),
                        ),

                        const SizedBox(height: 100),

                        Text(
                          Data.copyrightText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF17375E),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        70,
        30,
        70,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 34,
        vertical: 26,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.billPayment.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),

              ],
            ),
          ),
          Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 70,
          ),
        ],
      ),
    );
  }


  Widget _buildPaymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF0097B2),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [

          const SizedBox(height: 10),

          _buildInformationRow(
            icon: Icons.business_rounded,
            label: AppLocalizations.of(context)!.billProvider,
            value: _safeBillType,
          ),
          const Divider(height: 50),
          _buildInformationRow(
            icon: Icons.code_rounded,
            label: AppLocalizations.of(context)!.billCode,
            value: _safeBillCode,
          ),
          const Divider(height: 50),
          _buildInformationRow(
            icon: Icons.numbers_rounded,
            label: AppLocalizations.of(context)!.accountNumber,
            value: _safeAccountNumber,
          ),
          const SizedBox(height: 80),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 26,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFF5FFF6),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: const Color(0xFF66BB6A),
                width: 3,
              ),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.totalPaymentAmount.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF39724A),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 14),
                Text(
                  _formatAmount(
                    widget.totalAmount,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 76,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          _buildQrInstruction(),

          const SizedBox(height: 40),

          if (!_paymentCompleted)
            _buildModernQrPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildInformationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF4FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1976D2),
            size: 48,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF63758A),
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF102A43),
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildQrInstruction() {
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FBF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFB3E2D1),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFE4F8F1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Color(0xFF118762),
              size: 52,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              loc.scanQrInstruction,
              style: const TextStyle(
                color: Color(0xFF155D49),
                fontSize: 25,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFE4F8F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              color: Color(0xFF118762),
              size: 34,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildModernQrPaymentButton() {
    final loc = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      enabled: !_isCreatingOrder,
      label: loc.payWithDuitNowQr,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isCreatingOrder ? null : _startQrPayment,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: double.infinity,
            height: 126,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: _isCreatingOrder
                    ? const [
                        Color(0xFF76B5A1),
                        Color(0xFF589782),
                      ]
                    : const [
                        Color(0xFF12A878),
                        Color(0xFF07845D),
                        Color(0xFF056B4D),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.72),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF087C5A).withOpacity(
                    _isCreatingOrder ? 0.15 : 0.30,
                  ),
                  blurRadius: 22,
                  offset: const Offset(0, 11),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _isCreatingOrder
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            color: Color(0xFF087C5A),
                          ),
                        )
                      : const Icon(
                          Icons.qr_code_2_rounded,
                          color: Color(0xFF087C5A),
                          size: 62,
                        ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCreatingOrder
                            ? loc.preparingQr.toUpperCase()
                            : loc.payWithDuitNowQr.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _isCreatingOrder
                                ? Icons.hourglass_top_rounded
                                : Icons.lock_outline_rounded,
                            color: Colors.white.withOpacity(0.92),
                            size: 21,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isCreatingOrder
                                  ? loc.pleaseDoNotClose
                                  : _formatAmount(widget.totalAmount),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      _isCreatingOrder ? 0.18 : 1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isCreatingOrder
                        ? Icons.hourglass_top_rounded
                        : Icons.arrow_forward_rounded,
                    color: _isCreatingOrder
                        ? Colors.white
                        : const Color(0xFF087C5A),
                    size: 39,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEF9A9A),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFC62828),
            size: 42,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: const TextStyle(
                color: Color(0xFFC62828),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}