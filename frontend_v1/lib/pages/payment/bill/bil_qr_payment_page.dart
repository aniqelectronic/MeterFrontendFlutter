import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/resit/bill/bill_receipt_page.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_payment_service.dart';
import 'package:frontend_v1/services/iimmpact/iimmpact_refid_service.dart';

import 'package:frontend_v1/services/pegepay/pegepay_service.dart';
import 'package:frontend_v1/services/pegepay/pegepay_webview_helper.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:window_manager/window_manager.dart';

import 'package:frontend_v1/pages/resit/bill/ptptn_receipt_page.dart';

// ============================================================================
// QR PAYMENT RESULT
// ============================================================================

class BilQrPaymentResult {
  final String refId;

  final String orderNo;
  final String bankTransactionNo;

  final String billType;
  final String billCode;
  final String accountNumber;

  final double billAmount;
  final double totalAmount;

  const BilQrPaymentResult({
    required this.refId,
    required this.orderNo,
    required this.bankTransactionNo,
    required this.billType,
    required this.billCode,
    required this.accountNumber,
    required this.billAmount,
    required this.totalAmount,
  });
}

// ============================================================================
// SHARED QR PAYMENT PAGE
// ============================================================================
//
// USED BY:
//
// - Electric
// - Water
// - Broadband
// - Entertainment
// - Telco Postpaid
// - Mobile PIN
//
// ============================================================================
//
// PAYMENT FLOW:
//
// 1. Customer confirms amount.
// 2. PegePay DuitNow QR is created.
// 3. Customer completes DuitNow payment.
// 4. PegePay reports SUCCESS.
// 5. Flutter calls IIMMPACT:
//
//        POST /v2/topup
//
// 6. If IIMMPACT returns:
//
//        Accepted
//        Processing
//
//    poll again using the SAME refid.
//
// 7. Continue only when:
//
//        status == "Succesful"
//
//    IMPORTANT:
//    IIMMPACT spells this as "Succesful".
//
// 8. Mobile PIN additionally extracts:
//
//        sn
//        pin
//        expiry
//        note
//        voucherlink
//
// 9. Open receipt.
//
// ============================================================================
//
// IMPORTANT PAYMENT VALUES:
//
// billAmount
// = amount sent to IIMMPACT.
//
// totalAmount
// = amount customer pays through PegePay.
//
// Example Mobile PIN:
//
// PIN denomination    RM10.00
// Customer adjustment +RM0.50
//
// IIMMPACT amount     RM10.00
// PegePay amount      RM10.50
//
// ============================================================================

class BilQrPaymentPage extends StatefulWidget {
  /// Provider/product display name.
  ///
  /// Examples:
  /// TNB
  /// Celcom Postpaid
  /// Celcom Pin
  final String billType;

  /// IIMMPACT product code.
  ///
  /// Examples:
  /// FP
  /// CB
  /// CP
  final String billCode;

  /// IIMMPACT account/recipient identifier.
  ///
  /// For normal bills:
  /// bill account/mobile number.
  ///
  /// IMPORTANT:
  /// Mobile PIN /v2/topup also requires account.
  /// Do not leave this empty when real Mobile PIN execution is enabled.
  final String accountNumber;

  /// Amount sent to IIMMPACT.
  final double billAmount;

  /// Amount charged to customer.
  final double totalAmount;

  // ==========================================================================
  // TELCO POSTPAID
  // ==========================================================================

  final bool useTelcoReceipt;

  // ==========================================================================
  // MOBILE PIN
  // ==========================================================================

  final bool useMobilePinReceipt;

  // ==========================================================================
  // EWALLET
  // ==========================================================================

  final bool useEWalletPinReceipt;
  final bool useEWalletPinlessReceipt;

  final EWalletReceiptExtraData? eWalletReceiptData;

  final MobilePinReceiptExtraData? mobilePinReceiptData;

  // ==========================================================================
  // PTPTN
  // ==========================================================================

  final bool usePtptnReceipt;

  final String ptptnNric;

  final String ptptnSubproductCode;

  final String ptptnAccountType;

  final String ptptnAccountCategory;

  final double ptptnServiceAdjustment;

  // ==========================================================================
  // IIMMPACT PRODUCT-SPECIFIC EXTRAS
  // ==========================================================================

  final Map<String, dynamic>
      iimmpactExtras;

