import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_v1/im15_controller/im15_native_serial_manager.dart';
import 'package:frontend_v1/im15_controller/pax_im15_c200_sale.dart';
import 'package:frontend_v1/im15_model/im15_response_model.dart';
import 'package:frontend_v1/im15_utils/im15_transaction_logger.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/payment/payment.dart';
import 'package:frontend_v1/pages/resit/resit.dart';

/// ===============================================================
/// PIN ENTRY SCREEN
/// ===============================================================
///
/// TESTING MODE:
///   forceSuccessForTesting = true
///
///   - Still connects to the real IM15 card reader.
///   - Still sends the real C200 transaction.
///   - Still waits for card, PIN, PEF and R200.
///   - Declined, wrong PIN, timeout, null response and exceptions
///     are forced into SUCCESS for application-flow testing.
///
/// DEPLOYMENT MODE:
///   forceSuccessForTesting = false
///
///   - Uses the real IM15 result.
///   - Only R200 status code "00" is treated as approved.
///   - Other response codes are shown as failed.
/// ===============================================================

class PinEntryScreen extends StatefulWidget {
  final String amount;
  final String port;
  final String traceNo;
  final String biz;
  final dynamic paymentData;
  final String transactionType;

  const PinEntryScreen({
    super.key,
    required this.amount,
    required this.port,
    required this.traceNo,
    required this.biz,
    required this.paymentData,
    required this.transactionType,
  });

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

enum PinEntryStage {
  connecting,
  waitingForPin,
  processing,
  success,
  failed,
  cancelling,
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  // =============================================================
  // CHANGE ONLY THIS FOR TESTING OR DEPLOYMENT
  // =============================================================

  /// true:
  /// Real card transaction still runs, but every final result is
  /// treated as successful.
  ///
  /// false:
  /// Real deployment. Only status code "00" is successful.
  static const bool forceSuccessForTesting = true;

  // =============================================================
  // TIMEOUT SETTINGS
  // =============================================================

  static const int _timeoutSeconds = 120;

  Timer? _pinTimeoutTimer;
  int _secondsRemaining = _timeoutSeconds;

  // =============================================================
  // UI STATE
  // =============================================================

  PinEntryStage _stage = PinEntryStage.connecting;

  String? _realStatusCode;
  String? _failureMessage;

  bool _pinRequestReceived = false;
  bool _pinCompleted = false;
  bool _transactionCompleted = false;
  bool _isCancelled = false;
  bool _isNavigating = false;

  // =============================================================
  // CARD READER
  // =============================================================

  IM15TransactionLogger? _logger;
  PaxIM15C200Sale? _saleInstance;
  IM15NativeSerialManager? _serialManager;

  @override
  void initState() {
    super.initState();

    debugPrint(
      '[PinEntryScreen] Starting PIN screen. '
      'Force success testing: $forceSuccessForTesting',
    );

    _startTimeoutTimer();
    _initializeCardReaderCommunication();
  }

  @override
  void dispose() {
    debugPrint('[PinEntryScreen] Disposing resources');

    _pinTimeoutTimer?.cancel();
    _pinTimeoutTimer = null;

    _cleanupCardReader();

    super.dispose();
  }

  // =============================================================
  // INITIALIZATION
  // =============================================================

  Future<void> _initializeCardReaderCommunication() async {
    try {
      _logger = IM15TransactionLogger(
        'PIN Entry - ${widget.transactionType}',
      );

      _saleInstance = PaxIM15C200Sale();
      _serialManager = IM15NativeSerialManager();

      _logger?.logInfo(
        'Starting PIN entry transaction for RM${widget.amount}',
      );

      _logger?.logInfo(
        'Port: ${widget.port}, Trace: ${widget.traceNo}',
      );

      if (mounted) {
        setState(() {
          _stage = PinEntryStage.connecting;
        });
      }

      await _startTransactionWithPIN();
    } catch (error, stackTrace) {
      debugPrint(
        '[PinEntryScreen] Initialization error: $error',
      );

      debugPrintStack(stackTrace: stackTrace);

      _logger?.logInfo(
        'Initialization error: $error',
      );

      if (!mounted ||
          _isCancelled ||
          _isNavigating ||
          _transactionCompleted) {
        return;
      }

      // ==========================================================
      // TESTING RESULT
      // ==========================================================
      // Even initialization/connection errors become successful
      // when testing mode is enabled.
      if (forceSuccessForTesting) {
        _forceTestingSuccess(
          source: 'INITIALIZATION_ERROR',
        );
        return;
      }

      // ==========================================================
      // REAL DEPLOYMENT RESULT
      // ==========================================================
      _handleTransactionFailure(
        statusCode: 'CONNECTION_ERROR',
      );
    }
  }

