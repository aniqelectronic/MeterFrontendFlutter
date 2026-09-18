import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/resit/bill/digital_voucher_receipt_page.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_payment_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_refid_service.dart';

import 'package:frontend_v1/services/pegepay/pegepay_service.dart';
import 'package:frontend_v1/services/pegepay/pegepay_webview_helper.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:window_manager/window_manager.dart';

// ============================================================================
// DIGITAL VOUCHER QR PAYMENT
//
// FLOW:
//
// PDIGITALVOUCHER4PAGE
//      ↓
// DigitalVoucherQrPaymentPage
//      ↓
// PegePay DuitNow QR
//      ↓
// customer payment success
//      ↓
// POST /v2/topup
//      ↓
// wait for final IIMMPACT status
//      ↓
// PIN / SN / expiry / voucher link
//      ↓
// DigitalVoucherReceiptPage
//
// IMPORTANT:
//
// baseAmount
// = actual voucher amount sent to IIMMPACT.
//
// totalAmount
// = customer payment amount after catalog price_adjustment.
//
// Digital Voucher does NOT currently collect account/phone.
//
// Therefore:
//
// account = ''
// accountRequired = false
//
// extras = {}
// ============================================================================

class DigitalVoucherQrPaymentPage
    extends StatefulWidget {
  final String productName;
  final String productCode;

  final String imageUrl;

  final String fieldId;
  final String fieldType;

  final String? optionCode;
  final String? optionName;
  final String? optionDescription;

  final double baseAmount;

  final double topupAmount;

  final double serviceAdjustment;
  final double totalAmount;

  final String processingTime;

  // Localized provider instruction/note from Page 4.
  final String note;

  const DigitalVoucherQrPaymentPage({
    super.key,
    required this.productName,
    required this.productCode,
    required this.imageUrl,
    required this.fieldId,
    required this.fieldType,
    required this.optionCode,
    required this.optionName,
    required this.optionDescription,
    required this.baseAmount,
    required this.topupAmount,
    required this.serviceAdjustment,
    required this.totalAmount,
    required this.processingTime,
    required this.note,
  });

  @override
  State<DigitalVoucherQrPaymentPage> createState() =>
      _DigitalVoucherQrPaymentPageState();
}