  const BilQrPaymentPage({
    super.key,
    required this.billType,
    required this.billCode,
    required this.accountNumber,
    required this.billAmount,
    required this.totalAmount,

  // ==========================================================================
  // TELCO POSTPAID
  // ==========================================================================

    this.useTelcoReceipt = false,

  // ==========================================================================
  // MOBILE PIN
  // ==========================================================================

    this.useMobilePinReceipt = false,
    this.mobilePinReceiptData,

  // ==========================================================================
  // EWALLET
  // ==========================================================================

    this.useEWalletPinReceipt = false,
    this.useEWalletPinlessReceipt = false,
    this.eWalletReceiptData,

    // ========================================================================
    // PTPTN
    // ========================================================================

    this.usePtptnReceipt = false,

    this.ptptnNric = '',

    this.ptptnSubproductCode = '',

    this.ptptnAccountType = '',

    this.ptptnAccountCategory = '',

    this.ptptnServiceAdjustment = 0,

    // ========================================================================
    // IIMMPACT EXTRAS
    // ========================================================================

    this.iimmpactExtras =
        const <String, dynamic>{},
  });

  @override
  State<BilQrPaymentPage> createState() =>
      _BilQrPaymentPageState();
}

class _BilQrPaymentPageState extends State<BilQrPaymentPage> {
  bool _isCreatingOrder = false;

  bool _isProcessingReceipt = false;

  /// Once PegePay says payment succeeded, keep this true.
  ///
  /// IMPORTANT:
  /// We must NOT allow another QR payment for the same customer flow if
  /// IIMMPACT later returns Processing/Failed.
  ///
  /// Otherwise the customer could accidentally pay twice.
  bool _paymentCompleted = false;

  String? _errorMessage;

  // ==========================================================================
  // IIMMPACT REFID
  // ==========================================================================

  String? _transactionRefId;

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

  bool get _isBusy {
    return _isCreatingOrder ||
        _isProcessingReceipt;
  }

  // ==========================================================================
  // SAFE DISPLAY VALUES
  // ==========================================================================

  String get _safeBillType {
    final String value =
        widget.billType.trim();

    if (value.isNotEmpty) {
      return value;
    }

    final String code =
        widget.billCode.trim();

    if (code.isNotEmpty) {
      return code;
    }

    return AppLocalizations.of(context)!
        .billPayment;
  }

  String get _safeBillCode {
    final String value =
        widget.billCode.trim();

    if (value.isEmpty) {
      return '-';
    }

    return value.toUpperCase();
  }

  String get _safeAccountNumber {
    final String value =
        widget.accountNumber.trim();

    if (value.isEmpty) {
      return '-';
    }

    return value;
  }