  // =============================================================
  // REAL CARD TRANSACTION
  // =============================================================

  Future<void> _startTransactionWithPIN() async {
    try {
      final sale = _saleInstance;
      final logger = _logger;

      if (sale == null || logger == null) {
        throw Exception(
          'Card-reader service was not initialized.',
        );
      }

      debugPrint(
        '[PinEntryScreen] Starting actual IM15 C200 transaction',
      );

      final response = await sale.executeSale(
        widget.port,
        _formatAmountForPax(widget.amount),
        widget.traceNo,
        logger,

        onPINRequired: () {
          debugPrint(
            '[PinEntryScreen] PIN REQUIRED callback received',
          );

          if (!mounted ||
              _isCancelled ||
              _isNavigating ||
              _transactionCompleted) {
            return;
          }

          setState(() {
            _pinRequestReceived = true;
            _stage = PinEntryStage.waitingForPin;
          });

          _logger?.logInfo(
            'PIN required callback received',
          );
        },

        onPINCompleted: () {
          debugPrint(
            '[PinEntryScreen] PIN COMPLETED callback received',
          );

          if (!mounted ||
              _isCancelled ||
              _isNavigating ||
              _transactionCompleted) {
            return;
          }

          setState(() {
            _pinCompleted = true;
            _stage = PinEntryStage.processing;
          });

          _logger?.logInfo(
            'PIN completed callback received',
          );
        },
      );

      if (!mounted ||
          _isCancelled ||
          _isNavigating ||
          _transactionCompleted) {
        return;
      }

      _pinTimeoutTimer?.cancel();

      final statusCode = _getResponseStatusCode(response);

      _realStatusCode = statusCode;

      debugPrint(
        '[PinEntryScreen] Actual terminal result: $statusCode',
      );

      _logger?.logInfo(
        'Actual terminal result: $statusCode',
      );

      // ==========================================================
      // TESTING SUCCESS CODE
      // ==========================================================
      //
      // The real card-reader process has already completed.
      // Regardless of whether the response is:
      //
      // - 00 approved
      // - 05 declined
      // - 51 insufficient funds
      // - 54 expired card
      // - 55 incorrect PIN
      // - TA aborted
      // - null/no response
      //
      // the application continues as successful.
      //
      // For deployment, set:
      //
      // forceSuccessForTesting = false
      // ==========================================================

      if (forceSuccessForTesting) {
        _forceTestingSuccess(
          source: statusCode,
          originalResponse: response,
        );

        return;
      }

      // ==========================================================
      // REAL DEPLOYMENT SUCCESS CODE
      // ==========================================================
      //
      // This code automatically runs when:
      //
      // forceSuccessForTesting = false
      //
      // Only status code 00 is approved.
      // ==========================================================

      if (response != null &&
          response.statusCode?.trim() == '00') {
        _handleTransactionSuccess(response);
      } else {
        _handleTransactionFailure(
          statusCode: statusCode,
        );
      }

      /*
      =============================================================
      OPTIONAL COMMENT/UNCOMMENT VERSION
      =============================================================

      If you prefer manually commenting code instead of using the
      forceSuccessForTesting setting, use this structure:

      // ---------- TESTING ----------
      _forceTestingSuccess(
        source: statusCode,
        originalResponse: response,
      );

      // ---------- REAL DEPLOYMENT ----------
      // if (response != null &&
      //     response.statusCode?.trim() == '00') {
      //   _handleTransactionSuccess(response);
      // } else {
      //   _handleTransactionFailure(
      //     statusCode: statusCode,
      //   );
      // }

      The boolean setting is safer because you only change one line.
      =============================================================
      */
    } catch (error, stackTrace) {
      debugPrint(
        '[PinEntryScreen] Actual transaction error: $error',
      );

      debugPrintStack(stackTrace: stackTrace);

      _logger?.logInfo(
        'Actual transaction error: $error',
      );

      if (!mounted ||
          _isCancelled ||
          _isNavigating ||
          _transactionCompleted) {
        return;
      }

      _pinTimeoutTimer?.cancel();

      // ==========================================================
      // TESTING EXCEPTION RESULT
      // ==========================================================
      //
      // A communication exception is also forced into success
      // during testing.
      // ==========================================================

      if (forceSuccessForTesting) {
        _forceTestingSuccess(
          source: 'TRANSACTION_EXCEPTION',
        );

        return;
      }

      // ==========================================================
      // REAL DEPLOYMENT EXCEPTION RESULT
      // ==========================================================

      _handleTransactionFailure(
        statusCode: 'SYSTEM_ERROR',
      );
    }
  }

