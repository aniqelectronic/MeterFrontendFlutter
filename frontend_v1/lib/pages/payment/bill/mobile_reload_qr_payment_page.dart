import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/resit/bill/mobile_reload_receipt_page.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_payment_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_refid_service.dart';

import 'package:frontend_v1/services/pegepay/pegepay_service.dart';
import 'package:frontend_v1/services/pegepay/pegepay_webview_helper.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:window_manager/window_manager.dart';

// ============================================================================
// MOBILE RELOAD QR PAYMENT
//
// Supports:
//
// MOBILE PREPAID:
// product = D / C / M / U / ...
// account = phone
// amount  = reload amount
// extras  = {}
//
// MOBILE DATA:
// product = CEL / DI / UMI / ...
// account = phone
// amount  = selected plan price
// extras  = {
//   "subproduct_code": selected plan code
// }
//
// IMPORTANT:
//
// baseAmount
// = amount sent to IIMMPACT.
//
// totalAmount
// = amount customer pays through PegePay after catalog adjustment.
// ============================================================================

class MobileReloadQrPaymentPage
    extends StatefulWidget {
  final String providerName;
  final String productCode;

  final String category;

  final String phoneNumber;

  final String fieldId;

  final String optionCode;
  final String optionName;
  final String optionDescription;

  final double baseAmount;
  final double serviceAdjustment;
  final double totalAmount;

  final String processingTime;

  const MobileReloadQrPaymentPage({
    super.key,
    required this.providerName,
    required this.productCode,
    required this.category,
    required this.phoneNumber,
    required this.fieldId,
    required this.optionCode,
    required this.optionName,
    required this.optionDescription,
    required this.baseAmount,
    required this.serviceAdjustment,
    required this.totalAmount,
    required this.processingTime,
  });

  @override
  State<MobileReloadQrPaymentPage>
      createState() =>
          _MobileReloadQrPaymentPageState();
}

