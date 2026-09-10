import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/resit/bill/console_store_receipt_page.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_payment_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_refid_service.dart';

import 'package:frontend_v1/services/pegepay/pegepay_service.dart';
import 'package:frontend_v1/services/pegepay/pegepay_webview_helper.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:window_manager/window_manager.dart';

// ============================================================================
// CONSOLE & APP STORE QR PAYMENT
//
// DYNAMIC:
//
// productCode
// option
// amount
// image
// processing time
// note
//
// are all received from Catalog / Options.
//
// Catalog fulfillment for Console & App Stores:
//
// selected pricing option
//      ↓
// price.amount
//      ↓
// IIMMPACT amount
//
// Console Store products currently do not define an account field,
// therefore payment is submitted with:
//
// account: ''
// accountRequired: false
// ============================================================================

class ConsoleStoreQrPaymentPage
    extends StatefulWidget {
  final String productCode;
  final String productName;
  final String imageUrl;

  final String optionCode;
  final String optionName;
  final String optionDescription;

  final double iimmpactAmount;

  final double baseAmount;
  final double serviceAdjustment;
  final double totalAmount;

  final String processingTime;
  final String productNote;

  const ConsoleStoreQrPaymentPage({
    super.key,
    required this.productCode,
    required this.productName,
    required this.imageUrl,
    required this.optionCode,
    required this.optionName,
    required this.optionDescription,
    required this.iimmpactAmount,
    required this.baseAmount,
    required this.serviceAdjustment,
    required this.totalAmount,
    required this.processingTime,
    required this.productNote,
  });

  @override
  State<ConsoleStoreQrPaymentPage> createState() =>
      _ConsoleStoreQrPaymentPageState();
}