  // =============================================================
  // FORCE SUCCESS FOR TESTING
  // =============================================================

  void _forceTestingSuccess({
    required String source,
    IM15ResponseModel? originalResponse,
  }) {
    if (!mounted ||
        _isCancelled ||
        _isNavigating ||
        _transactionCompleted) {
      return;
    }

    debugPrint(
      '[PinEntryScreen] TEST MODE: Forcing success. '
      'Actual result: $source',
    );

    _logger?.logInfo(
      'TEST MODE: Forced success. Actual result: $source',
    );

    final response =
        originalResponse ?? _createTestingSuccessResponse();

    // Replace the declined/error status with approved for the
    // application testing flow.
    response.statusCode = '00';

    if (response.approvalCode == null ||
        response.approvalCode!.trim().isEmpty) {
      response.approvalCode = 'TESTOK';
    }

    if (response.rrn == null ||
        response.rrn!.trim().isEmpty) {
      response.rrn = 'TEST${DateTime.now().millisecondsSinceEpoch}'
          .substring(0, 12);
    }

    if (response.traceNo == null ||
        response.traceNo!.trim().isEmpty) {
      response.traceNo = _createSixDigitTrace();
    }

    response.amount = _formatAmountForPax(
      widget.amount,
    );

    _handleTransactionSuccess(
      response,
      forcedByTesting: true,
    );
  }

  IM15ResponseModel _createTestingSuccessResponse() {
    return IM15ResponseModel()
      ..statusCode = '00'
      ..approvalCode = 'TESTOK'
      ..rrn = _createTestingRrn()
      ..traceNo = _createSixDigitTrace()
      ..batchNo = '000001'
      ..hostNo = '00'
      ..terminalId = 'TESTTID'
      ..merchantId = 'TESTMERCHANT'
      ..amount = _formatAmountForPax(widget.amount);
  }

  String _createTestingRrn() {
    final timestamp =
        DateTime.now().millisecondsSinceEpoch.toString();

    if (timestamp.length >= 12) {
      return timestamp.substring(
        timestamp.length - 12,
      );
    }

    return timestamp.padLeft(12, '0');
  }

  String _createSixDigitTrace() {
    final timestamp =
        DateTime.now().millisecondsSinceEpoch.toString();

    if (timestamp.length >= 6) {
      return timestamp.substring(
        timestamp.length - 6,
      );
    }

    return timestamp.padLeft(6, '0');
  }

  // =============================================================
  // RESPONSE STATUS
  // =============================================================

  String _getResponseStatusCode(
    IM15ResponseModel? response,
  ) {
    if (response == null) {
      return 'NO_RESPONSE';
    }

    final status = response.statusCode?.trim();

    if (status == null || status.isEmpty) {
      return 'UNKNOWN';
    }

    return status;
  }

  // =============================================================
  // SUCCESS
  // =============================================================