  String _formatAmount(
    double amount,
  ) {
    return 'RM ${amount.toStringAsFixed(2)}';
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
    // VALIDATE AMOUNTS
    // ========================================================================

    if (widget.totalAmount <= 0 ||
        widget.billAmount <= 0) {
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
    // VALIDATE IIMMPACT PRODUCT
    // ========================================================================

    if (widget.billCode
        .trim()
        .isEmpty) {
      await _showMessage(
        title:
            'Invalid Product',
        message:
            'IIMMPACT product code is missing.',
        isError:
            true,
      );

      return;
    }

    // ========================================================================
    // IMPORTANT - MOBILE PIN ACCOUNT
    // ========================================================================
    //
    // /v2/topup documentation says:
    //
    // account = REQUIRED.
    //
    // At the moment your Mobile PIN page may still pass:
    //
    // accountNumber: ''
    //
    // We intentionally BLOCK payment BEFORE the user pays.
    //
    // This is much safer than:
    //
    // Customer pays DuitNow
    //        ↓
    // IIMMPACT rejects account
    //
    // Once you confirm what IIMMPACT expects for PIN products,
    // pass that value from PMOBILEPIN4PAGE.
    //
    // ========================================================================

    if (widget.useMobilePinReceipt &&
        widget.accountNumber
            .trim()
            .isEmpty) {
      await _showMessage(
        title:
            'Mobile PIN Not Ready',
        message:
            'The IIMMPACT account value for Mobile PIN has not been '
            'configured yet. Payment has been blocked to prevent the '
            'customer from being charged without receiving a PIN.',
        isError:
            true,
      );

      return;
    }

    // ========================================================================
    // GENERATE STABLE REFID
    // ========================================================================

    final String refId =
        _currentRefId;

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'NEW PAYMENT SESSION',
    );
    debugPrint(
      '========================================',
    );
    debugPrint(
      'RefId          : $refId',
    );
    debugPrint(
      'Product        : ${widget.billCode}',
    );
    debugPrint(
      'Account        : ${widget.accountNumber}',
    );
    debugPrint(
      'IIMMPACT Amount: ${widget.billAmount}',
    );
    debugPrint(
      'Customer Total : ${widget.totalAmount}',
    );
    debugPrint(
      'Mobile PIN     : ${widget.useMobilePinReceipt}',
    );
    debugPrint(
      'Telco Postpaid : ${widget.useTelcoReceipt}',
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
      // ======================================================================
      // PREPARING QR DIALOG
      // ======================================================================

      _showLoadingDialog();

      loadingDialogVisible =
          true;

      // ======================================================================
      // PEGE PAY PAYMENT AMOUNT
      // ======================================================================
      //
      // TEST MODE:
      //
      // Keep RM0.01 while testing.
      //
      // PRODUCTION:
      //
      // final double paymentAmount =
      //     widget.totalAmount;
      //
      // ======================================================================

      final double paymentAmount =
          0.01;

      debugPrint(
        '[BilQrPaymentPage] '
        'PegePay amount = '
        '$paymentAmount',
      );

      // ======================================================================
      // CREATE PEGE PAY ORDER
      // ======================================================================

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

      // ======================================================================
      // CLOSE PREPARING DIALOG
      // ======================================================================

      if (loadingDialogVisible) {
        Navigator.of(
          context,
          rootNavigator:
              true,
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
          'PegePay did not return a valid iframe URL or order number.',
        );
      }

      debugPrint(
        '[BilQrPaymentPage] '
        'PegePay order created: $orderNo',
      );

      // ======================================================================
      // OPEN PEGE PAY WEBVIEW
      // ======================================================================

      await PegePayWebViewHelper.open(
        iframeUrl:
            iframeUrl,
        orderNo:
            orderNo,

        // ====================================================================
        // PEGE PAY SUCCESS
        // ====================================================================

        onSuccess: (
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

          debugPrint('');
          debugPrint(
            '========================================',
          );
          debugPrint(
            'PEGE PAY SUCCESS',
          );
          debugPrint(
            '========================================',
          );
          debugPrint(
            'Order No : $successfulOrderNo',
          );
          debugPrint(
            'Bank Trx : $bankTransactionNo',
          );
          debugPrint(
            'RefId    : $_currentRefId',
          );
          debugPrint(
            '========================================',
          );
          debugPrint('');

          if (!mounted) {
            return;
          }

          // ==================================================================
          // IMPORTANT
          //
          // Customer payment is now completed.
          //
          // Do NOT let customer start another QR transaction from this page.
          // ==================================================================

          setState(() {
            _paymentCompleted =
                true;

            _isCreatingOrder =
                false;

            _isProcessingReceipt =
                true;
          });

          // ==================================================================
          // RESTORE FLUTTER WINDOW
          // ==================================================================

          await _restoreFlutterWindow();

          if (!mounted) {
            return;
          }

          // ==================================================================
          // SHOW PROCESSING DIALOG
          //
          // Keep this dialog visible while IIMMPACT is actually processing.
          // ==================================================================

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
            // IIMMPACT REQUEST
            // ================================================================
            //
            // amount:
            //
            // widget.billAmount
            //
            // NOT:
            //
            // widget.totalAmount
            //
            // Because totalAmount can include our catalog adjustment.
            //
            // ================================================================

            debugPrint('');
            debugPrint(
              '========================================',
            );
            debugPrint(
              'SENDING TO IIMMPACT',
            );
            debugPrint(
              '========================================',
            );
            debugPrint(
              'RefId   : $_currentRefId',
            );
            debugPrint(
              'Product : ${widget.billCode}',
            );
            debugPrint(
              'Account : ${widget.accountNumber}',
            );
            debugPrint(
              'Amount  : ${widget.billAmount}',
            );
            debugPrint(
              'Order   : $successfulOrderNo',
            );
            debugPrint(
              '========================================',
            );
            debugPrint('');

            iimmpactResult =
                await IimmpactPaymentService
                    .waitForFinalStatus(
              refId:
                  _currentRefId,

              product:
                  widget.billCode,

              account:
                  widget.accountNumber,

              amount:
                  widget.billAmount,

              // PegePay order can help us trace the purchase.
              remarks:
                  successfulOrderNo,

              extras:
                  widget.iimmpactExtras,

              // IIMMPACT recommends 5-10 sec polling.
              interval:
                  const Duration(
                seconds: 6,
              ),

              // First request + subsequent polling.
              //
              // 10 attempts gives roughly ~1 minute.
              maxAttempts:
                  10,
            );

            debugPrint('');
            debugPrint(
              '========================================',
            );
            debugPrint(
              'IIMMPACT FINAL RESULT',
            );
            debugPrint(
              '========================================',
            );
            debugPrint(
              'HTTP       : '
              '${iimmpactResult.httpStatusCode}',
            );
            debugPrint(
              'Status Code: '
              '${iimmpactResult.statusCode}',
            );
            debugPrint(
              'Status     : '
              '${iimmpactResult.status}',
            );
            debugPrint(
              'Product    : '
              '${iimmpactResult.product}',
            );
            debugPrint(
              'Account    : '
              '${iimmpactResult.account}',
            );
            debugPrint(
              'Amount     : '
              '${iimmpactResult.amount}',
            );
            debugPrint(
              'RefId      : '
              '${iimmpactResult.refId}',
            );

            if (widget.useMobilePinReceipt ||
            widget.useEWalletPinReceipt) {
              debugPrint(
                'SN         : '
                '${iimmpactResult.serialNumber}',
              );
              debugPrint(
                'PIN        : '
                '${iimmpactResult.pin}',
              );
              debugPrint(
                'Expiry     : '
                '${iimmpactResult.expiry}',
              );
              debugPrint(
                'Note       : '
                '${iimmpactResult.note}',
              );
              debugPrint(
                'Voucher URL: '
                '${iimmpactResult.voucherLink}',
              );
            }

            debugPrint(
              '========================================',
            );
            debugPrint('');

            // ================================================================
            // IIMMPACT STATUS HANDLING
            // ================================================================
            //
            // KIOSK BUSINESS RULE:
            //
            // Succesful
            // -> completed by provider
            // -> continue to receipt
            //
            // Accepted / Processing
            // -> transaction already accepted by IIMMPACT
            // -> provider may still be processing
            // -> continue to receipt
            //
            // Failed / Refund
            // -> do NOT continue to receipt
            //
            // ================================================================

            // ================================================================
            // FAILED
            // ================================================================

            if (iimmpactResult.isFailed) {
              throw IimmpactPaymentException(
                iimmpactResult.remarks.isNotEmpty
                    ? iimmpactResult.remarks
                    : 'The provider rejected the transaction.',
                result: iimmpactResult,
              );
            }

            // ================================================================
            // REFUND
            // ================================================================

            if (iimmpactResult.isRefund) {
              throw IimmpactPaymentException(
                'The provider transaction was refunded.',
                result: iimmpactResult,
              );
            }

            // ================================================================
            // ACCEPTED / PROCESSING / SUCCESSFUL
            // ================================================================

          final bool requiresFinalSuccess =
              widget.useMobilePinReceipt ||
              widget.useEWalletPinReceipt;

          final bool canProceedToReceipt =
              iimmpactResult.isSuccessful ||
              (!requiresFinalSuccess &&
                  iimmpactResult.isPending);

            if (!canProceedToReceipt) {
              throw IimmpactPaymentException(
                'Unexpected provider status: '
                '${iimmpactResult.status}',
                result: iimmpactResult,
              );
            }

            // ================================================================
            // CONTINUE TO RECEIPT
            // ================================================================

            if (iimmpactResult.isSuccessful) {
              debugPrint(
                '[BilQrPaymentPage] '
                'IIMMPACT transaction completed successfully. '
                'Proceeding to receipt.',
              );
            } else {
              debugPrint(
                '[BilQrPaymentPage] '
                'IIMMPACT transaction accepted and still processing. '
                'Proceeding to receipt. '
                'Status: ${iimmpactResult.status}',
              );
            }
          } catch (error, stackTrace) {
            debugPrint(
              '[BilQrPaymentPage] '
              'IIMMPACT execution error: '
              '$error',
            );

            debugPrintStack(
              stackTrace:
                  stackTrace,
            );

            // ================================================================
            // CLOSE PROCESSING DIALOG
            // ================================================================

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

            // ================================================================
            // IMPORTANT:
            //
            // PegePay already succeeded.
            //
            // Therefore do NOT reset:
            //
            // _paymentCompleted = false
            //
            // Otherwise customer could accidentally pay twice.
            // ================================================================

            final String message =
                error is IimmpactPaymentException
                    ? error.message
                    : error.toString();

            await _showMessage(
              title:
                  'Provider Processing Error',

              message:
                  '$message\n\n'
                  'Payment Reference:\n'
                  '$_currentRefId\n\n'
                  'The DuitNow payment has already been received. '
                  'Do not make another payment for the same transaction.',

              isError:
                  true,
            );

            return;
          }

          // ==================================================================
          // CLOSE PROCESSING DIALOG AFTER SUCCESS
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
          // BUILD MOBILE PIN RESULT
          // ==================================================================

          MobilePinReceiptExtraData?
              finalMobilePinData;

          if (widget.useMobilePinReceipt) {
            final MobilePinReceiptExtraData?
                original =
                widget.mobilePinReceiptData;

            if (original == null) {
              setState(() {
                _isProcessingReceipt =
                    false;
              });

              await _showMessage(
                title:
                    'Mobile PIN Error',
                message:
                    'Mobile PIN receipt information is missing.',
                isError:
                    true,
              );

              return;
            }

            // ================================================================
            // IIMMPACT MOBILE PIN RESPONSE
            // ================================================================
            //
            // Example:
            //
            // data.sn
            // data.pin
            // data.expiry
            // data.note
            // data.voucherlink
            //
            // ================================================================

            final MobilePinReceiptItem
                pinItem =
                MobilePinReceiptItem(
              refId:
                  iimmpactResult
                          .refId
                          .isNotEmpty
                      ? iimmpactResult
                          .refId
                      : _currentRefId,

              serialNumber:
                  iimmpactResult
                      .serialNumber,

              pin:
                  iimmpactResult
                      .pin,

              expiry:
                  iimmpactResult
                      .expiry,

              note:
                  iimmpactResult
                      .note,

              voucherLink:
                  iimmpactResult
                      .voucherLink,
            );

            // ================================================================
            // ONE PIN ONLY FOR NOW
            //
            // FUTURE:
            // multiple PIN purchase can use multiple MobilePinReceiptItem.
            // ================================================================

            finalMobilePinData =
                MobilePinReceiptExtraData(
              providerName:
                  original
                      .providerName,

              productCode:
                  original
                      .productCode,

              denomination:
                  original
                      .denomination,

              quantity:
                  1,

              customerTotal:
                  original
                      .customerTotal,

              pins: [
                pinItem,
              ],
            );
          }



    // ==================================================================
    // BUILD E-WALLET RESULT
    // ==================================================================

    EWalletReceiptExtraData?
        finalEWalletData;

    if (widget.useEWalletPinReceipt ||
        widget.useEWalletPinlessReceipt) {
      final EWalletReceiptExtraData?
          original =
          widget.eWalletReceiptData;

      if (original == null) {
        setState(() {
          _isProcessingReceipt = false;
        });

        await _showMessage(
          title: 'E-Wallet Error',
          message:
              'E-Wallet receipt information is missing.',
          isError: true,
        );

        return;
      }

      finalEWalletData =
          EWalletReceiptExtraData(
        providerName:
            original.providerName,

        productCode:
            original.productCode,

        phoneNumber:
            original.phoneNumber,

        reloadAmount:
            original.reloadAmount,

        serviceAdjustment:
            original.serviceAdjustment,

        customerTotal:
            original.customerTotal,

        isPin:
            original.isPin,

        providerNote:
           original.providerNote,

        // These values come from IIMMPACT.
        // For PIN products they may contain the actual PIN/voucher.
        serialNumber:
            iimmpactResult.serialNumber,

        pin:
            iimmpactResult.pin,

        expiry:
            iimmpactResult.expiry,

        note:
            iimmpactResult.note,

        voucherLink:
            iimmpactResult.voucherLink,
      );
    }

          if (!mounted) {
            return;
          }
          // ==========================================================================
          // PTPTN RECEIPT
          // ==========================================================================

          if (widget.usePtptnReceipt) {
            Navigator.pushReplacement(
              context,

              MaterialPageRoute(
                settings:
                    const RouteSettings(
                  name: '/receipt',
                ),

                builder:
                    (_) =>
                        PtptnReceiptPage(
                  data:
                      PtptnReceiptData(
                    // ================================================================
                    // PROVIDER
                    // ================================================================

                    providerName:
                        widget.billType,

                    productCode:
                        widget.billCode,

                    // ================================================================
                    // PTPTN ACCOUNT
                    // ================================================================

                    nric:
                        widget.ptptnNric,

                    subproductCode:
                        widget
                            .ptptnSubproductCode,

                    accountType:
                        widget
                            .ptptnAccountType,

                    accountCategory:
                        widget
                            .ptptnAccountCategory,

                    accountNumber:
                        widget.accountNumber,

                    // ================================================================
                    // PAYMENT
                    // ================================================================

                    paymentAmount:
                        widget.billAmount,

                    serviceAdjustment:
                        widget
                            .ptptnServiceAdjustment,

                    totalAmount:
                        widget.totalAmount,

                    // ================================================================
                    // TRANSACTION
                    // ================================================================

                    refId:
                        iimmpactResult!
                                .refId
                                .isNotEmpty
                            ? iimmpactResult.refId
                            : _currentRefId,

                    orderNo:
                        successfulOrderNo,

                    bankTransactionNo:
                        bankTransactionNo,

                    paymentMethod:
                        'DuitNow QR',

                    providerStatus:
                        iimmpactResult.status,

                    paidAt:
                        DateTime.now(),
                  ),
                ),
              ),
            );

            return;
          }
          // ==================================================================
          // OPEN RECEIPT
          // ==================================================================

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              settings:
                  const RouteSettings(
                name:
                    '/receipt',
              ),
              builder:
                  (_) =>
                      BillReceiptPage(
                data:
                    BillReceiptData(
                  // ==========================================================
                  // IIMMPACT REFERENCE
                  // ==========================================================

                  refId:
                      iimmpactResult!
                              .refId
                              .isNotEmpty
                          ? iimmpactResult
                              .refId
                          : _currentRefId,

                  // ==========================================================
                  // SHARED PAYMENT DATA
                  // ==========================================================

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

                  orderNo:
                      successfulOrderNo,

                  bankTransactionNo:
                      bankTransactionNo,

                  paymentMethod:
                      'DuitNow QR',

                  paidAt:
                      DateTime.now(),

                  // ==========================================================
                  // TELCO POSTPAID
                  // ==========================================================

                  telco:
                      widget.useTelcoReceipt
                          ? TelcoReceiptExtraData(
                              providerName:
                                  widget.billType,

                              productCode:
                                  widget.billCode,

                              accountNumber:
                                  widget.accountNumber,

                              providerAmount:
                                  widget.billAmount,

                              serviceAdjustment:
                                  widget.totalAmount -
                                      widget.billAmount,

                              customerTotal:
                                  widget.totalAmount,
                            )
                          : null,

                  // ==========================================================
                  // MOBILE PIN
                  //
                  // Now this contains the REAL PIN response.
                  // ==========================================================

                  mobilePin:
                      widget.useMobilePinReceipt
                          ? finalMobilePinData
                          : null,

                  // ==========================================================
                  // E-WALLET
                  // ==========================================================

                  eWallet:
                      (widget.useEWalletPinReceipt ||
                              widget.useEWalletPinlessReceipt)
                          ? finalEWalletData
                          : null,
                ),
              ),
            ),
          );
        },