class _DigitalVoucherQrPaymentPageState
    extends State<DigitalVoucherQrPaymentPage> {
  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primary =
      Color(0xFFE65175);

  static const Color _dark =
      Color(0xFFC83261);

  static const Color _light =
      Color(0xFFFFEDF2);

  static const Color _green =
      Color(0xFF087C5A);

  static const Color _red =
      Color(0xFFC62828);

  // ==========================================================================
  // STATE
  // ==========================================================================

  bool _isCreatingOrder = false;

  bool _isProcessingReceipt = false;

  bool _paymentCompleted = false;

  String? _errorMessage;

  String? _transactionRefId;

  // ==========================================================================
  // BASIC VALUES
  // ==========================================================================

  bool get _isBusy =>
      _isCreatingOrder ||
      _isProcessingReceipt;

  bool get _isSelect =>
      widget.fieldType
          .trim()
          .toLowerCase() ==
      'select';

  bool get _hasOptionName =>
      (widget.optionName ?? '')
          .trim()
          .isNotEmpty;

  bool get _hasOptionDescription {
    final String value =
        (widget.optionDescription ?? '')
            .trim();

    return value.isNotEmpty &&
        value.toLowerCase() != 'null' &&
        value != '-';
  }

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

  String _formatProcessingTime(
    AppLocalizations loc,
  ) {
    final String value =
        widget.processingTime
            .trim()
            .toLowerCase();

    switch (value) {
      case 'pin':
        return loc
            .digitalVoucherDeliveryPin;

      case 'link':
        return loc
            .digitalVoucherDeliveryLink;

      case 'instant':
        return loc.processingInstant;

      case '24_hours':
        return loc.processing24Hours;

      case '3_days':
        return loc.processing3Days;

      default:
        if (value.isEmpty) {
          return '-';
        }

        return value
            .replaceAll(
              '_',
              ' ',
            )
            .toUpperCase();
    }
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
            loc.digitalVoucherPaymentInvalidProductTitle,
        message:
            loc.digitalVoucherPaymentInvalidProductMessage,
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
      'NEW DIGITAL VOUCHER PAYMENT',
    );
    debugPrint(
      '========================================',
    );
    debugPrint(
      'RefId       : $refId',
    );
    debugPrint(
      'Product     : ${widget.productCode}',
    );
    debugPrint(
      'Name        : ${widget.productName}',
    );
    debugPrint(
      'Field ID    : ${widget.fieldId}',
    );
    debugPrint(
      'Field Type  : ${widget.fieldType}',
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
      'Processing  : ${widget.processingTime}',
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
      // ======================================================================
      // PREPARING QR
      // ======================================================================

      _showLoadingDialog();

      loadingDialogVisible =
          true;

      // ======================================================================
      // PEGE PAY AMOUNT
      //
      // TEST:
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

      // ======================================================================
      // OPEN QR WEBVIEW
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

          // ==================================================================
          // CUSTOMER ALREADY PAID.
          //
          // Do not allow another QR.
          // ==================================================================

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

          // ==================================================================
          // PROCESSING VOUCHER
          // ==================================================================

          _showReceiptProcessingDialog();

          bool processingDialogVisible =
              true;

          IimmpactPaymentResult?
              iimmpactResult;

          try {
            debugPrint('');
            debugPrint(
              '========================================',
            );
            debugPrint(
              'DIGITAL VOUCHER -> IIMMPACT',
            );
            debugPrint(
              '========================================',
            );
            debugPrint(
              'RefId   : $_currentRefId',
            );
            debugPrint(
              'Product : ${widget.productCode}',
            );
            debugPrint(
              'Account : [NOT REQUIRED]',
            );
            debugPrint(
              'Amount  : ${widget.baseAmount}',
            );
            debugPrint(
              'Order   : $successfulOrderNo',
            );
            debugPrint(
              '========================================',
            );

            // ================================================================
            // IIMMPACT DIGITAL VOUCHER
            //
            // IMPORTANT:
            //
            // account:
            //   Digital Voucher Page 4 does not collect account/phone.
            //
            // accountRequired:
            //   false
            //
            // amount:
            //   baseAmount
            //
            // DO NOT SEND totalAmount.
            //
            // totalAmount may include our catalog price adjustment.
            //
            // extras:
            //   {}
            //
            // Current Digital Voucher catalog pricing resolves the selected
            // option to its amount, so the amount itself is sent to /v2/topup.
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
                  widget.topupAmount,

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

            debugPrint('');
            debugPrint(
              '========================================',
            );
            debugPrint(
              'DIGITAL VOUCHER FINAL RESULT',
            );
            debugPrint(
              '========================================',
            );
            debugPrint(
              'Status      : ${iimmpactResult.status}',
            );
            debugPrint(
              'Product     : ${iimmpactResult.product}',
            );
            debugPrint(
              'Amount      : ${iimmpactResult.amount}',
            );
            debugPrint(
              'RefId       : ${iimmpactResult.refId}',
            );
            debugPrint(
              'SN          : ${iimmpactResult.serialNumber}',
            );
            debugPrint(
              'PIN         : ${iimmpactResult.pin}',
            );
            debugPrint(
              'Expiry      : ${iimmpactResult.expiry}',
            );
            debugPrint(
              'VoucherLink : ${iimmpactResult.voucherLink}',
            );
            debugPrint(
              'Note        : ${iimmpactResult.note}',
            );
            debugPrint(
              '========================================',
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
                        .digitalVoucherPaymentProviderRejected,

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
                    .digitalVoucherPaymentProviderRefunded,

                result:
                    iimmpactResult,
              );
            }

            // ================================================================
            // VOUCHER NEEDS FINAL SUCCESS
            //
            // PIN/LINK/SN may only be returned after final success.
            // ================================================================

            if (!iimmpactResult
                .isSuccessful) {
              throw IimmpactPaymentException(
                '${loc.digitalVoucherPaymentStillProcessing}\n\n'
                '${loc.digitalVoucherPaymentReference}:\n'
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
              '[DigitalVoucherQrPaymentPage] '
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

            // ================================================================
            // IMPORTANT:
            //
            // Customer payment was already successful.
            // Do NOT create another QR.
            // ================================================================

            await _showMessage(
              title:
                  loc
                      .digitalVoucherPaymentProviderErrorTitle,

              message:
                  '$message\n\n'
                  '${loc.digitalVoucherPaymentAlreadyReceivedWarning}',

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
                      DigitalVoucherReceiptPage(
                data:
                    DigitalVoucherReceiptData(
                  productName:
                      widget.productName,

                  productCode:
                      widget.productCode,
                  
                  imageUrl:
                      widget.imageUrl,

                  fieldId:
                      widget.fieldId,

                  fieldType:
                      widget.fieldType,

                  optionCode:
                      widget.optionCode ?? '',

                  optionName:
                      widget.optionName ?? '',

                  optionDescription:
                      widget.optionDescription ?? '',

                  baseAmount:
                      widget.baseAmount,

                  serviceAdjustment:
                      widget.serviceAdjustment,

                  totalAmount:
                      widget.totalAmount,

                  processingTime:
                      widget.processingTime,

                  instructionNote:
                      widget.note,

                  refId:
                      finalResult
                              .refId
                              .isNotEmpty
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

                  providerNote:
                      finalResult.note,
                ),
              ),
            ),
          );
        },

        // ====================================================================
        // PAYMENT CANCEL
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
        '[DigitalVoucherQrPaymentPage] '
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
  // RESTORE FLUTTER WINDOW
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
        '[DigitalVoucherQrPaymentPage] '
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
      context:
          context,

      useRootNavigator:
          true,

      barrierDismissible:
          false,

      builder: (_) {
        return PopScope(
          canPop:
              false,

          child:
              Material(
            color:
                const Color(
              0xFF071A2F,
            ).withOpacity(
              0.82,
            ),

            child:
                Center(
              child:
                  Container(
                width:
                    650,

                padding:
                    const EdgeInsets.symmetric(
                  horizontal:
                      46,
                  vertical:
                      44,
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
                      0xFFF1CBD6,
                    ),
                    width:
                        2,
                  ),
                ),

                child:
                    Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Container(
                      width:
                          138,
                      height:
                          138,

                      decoration:
                          BoxDecoration(
                        color:
                            _light,

                        shape:
                            BoxShape.circle,

                        border:
                            Border.all(
                          color:
                              _primary,
                          width:
                              5,
                        ),
                      ),

                      child:
                          const Icon(
                        Icons.qr_code_2_rounded,

                        size:
                            88,

                        color:
                            _primary,
                      ),
                    ),

                    const SizedBox(
                      height:
                          28,
                    ),

                    Text(
                      loc
                          .digitalVoucherPreparingQrPayment,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            _dark,

                        fontSize:
                            42,

                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height:
                          28,
                    ),

                    Text(
                      '${widget.productName}\n'
                      '${_formatAmount(widget.totalAmount)}',

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF294A73,
                        ),

                        fontSize:
                            27,

                        height:
                            1.4,

                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height:
                          30,
                    ),

                    const SizedBox(
                      width:
                          72,
                      height:
                          72,

                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            7,

                        color:
                            _primary,

                        backgroundColor:
                            Color(
                          0xFFFFDFE8,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height:
                          24,
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

                        fontSize:
                            22,

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
  // PROCESSING VOUCHER DIALOG
  // ==========================================================================

  void _showReceiptProcessingDialog() {
    final loc =
        AppLocalizations.of(context)!;

    showDialog<void>(
      context:
          context,

      useRootNavigator:
          true,

      barrierDismissible:
          false,

      builder: (_) {
        return PopScope(
          canPop:
              false,

          child:
              Material(
            color:
                const Color(
              0xFF061425,
            ).withOpacity(
              0.88,
            ),

            child:
                Center(
              child:
                  Container(
                width:
                    700,

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
                      0xFFF1CBD6,
                    ),
                    width:
                        3,
                  ),
                ),

                child:
                    Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    const SizedBox(
                      width:
                          148,
                      height:
                          148,

                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            8,

                        color:
                            _primary,

                        backgroundColor:
                            _light,
                      ),
                    ),

                    const SizedBox(
                      height:
                          30,
                    ),

                    Text(
                      loc
                          .digitalVoucherProcessingTitle,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            _dark,

                        fontSize:
                            42,

                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height:
                          14,
                    ),

                    Text(
                      loc
                          .digitalVoucherProcessingMessage,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF5B6B7B,
                        ),

                        fontSize:
                            25,

                        height:
                            1.4,

                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height:
                          28,
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

                        fontSize:
                            29,

                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    if (_hasOptionName) ...[
                      const SizedBox(
                        height:
                            9,
                      ),

                      Text(
                        widget.optionName!,

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF607086,
                          ),

                          fontSize:
                              24,

                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],

                    const SizedBox(
                      height:
                          12,
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

                        fontSize:
                            40,

                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height:
                          22,
                    ),

                    Text(
                      loc
                          .digitalVoucherProcessingLocked,

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF685D84,
                        ),

                        fontSize:
                            21,

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
      context:
          context,

      barrierDismissible:
          false,

      builder:
          (
        dialogContext,
      ) {
        final Color accent =
            isError
                ? _red
                : _primary;

        return Dialog(
          backgroundColor:
              Colors.transparent,

          child:
              Container(
            width:
                680,

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

            child:
                Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                Icon(
                  isError
                      ? Icons.error_outline_rounded
                      : Icons.info_outline_rounded,

                  color:
                      accent,

                  size:
                      100,
                ),

                const SizedBox(
                  height:
                      22,
                ),

                Text(
                  title,

                  textAlign:
                      TextAlign.center,

                  style:
                      TextStyle(
                    color:
                        accent,

                    fontSize:
                        42,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height:
                      20,
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

                    fontSize:
                        25,

                    height:
                        1.45,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height:
                      30,
                ),

                SizedBox(
                  width:
                      double.infinity,

                  height:
                      80,

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

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),

                    child:
                        Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .ok,

                      style:
                          const TextStyle(
                        fontSize:
                            28,

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

      child:
          Scaffold(
        body:
            Stack(
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
              child:
                  Column(
                children: [
                  _buildHeader(
                    loc,
                  ),

                  Expanded(
                    child:
                        Padding(
                      padding:
                          const EdgeInsets.only(
                        right:
                            18,
                      ),

                      child:
                          Scrollbar(
                        thumbVisibility:
                            true,

                        trackVisibility:
                            true,

                        thickness:
                            10,

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

                          child:
                              Column(
                            children: [
                              _buildInformationCard(
                                loc,
                              ),

                              const SizedBox(
                                height:
                                    26,
                              ),

                              _buildTotalPaymentCard(
                                loc,
                              ),

                              const SizedBox(
                                height:
                                    26,
                              ),

                              _buildPaymentActionCard(
                                loc,
                              ),

                              if (_errorMessage !=
                                  null) ...[
                                const SizedBox(
                                  height:
                                      22,
                                ),

                                _buildErrorCard(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ============================================================
                  // BACK + FOOTER
                  // ============================================================

                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      70,
                      14,
                      70,
                      34,
                    ),

                    child:
                        Column(
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
                              width:
                                  620,

                              height:
                                  98,

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
                          height:
                              28,
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

                            fontSize:
                                21,

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

            // ================================================================
            // LOCK PAGE
            // ================================================================

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
        horizontal:
            30,
        vertical:
            22,
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
              0xFFC83261,
            ),
            Color(
              0xFFE65175,
            ),
            Color(
              0xFFF17C9C,
            ),
          ],
        ),
      ),

      child:
          Row(
        children: [
          const Icon(
            Icons.card_giftcard_rounded,

            color:
                Colors.white,

            size:
                54,
          ),

          const SizedBox(
            width:
                20,
          ),

          Expanded(
            child:
                Text(
              loc
                  .digitalVoucherPaymentTitle
                  .toUpperCase(),

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Colors.white,

                fontSize:
                    40,

                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(
            width:
                20,
          ),

          const Icon(
            Icons.shield_outlined,

            color:
                Colors.white,

            size:
                50,
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
            0xFFF1CBD6,
          ),

          width:
              2,
        ),
      ),

      child:
          Column(
        children: [
          _buildCardTitle(
            icon:
                Icons.card_giftcard_rounded,

            title:
                loc.digitalVoucherPaymentDetails,

            accent:
                _primary,

            background:
                _light,
          ),

          const SizedBox(
            height:
                24,
          ),

          // ==================================================================
          // PRODUCT
          // ==================================================================

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
                    0xFFC83261,
                  ),
                  Color(
                    0xFFE65175,
                  ),
                  Color(
                    0xFFF17C9C,
                  ),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(
                28,
              ),
            ),

            child:
                Column(
              children: [
                Text(
                  widget.productName,

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,

                    fontSize:
                        37,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height:
                      10,
                ),

                Text(
                  _formatProcessingTime(
                    loc,
                  ),

                  style:
                      TextStyle(
                    color:
                        Colors.white.withOpacity(
                      0.88,
                    ),

                    fontSize:
                        25,

                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================================
          // OPTION/PACKAGE
          // ==================================================================

          if (_isSelect &&
              _hasOptionName) ...[
            const SizedBox(
              height:
                  22,
            ),

            _buildInfoTile(
              icon:
                  Icons.sell_rounded,

              label:
                  loc.digitalVoucherSelectedPackage,

              value:
                  widget.optionName!,
            ),
          ],

          if (_hasOptionDescription) ...[
            const SizedBox(
              height:
                  16,
            ),

            _buildInfoTile(
              icon:
                  Icons.description_outlined,

              label:
                  loc.digitalVoucherOptionDetails,

              value:
                  widget.optionDescription!,
            ),
          ],

          const SizedBox(
            height:
                16,
          ),

          // ==================================================================
          // VOUCHER VALUE
          // ==================================================================

          _buildInfoTile(
            icon:
                Icons.payments_rounded,

            label:
                loc.digitalVoucherVoucherValue,

            value:
                _formatAmount(
              widget.baseAmount,
            ),
          ),

          // ==================================================================
          // ADJUSTMENT
          // ==================================================================

          if (widget
                  .serviceAdjustment
                  .abs() >=
              0.005) ...[
            const SizedBox(
              height:
                  16,
            ),

            _buildInfoTile(
              icon:
                  Icons.tune_rounded,

              label:
                  loc
                      .digitalVoucherServiceAdjustment,

              value:
                  _formatSignedAmount(
                widget.serviceAdjustment,
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

          width:
              2.5,
        ),
      ),

      child:
          Column(
        children: [
          _buildCardTitle(
            icon:
                Icons.account_balance_wallet_rounded,

            title:
                loc.digitalVoucherTotalPayment,

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
            height:
                22,
          ),

          FittedBox(
            fit:
                BoxFit.scaleDown,

            child:
                Text(
              _formatAmount(
                widget.totalAmount,
              ),

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF125B2D,
                ),

                fontSize:
                    82,

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

        border:
            Border.all(
          color:
              const Color(
            0xFFF1CBD6,
          ),

          width:
              2,
        ),
      ),

      child:
          Column(
        children: [
          _buildCardTitle(
            icon:
                Icons.qr_code_2_rounded,

            title:
                loc.paymentSectionTitle,

            accent:
                _primary,

            background:
                _light,
          ),

          const SizedBox(
            height:
                24,
          ),

          const Icon(
            Icons.qr_code_scanner_rounded,

            color:
                _green,

            size:
                100,
          ),

          const SizedBox(
            height:
                18,
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

              fontSize:
                  25,

              fontWeight:
                  FontWeight.w700,

              height:
                  1.4,
            ),
          ),

          const SizedBox(
            height:
                24,
          ),

          SizedBox(
            width:
                double.infinity,

            height:
                126,

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

              child:
                  Row(
                children: [
                  Container(
                    width:
                        84,

                    height:
                        84,

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        22,
                      ),
                    ),

                    child:
                        _isBusy
                            ? const Padding(
                                padding:
                                    EdgeInsets.all(
                                  21,
                                ),

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      4,

                                  color:
                                      _green,
                                ),
                              )
                            : const Icon(
                                Icons.qr_code_2_rounded,

                                color:
                                    _green,

                                size:
                                    58,
                              ),
                  ),

                  const SizedBox(
                    width:
                        22,
                  ),

                  Expanded(
                    child:
                        Text(
                      _isBusy
                          ? loc
                              .preparingQr
                              .toUpperCase()
                          : loc
                              .payWithDuitNowQr
                              .toUpperCase(),

                      style:
                          const TextStyle(
                        fontSize:
                            29,

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
                      fontSize:
                          25,

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
          width:
              58,

          height:
              58,

          decoration:
              BoxDecoration(
            color:
                background,

            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),

          child:
              Icon(
            icon,

            color:
                accent,

            size:
                34,
          ),
        ),

        const SizedBox(
          width:
              15,
        ),

        Flexible(
          child:
              Text(
            title.toUpperCase(),

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  Color(
                0xFF193A5A,
              ),

              fontSize:
                  29,

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

      child:
          Row(
        children: [
          Icon(
            icon,

            color:
                _primary,

            size:
                40,
          ),

          const SizedBox(
            width:
                18,
          ),

          Expanded(
            child:
                Column(
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

                    fontSize:
                        22,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height:
                      7,
                ),

                Text(
                  value,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF182D43,
                    ),

                    fontSize:
                        30,

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

          width:
              2,
        ),
      ),

      child:
          Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,

            color:
                _red,

            size:
                42,
          ),

          const SizedBox(
            width:
                18,
          ),

          Expanded(
            child:
                Text(
              _errorMessage ?? '',

              style:
                  const TextStyle(
                color:
                    _red,

                fontSize:
                    22,

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