  void _handleTransactionSuccess(
    IM15ResponseModel response, {
    bool forcedByTesting = false,
  }) {
    if (!mounted ||
        _isCancelled ||
        _isNavigating ||
        _transactionCompleted) {
      return;
    }

    _transactionCompleted = true;
    _pinTimeoutTimer?.cancel();

    debugPrint(
      '[PinEntryScreen] Payment successful. '
      'Testing override: $forcedByTesting',
    );

    _logger?.logInfo(
      'Payment successful. '
      'Testing override: $forcedByTesting',
    );

    setState(() {
      _stage = PinEntryStage.success;
    });

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (!mounted ||
            _isCancelled ||
            _isNavigating) {
          return;
        }

        _navigateToReceipt(response);
      },
    );
  }

  // =============================================================
  // FAILURE
  // =============================================================

  void _handleTransactionFailure({
    required String statusCode,
  }) {
    if (!mounted ||
        _isCancelled ||
        _isNavigating ||
        _transactionCompleted) {
      return;
    }

    _transactionCompleted = true;
    _pinTimeoutTimer?.cancel();

    _realStatusCode = statusCode;
    _failureMessage = _getFailureMessageKey(statusCode);

    debugPrint(
      '[PinEntryScreen] Payment failed. '
      'Status: $statusCode',
    );

    _logger?.logInfo(
      'Payment failed. Status: $statusCode',
    );

    setState(() {
      _stage = PinEntryStage.failed;
    });

    Future.delayed(
      const Duration(seconds: 4),
      () {
        if (!mounted ||
            _isCancelled ||
            _isNavigating) {
          return;
        }

        _navigateBackToPayment();
      },
    );
  }

  String _getFailureMessageKey(String statusCode) {
    switch (statusCode) {
      case '05':
      case 'Z1':
      case 'Z3':
        return 'declined';

      case '51':
        return 'insufficientFunds';

      case '54':
      case 'EC':
        return 'expiredCard';

      case '55':
      case 'PE':
        return 'incorrectPin';

      case '14':
      case 'IC':
        return 'invalidCard';

      case '58':
        return 'notPermitted';

      case '91':
      case 'CE':
      case 'LE':
        return 'connectionProblem';

      case 'TA':
        return 'cancelled';

      case 'TIMEOUT':
      case 'NO_RESPONSE':
        return 'timeout';

      default:
        return 'generalFailure';
    }
  }

  // =============================================================
  // TIMEOUT
  // =============================================================

  void _startTimeoutTimer() {
    _pinTimeoutTimer?.cancel();

    _pinTimeoutTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted ||
            _isCancelled ||
            _isNavigating ||
            _transactionCompleted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          timer.cancel();
          _handleTimeout();
        }
      },
    );
  }

  void _handleTimeout() {
    if (!mounted ||
        _isCancelled ||
        _isNavigating ||
        _transactionCompleted) {
      return;
    }

    debugPrint(
      '[PinEntryScreen] Screen timeout reached',
    );

    _logger?.logInfo(
      'PIN-entry screen timeout reached',
    );

    // Testing mode still records the timeout but forces success.
    if (forceSuccessForTesting) {
      _forceTestingSuccess(
        source: 'TIMEOUT',
      );

      return;
    }

    _handleTransactionFailure(
      statusCode: 'TIMEOUT',
    );
  }

  // =============================================================
  // CANCELLATION
  // =============================================================

  Future<void> _handleCardReaderCancellation() async {
    if (!mounted ||
        _isCancelled ||
        _isNavigating ||
        _transactionCompleted) {
      return;
    }

    _isCancelled = true;
    _pinTimeoutTimer?.cancel();

    setState(() {
      _stage = PinEntryStage.cancelling;
    });

    _logger?.logInfo(
      'Card-reader cancellation detected',
    );

    await Future.delayed(
      const Duration(seconds: 10),
    );

    if (!mounted || _isNavigating) return;

    _navigateBackToPayment();
  }

  // =============================================================
  // FORMAT AMOUNT
  // =============================================================

  String _formatAmountForPax(String amount) {
    try {
      final amountValue =
          double.tryParse(amount) ?? 0.0;

      final cents = (amountValue * 100).round();

      return cents.toString().padLeft(
        12,
        '0',
      );
    } catch (_) {
      return '000000000000';
    }
  }

  // =============================================================
  // NAVIGATION
  // =============================================================

  void _navigateToReceipt(
    IM15ResponseModel response,
  ) {
    if (_isNavigating) return;

    _isNavigating = true;

    final bankTransactionNo =
        response.rrn?.trim().isNotEmpty == true
            ? response.rrn!.trim()
            : response.traceNo?.trim() ?? '0';

    try {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacement(
        MaterialPageRoute(
          settings: const RouteSettings(
            name: '/receipt',
          ),
          builder: (_) => RESITPAGE(
            biz: widget.biz,
            data: ResitData(
              amount: widget.amount,
              plate: widget.paymentData?.plate,
              hour: widget.paymentData?.hour,
              taxItems: widget.paymentData?.taxItems,
              licenseNos: widget.paymentData?.licenseNos,
              compoundNos:
                  widget.paymentData?.compoundNos,
              taksiranItems:
                  widget.paymentData?.taksiranItems,
              sewaanItems:
                  widget.paymentData?.sewaanItems,
              offenderName:
                  widget.paymentData?.offenderName,
              violationType:
                  widget.paymentData?.violationType,
              kodhasil:
                  widget.paymentData?.kodhasil,
              date: widget.paymentData?.date,
              time: widget.paymentData?.time,
              pegeOrderNo: response.traceNo ?? '0',
              pegeBankTrxNo: bankTransactionNo,
              typePayment: 'Debit/Credit Card',
            ),
          ),
        ),
      );
    } catch (error) {
      debugPrint(
        '[PinEntryScreen] Receipt navigation error: $error',
      );

      _isNavigating = false;
    }
  }

  void _navigateBackToPayment() {
    if (_isNavigating) return;

    _isNavigating = true;

    try {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushAndRemoveUntil(
        MaterialPageRoute(
          settings: const RouteSettings(
            name: '/payment',
          ),
          builder: (_) => PAYMENTPAGE(
            biz: widget.biz,
            data: widget.paymentData,
          ),
        ),
        (route) => false,
      );
    } catch (error) {
      debugPrint(
        '[PinEntryScreen] Payment navigation error: $error',
      );

      _isNavigating = false;
    }
  }

  // =============================================================
  // CLEANUP
  // =============================================================

  void _cleanupCardReader() {
    try {
      _logger?.endSession();
    } catch (_) {}

    _logger = null;
    _saleInstance = null;
    _serialManager = null;
  }

  // =============================================================
  // LOCALIZED UI CONTENT
  // =============================================================

  String _getTitle(
    AppLocalizations l10n,
  ) {
    switch (_stage) {
      case PinEntryStage.connecting:
        return l10n.pinConnectingTitle;

      case PinEntryStage.waitingForPin:
        return l10n.pinEntryTitle;

      case PinEntryStage.processing:
        return l10n.pinProcessingTitle;

      case PinEntryStage.success:
        return l10n.pinSuccessTitle;

      case PinEntryStage.failed:
        return l10n.pinFailedTitle;

      case PinEntryStage.cancelling:
        return l10n.pinCancellingTitle;
    }
  }

  String _getMessage(
    AppLocalizations l10n,
  ) {
    switch (_stage) {
      case PinEntryStage.connecting:
        return l10n.pinConnectingMessage;

      case PinEntryStage.waitingForPin:
        return l10n.pinEntryMessage;

      case PinEntryStage.processing:
        return l10n.pinProcessingMessage;

      case PinEntryStage.success:
        if (forceSuccessForTesting) {
          return l10n.pinTestSuccessMessage;
        }

        return l10n.pinSuccessMessage;

      case PinEntryStage.failed:
        return _localizedFailureMessage(l10n);

      case PinEntryStage.cancelling:
        return l10n.pinCancellingMessage;
    }
  }

  String _localizedFailureMessage(
    AppLocalizations l10n,
  ) {
    switch (_failureMessage) {
      case 'declined':
        return l10n.pinFailureDeclined;

      case 'insufficientFunds':
        return l10n.pinFailureInsufficientFunds;

      case 'expiredCard':
        return l10n.pinFailureExpiredCard;

      case 'incorrectPin':
        return l10n.pinFailureIncorrectPin;

      case 'invalidCard':
        return l10n.pinFailureInvalidCard;

      case 'notPermitted':
        return l10n.pinFailureNotPermitted;

      case 'connectionProblem':
        return l10n.pinFailureConnection;

      case 'cancelled':
        return l10n.pinFailureCancelled;

      case 'timeout':
        return l10n.pinFailureTimeout;

      default:
        return l10n.pinFailureGeneral;
    }
  }

  IconData _getStageIcon() {
    switch (_stage) {
      case PinEntryStage.connecting:
        return Icons.credit_card;

      case PinEntryStage.waitingForPin:
        return Icons.lock_outline_rounded;

      case PinEntryStage.processing:
        return Icons.sync_rounded;

      case PinEntryStage.success:
        return Icons.check_circle_rounded;

      case PinEntryStage.failed:
        return Icons.error_rounded;

      case PinEntryStage.cancelling:
        return Icons.cancel_rounded;
    }
  }

  Color _getStageColor() {
    switch (_stage) {
      case PinEntryStage.connecting:
        return const Color(0xFF0359D2);

      case PinEntryStage.waitingForPin:
        return const Color(0xFFF59E0B);

      case PinEntryStage.processing:
        return const Color(0xFF0359D2);

      case PinEntryStage.success:
        return const Color(0xFF169B62);

      case PinEntryStage.failed:
        return const Color(0xFFD92D20);

      case PinEntryStage.cancelling:
        return const Color(0xFFF97316);
    }
  }

  Color _getLightStageColor() {
    switch (_stage) {
      case PinEntryStage.connecting:
        return const Color(0xFFEAF2FF);

      case PinEntryStage.waitingForPin:
        return const Color(0xFFFFF7E5);

      case PinEntryStage.processing:
        return const Color(0xFFEAF2FF);

      case PinEntryStage.success:
        return const Color(0xFFE9F8F0);

      case PinEntryStage.failed:
        return const Color(0xFFFFEEEE);

      case PinEntryStage.cancelling:
        return const Color(0xFFFFF1E8);
    }
  }

  bool get _showProgressIndicator {
    return _stage == PinEntryStage.connecting ||
        _stage == PinEntryStage.processing ||
        _stage == PinEntryStage.cancelling;
  }

  bool get _showTimer {
    return _stage == PinEntryStage.connecting ||
        _stage == PinEntryStage.waitingForPin;
  }

  // =============================================================
  // UI
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stageColor = _getStageColor();

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                color: Colors.white.withOpacity(0.10),
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 70,
                    vertical: 40,
                  ),
                  child: Container(
                    width: 850,
                    padding: const EdgeInsets.fromLTRB(
                      55,
                      55,
                      55,
                      50,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.98),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          blurRadius: 35,
                          spreadRadius: 4,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (forceSuccessForTesting)
                          _buildTestingBanner(l10n),

                        if (forceSuccessForTesting)
                          const SizedBox(height: 25),

                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: _getLightStageColor(),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: stageColor,
                              width: 5,
                            ),
                          ),
                          child: _showProgressIndicator
                              ? Padding(
                                  padding:
                                      const EdgeInsets.all(42),
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 8,
                                    color: stageColor,
                                  ),
                                )
                              : Icon(
                                  _getStageIcon(),
                                  color: stageColor,
                                  size: 95,
                                ),
                        ),

                        const SizedBox(height: 35),

                        Text(
                          _getTitle(l10n),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: stageColor,
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            height: 1.10,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Text(
                          _getMessage(l10n),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 35),

                        _buildAmountCard(l10n),

                        const SizedBox(height: 30),

                        if (_stage ==
                            PinEntryStage.waitingForPin)
                          _buildPinInstructionCard(l10n),

                        if (_stage ==
                            PinEntryStage.waitingForPin)
                          const SizedBox(height: 25),

                        if (_showTimer)
                          _buildTimerCard(l10n),

                        if (_stage == PinEntryStage.failed &&
                            _realStatusCode != null)
                          const SizedBox(height: 20),

                        if (_stage == PinEntryStage.failed &&
                            _realStatusCode != null)
                          Text(
                            '${l10n.pinReferenceCode}: '
                            '$_realStatusCode',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                        const SizedBox(height: 25),

                        if (_stage ==
                            PinEntryStage.waitingForPin)
                          _buildSafetyNotice(l10n),

                        if (_stage == PinEntryStage.success)
                          _buildSuccessNotice(l10n),

                        if (_stage == PinEntryStage.failed)
                          _buildFailureNotice(l10n),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestingBanner(
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFF59E0B),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.science_outlined,
            color: Color(0xFFB54708),
            size: 34,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              l10n.pinTestingModeNotice,
              style: const TextStyle(
                color: Color(0xFF7A2E0E),
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 25,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFB9CCE9),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            l10n.pinPaymentAmount,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'RM ${widget.amount}',
            style: const TextStyle(
              color: Color(0xFF0359D2),
              fontSize: 58,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinInstructionCard(
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF5B942),
          width: 3,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.pin_outlined,
            color: Color(0xFFB26A00),
            size: 55,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              l10n.pinKeypadInstruction,
              style: const TextStyle(
                color: Color(0xFF5A3A00),
                fontSize: 27,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(
    AppLocalizations l10n,
  ) {
    final isUrgent = _secondsRemaining <= 30;

    final color = isUrgent
        ? const Color(0xFFD92D20)
        : const Color(0xFF0359D2);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: isUrgent
            ? const Color(0xFFFFEEEE)
            : const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            color: color,
            size: 37,
          ),
          const SizedBox(width: 13),
          Text(
            '${l10n.pinTimeRemaining}: '
            '$_secondsRemaining ${l10n.pinSeconds}',
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyNotice(
    AppLocalizations l10n,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: Color(0xFF0359D2),
          size: 32,
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            l10n.pinDoNotRemoveCard,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 23,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessNotice(
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F8F0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        l10n.pinSuccessNextStep,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF087443),
          fontSize: 25,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildFailureNotice(
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        l10n.pinFailureNextStep,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFB42318),
          fontSize: 25,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}