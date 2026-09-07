import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/resit/bill/gaming_receipt_page.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_payment_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_refid_service.dart';

import 'package:frontend_v1/services/pegepay/pegepay_service.dart';
import 'package:frontend_v1/services/pegepay/pegepay_webview_helper.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:window_manager/window_manager.dart';

// ============================================================================
// GAMING QR PAYMENT PAGE
//
// FLOW:
//
// PGAMING5PAGE
//      -> GamingQrPaymentPage
//      -> PegePay DuitNow QR
//      -> payment success
//      -> POST /v2/topup
//      -> wait for final IIMMPACT status
//      -> extract PIN / SN / expiry / note / voucher link
//      -> GamingReceiptPage
//
// IMPORTANT:
//
// baseAmount
// = /v2/options -> price.amount
// = amount sent to IIMMPACT
//
// totalAmount
// = amount charged to customer through PegePay
// = baseAmount + catalog price_adjustment
// ============================================================================

class GamingQrPaymentPage extends StatefulWidget {
  final String platformName;
  final String productCode;

  final String optionCode;
  final String optionName;
  final String optionDescription;

  final double baseAmount;
  final double serviceAdjustment;
  final double totalAmount;

  final String processingTime;

  const GamingQrPaymentPage({
    super.key,
    required this.platformName,
    required this.productCode,
    required this.optionCode,
    required this.optionName,
    required this.optionDescription,
    required this.baseAmount,
    required this.serviceAdjustment,
    required this.totalAmount,
    required this.processingTime,
  });

  @override
  State<GamingQrPaymentPage> createState() =>
      _GamingQrPaymentPageState();
}

class _GamingQrPaymentPageState extends State<GamingQrPaymentPage> {
  bool _isCreatingOrder = false;
  bool _isProcessingReceipt = false;
  bool _paymentCompleted = false;

  String? _errorMessage;
  String? _transactionRefId;

  double get _iimmpactGamingAmount {
  final double? value =
      double.tryParse(
    widget.optionCode.trim(),
  );

  if (value == null ||
      value <= 0) {
    throw Exception(
      'Invalid gaming denomination: '
      '${widget.optionCode}',
    );
  }

  return value;
}

  // ==========================================================================
  // REF ID
  // ==========================================================================

  String get _currentRefId {
    final existing = _transactionRefId;

    if (existing != null &&
        existing.isNotEmpty) {
      return existing;
    }

    final generated =
        IimmpactRefIdService.generate();

    _transactionRefId = generated;

    return generated;
  }

  bool get _isBusy =>
      _isCreatingOrder ||
      _isProcessingReceipt;

  String _formatAmount(double amount) =>
      'RM ${amount.toStringAsFixed(2)}';

  // ==========================================================================
  // START PAYMENT
  // ==========================================================================

  Future<void> _startQrPayment() async {
    if (_isBusy ||
        _paymentCompleted) {
      return;
    }

    final loc =
        AppLocalizations.of(context)!;

    if (widget.baseAmount <= 0 ||
        widget.totalAmount <= 0) {
      await _showMessage(
        title: loc.invalidAmount,
        message:
            loc.paymentAmountMustBeMoreThanZero,
        isError: true,
      );

      return;
    }

    if (widget.productCode
        .trim()
        .isEmpty) {
      await _showMessage(
        title:
            loc.gamingPaymentInvalidProductTitle,
        message:
            loc.gamingPaymentInvalidProductMessage,
        isError:
            true,
      );

      return;
    }

    final refId =
        _currentRefId;

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'NEW GAMING PAYMENT SESSION',
    );
    debugPrint(
      '========================================',
    );
    debugPrint(
      'RefId          : $refId',
    );
    debugPrint(
      'Platform       : ${widget.platformName}',
    );
    debugPrint(
      'Product Code   : ${widget.productCode}',
    );
    debugPrint(
      'Option Code    : ${widget.optionCode}',
    );
    debugPrint(
      'Option Name    : ${widget.optionName}',
    );
    debugPrint(
      'Gaming Denom  : $_iimmpactGamingAmount',
    );

