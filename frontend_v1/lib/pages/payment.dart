import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/license/license_service.dart';
import 'package:frontend_v1/controllers/parking/parking_controller.dart';
import 'package:frontend_v1/controllers/tax/tax_service.dart';
import 'package:frontend_v1/im15_abstract/abstract_c200_transaction_service.dart';
import 'package:frontend_v1/im15_serial/im15_port_detector.dart';
import 'package:frontend_v1/im15_serial/im15_serial_connection_manager.dart';
import 'package:frontend_v1/im15_serial/im15_serial_settings.dart';
import 'package:frontend_v1/im15_services/compound_c200_service.dart';
import 'package:frontend_v1/im15_services/license_c200_service.dart';
import 'package:frontend_v1/im15_services/parking_c200_service.dart';
import 'package:frontend_v1/im15_services/tax_c200_service.dart';
import 'package:frontend_v1/im15_utils/payment_spinner.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/tax/payment_tax_item.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/resit.dart';
import 'package:frontend_v1/pages/pin_entry.dart'; // Import new PIN entry screen
import 'package:frontend_v1/services/pegepay_qr_page.dart';
import 'package:frontend_v1/services/pegepay_service.dart';
import 'package:frontend_v1/services/pegepay_webview_helper.dart';
import 'package:intl/intl.dart';
import 'package:frontend_v1/model/taksiran/taksiran_payment_item.dart';
import 'package:frontend_v1/controllers/taksiran/taksiran_payment_service_bentong.dart';
import 'package:frontend_v1/model/sewaan/sewaan_payment_item.dart';
import 'package:frontend_v1/controllers/sewaan/sewaan_payment_service_bentong.dart';


class PaymentData {
  String? plate;
  String? biz;
  int? hour;
  String? amount;
  String? samanNo;
  String? licenseNo;
  String? accountNo;
  List<PaymentTaxItem>? taxItems;
  List<String>? licenseNos;
  List<String>? compoundNos;
  List<TaksiranPaymentItem>? taksiranItems;
  List<SewaanPaymentItem>? sewaanItems;

  String? offenderName;
  String? violationType;
  String? kodhasil;
  String? date;
  String? time;

  PaymentData({
    this.biz,
    this.plate,
    this.hour,
    this.amount,
    this.samanNo,
    this.licenseNo,
    this.accountNo,
    this.taxItems,
    this.licenseNos, 
    this.compoundNos,
    this.offenderName,
    this.violationType,
    this.kodhasil,
    this.date,
    this.time,
    this.taksiranItems,
    this.sewaanItems,
  });

}

void showLoadingDialog(BuildContext context, {String message = "Loading..."}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 15),
            Text(
              message,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black,),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

void showPINEntryDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Container(
        width: 350,
        height: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 80,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 20),
            Text(
              "PIN REQUIRED",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Please enter your PIN\non the card reader",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellow[700]!, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.orange[700],
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Waiting for PIN entry...",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


class PAYMENTPAGE extends StatelessWidget {
  final String biz;
  final PaymentData data;

  // Track if a transaction is in progress to prevent multiple simultaneous transactions
  static bool _transactionInProgress = false;

  const PAYMENTPAGE({
    super.key,
    required this.biz,
    required this.data,
  });


  @override
  Widget build(BuildContext context) {
    
    final String displayedAmount = data.amount ?? "0.00";

    return Scaffold(
      body: Stack(
        children: [
          // Background image
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

          // Title
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.paymentTitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // First Text
          Positioned(
            top: 230,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.paymentSubtitle,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

// Second Text (amount)
Positioned(
  top: 380,
  left: 0,
  right: 0,
  child: Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.totalAmountText,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.payments,
                size: 40,
                color: Color.fromARGB(255, 3, 89, 210),
              ),
              const SizedBox(width: 15),
              Text(
                "RM $displayedAmount",
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
),

          // CARD READER Button
          Positioned(
            top: 750,
            left: -500,
            right: 0,
            child: Center(
  child: _PaymentKioskButton(
    icon: IconData(0xe19f, fontFamily: 'MaterialIcons'),
    label: AppLocalizations.of(context)!.cardButton,
                    onPressed: () async {
                    // Prevent multiple simultaneous transactions
                    if (_transactionInProgress) {
                      print('[PAYMENTPAGE] ⚠️ Transaction already in progress, ignoring button press');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Transaction already in progress. Please wait.")),
                      );
                      return;
                    }

                    _transactionInProgress = true;
                    final amount = data.amount ?? "0.00";
                    final PaymentSpinner spinner = PaymentSpinner(context);

                    bool spinnerShown = false;
                    
                    try {
                      // Validate amount for RM250 threshold
                      final double amountValue = double.tryParse(amount) ?? 0.0;
                      
                      if (amountValue > 250.00) {
                        // Amount exceeds RM250 - navigate to PIN entry screen
                        print('[PAYMENTPAGE] ⚠️ Amount RM${amountValue.toStringAsFixed(2)} exceeds RM250 - navigating to PIN entry screen');
                        
                        // First, detect port and prepare for transaction
                        await spinner.show();
                        spinnerShown = true;

                        // Detect port automatically with timeout
                        final port = await Future.any([
                          IM15PortDetector.detect(),
                          Future.delayed(const Duration(seconds: 10), () => null),
                        ]);
                    
                        if (port == null) {
                          if (spinnerShown) await spinner.hide();
                          spinnerShown = false;
                          _transactionInProgress = false;
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("No IM15 device detected. Please check connection."),
                              duration: Duration(seconds: 3),
                            ),
                          );
                          return;
                        }
                        
                        // Hide spinner before navigating to PIN screen
                        if (spinnerShown) {
                          await spinner.hide();
                          spinnerShown = false;
                        }
                        
                        // Navigate to PIN entry screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/payment'),
                            builder: (_) => PinEntryScreen(
                              amount: amount,
                              port: port,
                              traceNo: DateTime.now().millisecondsSinceEpoch.toString(),
                              biz: biz,
                              paymentData: data,
                              transactionType: _getTransactionTypeLabel(biz),
                            ),
                          ),
                        ).then((_) {
                          // Reset transaction flag when returning from PIN screen
                          _transactionInProgress = false;
                        });
                        
                        return; // Exit early - PIN screen will handle the rest
                      }
                      
                      // Amount ≤ RM250 - proceed with normal transaction flow
                      print('[PAYMENTPAGE] ✅ Amount RM${amountValue.toStringAsFixed(2)} ≤ RM250 - proceeding with normal transaction');

                      await spinner.show();
                      spinnerShown = true;

                      final serialSettings = IM15SerialSettings();
                      final connMgr = IM15SerialConnectionManager(serialSettings);
                  
                      AbstractC200TransactionService? service;
                  
                      // Select service based on biz type
                      if (biz == "PARKING" || biz == "EXTENDPARKING") {
                        service = ParkingC200Service(context, spinner, [], connMgr);
                      } else if (biz == "CUKAI") {
                        service = TaxC200Service(context, spinner, [], connMgr);
                      } else if (biz == "LESEN") {
                        service = LicenseC200Service(context, spinner, [], connMgr);
                      } else if (biz == "MULTICOMPOUND" || biz == "SINGLECOMPOUND") {
                        service = CompoundC200Service(context, spinner, [], connMgr);
                      }
                  
                      if (service == null) {
                        throw Exception("Unsupported business type: $biz");
                      }
                      
                  
                      // Detect port automatically with timeout
                      final port = await Future.any([
                        IM15PortDetector.detect(),
                        Future.delayed(const Duration(seconds: 10), () => null),
                      ]);
                    
                      if (port == null) {
                        throw Exception("No IM15 device detected. Please check connection.");
                      }
                  
                      await service.execute(
                        amount,
                        port,
                        DateTime.now().millisecondsSinceEpoch.toString(), // traceNo
                        onSuccess: () async {
                          print('[PAYMENTPAGE] ✅ Card payment successful');
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Card payment successful")),
                          );
                  
                          // =============================
                          // ===== PARKING CARD PAYMENT
                          // =============================
                          if (biz == "PARKING") {
                            final result = await ParkingService.callParkingPayAPI(
                              plate: data.plate ?? "",
                              timeUsed: data.hour ?? 0,
                              typePayment: "CARD",
                              orderNo: "0",
                              bankTrxNo: "0",
                            );
                  
                            if (result != null && !result.startsWith("Error")) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(name: '/receipt'),
                                  builder: (_) => RESITPAGE(
                                    biz: biz,
                                    data: ResitData(
                                      plate: data.plate,
                                      hour: data.hour,
                                      amount: data.amount,
                                      pegeOrderNo: "0",
                                      pegeBankTrxNo: "0",
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                  
                          // =============================
                          // ===== EXTEND PARKING CARD PAYMENT
                          // =============================
                          else if (biz == "EXTENDPARKING") {
                            final result = await ParkingService.callParkingExtendAPI(
                              plate: data.plate ?? "",
                              extendHours: data.hour ?? 0,
                              typePayment: "CARD",
                              orderNo: "0",
                              bankTrxNo: "0",
                            );
                  
                            if (result != null && !result.startsWith("Error")) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(name: '/receipt'),
                                  builder: (_) => RESITPAGE(
                                    biz: "PARKING",
                                    data: ResitData(
                                      plate: data.plate,
                                      hour: data.hour,
                                      amount: data.amount,
                                      pegeOrderNo: "0",
                                      pegeBankTrxNo: "0",
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result ?? "Extend parking failed")),
                              );
                            }
                          }
                  
                          // =============================
                          // ===== TAX CARD PAYMENT
                          // =============================
                          else if (biz == "CUKAI") {
                            final billNos = data.taxItems!.map((e) => e.billNo).toList();
                            final success = await TaxService.payMultipleTaxes(billNos);
                  
                            if (success) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(name: '/receipt'),
                                  builder: (_) => RESITPAGE(
                                    biz: "CUKAI",
                                    data: ResitData(
                                      amount: data.amount,
                                      taxItems: data.taxItems,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Tax payment failed")),
                              );
                            }
                          }
                  
                          // =============================
                          // ===== LICENSE CARD PAYMENT
                          // =============================
                          else if (biz == "LESEN") {
                            final licenseNos = data.licenseNos ?? [];
                            if (licenseNos.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Tiada lesen dipilih")),
                              );
                              return;
                            }
                  
                            final success = await LicenseService.payMultipleLicenses(licenseNos);
                            if (success) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(name: '/receipt'),
                                  builder: (_) => RESITPAGE(
                                    biz: "LESEN",
                                    data: ResitData(
                                      amount: data.amount,
                                      licenseNos: licenseNos,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Pembayaran lesen gagal")),
                              );
                            }
                          }
                  
                          // =============================
                          // ===== COMPOUND CARD PAYMENT
                          // =============================
                          else if (biz == "MULTICOMPOUND" || biz == "SINGLECOMPOUND") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: const RouteSettings(name: '/receipt'),
                                builder: (_) => RESITPAGE(
                                  biz: biz,
                                  data: ResitData(
                                    amount: data.amount,
                                    compoundNos: data.compoundNos,
                                    plate: data.plate,
                                    offenderName: data.offenderName,
                                    violationType: data.violationType,
                                    kodhasil: data.kodhasil,
                                    date: data.date ?? DateFormat("yyyy-MM-dd").format(DateTime.now()),
                                    time: data.time ?? DateFormat("HH:mm:ss").format(DateTime.now()),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        onFailure: () async {
                          print('[PAYMENTPAGE] ❌ Card payment failed');
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Card payment failed or timeout. Please try again."),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                        onPINRequired: () async {
                          // This shouldn't be called for amounts ≤ RM250
                          print('[PAYMENTPAGE] ⚠️ Unexpected PIN required for amount ≤ RM250');
                        },
                        onPINCompleted: () async {
                          // This shouldn't be called for amounts ≤ RM250
                          print('[PAYMENTPAGE] ⚠️ Unexpected PIN completed for amount ≤ RM250');
                        },
                      );
                    } catch (e) {
                      print('[PAYMENTPAGE] ❌ Payment error: $e');
                      
                      // Show user-friendly error message
                      String errorMessage = "Payment error occurred. Please try again.";
                      if (e.toString().contains("timeout") || e.toString().contains("Timeout")) {
                        errorMessage = "Transaction timeout. Please check card reader and try again.";
                      } else if (e.toString().contains("port") || e.toString().contains("connection")) {
                        errorMessage = "Card reader connection failed. Please check device.";
                      } else if (e.toString().contains("declined")) {
                        errorMessage = "Transaction declined. Please check your card.";
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          duration: const Duration(seconds: 4),
                          backgroundColor: Colors.red[700],
                        ),
                      );
                    } finally {
                      // ALWAYS hide spinner and reset transaction flag
                      if (spinnerShown) {
                        try {
                          await spinner.hide();
                          print('[PAYMENTPAGE] ✅ Spinner hidden in finally block');
                        } catch (hideError) {
                          print('[PAYMENTPAGE] ⚠️ Error hiding spinner in finally block: $hideError');
                        }
                      }
                      
                      _transactionInProgress = false;
                      print('[PAYMENTPAGE] ✅ Transaction flag reset');
                    }
                  },
              ),
            ),
          ),

          // QR PAYMENT Button
          Positioned(
            top: 750,
            left: 0,
            right: -500,
            child: Center(
            child: _PaymentKioskButton(
            icon: IconData(0xe4f5, fontFamily: 'MaterialIcons'),
            label: AppLocalizations.of(context)!.qrButton,
                        onPressed: () async {
                          //double amount = double.tryParse(data.amount ?? "0.00") ?? 0.00;
                          showLoadingDialog(context); 

                          double testing = 0.01;
                        
                          try {
                            final result = await PegePayService.createOrder(
                              testing,
                              //amount,
                              Config.storeId,
                              Config.terminalId,
                              Config.shiftId,
                            );

                             Navigator.pop(context);
                        
                            final iframeUrl = result["iframe_url"];
                            final orderNo = result["order_no"];
                        
                            if (iframeUrl == null || orderNo == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Failed to create PegePay order.")),
                              );
                              return;
                            }
                        
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     settings: const RouteSettings(name: '/payment'),
                            //     builder: (_) => PegePayQRPageDesktopWebView(
                            //        iframeUrl: iframeUrl,
                            //       orderNo: orderNo,
                            //        onSuccess: () async {
                            //         ScaffoldMessenger.of(context).showSnackBar(
                            //           const SnackBar(content: Text("Payment successful!")),
                            //         );

                            await PegePayWebViewHelper.open(
                            iframeUrl: iframeUrl,
                            orderNo: orderNo,

                            onSuccess: (Map<String, dynamic> paymentResult) async {
                            final pegeOrderNo = paymentResult["order_no"] ?? orderNo;
                            final pegeBankTrxNo = paymentResult["bank_trx_no"] ?? "";
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Payment successful!")),
                              );


                                  /* ======================= */
                                  /* ===== PARKING QR PAYMENT ===== */
                                  /* ======================= */
                                  
                                  if (biz == "PARKING") {
                                    final result = await ParkingService.callParkingPayAPI(
                                      plate: data.plate ?? "",
                                      timeUsed: data.hour ?? 0,
                                      typePayment: "QR",
                                      orderNo: pegeOrderNo,
                                      bankTrxNo: pegeBankTrxNo,
                                    );
                                  
                                    if (result != null && !result.startsWith("Error")) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          settings: const RouteSettings(name: '/receipt'),
                                          builder: (_) => RESITPAGE(
                                            biz: biz,
                                            data: ResitData(
                                              plate: data.plate,
                                              hour: data.hour,
                                              amount: data.amount,
                                              pegeOrderNo: pegeOrderNo,
                                              pegeBankTrxNo: pegeBankTrxNo,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }

                                  /* ======================= */
                                  /* ===== Extend QR PAYMENT ===== */
                                  /* ======================= */

                                  else if (biz == "EXTENDPARKING") {
                                 final result = await ParkingService.callParkingExtendAPI(
                                   plate: data.plate ?? "",
                                   extendHours: data.hour ?? 0,
                                   typePayment: "QR",
                                     orderNo: pegeOrderNo,
                                    bankTrxNo: pegeBankTrxNo,
                                 );
                               
                                 if (result != null && !result.startsWith("Error")) {
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                      settings: const RouteSettings(name: '/receipt'),
                                       builder: (_) => RESITPAGE(
                                         biz: "PARKING",
                                         data: ResitData(
                                           plate: data.plate,
                                           hour: data.hour,
                                           amount: data.amount,
                                           pegeOrderNo: pegeOrderNo,
                                           pegeBankTrxNo: pegeBankTrxNo,
                                         ),
                                       ),
                                     ),
                                   );
                                 } else {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text(result ?? "Extend parking failed")),
                                   );
                                 }
                               }
                                                                 
                                  /* ======================= */
                                  /* ===== TAX QR PAYMENT ===== */
                                  /* ======================= */
                                  // else if (biz == "CUKAI") {
                                  //   final billNos =
                                  //       data.taxItems!.map((e) => e.billNo).toList();
                                  
                                  //   final success = await TaxService.payMultipleTaxes(billNos);
                                  
                                  //   if (success) {
                                  //    Navigator.push(
                                  //      context,
                                  //      MaterialPageRoute(
                                  //       settings: const RouteSettings(name: '/receipt'),
                                  //        builder: (_) => RESITPAGE(
                                  //          biz: "CUKAI",
                                  //          data: ResitData(
                                  //            amount: data.amount,
                                  //            taxItems: data.taxItems,
                                  //            pegeOrderNo: pegeOrderNo,
                                  //            pegeBankTrxNo: pegeBankTrxNo,
                                  //          ),
                                  //        ),
                                  //      ),
                                  //    );
                                     
                                  //   } else {
                                  //     ScaffoldMessenger.of(context).showSnackBar(
                                  //       const SnackBar(content: Text("Tax payment failed")),
                                  //     );
                                  //   }
                                  // }

                                  else if (biz == "CUKAI") {
                                  final items = data.taksiranItems ?? [];

                                  if (items.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Tiada cukai dipilih")),
                                    );
                                    return;
                                  }

                                  final success = await TaksiranPaymentServiceBentong.payMultiple(
                                    items: items,
                                    referenceNo: pegeOrderNo,
                                  );

                                  if (success) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        settings: const RouteSettings(name: '/receipt'),
                                        builder: (_) => RESITPAGE(
                                          biz: "CUKAI",
                                          data: ResitData(
                                            amount: data.amount,
                                            taksiranItems: data.taksiranItems,
                                            pegeOrderNo: pegeOrderNo,
                                            pegeBankTrxNo: pegeBankTrxNo,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Cukai payment update failed")),
                                    );
                                  }
                                }
                                   /* ======================= */
                                   /* ===== SEWAAN QR PAYMENT ===== */
                                   /* ======================= */
                                else if (biz == "SEWAAN") {
                                    final items = data.sewaanItems ?? [];

                                    if (items.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Tiada sewaan dipilih")),
                                      );
                                      return;
                                    }

                                    final success = await SewaanPaymentServiceBentong.payMultipleSewaan(
                                      items: items,
                                      referenceNo: pegeBankTrxNo,
                                    );

                                    if (success) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          settings: const RouteSettings(name: '/receipt'),
                                          builder: (_) => RESITPAGE(
                                            biz: "SEWAAN",
                                            data: ResitData(
                                              amount: data.amount,
                                              pegeOrderNo: pegeOrderNo,
                                              pegeBankTrxNo: pegeBankTrxNo,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Sewaan payment update failed"),
                                        ),
                                      );
                                    }
                                  }
                                                                    
                                   /* ======================= */
                                   /* ===== LICENSE QR PAYMENT ===== */
                                   /* ======================= */
                                   else if (biz == "LESEN") {
                                   final licenseNos = data.licenseNos ?? [];
                                   print('Selected licenses:  $licenseNos');

                                 
                                   if (licenseNos.isEmpty) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(content: Text("Tiada lesen dipilih")),
                                     );
                                     return;
                                   }
                                 
                                   final success =
                                       await LicenseService.payMultipleLicenses(licenseNos);
                                 
                                   if (success) {
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(
                                        settings: const RouteSettings(name: '/receipt'),
                                         builder: (_) => RESITPAGE(
                                           biz: "LESEN", 
                                           data: ResitData(
                                             amount: data.amount,
                                             licenseNos: licenseNos, 
                                             pegeOrderNo: pegeOrderNo,
                                             pegeBankTrxNo: pegeBankTrxNo,
                                           ),
                                         ),
                                       ),
                                     );
                                   } else {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(content: Text("Pembayaran lesen gagal")),
                                     );
                                   }
                                 }
      
                                  /* ======================= */
                                  /* ===== MULTIPLECOMPOUND QR PAYMENT ===== */
                                  /* ======================= */

                                 else if (biz == "MULTICOMPOUND") {
                                   // NO API CALL ❌
                                   // Just go to receipt page ✅
                                //Navigator.pop(context);
                                 
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                      settings: const RouteSettings(name: '/receipt'),
                                       builder: (_) => RESITPAGE(
                                         biz: "MULTICOMPOUND",
                                         data: ResitData(
                                           amount: data.amount,
                                           compoundNos: data.compoundNos,
                                           pegeOrderNo: pegeOrderNo,
                                           pegeBankTrxNo: pegeBankTrxNo,
                                         ),
                                       ),
                                     ),
                                   );
                                 }
                                  
                                else if (biz == "SINGLECOMPOUND") {
                                 Navigator.push(
                                   context,
                                   MaterialPageRoute(
                                    settings: const RouteSettings(name: '/receipt'),
                                     builder: (_) => RESITPAGE(
                                       biz: "SINGLECOMPOUND",
                                       data: ResitData(
                                        amount: data.amount,
                                        pegeOrderNo: pegeOrderNo,
                                        pegeBankTrxNo: pegeBankTrxNo,
                                        compoundNos: data.compoundNos,
                                        plate: data.plate,
                                        offenderName: data.offenderName,
                                        violationType: data.violationType,
                                        kodhasil: data.kodhasil,
                                        date: data.date ?? DateFormat("yyyy-MM-dd").format(DateTime.now()),
                                        time: data.time ?? DateFormat("HH:mm:ss").format(DateTime.now()),
                                       ),
                                     ),
                                   ),
                                 );
                               }
                               
                                  },
                                    onCancel: () {
    print("User closed QR window");
    // stay on payment page (no navigation needed)
  },
);
                                  
                            //     ),
                            //   ),
                            // );
                          } catch (e) {
                            Navigator.pop(context);
                            print("PegePay createOrder error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Error creating PegePay order.")),
                            );
                          }
                        },
              ),
            ),
          ),

        
        //we accept text + payment method image

          Positioned(
          top: 1200,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.weAcceptText,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 18),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20), // rounded image
                  child: Image.asset(
                    "lib/images/Payment_Method.png",
                    width: 520,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),


          // Bottom button (KEMBALI)
          Positioned(
            bottom: 180,
            left: 300,
            right: 300,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                  side: const BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  AppLocalizations.of(context)!.backButton,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Footer text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child:  Center(
              child: Text(
                Data.copyrightText,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Helper function to get transaction type label
  String _getTransactionTypeLabel(String biz) {
    switch (biz) {
      case "PARKING":
        return "Parking Payment";
      case "EXTENDPARKING":
        return "Extend Parking";
      case "CUKAI":
        return "Tax Payment";
      case "LESEN":
        return "License Payment";
      case "MULTICOMPOUND":
        return "Multiple Compound";
      case "SINGLECOMPOUND":
        return "Single Compound";
      default:
        return "Payment";
    }
  }
  
}

/// =======================================================
/// PAYMENT BUTTON STYLE (SAME AS PBT3)
/// =======================================================
class _PaymentKioskButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PaymentKioskButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 400,
        height: 400,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF6F9FF),
                Color(0xFFD1DFF3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
              ),
            ],
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 160,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