class _MobileReloadQrPaymentPageState
    extends State<MobileReloadQrPaymentPage> {
  static const Color _primary =
      Color(0xFF7B4DCC);

  static const Color _dark =
      Color(0xFF56339B);

  static const Color _green =
      Color(0xFF087C5A);

  bool _isCreatingOrder = false;

  bool _isProcessingReceipt = false;

  bool _paymentCompleted = false;

  String? _errorMessage;

  String? _transactionRefId;

  // ==========================================================================
  // TYPE
  // ==========================================================================

  bool get _isInternet =>
      widget.category
          .trim()
          .toLowerCase() ==
      'mobiledata';

  bool get _hasOptionDescription {
    final String description =
        widget.optionDescription.trim();

    return description.isNotEmpty &&
        description.toLowerCase() != 'null' &&
        description != '-';
  }

  bool get _isBusy =>
    _isCreatingOrder ||
    _isProcessingReceipt;

  // ==========================================================================
  // REF ID
  // ==========================================================================

  String get _currentRefId {
    final existing =
        _transactionRefId;

    if (existing != null &&
        existing.isNotEmpty) {
      return existing;
    }

    final generated =
        IimmpactRefIdService
            .generate();

    _transactionRefId =
        generated;

    return generated;
  }

  // ==========================================================================
  // FORMAT
  // ==========================================================================

  String _formatAmount(
    double amount,
  ) {
    return 'RM '
        '${amount.toStringAsFixed(2)}';
  }

  // ==========================================================================
  // EXTRAS
  // ==========================================================================

  Map<String, dynamic>
      get _iimmpactExtras {
    // ========================================================================
    // MOBILE DATA
    //
    // IIMMPACT requires:
    //
    // extras.subproduct_code
    //
    // ========================================================================

    if (_isInternet) {
      return <String, dynamic>{
        'subproduct_code':
            widget.optionCode.trim(),
      };
    }

    // ========================================================================
    // MOBILE PREPAID
    // ========================================================================

    return const <String, dynamic>{};
  }

  // ==========================================================================
  // PAYMENT
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
        title:
            loc.invalidAmount,

        message:
            loc
                .paymentAmountMustBeMoreThanZero,

        isError:
            true,
      );

      return;
    }

    if (widget.productCode
        .trim()
        .isEmpty) {
      await _showMessage(
        title:
            loc
                .mobileReloadPaymentInvalidProductTitle,

        message:
            loc
                .mobileReloadPaymentInvalidProductMessage,

        isError:
            true,
      );

      return;
    }

    if (widget.phoneNumber
        .trim()
        .isEmpty) {
      await _showMessage(
        title:
            loc
                .mobileReloadInvalidPhoneTitle,

        message:
            loc
                .mobileReloadInvalidPhoneMessage,

        isError:
            true,
      );

      return;
    }

    // ========================================================================
    // MOBILE DATA MUST HAVE SUBPRODUCT
    // ========================================================================

    if (_isInternet &&
        widget.optionCode
            .trim()
            .isEmpty) {
      await _showMessage(
        title:
            loc
                .mobileReloadPaymentInvalidPlanTitle,

        message:
            loc
                .mobileReloadPaymentInvalidPlanMessage,

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
      'NEW MOBILE RELOAD PAYMENT',
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
      'Category    : ${widget.category}',
    );
    debugPrint(
      'Phone       : ${widget.phoneNumber}',
    );
    debugPrint(
      'Option Code : ${widget.optionCode}',
    );
    debugPrint(
      'Amount      : ${widget.baseAmount}',
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
      // PEGE PAY AMOUNT
      //
      // TEST:
      //
      // Keep RM0.01.
      //
      // PRODUCTION:
      //
      // final double paymentAmount =
      //     widget.totalAmount;
      //
      // ======================================================================

      final double paymentAmount =
          0.01;

      final Map<String, dynamic> result =
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

      await PegePayWebViewHelper.open(
        iframeUrl:
            iframeUrl,

        orderNo:
            orderNo,

        // ====================================================================
        // SUCCESS
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

          // Customer already paid.
          // Never allow a second QR from this page.

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
            // IIMMPACT TOPUP
            // ================================================================

            iimmpactResult =
                await IimmpactPaymentService
                    .waitForFinalStatus(
              refId:
                  _currentRefId,

              product:
                  widget.productCode,

              account:
                  widget.phoneNumber,

              amount:
                  widget.baseAmount,

              remarks:
                  successfulOrderNo,

              extras:
                  _iimmpactExtras,

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
                        .mobileReloadPaymentProviderRejected,

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
                    .mobileReloadPaymentProviderRefunded,

                result:
                    iimmpactResult,
              );
            }

            // ================================================================
            // REQUIRE FINAL SUCCESS
            //
            // Accepted/Processing has already been polled above.
            // Do not issue another payment.
            // ================================================================

            if (!iimmpactResult
                .isSuccessful) {
              throw IimmpactPaymentException(
                '${loc.mobileReloadPaymentStillProcessing}\n'
                '${loc.mobileReloadPaymentReference}: '
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
              '[MobileReloadQrPaymentPage] '
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
                      .mobileReloadPaymentProviderErrorTitle,

              message:
                  '$message\n\n'
                  '${loc.mobileReloadPaymentAlreadyReceivedWarning}',

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
              rootNavigator: true,
            ).pop();

            processingDialogVisible =
                false;
          }

          if (!mounted ||
              iimmpactResult == null) {
            return;
          }

          // ==================================================================
          // IIMMPACT FINAL NON-NULL RESULT
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
                      MobileReloadReceiptPage(
                data:
                    MobileReloadReceiptData(
                  providerName:
                      widget.providerName,

                  productCode:
                      widget.productCode,

                  category:
                      widget.category,

                  phoneNumber:
                      widget.phoneNumber,

                  optionCode:
                      widget.optionCode,

                  optionName:
                      widget.optionName,

                  optionDescription:
                      widget.optionDescription,

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
        '[MobileReloadQrPaymentPage] '
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

      await windowManager
          .setFullScreen(
        true,
      );
    } catch (error) {
      debugPrint(
        '[MobileReloadQrPaymentPage] '
        'Window restore error: $error',
      );
    }
  }

  // ==========================================================================
  // PREPARING QR
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
                          .mobileReloadPreparingQrPayment,

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
                      '${widget.phoneNumber}\n'
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
  // PROCESSING
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
                            _primary,

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
                          .mobileReloadProcessingTitle,

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
                      loc
                          .mobileReloadProcessingMessage,

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
                      widget.phoneNumber,

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
                      loc
                          .mobileReloadProcessingLocked,

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
                        ElevatedButton.styleFrom(
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
            Color(0xFF56339B),
            Color(0xFF7B4DCC),
            Color(0xFF9A78F2),
          ],
        ),
      ),

      child: Row(
        children: [
          Icon(
            _isInternet
                ? Icons
                    .signal_cellular_alt_rounded
                : Icons
                    .phone_android_rounded,

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
                  .mobileReloadPaymentTitle
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
          _buildCardTitle(
            icon:
                Icons
                    .phone_android_rounded,

            title:
                loc
                    .mobileReloadPaymentDetails,

            accent:
                _primary,

            background:
                const Color(
              0xFFF0EBFF,
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
                  Color(0xFF56339B),
                  Color(0xFF7B4DCC),
                  Color(0xFF9A78F2),
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
                  widget.phoneNumber,

                  style:
                      TextStyle(
                    color:
                        Colors.white.withOpacity(
                      0.85,
                    ),

                    fontSize: 28,

                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          if (_isInternet) ...[
            if (widget.optionName
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: 22,
              ),

              _buildInfoTile(
                icon:
                    Icons.signal_cellular_alt_rounded,

                label:
                    loc.mobileReloadSelectedPlan,

                value:
                    widget.optionName,
              ),
            ],

            // ================================================================
            // PLAN DESCRIPTION
            //
            // Only show when IIMMPACT actually provides a description.
            // ================================================================

            if (_hasOptionDescription) ...[
              const SizedBox(
                height: 16,
              ),

              _buildInfoTile(
                icon:
                    Icons.description_outlined,

                label:
                    loc.mobileReloadReceiptPlanDetails,

                value:
                    widget.optionDescription,
              ),
            ],
          ] else ...[
            const SizedBox(
              height: 22,
            ),

            _buildInfoTile(
              icon:
                  Icons.payments_rounded,

              label:
                  loc.mobileReloadReloadAmount,

              value:
                  _formatAmount(
                widget.baseAmount,
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

        border:
            Border.all(
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
  // ACTION
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
          _buildCardTitle(
            icon:
                Icons.qr_code_2_rounded,

            title:
                loc.paymentSectionTitle,

            accent:
                _primary,

            background:
                const Color(
              0xFFF0EBFF,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          const Icon(
            Icons.qr_code_scanner_rounded,

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
  // COMMON UI
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

        border:
            Border.all(
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
            Icons.error_outline_rounded,

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