    debugPrint(
      'Voucher Price : ${widget.baseAmount}',
    );

    debugPrint(
      'Customer Total: ${widget.totalAmount}',
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
      _showLoadingDialog();
      loadingDialogVisible =
          true;

      // ======================================================================
      // TEST / PRODUCTION PAYMENT AMOUNT
      //
      // Keep 0.01 while testing.
      //
      // Production:
      //
      // final double paymentAmount =
      //     widget.totalAmount;
      // ======================================================================

      final double paymentAmount =
          0.01;

      final result =
          await PegePayService
              .createOrder(
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

      final iframeUrl =
          result['iframe_url']
                  ?.toString()
                  .trim() ??
              '';

      final orderNo =
          result['order_no']
                  ?.toString()
                  .trim() ??
              '';

      if (iframeUrl.isEmpty ||
          orderNo.isEmpty) {
        throw Exception(
          'PegePay did not return a valid iframe URL or order number.',
        );
      }

      await PegePayWebViewHelper.open(
        iframeUrl: iframeUrl,
        orderNo: orderNo,

        // ====================================================================
        // PEGE PAY SUCCESS
        // ====================================================================

        onSuccess:
            (
          Map<String, dynamic>
              paymentResult,
        ) async {
          final successfulOrderNo =
              paymentResult['order_no']
                      ?.toString()
                      .trim() ??
                  orderNo;

          final bankTransactionNo =
              paymentResult['bank_trx_no']
                      ?.toString()
                      .trim() ??
                  '';

          if (!mounted) {
            return;
          }

          setState(() {
            _paymentCompleted =
                true;

            _isCreatingOrder =
                false;

            _isProcessingReceipt =
                true;
          });

          await _restoreFlutterWindow();

          if (!mounted) {
            return;
          }

          _showReceiptProcessingDialog(
            orderNo:
                successfulOrderNo,
          );

          bool processingDialogVisible =
              true;

          IimmpactPaymentResult?
              iimmpactResult;

          try {
            // ================================================================
            // IIMMPACT GAMING PURCHASE
            // ================================================================
            //
            // Current gaming catalog:
            //
            // account_type = not_required
            //
            // The selected gaming denomination / option code
            // is sent to IIMMPACT as amount.
            //
            // Example:
            // 65 Garena Shells -> amount = 65
            //
            // The RM price from /options is used for
            // the customer payment amount.
            // ================================================================

            iimmpactResult =
                await IimmpactPaymentService
                    .waitForFinalStatus(
              refId:
                  _currentRefId,

              product:
                  widget.productCode,

              // Gaming such as GSMY does not require
              // an account number.
              account:
                  '',

              accountRequired:
                  false,

              // IMPORTANT:
              // Send gaming denomination to IIMMPACT.
              //
              // Example:
              // Garena 65 Shells = amount 65
              //
              // Do NOT send RM5.40 here.
              amount:
                  _iimmpactGamingAmount,

              remarks:
                  successfulOrderNo,

              extras:
                  const <String, dynamic>{},

              interval:
                  const Duration(
                seconds: 6,
              ),

              maxAttempts:
                  10,
            );

            if (iimmpactResult.isFailed) {
              throw IimmpactPaymentException(
                iimmpactResult
                        .remarks
                        .isNotEmpty
                    ? iimmpactResult
                        .remarks
                    : loc
                        .gamingPaymentProviderRejected,
                result:
                    iimmpactResult,
              );
            }

            if (iimmpactResult.isRefund) {
              throw IimmpactPaymentException(
                loc
                    .gamingPaymentProviderRefunded,
                result:
                    iimmpactResult,
              );
            }

            // Gaming must reach final success because
            // PIN / code / link is needed for the receipt.
            if (!iimmpactResult.isSuccessful) {
              throw IimmpactPaymentException(
                '${loc.gamingPaymentUnexpectedStatus}: '
                '${iimmpactResult.status}',
                result:
                    iimmpactResult,
              );
            }
          } catch (error, stackTrace) {
            debugPrint(
              '[GamingQrPaymentPage] '
              'IIMMPACT execution error: '
              '$error',
            );

            debugPrintStack(
              stackTrace: stackTrace,
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

            final message =
                error is
                        IimmpactPaymentException
                    ? error.message
                    : error.toString();

            await _showMessage(
              title:
                  loc
                      .gamingPaymentProviderErrorTitle,

              message:
                  '$message\n\n'
                  '${loc.gamingPaymentReference}:\n'
                  '$_currentRefId\n\n'
                  '${loc.gamingPaymentAlreadyReceivedWarning}',

              isError:
                  true,
            );

            return;
          }

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

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              settings:
                  const RouteSettings(
                name: '/receipt',
              ),
              builder:
                  (_) =>
                      GamingReceiptPage(
                data:
                    GamingReceiptData(
                  platformName:
                      widget.platformName,

                  productCode:
                      widget.productCode,

                  optionCode:
                      widget.optionCode,

                  optionName:
                      widget.optionName,

                  optionDescription:
                      widget
                          .optionDescription,

                  baseAmount:
                      widget.baseAmount,

                  serviceAdjustment:
                      widget
                          .serviceAdjustment,

                  totalAmount:
                      widget.totalAmount,

                  processingTime:
                      widget.processingTime,

                  refId:
                      iimmpactResult!
                              .refId
                              .isNotEmpty
                          ? iimmpactResult
                              .refId
                          : _currentRefId,

                  orderNo:
                      successfulOrderNo,

                  bankTransactionNo:
                      bankTransactionNo,

                  paymentMethod:
                      'DuitNow QR',

                  paidAt:
                      DateTime.now(),

                  serialNumber:
                      iimmpactResult
                          .serialNumber,

                  pin:
                      iimmpactResult.pin,

                  expiry:
                      iimmpactResult.expiry,

                  note:
                      iimmpactResult.note,

                  voucherLink:
                      iimmpactResult
                          .voucherLink,
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
              content:
                  Text(
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
    } catch (error, stackTrace) {
      debugPrint(
        '[GamingQrPaymentPage] '
        'QR creation/payment error: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
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
        '[GamingQrPaymentPage] '
        'Window restore error: $error',
      );
    }
  }

  // ==========================================================================
  // LOADING DIALOG
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
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFD9D2F6,
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
                          0xFFF0EBFF,
                        ),
                        shape:
                            BoxShape.circle,
                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFF7048E8,
                          ),
                          width: 5,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .qr_code_2_rounded,
                        size: 88,
                        color:
                            Color(
                          0xFF7048E8,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    Text(
                      loc
                          .gamingPreparingQrPayment,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF5630C7,
                        ),
                        fontSize: 42,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    Text(
                      '${widget.platformName}\n'
                      '${_formatAmount(widget.totalAmount)}',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF294A73,
                        ),
                        fontSize: 28,
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
                            Color(
                          0xFF7048E8,
                        ),
                        backgroundColor:
                            Color(
                          0xFFE8E1FF,
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
  // PROCESSING RECEIPT
  // ==========================================================================

  void _showReceiptProcessingDialog({
    required String orderNo,
  }) {
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
                  border:
                      Border.all(
                    color:
                        const Color(
                      0xFFCFC4F7,
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
                            Color(
                          0xFF7048E8,
                        ),
                        backgroundColor:
                            Color(
                          0xFFEDE7FF,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    Text(
                      loc
                          .gamingProcessingPurchaseTitle,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF5630C7,
                        ),
                        fontSize: 42,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Text(
                      loc
                          .gamingProcessingPurchaseMessage,
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
                      widget.platformName,
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
                            Color(
                          0xFF5630C7,
                        ),
                        fontSize: 40,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    Text(
                      loc
                          .gamingProcessingPurchaseLocked,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF685D84,
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
  // MESSAGE
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
        final accentColor =
            isError
                ? const Color(
                    0xFFC62828,
                  )
                : const Color(
                    0xFF7048E8,
                  );

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
                      accentColor,
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
                        accentColor,
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
                          accentColor,
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
  // PAGE
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
                              _buildGamingInformationCard(
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
                            child:
                                SizedBox(
                              width: 620,
                              height: 98,
                              child:
                                  KioskBackButton(
                                onPressed:
                                    () {
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
            Color(
              0xFF5630C7,
            ),
            Color(
              0xFF7048E8,
            ),
            Color(
              0xFF9A78F2,
            ),
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sports_esports_rounded,
            color:
                Colors.white,
            size: 54,
          ),

          const SizedBox(
            width: 20,
          ),

          Expanded(
            child: Text(
              loc
                  .gamingPaymentTitle
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
  // INFORMATION CARD
  // ==========================================================================

  Widget _buildGamingInformationCard(
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
            Colors.white.withOpacity(
          0.99,
        ),
        borderRadius:
            BorderRadius.circular(
          34,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD9D2F6,
          ),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          _PaymentInfoRow(
            label:
                loc.gamingReceiptPlatform,
            value:
                widget.platformName,
          ),

          const Divider(
            height: 34,
          ),

          _PaymentInfoRow(
            label:
                loc.gamingReceiptSelectedPackage,
            value:
                widget.optionName,
          ),

          const Divider(
            height: 34,
          ),

          _PaymentInfoRow(
            label:
                loc.gamingReceiptBaseAmount,
            value:
                _formatAmount(
              widget.baseAmount,
            ),
          ),

          if (widget
                  .serviceAdjustment
                  .abs() >=
              0.005) ...[
            const Divider(
              height: 34,
            ),

            _PaymentInfoRow(
              label:
                  loc
                      .gamingReceiptServiceAdjustment,
              value:
                  _formatAmount(
                widget
                    .serviceAdjustment,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // TOTAL
  // ==========================================================================

  Widget _buildTotalPaymentCard(
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
            const Color(
          0xFFF7F4FF,
        ),
        borderRadius:
            BorderRadius.circular(
          34,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFB9A8F5,
          ),
          width: 2.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            loc.gamingPaymentTotal,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF5630C7,
              ),
              fontSize: 31,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 18,
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
                  0xFF16813B,
                ),
                fontSize: 86,
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
  // PAY ACTION
  // ==========================================================================

  Widget _buildPaymentActionCard(
    AppLocalizations loc,
  ) {
    final disabled =
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
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          34,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD9D2F6,
          ),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.qr_code_scanner_rounded,
            color:
                Color(
              0xFF7048E8,
            ),
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
              height: 1.4,
              fontWeight:
                  FontWeight.w700,
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
                ElevatedButton.icon(
              onPressed:
                  disabled
                      ? null
                      : _startQrPayment,
              icon:
                  const Icon(
                Icons.qr_code_2_rounded,
                size: 56,
              ),
              label:
                  Text(
                disabled
                    ? loc
                        .preparingQr
                        .toUpperCase()
                    : loc
                        .payWithDuitNowQr
                        .toUpperCase(),
                style:
                    const TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF7048E8,
                ),
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
            ),
          ),
        ],
      ),
    );
  }

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
      ),
      child: Text(
        _errorMessage ?? '',
        textAlign:
            TextAlign.center,
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
    );
  }
}

class _PaymentInfoRow
    extends StatelessWidget {
  final String label;
  final String value;

  const _PaymentInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF63758A,
              ),
              fontSize: 28,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(
          width: 20,
        ),

        Expanded(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF17283E,
              ),
              fontSize: 30,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
