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
  bool _isProcessingReceipt = false;
  bool _paymentCompleted = false;

  String? _errorMessage;

  bool get _isBusy =>
      _isCreatingOrder || _isProcessingReceipt;

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
    if (_isBusy || _paymentCompleted) {
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
            _isProcessingReceipt = true;
          });

          await _restoreFlutterWindow();

          if (!mounted) {
            return;
          }

          _showReceiptProcessingDialog(
            orderNo: successfulOrderNo,
          );

          await Future<void>.delayed(
            const Duration(milliseconds: 1600),
          );

          if (!mounted) {
            return;
          }

          Navigator.of(
            context,
            rootNavigator: true,
          ).pop();

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
                  bankTransactionNo:
                      bankTransactionNo,
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
            _isProcessingReceipt = false;
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
        _isProcessingReceipt = false;
        _errorMessage = loc.unableToCreateQr;
      });

      _showMessage(
        title: loc.paymentError,
        message: loc.unableToCreateQr,
        isError: true,
      );
    }
  }


  void _showReceiptProcessingDialog({
    required String orderNo,
  }) {
    final loc = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Material(
            color: const Color(0xFF061425).withOpacity(0.88),
            child: Center(
              child: Container(
                width: 700,
                padding: const EdgeInsets.fromLTRB(
                  48,
                  46,
                  48,
                  42,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: const Color(0xFFA7DCC4),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.38),
                      blurRadius: 42,
                      spreadRadius: 5,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 148,
                          height: 148,
                          child: CircularProgressIndicator(
                            strokeWidth: 8,
                            color: Color(0xFF118762),
                            backgroundColor:
                                Color(0xFFDDF2E9),
                          ),
                        ),
                        Container(
                          width: 108,
                          height: 108,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F8F1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Color(0xFF118762),
                            size: 66,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      loc.billReceiptProcessingTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF0B6A4D),
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      loc.billReceiptProcessingMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF5B6B7B),
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FC),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFD4E1ED),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _safeBillType,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF17324D),
                              fontSize: 29,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            _formatAmount(widget.totalAmount),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF0D6D4D),
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            orderNo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF118762),
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            loc.billReceiptProcessingLocked,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF407565),
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
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
      canPop: !_isBusy,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/images/pnew.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.04),
                      Colors.white.withOpacity(0.22),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 10,
                        radius: const Radius.circular(20),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            62,
                            34,
                            62,
                            26,
                          ),
                          child: Column(
                            children: [
                              _buildBillInformationCard(),
                              const SizedBox(height: 26),
                              _buildTotalPaymentCard(),
                              const SizedBox(height: 26),
                              _buildPaymentActionCard(),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 22),
                                _buildErrorCard(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      70,
                      14,
                      70,
                      34,
                    ),
                    child: Column(
                      children: [
                        IgnorePointer(
                          ignoring: _isBusy,
                          child: AnimatedOpacity(
                            duration:
                                const Duration(milliseconds: 180),
                            opacity: _isBusy ? 0.45 : 1,
                            child: SizedBox(
                              width: 620,
                              height: 98,
                              child: KioskBackButton(
                                onPressed: () {
                                  if (_isBusy) {
                                    return;
                                  }

                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          Data.copyrightText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF17375E),
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isBusy)
              const Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: ColoredBox(
                    color: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader() {
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(62, 28, 62, 0),
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0E3B73),
            Color(0xFF1769B8),
            Color(0xFF45A9F2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              loc.billPayment.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 39,
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildBillInformationCard() {
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        28,
        28,
        28,
        30,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.99),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: const Color(0xFFD2DFEC),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17375E).withOpacity(0.13),
            blurRadius: 28,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(
            icon: Icons.description_rounded,
            title: loc.billInformationTitle,
            accentColor: const Color(0xFF1976D2),
            iconBackground: const Color(0xFFE7F1FC),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF123E70),
                  Color(0xFF1769B8),
                  Color(0xFF3C9FEA),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.24),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.billProvider,
                        style: TextStyle(
                          color:
                              Colors.white.withOpacity(0.78),
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _safeBillType,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          height: 1.08,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.code_rounded,
                  label: loc.billCode,
                  value: _safeBillCode,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.numbers_rounded,
                  label: loc.accountNumber,
                  value: _safeAccountNumber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPaymentCard() {
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        30,
        28,
        30,
        30,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FCF8),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: const Color(0xFF7BCC9D),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF118762).withOpacity(0.11),
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardTitle(
            icon: Icons.account_balance_wallet_rounded,
            title: loc.totalPaymentAmount,
            accentColor: const Color(0xFF118762),
            iconBackground: const Color(0xFFE1F5EB),
            centered: true,
          ),
          const SizedBox(height: 22),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatAmount(widget.totalAmount),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF125B2D),
                fontSize: 86,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentActionCard() {
    final loc = AppLocalizations.of(context)!;
    final bool disabled =
        _isBusy || _paymentCompleted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        28,
        28,
        28,
        30,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.99),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: const Color(0xFFD2DFEC),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17375E).withOpacity(0.13),
            blurRadius: 28,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardTitle(
            icon: Icons.qr_code_2_rounded,
            title: loc.paymentSectionTitle,
            accentColor: const Color(0xFF1976D2),
            iconBackground: const Color(0xFFE7F1FC),
            centered: true,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF6FAFD),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: const Color(0xFFD7E3EE),
                width: 1.8,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF16A277),
                        Color(0xFF087C5A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF087C5A)
                            .withOpacity(0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 70,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  loc.scanQrInstruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF35536A),
                    fontSize: 25,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 1.5,
            width: double.infinity,
            color: const Color(0xFFDDE6EF),
          ),
          const SizedBox(height: 24),
          Semantics(
            button: true,
            enabled: !disabled,
            label: loc.payWithDuitNowQr,
            child: IgnorePointer(
              ignoring: disabled,
              child: AnimatedOpacity(
                duration:
                    const Duration(milliseconds: 180),
                opacity: disabled ? 0.55 : 1,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: disabled
                        ? null
                        : _startQrPayment,
                    borderRadius:
                        BorderRadius.circular(28),
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 220),
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
                          colors: disabled
                              ? const [
                                  Color(0xFF79B5A2),
                                  Color(0xFF5E9A86),
                                ]
                              : const [
                                  Color(0xFF13A979),
                                  Color(0xFF07855E),
                                  Color(0xFF056B4D),
                                ],
                        ),
                        borderRadius:
                            BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF087C5A)
                                .withOpacity(
                              disabled ? 0.12 : 0.30,
                            ),
                            blurRadius: 24,
                            offset:
                                const Offset(0, 12),
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
                              borderRadius:
                                  BorderRadius.circular(24),
                            ),
                            child: _isBusy
                                ? const Padding(
                                    padding:
                                        EdgeInsets.all(22),
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 4,
                                      color:
                                          Color(0xFF087C5A),
                                    ),
                                  )
                                : const Icon(
                                    Icons.qr_code_2_rounded,
                                    color:
                                        Color(0xFF087C5A),
                                    size: 62,
                                  ),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isBusy
                                      ? loc.preparingQr
                                          .toUpperCase()
                                      : loc.payWithDuitNowQr
                                          .toUpperCase(),
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style:
                                      const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight:
                                        FontWeight.w900,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Row(
                                  children: [
                                    Icon(
                                      _isBusy
                                          ? Icons
                                              .hourglass_top_rounded
                                          : Icons
                                              .lock_outline_rounded,
                                      color: Colors.white
                                          .withOpacity(0.94),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _isBusy
                                            ? loc
                                                .pleaseDoNotClose
                                            : _formatAmount(
                                                widget
                                                    .totalAmount,
                                              ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.94),
                                          fontSize: 23,
                                          fontWeight:
                                              FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                disabled ? 0.20 : 1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isBusy
                                  ? Icons
                                      .hourglass_top_rounded
                                  : Icons
                                      .arrow_forward_rounded,
                              color: disabled
                                  ? Colors.white
                                  : const Color(
                                      0xFF087C5A,
                                    ),
                              size: 37,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildCardTitle({
    required IconData icon,
    required String title,
    required Color accentColor,
    required Color iconBackground,
    bool centered = false,
  }) {
    final row = Row(
      mainAxisSize:
          centered ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 34,
          ),
        ),
        const SizedBox(width: 15),
        Flexible(
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF193A5A),
              fontSize: 29,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );

    if (centered) {
      return Center(child: row);
    }

    return row;
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 150,
      ),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFD9E3EE),
          width: 1.7,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FC),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1976D2),
              size: 33,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7B8D),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF182D43),
              fontSize: 30,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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