        // ====================================================================
        // PEGE PAY CANCEL
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

          final loc =
              AppLocalizations.of(
            context,
          )!;

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
                seconds:
                    3,
              ),
            ),
          );
        },
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[BilQrPaymentPage] '
        'QR creation/payment error: $error',
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
  // RECEIPT / PROVIDER PROCESSING DIALOG
  // ==========================================================================

  void _showReceiptProcessingDialog({
    required String orderNo,
  }) {
    final loc =
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
                      0xFFA7DCC4,
                    ),
                    width:
                        3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(
                        0.38,
                      ),
                      blurRadius:
                          42,
                      spreadRadius:
                          5,
                      offset:
                          const Offset(
                        0,
                        18,
                      ),
                    ),
                  ],
                ),
                child:
                    Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Stack(
                      alignment:
                          Alignment.center,
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
                                Color(
                              0xFF118762,
                            ),
                            backgroundColor:
                                Color(
                              0xFFDDF2E9,
                            ),
                          ),
                        ),

                        Container(
                          width:
                              108,
                          height:
                              108,
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(
                              0xFFE8F8F1,
                            ),
                            shape:
                                BoxShape.circle,
                          ),
                          child:
                              const Icon(
                            Icons.receipt_long_rounded,
                            color:
                                Color(
                              0xFF118762,
                            ),
                            size:
                                66,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height:
                          30,
                    ),

                    Text(
                      loc.billReceiptProcessingTitle,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF0B6A4D,
                        ),
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
                      loc.billReceiptProcessingMessage,
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
                        fontWeight:
                            FontWeight.w700,
                        height:
                            1.4,
                      ),
                    ),

                    const SizedBox(
                      height:
                          28,
                    ),

                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            26,
                        vertical:
                            20,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF5F8FC,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          22,
                        ),
                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFD4E1ED,
                          ),
                          width:
                              2,
                        ),
                      ),
                      child:
                          Column(
                        children: [
                          Text(
                            _safeBillType,
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

                          const SizedBox(
                            height:
                                9,
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
                                0xFF0D6D4D,
                              ),
                              fontSize:
                                  40,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),

                          const SizedBox(
                            height:
                                9,
                          ),

                          Text(
                            orderNo,
                            maxLines:
                                2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF718096,
                              ),
                              fontSize:
                                  20,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const SizedBox(
                            height:
                                10,
                          ),

                          Text(
                            _currentRefId,
                            maxLines:
                                2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF718096,
                              ),
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height:
                          22,
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color:
                              Color(
                            0xFF118762,
                          ),
                          size:
                              26,
                        ),

                        const SizedBox(
                          width:
                              10,
                        ),

                        Flexible(
                          child:
                              Text(
                            loc.billReceiptProcessingLocked,
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF407565,
                              ),
                              fontSize:
                                  21,
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
            ),
          ),
        );
      },
    );
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
        '[BilQrPaymentPage] '
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
      builder:
          (_) {
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
                      0xFFB7CAE8,
                    ),
                    width:
                        2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(
                        0.35,
                      ),
                      blurRadius:
                          36,
                      spreadRadius:
                          4,
                      offset:
                          const Offset(
                        0,
                        16,
                      ),
                    ),
                  ],
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
                            const Color(
                          0xFFE8F2FF,
                        ),
                        shape:
                            BoxShape.circle,
                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFF1469E8,
                          ),
                          width:
                              5,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .qr_code_2_rounded,
                        size:
                            88,
                        color:
                            Color(
                          0xFF1469E8,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height:
                          28,
                    ),

                    Text(
                      loc.preparingQrPayment,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF0359D2,
                        ),
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

                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            26,
                        vertical:
                            22,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF2F7FD,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFB7CAE8,
                          ),
                          width:
                              2,
                        ),
                      ),
                      child:
                          Text(
                        '${loc.paymentForBill(_safeBillType)}\n'
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
                          fontWeight:
                              FontWeight.w900,
                          height:
                              1.4,
                        ),
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
                            Color(
                          0xFF1469E8,
                        ),
                        backgroundColor:
                            Color(
                          0xFFDCE9FA,
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
  // MESSAGE
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
        final Color accentColor =
            isError
                ? const Color(
                    0xFFC62828,
                  )
                : const Color(
                    0xFF1976D2,
                  );

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
                      ? Icons
                          .error_outline_rounded
                      : Icons
                          .info_outline_rounded,
                  color:
                      accentColor,
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
                        accentColor,
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
                    fontWeight:
                        FontWeight.w700,
                    height:
                        1.45,
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
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
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

            Positioned.fill(
              child:
                  DecoratedBox(
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors: [
                      Colors.white
                          .withOpacity(
                        0.04,
                      ),
                      Colors.white
                          .withOpacity(
                        0.22,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ================================================================
            // CONTENT
            // ================================================================

            SafeArea(
              child:
                  Column(
                children: [
                  _buildHeader(),

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
                              _buildBillInformationCard(),

                              const SizedBox(
                                height:
                                    26,
                              ),

                              _buildTotalPaymentCard(),

                              const SizedBox(
                                height:
                                    26,
                              ),

                              _buildPaymentActionCard(),

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

                  // ==========================================================
                  // BOTTOM
                  // ==========================================================

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
            // TOUCH BLOCKER
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

  Widget _buildHeader() {
    final loc =
        AppLocalizations.of(context)!;

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
          begin:
              Alignment.centerLeft,
          end:
              Alignment.centerRight,
          colors: [
            Color(
              0xFF0E3B73,
            ),
            Color(
              0xFF1769B8,
            ),
            Color(
              0xFF45A9F2,
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF0D47A1,
            ).withOpacity(
              0.25,
            ),
            blurRadius:
                24,
            offset:
                const Offset(
              0,
              11,
            ),
          ),
        ],
      ),
      child:
          Row(
        children: [
          Container(
            width:
                66,
            height:
                66,
            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.16,
              ),
              borderRadius:
                  BorderRadius.circular(
                19,
              ),
            ),
            child:
                const Icon(
              Icons.payments_rounded,
              color:
                  Colors.white,
              size:
                  40,
            ),
          ),

          const SizedBox(
            width:
                20,
          ),

          Expanded(
            child:
                Text(
              loc.billPayment
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
                letterSpacing:
                    0.5,
              ),
            ),
          ),

          const SizedBox(
            width:
                20,
          ),

          Container(
            width:
                66,
            height:
                66,
            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.16,
              ),
              borderRadius:
                  BorderRadius.circular(
                19,
              ),
            ),
            child:
                const Icon(
              Icons.shield_outlined,
              color:
                  Colors.white,
              size:
                  39,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BILL INFORMATION
  // ==========================================================================

  Widget _buildBillInformationCard() {
    final loc =
        AppLocalizations.of(context)!;

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        28,
        28,
        28,
        30,
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
            0xFFD2DFEC,
          ),
          width:
              2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(
              0xFF17375E,
            ).withOpacity(
              0.13,
            ),
            blurRadius:
                28,
            offset:
                const Offset(
              0,
              13,
            ),
          ),
        ],
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildCardTitle(
            icon:
                Icons.description_rounded,
            title:
                loc.billInformationTitle,
            accentColor:
                const Color(
              0xFF1976D2,
            ),
            iconBackground:
                const Color(
              0xFFE7F1FC,
            ),
          ),

          const SizedBox(
            height:
                24,
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
                begin:
                    Alignment.centerLeft,
                end:
                    Alignment.centerRight,
                colors: [
                  Color(
                    0xFF123E70,
                  ),
                  Color(
                    0xFF1769B8,
                  ),
                  Color(
                    0xFF3C9FEA,
                  ),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                28,
              ),
            ),
            child:
                Row(
              children: [
                Container(
                  width:
                      90,
                  height:
                      90,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white.withOpacity(
                      0.16,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      25,
                    ),
                  ),
                  child:
                      Icon(
                    widget.useMobilePinReceipt
                        ? Icons.sim_card_download_rounded
                        : Icons.receipt_long_rounded,
                    color:
                        Colors.white,
                    size:
                        52,
                  ),
                ),

                const SizedBox(
                  width:
                      22,
                ),

                Expanded(
                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.useMobilePinReceipt
                            ? _safeBillCode
                            : loc.billProvider,
                        style:
                            TextStyle(
                          color:
                              Colors.white.withOpacity(
                            0.78,
                          ),
                          fontSize:
                              23,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height:
                            7,
                      ),

                      Text(
                        _safeBillType,
                        maxLines:
                            2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize:
                              38,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height:
                22,
          ),

          if (widget.useMobilePinReceipt)
            _buildInfoTile(
              icon:
                  Icons.payments_rounded,
              label:
                  loc.amount,
              value:
                  _formatAmount(
                widget.billAmount,
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child:
                      _buildInfoTile(
                    icon:
                        Icons.code_rounded,
                    label:
                        loc.billCode,
                    value:
                        _safeBillCode,
                  ),
                ),

                const SizedBox(
                  width:
                      18,
                ),

                Expanded(
                  child:
                      _buildInfoTile(
                    icon:
                        Icons.numbers_rounded,
                    label:
                        loc.accountNumber,
                    value:
                        _safeAccountNumber,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TOTAL PAYMENT
  // ==========================================================================

  Widget _buildTotalPaymentCard() {
    final loc =
        AppLocalizations.of(context)!;

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
                Icons
                    .account_balance_wallet_rounded,
            title:
                loc.totalPaymentAmount,
            accentColor:
                const Color(
              0xFF118762,
            ),
            iconBackground:
                const Color(
              0xFFE1F5EB,
            ),
            centered:
                true,
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
                    86,
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

  Widget _buildPaymentActionCard() {
    final loc =
        AppLocalizations.of(context)!;

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
            0xFFD2DFEC,
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
            accentColor:
                const Color(
              0xFF1976D2,
            ),
            iconBackground:
                const Color(
              0xFFE7F1FC,
            ),
            centered:
                true,
          ),

          const SizedBox(
            height:
                24,
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
              color:
                  const Color(
                0xFFF6FAFD,
              ),
              borderRadius:
                  BorderRadius.circular(
                26,
              ),
            ),
            child:
                Column(
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  color:
                      Color(
                    0xFF087C5A,
                  ),
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
              ],
            ),
          ),

          const SizedBox(
            height:
                24,
          ),

          IgnorePointer(
            ignoring:
                disabled,
            child:
                AnimatedOpacity(
              duration:
                  const Duration(
                milliseconds:
                    180,
              ),
              opacity:
                  disabled
                      ? 0.55
                      : 1,
              child:
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
                        const Color(
                      0xFF087C5A,
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
                                          Color(
                                        0xFF087C5A,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .qr_code_2_rounded,
                                    color:
                                        Color(
                                      0xFF087C5A,
                                    ),
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
                              ? loc.preparingQr
                                  .toUpperCase()
                              : loc.payWithDuitNowQr
                                  .toUpperCase(),
                          style:
                              const TextStyle(
                            fontSize:
                                30,
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
                              26,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ],
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
  // CARD TITLE
  // ==========================================================================

  Widget _buildCardTitle({
    required IconData icon,
    required String title,
    required Color accentColor,
    required Color iconBackground,
    bool centered = false,
  }) {
    final Widget row =
        Row(
      mainAxisSize:
          centered
              ? MainAxisSize.min
              : MainAxisSize.max,
      children: [
        Container(
          width:
              58,
          height:
              58,
          decoration:
              BoxDecoration(
            color:
                iconBackground,
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
          child:
              Icon(
            icon,
            color:
                accentColor,
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

    if (centered) {
      return Center(
        child:
            row,
      );
    }

    return row;
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
      constraints:
          const BoxConstraints(
        minHeight:
            150,
      ),
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
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
                const Color(
              0xFF1976D2,
            ),
            size:
                38,
          ),

          const SizedBox(
            height:
                16,
          ),

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
            maxLines:
                2,
            overflow:
                TextOverflow.ellipsis,
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
                Color(
              0xFFC62828,
            ),
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
                    Color(
                  0xFFC62828,
                ),
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