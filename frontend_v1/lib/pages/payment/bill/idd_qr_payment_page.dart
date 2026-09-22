import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_payment_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_refid_service.dart';

import 'package:frontend_v1/services/pegepay/pegepay_service.dart';
import 'package:frontend_v1/services/pegepay/pegepay_webview_helper.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:window_manager/window_manager.dart';
import 'package:frontend_v1/pages/resit/bill/idd_receipt_page.dart';

// ============================================================================
// IDD QR PAYMENT RESULT
//
// We return this result after IIMMPACT finishes successfully.
//
// Later we can connect this directly to a dedicated IDD receipt page.
// ============================================================================

class IddQrPaymentResult {
  final String providerName;
  final String productCode;

  final String optionCode;
  final String optionName;

  final double baseAmount;
  final double serviceAdjustment;
  final double totalAmount;

  final String processingTime;

  final String refId;
  final String orderNo;
  final String bankTransactionNo;

  final String providerStatus;

  final String serialNumber;
  final String pin;
  final String expiry;
  final String voucherLink;
  final String note;

  final DateTime paidAt;

  const IddQrPaymentResult({
    required this.providerName,
    required this.productCode,
    required this.optionCode,
    required this.optionName,
    required this.baseAmount,
    required this.serviceAdjustment,
    required this.totalAmount,
    required this.processingTime,
    required this.refId,
    required this.orderNo,
    required this.bankTransactionNo,
    required this.providerStatus,
    required this.serialNumber,
    required this.pin,
    required this.expiry,
    required this.voucherLink,
    required this.note,
    required this.paidAt,
  });
}

// ============================================================================
// IDD QR PAYMENT PAGE
//
// IMPORTANT:
//
// Current catalog:
//
// RI:
// fields = amount only
// fulfillment = amount only
//
// UT:
// fields = amount only
// fulfillment = amount only
//
// Therefore:
//
// account = ""
// extras  = {}
//
// DO NOT request phone/account number unless a future catalog product
// actually contains role == account / fulfillment.account.
// ============================================================================

class IddQrPaymentPage extends StatefulWidget {
  final String providerName;

  final String productCode;

  final String optionCode;
  final String optionName;

  final double baseAmount;

  final double serviceAdjustment;

  final double totalAmount;

  final String processingTime;

  const IddQrPaymentPage({
    super.key,
    required this.providerName,
    required this.productCode,
    required this.optionCode,
    required this.optionName,
    required this.baseAmount,
    required this.serviceAdjustment,
    required this.totalAmount,
    required this.processingTime,
  });

  @override
  State<IddQrPaymentPage> createState() =>
      _IddQrPaymentPageState();
}

// ============================================================================
// STATE
// ============================================================================