class _ConsoleStoreQrPaymentPageState
    extends State<ConsoleStoreQrPaymentPage> {
  // ==========================================================================
  // STATE
  // ==========================================================================

  bool _isCreatingOrder =
      false;

  bool _isProcessingReceipt =
      false;

  bool _paymentCompleted =
      false;

  String? _errorMessage;

  String? _transactionRefId;

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF3949AB);

  static const Color _darkColor =
      Color(0xFF283593);

  static const Color _lightColor =
      Color(0xFFE8EAF6);

  static const Color _greenColor =
      Color(0xFF16813B);

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
  // BUSY
  // ==========================================================================

  bool get _isBusy =>
      _isCreatingOrder ||
      _isProcessingReceipt;

  // ==========================================================================
  // MONEY
  // ==========================================================================

  String _formatAmount(
    double amount,
  ) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  String _formatSignedAmount(
    double amount,
  ) {
    final String sign =
        amount >= 0
            ? '+'
            : '-';

    return '$sign RM '
        '${amount.abs().toStringAsFixed(2)}';
  }

  // ==========================================================================
  // START QR
  // ==========================================================================

  Future<void> _startQrPayment() async {
    if (_isBusy ||
        _paymentCompleted) {
      return;
    }

    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    // ========================================================================
    // VALIDATE PRICE
    // ========================================================================

    if (widget.baseAmount <= 0 ||
        widget.totalAmount <= 0 ||
        widget.iimmpactAmount <= 0) {
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
            loc.consoleStorePaymentInvalidProductTitle,
        message:
            loc.consoleStorePaymentInvalidProductMessage,
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
      'NEW CONSOLE STORE PAYMENT',
    );
    debugPrint(
      '========================================',
    );

    debugPrint(
      'RefId          : $refId',
    );

    debugPrint(
      'Product        : ${widget.productCode}',
    );

    debugPrint(
      'Product Name   : ${widget.productName}',
    );

    debugPrint(
      'Option Code    : ${widget.optionCode}',
    );

    debugPrint(
      'Option Name    : ${widget.optionName}',
    );

    debugPrint(
      'IIMMPACT Amount: ${widget.iimmpactAmount}',
    );

    debugPrint(
      'Base RM        : ${widget.baseAmount}',
    );

    debugPrint(
      'Adjustment     : ${widget.serviceAdjustment}',
    );

    debugPrint(
      'Customer Total : ${widget.totalAmount}',
    );

    debugPrint(
      '========================================',
    );
    debugPrint('');

    setState(() {
      _isCreatingOrder =
          true;

      _errorMessage =
          null;
    });

    bool loadingDialogVisible =
        false;

    try {
      _showLoadingDialog();

      loadingDialogVisible =
          true;

      // ======================================================================
      // PEGE PAY CUSTOMER PAYMENT
      //
      // TESTING:
      //
      // RM0.01
      //
      // PRODUCTION:
      //
      // final double paymentAmount =
      //     widget.totalAmount;
      // ======================================================================

      final double paymentAmount =
          0.01;

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
          rootNavigator:
              true,
        ).pop();

        loadingDialogVisible =
            false;
      }

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
          'PegePay did not return a valid iframe URL or order number.',
        );
      }

      // ======================================================================
      // OPEN DUITNOW QR
      // ======================================================================

      await PegePayWebViewHelper.open(
        iframeUrl:
            iframeUrl,

        orderNo:
            orderNo,

        // ====================================================================
        // QR SUCCESS
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

          _showReceiptProcessingDialog();

          bool processingDialogVisible =
              true;

          IimmpactPaymentResult?
              iimmpactResult;

          try {
            // ================================================================
            // IIMMPACT CONSOLE PURCHASE
            //
            // No account field is defined for console store products.
            //
            // amount comes dynamically from:
            //
            // selected option -> price.amount
            // ================================================================

            iimmpactResult =
                await IimmpactPaymentService
                    .waitForFinalStatus(
              refId:
                  _currentRefId,

              product:
                  widget.productCode,

              account:
                  '',

              accountRequired:
                  false,

              amount:
                  widget.iimmpactAmount,

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
                        .consoleStorePaymentProviderRejected,
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
                    .consoleStorePaymentProviderRefunded,
                result:
                    iimmpactResult,
              );
            }

            // ================================================================
            // SUCCESS REQUIRED
            // ================================================================

            if (!iimmpactResult.isSuccessful) {
              throw IimmpactPaymentException(
                '${loc.consoleStorePaymentUnexpectedStatus}: '
                '${iimmpactResult.status}',
                result:
                    iimmpactResult,
              );
            }
          } catch (
            error,
            stackTrace
          ) {
            debugPrint(
              '[ConsoleStoreQrPaymentPage] '
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
                rootNavigator:
                    true,
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
                      .consoleStorePaymentProviderErrorTitle,

              message:
                  '$message\n\n'
                  '${loc.consoleStorePaymentReference}:\n'
                  '$_currentRefId\n\n'
                  '${loc.consoleStorePaymentAlreadyReceivedWarning}',

              isError:
                  true,
            );

            return;
          }

          // ==================================================================
          // CLOSE PROCESSING
          // ==================================================================

          if (processingDialogVisible &&
              mounted) {
            Navigator.of(
              context,
              rootNavigator:
                  true,
            ).pop();

            processingDialogVisible =
                false;
          }

        if (!mounted ||
            iimmpactResult == null) {
          return;
        }

        // ==================================================================
        // IMPORTANT
        //
        // Convert nullable result into a guaranteed non-null local variable.
        //
        // This fixes:
        //
        // refId can't be unconditionally accessed
        // serialNumber can't be unconditionally accessed
        // pin can't be unconditionally accessed
        // expiry can't be unconditionally accessed
        // voucherLink can't be unconditionally accessed
        // ==================================================================

        final IimmpactPaymentResult finalResult =
            iimmpactResult;

        // ==================================================================
        // RECEIPT
        // ==================================================================

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings:
                const RouteSettings(
              name: '/receipt',
            ),
            builder:
                (_) =>
                    ConsoleStoreReceiptPage(
              data:
                  ConsoleStoreReceiptData(
                // ==========================================================
                // PRODUCT
                // ==========================================================

                productCode:
                    widget.productCode,

                productName:
                    widget.productName,

                imageUrl:
                    widget.imageUrl,

                // ==========================================================
                // OPTION
                // ==========================================================

                optionCode:
                    widget.optionCode,

                optionName:
                    widget.optionName,

                optionDescription:
                    widget.optionDescription,

                // ==========================================================
                // PAYMENT
                // ==========================================================

                baseAmount:
                    widget.baseAmount,

                serviceAdjustment:
                    widget.serviceAdjustment,

                totalAmount:
                    widget.totalAmount,

                processingTime:
                    widget.processingTime,

                // ==========================================================
                // CATALOG NOTE
                // ==========================================================

                productNote:
                    widget.productNote,

                // ==========================================================
                // TRANSACTION
                // ==========================================================

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

                // ==========================================================
                // IIMMPACT RESPONSE
                // ==========================================================

                serialNumber:
                    finalResult.serialNumber,

                pin:
                    finalResult.pin,

                expiry:
                    finalResult.expiry,

                voucherLink:
                    finalResult.voucherLink,
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
    } catch (
      error,
      stackTrace
    ) {
      debugPrint(
        '[ConsoleStoreQrPaymentPage] '
        'QR error: $error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      if (loadingDialogVisible &&
          mounted) {
        Navigator.of(
          context,
          rootNavigator:
              true,
        ).pop();
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
  // RESTORE FLUTTER WINDOW
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
        'Console Store window restore error: '
        '$error',
      );
    }
  }

  // ==========================================================================
  // QR LOADING DIALOG
  // ==========================================================================

  void _showLoadingDialog() {
    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    showDialog<void>(
      context:
          context,

      useRootNavigator:
          true,

      barrierDismissible:
          false,

      builder:
          (_) {
        return PopScope(
          canPop:
              false,

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
                        _lightColor,
                    width: 3,
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
                            _lightColor,

                        shape:
                            BoxShape.circle,

                        border:
                            Border.all(
                          color:
                              _primaryColor,
                          width: 5,
                        ),
                      ),

                      child:
                          const Icon(
                        Icons
                            .qr_code_2_rounded,
                        size: 88,
                        color:
                            _primaryColor,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    Text(
                      loc.consoleStorePreparingQrPayment,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            _darkColor,
                        fontSize: 40,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      '${widget.productName}\n'
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
                      height: 28,
                    ),

                    const SizedBox(
                      width: 72,
                      height: 72,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 7,
                        color:
                            _primaryColor,
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
  // RECEIPT PROCESSING
  // ==========================================================================

  void _showReceiptProcessingDialog() {
    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    showDialog<void>(
      context:
          context,

      useRootNavigator:
          true,

      barrierDismissible:
          false,

      builder:
          (_) {
        return PopScope(
          canPop:
              false,

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
                    const EdgeInsets.all(
                  46,
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
                        _lightColor,
                    width: 3,
                  ),
                ),

                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    const SizedBox(
                      width: 145,
                      height: 145,

                      child:
                          CircularProgressIndicator(
                        strokeWidth: 8,
                        color:
                            _primaryColor,
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    Text(
                      loc.consoleStoreProcessingPurchaseTitle,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            _darkColor,
                        fontSize: 40,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Text(
                      loc.consoleStoreProcessingPurchaseMessage,
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
                      height: 25,
                    ),

                    Text(
                      widget.productName,
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
                      style:
                          const TextStyle(
                        color:
                            _primaryColor,
                        fontSize: 40,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    Text(
                      loc.consoleStoreProcessingPurchaseLocked,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF68778A,
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
    final Color accent =
        isError
            ? const Color(
                0xFFC62828,
              )
            : _primaryColor;

    await showDialog<void>(
      context:
          context,

      barrierDismissible:
          false,

      builder:
          (
        dialogContext,
      ) {
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
                  size: 95,
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  title,
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color:
                        accent,
                    fontSize: 38,
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
                    fontSize: 24,
                    height: 1.4,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                SizedBox(
                  width:
                      double.infinity,

                  height:
                      78,

                  child:
                      ElevatedButton(
                    onPressed:
                        () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          accent,

                      foregroundColor:
                          Colors.white,
                    ),

                    child:
                        Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .ok,
                      style:
                          const TextStyle(
                        fontSize: 26,
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
    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    return PopScope(
      canPop:
          !_isBusy,

      child: Scaffold(
        body: Stack(
          children: [
            // ================================================================
            // BACKGROUND
            // ================================================================

            const Positioned.fill(
              child:
                  DecoratedBox(
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

            // ================================================================
            // PAGE
            // ================================================================

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(
                    loc,
                  ),

                  Expanded(
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

                          _buildTotalCard(
                            loc,
                          ),

                          const SizedBox(
                            height: 26,
                          ),

                          _buildPaymentCard(
                            loc,
                          ),

                          if (_errorMessage !=
                              null) ...[
                            const SizedBox(
                              height: 20,
                            ),

                            _buildErrorCard(),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ==========================================================
                  // BACK + FOOTER
                  // ==========================================================

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
                            opacity:
                                _isBusy
                                    ? 0.45
                                    : 1,

                            duration:
                                const Duration(
                              milliseconds: 180,
                            ),

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
                          height: 25,
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
                            fontSize: 20,
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
                child:
                    AbsorbPointer(
                  absorbing:
                      true,
                  child:
                      ColoredBox(
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
              0xFF283593,
            ),
            Color(
              0xFF3949AB,
            ),
            Color(
              0xFF5C6BC0,
            ),
          ],
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons
                .devices_other_rounded,
            color:
                Colors.white,
            size: 54,
          ),

          const SizedBox(
            width: 20,
          ),

          Expanded(
            child: Text(
              loc.consoleStorePaymentTitle
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

  Widget _buildInformationCard(
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
          34,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFD1D6F5,
          ),
          width: 2,
        ),
      ),

      child: Column(
        children: [
          // ==================================================================
          // PRODUCT
          // ==================================================================

          _PaymentInfoRow(
            label:
                loc.consoleStoreProductLabel,

            value:
                widget.productName,
          ),

          const Divider(
            height: 34,
          ),

          // ==================================================================
          // SELECTED VALUE
          // ==================================================================

          _PaymentInfoRow(
            label:
                loc.consoleStoreSelectedPackageLabel,

            value:
                widget.optionName,
          ),

          // ==================================================================
          // DESCRIPTION
          // ==================================================================

          if (widget.optionDescription
              .trim()
              .isNotEmpty) ...[
            const Divider(
              height: 34,
            ),

            _PaymentInfoRow(
              label:
                  loc.consoleStorePackageDescriptionLabel,

              value:
                  widget.optionDescription,
            ),
          ],

          const Divider(
            height: 34,
          ),

          // ==================================================================
          // BASE
          // ==================================================================

          _PaymentInfoRow(
            label:
                loc.consoleStoreSubtotalLabel,

            value:
                _formatAmount(
              widget.baseAmount,
            ),
          ),

          // ==================================================================
          // ADJUSTMENT
          // ==================================================================

          if (widget.serviceAdjustment
                  .abs() >=
              0.005) ...[
            const Divider(
              height: 34,
            ),

            _PaymentInfoRow(
              label:
                  loc
                      .consoleStoreServiceAdjustmentLabel,

              value:
                  _formatSignedAmount(
                widget.serviceAdjustment,
              ),
            ),
          ],

          if (widget.processingTime
              .trim()
              .isNotEmpty) ...[
            const Divider(
              height: 34,
            ),

            _PaymentInfoRow(
              label:
                  loc.processingTimeLabel,

              value:
                  widget.processingTime
                      .replaceAll(
                        '_',
                        ' ',
                      )
                      .toUpperCase(),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // TOTAL
  // ==========================================================================

  Widget _buildTotalCard(
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
            _lightColor,

        borderRadius:
            BorderRadius.circular(
          34,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFF9FA8DA,
          ),
          width: 2.5,
        ),
      ),

      child: Column(
        children: [
          Text(
            loc.consoleStorePaymentTotal,
            style:
                const TextStyle(
              color:
                  _darkColor,
              fontSize: 31,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          FittedBox(
            child: Text(
              _formatAmount(
                widget.totalAmount,
              ),
              style:
                  const TextStyle(
                color:
                    _greenColor,
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
  // PAYMENT CARD
  // ==========================================================================

  Widget _buildPaymentCard(
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
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          34,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFD1D6F5,
          ),
          width: 2,
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons
                .qr_code_scanner_rounded,
            color:
                _primaryColor,
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

            height:
                126,

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
                    ? loc.preparingQr
                        .toUpperCase()
                    : loc.payWithDuitNowQr
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
                    _primaryColor,

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

// ============================================================================
// PAYMENT INFORMATION ROW
// ============================================================================

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
              fontSize: 27,
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
              fontSize: 29,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}