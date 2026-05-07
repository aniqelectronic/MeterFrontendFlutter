import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:frontend_v1/im15_controller/pax_im15_c200_sale.dart';
import 'package:frontend_v1/im15_controller/im15_native_serial_manager.dart';
import 'package:frontend_v1/im15_model/im15_response_model.dart';
import 'package:frontend_v1/im15_utils/im15_transaction_logger.dart';
import 'package:frontend_v1/pages/resit.dart';
import 'package:frontend_v1/pages/payment.dart';
import 'dart:async';

/// PIN Entry Screen for secure PIN input when amount > RM250
/// NEW: Only physical card reader cancel button - shows loading screen during cancellation
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

class _PinEntryScreenState extends State<PinEntryScreen> {
  // PIN entry state
  String _enteredPin = '';
  bool _isProcessing = false;
  bool _pinValidated = false;
  bool _pinError = false;
  String _statusMessage = 'Waiting for card reader...';
  Timer? _pinTimeoutTimer;
  int _secondsRemaining = 120;
  bool _showManualPinEntry = false;
  List<String> _manualPinDigits = List.filled(6, '');

  // Card reader communication
  IM15TransactionLogger? _logger;
  PaxIM15C200Sale? _saleInstance;
  IM15NativeSerialManager? _serialManager;
  bool _transactionCompleted = false;
  bool _pinRequestReceived = false;
  bool _pefReceived = false;
  bool _serialPortOpen = false;
  bool _isCancelled = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    print('[PinEntryScreen] 🚀 initState - Starting PIN entry screen');
    _initializePinEntry();
  }

  @override
  void dispose() {
    print('[PinEntryScreen] 🗑️ dispose - Cleaning up resources');
    _pinTimeoutTimer?.cancel();
    _cleanupCardReader();
    super.dispose();
  }

  /// Initialize PIN entry process
  void _initializePinEntry() {
    print('[PinEntryScreen] 🔧 Initializing PIN entry...');
    _startPinTimeoutTimer();
    _initializeCardReaderCommunication();
  }

  /// Start 2-minute timeout timer for PIN entry
  void _startPinTimeoutTimer() {
    print('[PinEntryScreen] ⏱️ Starting 120-second countdown timer');
    _pinTimeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Check cancellation flag FIRST
      if (_isCancelled || _isNavigating) {
        print('[PinEntryScreen] 🛑 Timer cancelled due to cancellation/navigation');
        timer.cancel();
        return;
      }
      
      if (!mounted) {
        print('[PinEntryScreen] 🛑 Timer cancelled - widget not mounted');
        timer.cancel();
        return;
      }
      
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
          // Debug log every 10 seconds
          if (_secondsRemaining % 10 == 0) {
            print('[PinEntryScreen] ⏱️ Timer update: $_secondsRemaining seconds remaining');
          }
        }
      } else {
        print('[PinEntryScreen] ⏱️ Timer reached zero - triggering timeout');
        timer.cancel();
        _handlePinTimeout();
      }
    });
  }

  /// Initialize card reader communication
  void _initializeCardReaderCommunication() async {
    try {
      print('[PinEntryScreen] 🔌 Initializing card reader communication...');
      _logger = IM15TransactionLogger('PIN Entry - ${widget.transactionType}');
      _saleInstance = PaxIM15C200Sale();
      
      // Create and store serial manager reference
      _serialManager = IM15NativeSerialManager();
      
      _logger?.logInfo('Starting PIN entry for amount: RM${widget.amount}');
      _logger?.logInfo('Port: ${widget.port}, TraceNo: ${widget.traceNo}');
      
      if (mounted) {
        setState(() {
          _statusMessage = 'Connecting to card reader...';
        });
      }
      
      // Start the transaction with PIN callbacks
      await _startTransactionWithPIN();
      
    } catch (e) {
      print('[PinEntryScreen] ❌ Error initializing card reader: $e');
      _logger?.logInfo('Error initializing card reader: $e');
      if (!_isCancelled && mounted) {
        _handleError('Failed to connect to card reader: $e');
      }
    }
  }

  /// Start transaction with PIN callbacks
  Future<void> _startTransactionWithPIN() async {
    try {
      print('[PinEntryScreen] 💳 Starting transaction with PIN handling...');
      _logger?.logInfo('Starting transaction with PIN handling...');
      
      // Execute sale with PIN callbacks
      final response = await _saleInstance?.executeSale(
        widget.port,
        _formatAmountForPax(widget.amount),
        widget.traceNo,
        _logger!,
        onPINRequired: () {
          print('[PinEntryScreen] 🔐 PIN REQUIRED callback received');
          if (!mounted || _isCancelled) {
            print('[PinEntryScreen] ⚠️ Ignoring PIN required - cancelled or not mounted');
            return;
          }
          
          if (mounted) {
            setState(() {
              _pinRequestReceived = true;
              _statusMessage = 'Please enter your 6-digit PIN on the card reader';
            });
          }
          
          _logger?.logInfo('PIN required callback received');
        },
        onPINCompleted: () {
          print('[PinEntryScreen] ✅ PIN COMPLETED callback received');
          if (!mounted || _isCancelled) {
            print('[PinEntryScreen] ⚠️ Ignoring PIN completed - cancelled or not mounted');
            return;
          }
          
          if (mounted) {
            setState(() {
              _pefReceived = true;
              _pinValidated = true;
              _statusMessage = 'PIN validated successfully!';
            });
          }
          
          _logger?.logInfo('PIN completed callback received');
        },
      );
      
      if (_isCancelled) {
        print('[PinEntryScreen] ⚠️ Transaction cancelled by user');
        return;
      }
      
      if (response != null) {
        print('[PinEntryScreen] ✅ Transaction completed successfully');
        _logger?.logInfo('Transaction completed successfully');
        _handleTransactionSuccess(response);
      } else {
        // Check if this is a cancellation (null response could mean user cancelled on card reader)
        print('[PinEntryScreen] ❌ Transaction failed - no response (possible cancellation)');
        _logger?.logInfo('Transaction failed - no response or timeout');
        
        // Show cancellation loading screen
        _handleCardReaderCancellation();
      }
      
    } catch (e) {
      print('[PinEntryScreen] ❌ Transaction error: $e');
      _logger?.logInfo('Transaction error: $e');
      if (!_isCancelled && mounted) {
        _handleError('Transaction error: $e');
      }
    }
  }

  /// Format amount for PAX transaction (convert to cents)
  String _formatAmountForPax(String amount) {
    try {
      final double amountValue = double.tryParse(amount) ?? 0.0;
      final int cents = (amountValue * 100).round();
      return cents.toString().padLeft(12, '0');
    } catch (e) {
      return '000000000000';
    }
  }

  /// Handle PIN timeout
  void _handlePinTimeout() {
    print('[PinEntryScreen] ⏱️ TIMEOUT: Handling PIN entry timeout');
    if (!mounted || _isCancelled || _isNavigating) {
      print('[PinEntryScreen] ⚠️ Timeout ignored - already cancelled/navigating');
      return;
    }
    
    if (mounted) {
      setState(() {
        _statusMessage = 'PIN entry timeout. Returning to payment page...';
        _isProcessing = false;
        _pinError = true;
      });
    }
    
    _logger?.logInfo('PIN entry timeout after 2 minutes');
    
    // Force cleanup and navigation
    _forceCleanupAndNavigateBack();
  }

  /// NEW: Handle physical card reader cancellation
  void _handleCardReaderCancellation() async {
    print('[PinEntryScreen] 🚫 CARD READER CANCELLATION: Physical cancel button pressed');
    
    if (_isNavigating || _isCancelled) {
      print('[PinEntryScreen] ⚠️ Already cancelling/navigating, skipping');
      return;
    }
    
    _isCancelled = true;
    _pinTimeoutTimer?.cancel();
    
    _logger?.logInfo('Card reader cancellation detected (physical cancel button)');
    
    if (!mounted) return;
    
    // Show loading dialog with bilingual text
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Colors.orange,
                  strokeWidth: 6,
                ),
                const SizedBox(height: 30),
                const Text(
                  'CANCELLING PAYMENT...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  'MEMBATALKAN BAYARAN...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Please wait 10 seconds...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    print('[PinEntryScreen] 📺 Showing cancellation loading screen for 10 seconds...');
    
    // Wait 10 seconds for card reader to reset
    await Future.delayed(const Duration(seconds: 10));
    
    print('[PinEntryScreen] ✅ 10 seconds elapsed, closing loading and returning to payment');
    
    // Close loading dialog
    if (mounted) {
      try {
        Navigator.of(context).pop();
      } catch (e) {
        print('[PinEntryScreen] ⚠️ Error closing loading dialog: $e');
      }
    }
    
    // Return to payment page
    if (mounted) {
      _navigateBackToPayment();
    }
  }

  /// Handle transaction success
  void _handleTransactionSuccess(IM15ResponseModel response) {
    print('[PinEntryScreen] ✅ Transaction SUCCESS - Status: ${response.statusCode}');
    if (!mounted || _isCancelled || _isNavigating) return;
    
    _logger?.logInfo('Transaction SUCCESS - Status: ${response.statusCode}');
    
    if (mounted) {
      setState(() {
        _transactionCompleted = true;
        _statusMessage = 'Payment successful!';
      });
    }
    
    // Navigate to receipt page
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isCancelled && !_isNavigating) {
        _navigateToReceipt();
      }
    });
  }

  /// Navigate to receipt page
  void _navigateToReceipt() {
    if (_isNavigating) {
      print('[PinEntryScreen] ⚠️ Already navigating, skipping receipt navigation');
      return;
    }
    
    _isNavigating = true;
    print('[PinEntryScreen] 📄 Navigating to receipt page...');
    
    try {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RESITPAGE(
            biz: widget.biz,
            data: ResitData(
              amount: widget.amount,
              plate: widget.paymentData?.plate,
              hour: widget.paymentData?.hour,
              taxItems: widget.paymentData?.taxItems,
              licenseNos: widget.paymentData?.licenseNos,
              compoundNos: widget.paymentData?.compoundNos,
              offenderName: widget.paymentData?.offenderName,
              violationType: widget.paymentData?.violationType,
              kodhasil: widget.paymentData?.kodhasil,
              date: widget.paymentData?.date,
              time: widget.paymentData?.time,
            ),
          ),
        ),
      );
    } catch (e) {
      print('[PinEntryScreen] ❌ Error navigating to receipt: $e');
      _isNavigating = false;
    }
  }

  /// Navigate back to payment page
  void _navigateBackToPayment() {
    if (_isNavigating) {
      print('[PinEntryScreen] ⚠️ Already navigating, skipping');
      return;
    }
    
    _isNavigating = true;
    print('[PinEntryScreen] 🔙 Navigating back to payment page...');
    
    try {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PAYMENTPAGE(
            biz: widget.biz,
            data: widget.paymentData,
          ),
        ),
        (route) => false, // Remove all routes
      );
    } catch (e) {
      print('[PinEntryScreen] ❌ Error navigating back: $e');
      // Fallback: try simple pop
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (e2) {
        print('[PinEntryScreen] ❌ Fallback pop failed: $e2');
      }
    }
  }

  /// Force cleanup and navigate back
  void _forceCleanupAndNavigateBack() {
    if (_isNavigating) {
      print('[PinEntryScreen] ⚠️ Already navigating, skipping');
      return;
    }
    
    _isNavigating = true;
    print('[PinEntryScreen] 🔄 Force cleanup and navigate back...');
    
    // Cancel timer immediately
    _pinTimeoutTimer?.cancel();
    
    // Cleanup card reader in background (fire and forget)
    _cleanupCardReaderInBackground();
    
    // Navigate immediately without waiting
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _navigateBackToPayment();
      }
    });
  }

  /// Handle error
  void _handleError(String error) {
    print('[PinEntryScreen] ❌ Error: $error');
    if (!mounted || _isCancelled || _isNavigating) return;
    
    if (mounted) {
      setState(() {
        _statusMessage = error;
        _isProcessing = false;
        _pinError = true;
      });
    }
    
    _logger?.logInfo('Error: $error');
    
    // Force cleanup and navigation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isNavigating) {
        _forceCleanupAndNavigateBack();
      }
    });
  }

  /// Cleanup in background (fire and forget)
  void _cleanupCardReaderInBackground() {
    print('[PinEntryScreen] 🧹 BACKGROUND CLEANUP: Starting async cleanup...');
    
    // Run cleanup in background without blocking UI
    Future.microtask(() async {
      try {
        // Send EOT to reset card reader (don't wait for response)
        final serial = IM15NativeSerialManager();
        final opened = serial.open(widget.port);
        if (opened) {
          print('[PinEntryScreen] 📤 Sending EOT in background...');
          serial.sendByte(IM15NativeSerialManager.EOT);
          _logger?.logSend('EOT (background cleanup)');
          
          // Small delay then close
          await Future.delayed(const Duration(milliseconds: 100));
          serial.close();
          print('[PinEntryScreen] ✅ Background cleanup completed');
        }
      } catch (e) {
        print('[PinEntryScreen] ⚠️ Background cleanup error (ignored): $e');
      }
    });
  }

  /// Synchronous cleanup (for dispose)
  void _cleanupCardReader() {
    print('[PinEntryScreen] 🧹 SYNC CLEANUP: Cleaning up resources...');
    
    // Cancel timer
    if (_pinTimeoutTimer != null) {
      _pinTimeoutTimer!.cancel();
      _pinTimeoutTimer = null;
      print('[PinEntryScreen] ✅ Timer cancelled');
    }
    
    // Cleanup resources
    try {
      _logger?.endSession();
      _logger = null;
      _saleInstance = null;
      _serialManager = null;
      _serialPortOpen = false;
      print('[PinEntryScreen] ✅ Resources cleaned up');
    } catch (e) {
      print('[PinEntryScreen] ⚠️ Error cleaning up resources: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('[PinEntryScreen] 🔙 Back button pressed - blocked');
        return false; // Prevent back button
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/images/pnew.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Main content
            Center(
              child: Container(
                width: 800,
                height: 900,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'SECURE PIN ENTRY',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Amount display
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.orange, width: 3),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Payment Amount',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[900],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'RM ${widget.amount}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '(PIN required for amounts > RM250)',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Status message
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _pinError
                            ? Colors.red[50]
                            : _pinValidated
                                ? Colors.green[50]
                                : _pinRequestReceived
                                    ? Colors.yellow[50]
                                    : Colors.blue[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _pinError
                              ? Colors.red
                              : _pinValidated
                                  ? Colors.green
                                  : _pinRequestReceived
                                      ? Colors.orange
                                      : Colors.blue,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _pinError
                                ? Icons.error
                                : _pinValidated
                                    ? Icons.check_circle
                                    : _pinRequestReceived
                                        ? Icons.lock
                                        : Icons.device_unknown,
                            size: 60,
                            color: _pinError
                                ? Colors.red
                                : _pinValidated
                                    ? Colors.green
                                    : _pinRequestReceived
                                        ? Colors.orange
                                        : Colors.blue,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _statusMessage,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: _pinError
                                  ? Colors.red[900]
                                  : _pinValidated
                                      ? Colors.green[900]
                                      : _pinRequestReceived
                                          ? Colors.orange[900]
                                          : Colors.blue[900],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_pinRequestReceived && !_pefReceived && !_pinError)
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  'Please enter your 6-digit PIN on the card reader',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.orange, width: 2),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.info,
                                        size: 36,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 15),
                                      Text(
                                        'Use physical cancel button on card reader to cancel',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Timer display
                    if (!_pinError && !_pinValidated)
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _secondsRemaining < 30 ? Colors.red[50] : Colors.yellow[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _secondsRemaining < 30 ? Colors.red : Colors.orange, 
                            width: 2
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer,
                              size: 36,
                              color: _secondsRemaining < 30 ? Colors.red : Colors.orange,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              'Time remaining: $_secondsRemaining seconds',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: _secondsRemaining < 30 ? Colors.red[900] : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // NO CANCEL BUTTON - User must use physical card reader cancel button
                    // Processing indicator
                    if (_isProcessing && !_pinError)
                      Column(
                        children: [
                          const SizedBox(height: 40),
                          const CircularProgressIndicator(
                            strokeWidth: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _pinValidated
                                ? 'Completing transaction...'
                                : 'Processing...',
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}