class _IddQrPaymentPageState
    extends State<IddQrPaymentPage> {
  static const Color _primary =
      Color(0xFF1469E8);

  static const Color _dark =
      Color(0xFF064CAC);

  static const Color _green =
      Color(0xFF087C5A);

  bool _isCreatingOrder = false;

  bool _isProcessingReceipt = false;

  bool _paymentCompleted = false;

  String? _errorMessage;

  String? _transactionRefId;

  // ==========================================================================
  // BUSY
  // ==========================================================================

  bool get _isBusy =>
      _isCreatingOrder ||
      _isProcessingReceipt;

  // ==========================================================================
  // REF ID
  // ==========================================================================

  String get _currentRefId {
    final String? existing =
        _transactionRefId;

    if (existing != null &&
        existing.isNotEmpty) {
      return existing;
    }

    final String generated =
        IimmpactRefIdService.generate();

    _transactionRefId =
        generated;

    return generated;
  }

  // ==========================================================================
  // FORMAT MONEY
  // ==========================================================================

  String _formatAmount(
    double amount,
  ) {
    return 'RM '
        '${amount.toStringAsFixed(2)}';
  }

  // ==========================================================================
  // IIMMPACT ACCOUNT
  //
  // Current IDD catalog does NOT define:
  //
  // role == account
  // fulfillment.account
  //
  // Therefore it must remain empty.
  // ==========================================================================

  String get _iimmpactAccount => '';

  // ==========================================================================
  // EXTRAS
  //
  // Current RI / UT fulfillment does not define extras.
  // ==========================================================================

  Map<String, dynamic>
      get _iimmpactExtras {
    return const <String, dynamic>{};
  }

  // ==========================================================================
  // START QR PAYMENT
  // ==========================================================================

  Future<void> _startQrPayment() async {
    if (_isBusy ||
        _paymentCompleted) {
      return;
    }

    final loc =
        AppLocalizations.of(context)!;

    // ========================================================================
    // VALIDATE AMOUNT
    // ========================================================================

    if (widget.baseAmount <= 0 ||
        widget.totalAmount <= 0) {
      await _showMessage(
        title:
            loc.invalidAmount,
        message:
            loc.paymentAmountMustBeMoreThanZero,
        isError:
            true,
      );

      return;
    }

    // ========================================================================
    // VALIDATE PRODUCT
    // ========================================================================

    if (widget.productCode
        .trim()
        .isEmpty) {
      await _showMessage(
        title:
            loc.iddPaymentInvalidProductTitle,
        message:
            loc.iddPaymentInvalidProductMessage,
        isError:
            true,
      );

      return;
    }

    // ========================================================================
    // VALIDATE OPTION
    // ========================================================================

    if (widget.optionCode
        .trim()
        .isEmpty) {
      await _showMessage(
        title:
            loc.iddPaymentInvalidAmountTitle,
        message:
            loc.iddPaymentInvalidAmountMessage,
        isError:
            true,
      );

      return;
    }

    final String refId =
        _currentRefId;

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'NEW IDD QR PAYMENT',
    );
    debugPrint(
      '========================================',
    );
    debugPrint(
      'RefId       : $refId',
    );
    debugPrint(
      'Provider    : ${widget.providerName}',
    );
    debugPrint(
      'Product     : ${widget.productCode}',
    );
    debugPrint(
      'Account     : "$_iimmpactAccount"',
    );
    debugPrint(
      'Option Code : ${widget.optionCode}',
    );
    debugPrint(
      'Option Name : ${widget.optionName}',
    );
    debugPrint(
      'Base Amount : ${widget.baseAmount}',
    );
    debugPrint(
      'Adjustment  : ${widget.serviceAdjustment}',
    );
    debugPrint(
      'Total       : ${widget.totalAmount}',
    );
    debugPrint(
      'Extras      : $_iimmpactExtras',
    );
    debugPrint(
      '========================================',
    );
    debugPrint('');

    setState(() {
      _isCreatingOrder = true;
      _errorMessage = null;
    });

    bool loadingDialogVisible =
        false;

    try {
      // ======================================================================
      // SHOW PREPARING
      // ======================================================================

      _showLoadingDialog();

      loadingDialogVisible = true;

      // ======================================================================
      // PEGE PAY AMOUNT
      //
      // TESTING:
      //
      // Keep RM 0.05
      //
      // PRODUCTION:
      //
      // final double paymentAmount =
      //     widget.totalAmount;
      // ======================================================================

      final double paymentAmount =
          0.05;

      final Map<String, dynamic> result =
          await PegePayService.createOrder(
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

        loadingDialogVisible =
            false;
      }

      // ======================================================================
      // PEGE PAY RESULT
      // ======================================================================

      final String iframeUrl =
          result['iframe_url']
                  ?.toString()
                  .trim() ??
              '';

      final String orderNo =
          result['order_no']
                  ?.toString()
                  .trim() ??
              '';

      if (iframeUrl.isEmpty ||
          orderNo.isEmpty) {
        throw Exception(
          'PegePay did not return a valid '
          'iframe URL or order number.',
        );
      }

      // ======================================================================
      // OPEN PEGE PAY
      // ======================================================================

      await PegePayWebViewHelper.open(
        iframeUrl:
            iframeUrl,

        orderNo:
            orderNo,

        // ====================================================================
        // PAYMENT SUCCESS
        // ====================================================================

        onSuccess:
            (
          Map<String, dynamic>
              paymentResult,
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

          // Customer has already paid.
          // Never create another QR after this point.

          setState(() {
            _paymentCompleted =
                true;

            _isCreatingOrder =
                false;

            _isProcessingReceipt =
                true;
          });

          // ==================================================================
          // RESTORE FLUTTER
          // ==================================================================

          await _restoreFlutterWindow();

          if (!mounted) {
            return;
          }

          // ==================================================================
          // PROCESSING DIALOG
          // ==================================================================

          _showReceiptProcessingDialog();

          bool processingDialogVisible =
              true;

          IimmpactPaymentResult?
              iimmpactResult;

          try {
            // ================================================================
            // IIMMPACT
            //
            // RI / UT:
            //
            // product = RI / UT
            // account = ""
            // amount  = selected option price
            // extras  = {}
            // ================================================================

            iimmpactResult =
                await IimmpactPaymentService
                    .waitForFinalStatus(
              refId:
                  _currentRefId,

              product:
                  widget.productCode,

              account:
                  _iimmpactAccount,

              amount:
                  widget.baseAmount,

              remarks:
                  successfulOrderNo,

              extras:
                  _iimmpactExtras,

              // ================================================================
              // IDD does not use account for the current RI / UT catalog setup.
              // Allow empty account in the shared IIMMPACT service.
              // ================================================================
              accountRequired:
                  false,

              interval:
                  const Duration(
                seconds: 6,
              ),

              maxAttempts:
                  10,
            );

            // ================================================================
            // FAILED
            // ================================================================

            if (iimmpactResult.isFailed) {
              throw IimmpactPaymentException(
                iimmpactResult
                        .remarks
                        .isNotEmpty
                    ? iimmpactResult
                        .remarks
                    : loc
                        .iddPaymentProviderRejected,

                result:
                    iimmpactResult,
              );
            }

            // ================================================================
            // REFUND
            // ================================================================

            if (iimmpactResult.isRefund) {
              throw IimmpactPaymentException(
                loc
                    .iddPaymentProviderRefunded,

                result:
                    iimmpactResult,
              );
            }

            // ================================================================
            // FINAL SUCCESS REQUIRED
            // ================================================================

            if (!iimmpactResult
                .isSuccessful) {
              throw IimmpactPaymentException(
                '${loc.iddPaymentStillProcessing}\n'
                '${loc.iddPaymentReference}: '
                '$_currentRefId',

                result:
                    iimmpactResult,
              );
            }
          } catch (
            error,
            stackTrace
          ) {
            debugPrint(
              '[IddQrPaymentPage] '
              'IIMMPACT error: $error',
            );

            debugPrintStack(
              stackTrace:
                  stackTrace,
            );

            if (processingDialogVisible &&
                mounted) {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop();

              processingDialogVisible =
                  false;
            }

            if (!mounted) {
              return;
            }

            setState(() {
              _isProcessingReceipt =
                  false;
            });

            final String message =
                error is
                        IimmpactPaymentException
                    ? error.message
                    : error.toString();

            await _showMessage(
              title:
                  loc
                      .iddPaymentProviderErrorTitle,

              message:
                  '$message\n\n'
                  '${loc.iddPaymentAlreadyReceivedWarning}',

              isError:
                  true,
            );

            return;
          }

          // ==================================================================
          // CLOSE PROCESSING DIALOG
          // ==================================================================

          if (processingDialogVisible &&
              mounted) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pop();

            processingDialogVisible =
                false;
          }

          if (!mounted ||
              iimmpactResult == null) {
            return;
          }

          final IimmpactPaymentResult finalResult =
              iimmpactResult;

            // ==================================================================
            // OPEN IDD RECEIPT
            // ==================================================================

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(
                  name: '/receipt',
                ),
                builder: (_) =>
                    IddReceiptPage(
                  data:
                      IddReceiptData(
                    providerName:
                        widget.providerName,

                    productCode:
                        widget.productCode,

                    optionCode:
                        widget.optionCode,

                    optionName:
                        widget.optionName,

                    baseAmount:
                        widget.baseAmount,

                    serviceAdjustment:
                        widget.serviceAdjustment,

                    totalAmount:
                        widget.totalAmount,

                    processingTime:
                        widget.processingTime,

                    refId:
                        finalResult.refId.isNotEmpty
                            ? finalResult.refId
                            : _currentRefId,

                    orderNo:
                        successfulOrderNo,

                    bankTransactionNo:
                        bankTransactionNo,

                    paymentMethod:
                        'DuitNow QR',

                    paidAt:
                        DateTime.now(),

                    providerStatus:
                        finalResult.status,

                    serialNumber:
                        finalResult.serialNumber,

                    pin:
                        finalResult.pin,

                    expiry:
                        finalResult.expiry,

                    voucherLink:
                        finalResult.voucherLink,

                    note:
                        finalResult.note,
                  ),
                ),
              ),
            );
        },

        // ====================================================================
        // CANCEL
        // ====================================================================

        onCancel:
            () async {
          await _restoreFlutterWindow();

          if (!mounted) {
            return;
          }

          setState(() {
            _isCreatingOrder =
                false;

            _isProcessingReceipt =
                false;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                loc.qrPaymentCancelled,
              ),
              duration:
                  const Duration(
                seconds: 3,
              ),
            ),
          );
        },
      );
    } catch (
      error,
      stackTrace
    ) {
      debugPrint(
        '[IddQrPaymentPage] QR error: '
        '$error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      if (loadingDialogVisible &&
          mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();

        loadingDialogVisible =
            false;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isCreatingOrder =
            false;

        _isProcessingReceipt =
            false;

        _errorMessage =
            loc.unableToCreateQr;
      });

      await _showMessage(
        title:
            loc.paymentError,

        message:
            loc.unableToCreateQr,

        isError:
            true,
      );
    }
  }

  // ==========================================================================
  // RESTORE WINDOW
  // ==========================================================================

  Future<void> _restoreFlutterWindow() async {
    try {
      await windowManager.show();

      await windowManager.focus();

      await windowManager.setFullScreen(
        true,
      );
    } catch (error) {
      debugPrint(
        '[IddQrPaymentPage] '
        'Window restore error: $error',
      );
    }
  }

  // ==========================================================================
  // PREPARING QR DIALOG
  // ==========================================================================

  void _showLoadingDialog() {
    final loc =
        AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Material(
            color:
                const Color(
              0xFF071A2F,
            ).withOpacity(
              0.82,
            ),
            child: Center(
              child: Container(
                width: 650,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 46,
                  vertical: 44,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    32,
                  ),
                  border: Border.all(
                    color:
                        const Color(
                      0xFFBDD6F7,
                    ),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Container(
                      width: 138,
                      height: 138,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFEAF3FF,
                        ),
                        shape:
                            BoxShape.circle,
                        border: Border.all(
                          color:
                              _primary,
                          width: 5,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .qr_code_2_rounded,
                        size: 88,
                        color:
                            _primary,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    Text(
                      loc
                          .iddPreparingQrPayment,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            _dark,
                        fontSize: 42,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    Text(
                      '${widget.providerName}\n'
                      '${widget.optionName}\n'
                      '${_formatAmount(widget.totalAmount)}',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF294A73,
                        ),
                        fontSize: 27,
                        height: 1.4,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    const SizedBox(
                      width: 72,
                      height: 72,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 7,
                        color:
                            _primary,
                        backgroundColor:
                            Color(
                          0xFFDDEBFC,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      loc.pleaseDoNotClose,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF647187,
                        ),
                        fontSize: 22,
                        fontWeight:
                            FontWeight.w700,
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
  // PROCESSING IIMMPACT DIALOG
  // ==========================================================================

  void _showReceiptProcessingDialog() {
    final loc =
        AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Material(
            color:
                const Color(
              0xFF061425,
            ).withOpacity(
              0.88,
            ),
            child: Center(
              child: Container(
                width: 700,
                padding:
                    const EdgeInsets.fromLTRB(
                  48,
                  46,
                  48,
                  42,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    36,
                  ),
                  border: Border.all(
                    color:
                        const Color(
                      0xFFBDD6F7,
                    ),
                    width: 3,
                  ),
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 148,
                      height: 148,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 8,
                        color:
                            _primary,
                        backgroundColor:
                            Color(
                          0xFFDDEBFC,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    Text(
                      loc.iddProcessingTitle,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            _dark,
                        fontSize: 42,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Text(
                      loc.iddProcessingMessage,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF5B6B7B,
                        ),
                        fontSize: 25,
                        height: 1.4,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    Text(
                      widget.providerName,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF17324D,
                        ),
                        fontSize: 29,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      widget.optionName,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF607086,
                        ),
                        fontSize: 25,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      _formatAmount(
                        widget.totalAmount,
                      ),
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            _dark,
                        fontSize: 40,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    Text(
                      loc.iddProcessingLocked,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF5D6D84,
                        ),
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w800,
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
  // MESSAGE DIALOG
  // ==========================================================================

  Future<void> _showMessage({
    required String title,
    required String message,
    required bool isError,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (
        dialogContext,
      ) {
        final Color accent =
            isError
                ? const Color(
                    0xFFC62828,
                  )
                : _primary;

        return Dialog(
          backgroundColor:
              Colors.transparent,
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
                30,
              ),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  isError
                      ? Icons
                          .error_outline_rounded
                      : Icons
                          .info_outline_rounded,
                  color:
                      accent,
                  size: 100,
                ),

                const SizedBox(
                  height: 22,
                ),

                Text(
                  title,
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color:
                        accent,
                    fontSize: 42,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  message,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF435166,
                    ),
                    fontSize: 25,
                    height: 1.45,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 80,
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
                          accent,
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .ok,
                      style:
                          const TextStyle(
                        fontSize: 28,
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
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    return PopScope(
      canPop:
          !_isBusy,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration:
                    BoxDecoration(
                  image:
                      DecorationImage(
                    image:
                        AssetImage(
                      'lib/images/pnew.png',
                    ),
                    fit:
                        BoxFit.cover,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(
                    loc,
                  ),

                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(
                        right: 18,
                      ),
                      child: Scrollbar(
                        thumbVisibility:
                            true,
                        trackVisibility:
                            true,
                        thickness: 10,
                        radius:
                            const Radius.circular(
                          20,
                        ),
                        child:
                            SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(
                            62,
                            34,
                            62,
                            26,
                          ),
                          child: Column(
                            children: [
                              _buildInformationCard(
                                loc,
                              ),

                              const SizedBox(
                                height: 26,
                              ),

                              _buildTotalPaymentCard(
                                loc,
                              ),

                              const SizedBox(
                                height: 26,
                              ),

                              _buildPaymentActionCard(
                                loc,
                              ),

                              if (_errorMessage !=
                                  null) ...[
                                const SizedBox(
                                  height: 22,
                                ),

                                _buildErrorCard(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      70,
                      14,
                      70,
                      34,
                    ),
                    child: Column(
                      children: [
                        IgnorePointer(
                          ignoring:
                              _isBusy,
                          child:
                              AnimatedOpacity(
                            duration:
                                const Duration(
                              milliseconds:
                                  180,
                            ),
                            opacity:
                                _isBusy
                                    ? 0.45
                                    : 1,
                            child: SizedBox(
                              width: 620,
                              height: 98,
                              child:
                                  KioskBackButton(
                                onPressed: () {
                                  if (_isBusy) {
                                    return;
                                  }

                                  Navigator.pop(
                                    context,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        Text(
                          Data.copyrightText,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF17375E,
                            ),
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w800,
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
                    color:
                        Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader(
    AppLocalizations loc,
  ) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        62,
        28,
        62,
        0,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 22,
      ),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          30,
        ),
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF064CAC),
            Color(0xFF1469E8),
            Color(0xFF41A0F2),
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons
                .phone_in_talk_rounded,
            color:
                Colors.white,
            size: 54,
          ),

          const SizedBox(
            width: 20,
          ),

          Expanded(
            child: Text(
              loc.iddPaymentTitle
                  .toUpperCase(),
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 40,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(
            width: 20,
          ),

          const Icon(
            Icons.shield_outlined,
            color:
                Colors.white,
            size: 50,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INFORMATION
  // ==========================================================================

  Widget _buildInformationCard(
    AppLocalizations loc,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        28,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.99,
        ),
        borderRadius:
            BorderRadius.circular(
          34,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFC9DCF5,
          ),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          _buildCardTitle(
            icon:
                Icons
                    .phone_in_talk_rounded,
            title:
                loc.iddPaymentDetails,
            accent:
                _primary,
            background:
                const Color(
              0xFFEAF3FF,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets.all(
              24,
            ),
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(
                    0xFF064CAC,
                  ),
                  Color(
                    0xFF1469E8,
                  ),
                  Color(
                    0xFF41A0F2,
                  ),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                28,
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.providerName,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 37,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  widget.optionName,
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color:
                        Colors.white
                            .withOpacity(
                      0.85,
                    ),
                    fontSize: 27,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          _buildInfoTile(
            icon:
                Icons
                    .payments_rounded,
            label:
                loc.iddSelectedAmount,
            value:
                _formatAmount(
              widget.baseAmount,
            ),
          ),

          if (widget.serviceAdjustment
                  .abs() >=
              0.005) ...[
            const SizedBox(
              height: 16,
            ),

            _buildInfoTile(
              icon:
                  Icons
                      .tune_rounded,
              label:
                  loc
                      .iddServiceAdjustmentLabel,
              value:
                  '${widget.serviceAdjustment >= 0 ? '+' : '-'} '
                  '${_formatAmount(
                    widget.serviceAdjustment
                        .abs(),
                  )}',
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // TOTAL PAYMENT
  // ==========================================================================

  Widget _buildTotalPaymentCard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        30,
        28,
        30,
        30,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF5FCF8,
        ),
        borderRadius:
            BorderRadius.circular(
          34,
        ),
        border: Border.all(
          color:
              const Color(
            0xFF7BCC9D,
          ),
          width: 2.5,
        ),
      ),
      child: Column(
        children: [
          _buildCardTitle(
            icon:
                Icons
                    .account_balance_wallet_rounded,
            title:
                loc.totalPaymentAmount,
            accent:
                const Color(
              0xFF118762,
            ),
            background:
                const Color(
              0xFFE1F5EB,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          FittedBox(
            fit:
                BoxFit.scaleDown,
            child: Text(
              _formatAmount(
                widget.totalAmount,
              ),
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF125B2D,
                ),
                fontSize: 82,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PAYMENT ACTION
  // ==========================================================================

  Widget _buildPaymentActionCard(
    AppLocalizations loc,
  ) {
    final bool disabled =
        _isBusy ||
        _paymentCompleted;

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
            Colors.white.withOpacity(
          0.99,
        ),
        borderRadius:
            BorderRadius.circular(
          34,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFC9DCF5,
          ),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          _buildCardTitle(
            icon:
                Icons
                    .qr_code_2_rounded,
            title:
                loc.paymentSectionTitle,
            accent:
                _primary,
            background:
                const Color(
              0xFFEAF3FF,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          const Icon(
            Icons
                .qr_code_scanner_rounded,
            color:
                _green,
            size: 100,
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            loc.scanQrInstruction,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF35536A,
              ),
              fontSize: 25,
              fontWeight:
                  FontWeight.w700,
              height: 1.4,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          SizedBox(
            width:
                double.infinity,
            height: 126,
            child:
                ElevatedButton(
              onPressed:
                  disabled
                      ? null
                      : _startQrPayment,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    _green,
                foregroundColor:
                    Colors.white,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    28,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        22,
                      ),
                    ),
                    child: _isBusy
                        ? const Padding(
                            padding:
                                EdgeInsets.all(
                              21,
                            ),
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 4,
                              color:
                                  _green,
                            ),
                          )
                        : const Icon(
                            Icons
                                .qr_code_2_rounded,
                            color:
                                _green,
                            size: 58,
                          ),
                  ),

                  const SizedBox(
                    width: 22,
                  ),

                  Expanded(
                    child: Text(
                      _isBusy
                          ? loc
                              .preparingQr
                              .toUpperCase()
                          : loc
                              .payWithDuitNowQr
                              .toUpperCase(),
                      style:
                          const TextStyle(
                        fontSize: 29,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),

                  Text(
                    _formatAmount(
                      widget.totalAmount,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 25,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CARD TITLE
  // ==========================================================================

  Widget _buildCardTitle({
    required IconData icon,
    required String title,
    required Color accent,
    required Color background,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration:
              BoxDecoration(
            color:
                background,
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
          child: Icon(
            icon,
            color:
                accent,
            size: 34,
          ),
        ),

        const SizedBox(
          width: 15,
        ),

        Flexible(
          child: Text(
            title.toUpperCase(),
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF193A5A,
              ),
              fontSize: 29,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // INFO TILE
  // ==========================================================================

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF5F8FC,
        ),
        borderRadius:
            BorderRadius.circular(
          26,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                _primary,
            size: 40,
          ),

          const SizedBox(
            width: 18,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF6B7B8D,
                    ),
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  value,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF182D43,
                    ),
                    fontSize: 30,
                    fontWeight:
                        FontWeight.w900,
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
  // ERROR CARD
  // ==========================================================================

  Widget _buildErrorCard() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFFFF1F1,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFEF9A9A,
          ),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons
                .error_outline_rounded,
            color:
                Color(
              0xFFC62828,
            ),
            size: 42,
          ),

          const SizedBox(
            width: 18,
          ),

          Expanded(
            child: Text(
              _errorMessage ?? '',
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFFC62828,
                ),
                fontSize: 22,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}