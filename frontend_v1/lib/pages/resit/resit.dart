import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/compound/multiple_compound_controller.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/tax/payment_tax_item.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/home/p1bentong.dart';
import 'package:frontend_v1/widgets/kiosk_home_button.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../home/p1.dart';
import 'dart:async';
import 'package:frontend_v1/model/taksiran/taksiran_payment_item.dart';
import 'package:frontend_v1/model/sewaan/sewaan_payment_item.dart';

class ResitData {
  String? biz;
  String? plate;
  int? hour;
  String? amount;
  String? samanNo;
  String? licenseNo;
  String? accountNo;
  DateTime? startTime;
  DateTime? endTime;
  List<String>? licenseNos;
  List<String>? compoundNos;
  List<PaymentTaxItem>? taxItems;
  List<TaksiranPaymentItem>? taksiranItems;
  List<SewaanPaymentItem>? sewaanItems;


  String? offenderName;
  String? violationType;
  String? kodhasil;
  String? date;
  String? time;

  String? pegeOrderNo;
  String? pegeBankTrxNo;

  String? typePayment;

  ResitData({
    this.biz,
    this.plate,
    this.hour,
    this.amount,
    this.samanNo,
    this.licenseNo,
    this.accountNo,
    this.startTime,
    this.endTime,
    this.taxItems,
    this.licenseNos,
    this.compoundNos,
    this.offenderName,
    this.violationType,
    this.kodhasil,
    this.date,
    this.time,
    this.pegeOrderNo,
    this.pegeBankTrxNo,
    this.taksiranItems,
    this.typePayment,
    this.sewaanItems,
  });
}

class RESITPAGE extends StatefulWidget {
  final String biz;
  final ResitData data;

  const RESITPAGE({
    super.key,
    required this.biz,
    required this.data,
  });

  @override
  State<RESITPAGE> createState() => _RESITSTATE();
}

class _RESITSTATE extends State<RESITPAGE> {
  String startTimeStr = "Loading...";
  String endTimeStr = "Loading...";
  Uint8List? qrImageBytes;

  final String baseUrl = Config.baseUrl;

  Timer? _countdownTimer;
  int _remainingSeconds = 100;

  String? pegeOrderNo;
  String? pegeBankTrxNo;

  @override
  void initState() {
    super.initState();
    
    pegeOrderNo = widget.data.pegeOrderNo;
   pegeBankTrxNo = widget.data.pegeBankTrxNo;
 
    fetchTransactionData();
    fetchQrImage();
    _startCountdown();
  }

  Future<void> fetchTransactionData() async {
    try {
      String urlString;

      if (widget.biz == "PARKING") {
        urlString = "$baseUrl/transactions/latest/${widget.data.plate}";
      } else if (widget.biz == "LESEN") {
        urlString = "$baseUrl/license/latest/${widget.data.licenseNo}";
      } else if (widget.biz == "SAMAN") {
        urlString = "$baseUrl/saman/latest/${widget.data.samanNo}";
      } else {
        urlString = "$baseUrl/transactions/latest/${widget.data.plate}";
      }

      final url = Uri.parse(urlString);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        pegeOrderNo = jsonData['order_no'];
        pegeBankTrxNo = jsonData['bank_trx_no'];      

        final timeInRaw = jsonData['time_in'] ?? "";
        final timeOutRaw = jsonData['time_out'] ?? "";

        final inputFmt = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
        final outputFmt = DateFormat("hh:mm a");


setState(() {
  final backendOrderNo = jsonData['order_no']?.toString();
  final backendBankTrxNo = jsonData['bank_trx_no']?.toString();

  if (backendOrderNo != null && backendOrderNo.isNotEmpty && backendOrderNo != "null") {
    pegeOrderNo = backendOrderNo;
  }

  if (backendBankTrxNo != null && backendBankTrxNo.isNotEmpty && backendBankTrxNo != "null") {
    pegeBankTrxNo = backendBankTrxNo;
  }

  if (timeInRaw.isNotEmpty) {
    widget.data.startTime = inputFmt.parse(timeInRaw);
    startTimeStr = outputFmt.format(widget.data.startTime!);
  } else {
    startTimeStr = "N/A";
  }

  if (timeOutRaw.isNotEmpty) {
    widget.data.endTime = inputFmt.parse(timeOutRaw);

    final maxEndTime = DateTime(
      widget.data.endTime!.year,
      widget.data.endTime!.month,
      widget.data.endTime!.day,
      18,
      0,
    );

    if (widget.data.endTime!.isAfter(maxEndTime)) {
      widget.data.endTime = maxEndTime;
    }

    endTimeStr = outputFmt.format(widget.data.endTime!);
  } else {
    endTimeStr = "N/A";
  }
});
      } else {
        setState(() {
          startTimeStr = endTimeStr = "N/A";
        });
      }
    } catch (e) {
      setState(() {
        startTimeStr = endTimeStr = "Error";
      });
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                settings: const RouteSettings(name: '/p1'),
                builder: (_) => const P1BentongPage()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  Future<void> fetchQrImage() async {
    try {
      http.Response response;

      if (widget.biz == "PARKING") {
        response = await http.get(Uri.parse("$baseUrl/transactions/latest/qr"));
      } else if (widget.biz == "LESEN") {
        final licenseNos = widget.data.licenseNos;
        if (licenseNos == null || licenseNos.isEmpty) return;

        response = await http.post(
          Uri.parse("$baseUrl/license/receipt/qr/multi"),
          headers: {
            "Content-Type": "application/json",
            "Accept": "image/png",
          },
          body: jsonEncode({"licenses": licenseNos}),
        );
      } else if (widget.biz == "SAMAN") {
        response = await http.get(Uri.parse("$baseUrl/saman/latest/qr"));
      } 
      //else if (widget.biz == "CUKAI") {
      //   final billNos = widget.data.taxItems!.map((e) => e.billNo).toList();
      //   response = await http.post(
      //     Uri.parse("$baseUrl/tax/receipt/qr/multi"),
      //     headers: {
      //       "Content-Type": "application/json",
      //       "Accept": "image/png",
      //     },
      //     body: jsonEncode({"bill_no": billNos}),
      //   );
      // } 

            else if (widget.biz == "CUKAI") {
        final items = widget.data.taksiranItems;

        if (items == null || items.isEmpty) {
          debugPrint("No taksiran items found for Bentong receipt QR");
          return;
        }

        final taxItemsPayload = items.map((item) {
          return {
            "account_number": item.accountNo,
            "owner_name": item.ownerName,
            "property_address": item.propertyAddress,
            "amount": item.amount,
          };
        }).toList();

        response = await http.post(
          Uri.parse("$baseUrl/tax/receipt/qr/bentong"),
          headers: {
            "Content-Type": "application/json",
            "Accept": "image/png",
          },
          body: jsonEncode({
            "order_no": pegeOrderNo ?? widget.data.pegeOrderNo ?? "0",
            "paid_date": DateTime.now().toIso8601String(),
            "payment_method": widget.data.typePayment ?? " ",
            "bank_trx_no": pegeBankTrxNo ?? widget.data.pegeBankTrxNo ?? "",
            "tax_items": taxItemsPayload,
          }),
        );
      }

      else if (widget.biz == "SEWAAN") {
  final items = widget.data.sewaanItems;

  if (items == null || items.isEmpty) {
    debugPrint("No sewaan items found for Bentong receipt QR");
    return;
  }

  final sewaanItemsPayload = items.map((item) {
    return {
      "account_number": item.accountNo,
      "tenant_name": item.tenantName,
      "registration_no": item.registrationNo,
      "start_date": item.startDate,
      "end_date": item.endDate,
      "premise_address": item.premiseAddress,
      "mailing_address": item.mailingAddress,
      "outstanding_rent": item.outstandingRent,
      "current_rent": item.currentRent,
      "amount": item.amount,
    };
  }).toList();

  response = await http.post(
    Uri.parse("$baseUrl/sewaan/receipt/qr/bentong"),
    headers: {
      "Content-Type": "application/json",
      "Accept": "image/png",
    },
    body: jsonEncode({
      "order_no": pegeOrderNo ?? widget.data.pegeOrderNo ?? "0",
      "paid_date": DateTime.now().toIso8601String(),
      "payment_method": widget.data.typePayment ?? "QR",
      "bank_trx_no": pegeBankTrxNo ?? widget.data.pegeBankTrxNo ?? "",
      "sewaan_items": sewaanItemsPayload,
    }),
  );
}
            
      else if (widget.biz == "MULTICOMPOUND") {
        final compoundNos = widget.data.compoundNos;
        if (compoundNos == null || compoundNos.isEmpty) return;
        final compoundMap = {
          for (var c in MultipleCompoundController.compoundList)
            c.compoundNum: c.amount
        };
        final totalAmount = double.tryParse(widget.data.amount ?? "0.00") ?? 0.0;
        final compoundsPayload = compoundNos
            .map((c) => {"compoundnum": c, "amount": compoundMap[c] ?? 0.0})
            .toList();

        response = await http.post(
          Uri.parse("$baseUrl/compound/receipt/qr/multi"),
          headers: {
            "Content-Type": "application/json",
            "Accept": "image/png",
          },
          body: jsonEncode({
            "compounds": compoundsPayload,
            "total_amount": totalAmount,
          }),
        );
      } else if (widget.biz == "SINGLECOMPOUND") {
        final compoundNum = widget.data.compoundNos?.first;
        final totalAmount = double.tryParse(widget.data.amount ?? "0.00") ?? 0.0;
        if (compoundNum == null) return;
        final singleCompoundPayload = {
          "compoundnum": compoundNum,
          "name": widget.data.offenderName ?? "N/A",
          "offense": widget.data.violationType ?? "Compound Payment",
          "plate": widget.data.plate ?? "",
          "date": widget.data.date ??
              DateFormat("yyyy-MM-dd").format(DateTime.now()),
          "time":
              widget.data.time ?? DateFormat("HH:mm:ss").format(DateTime.now()),
          "amount": totalAmount,
        };

        response = await http.post(
          Uri.parse("$baseUrl/compound/receipt/qr/single"),
          headers: {
            "Content-Type": "application/json",
            "Accept": "image/png",
          },
          body: jsonEncode(singleCompoundPayload),
        );
      } else {
        return;
      }

      if (response.statusCode == 200) {
        setState(() {
          qrImageBytes = response.bodyBytes;
        });
      }
    } catch (e) {
      debugPrint("Failed to load QR image: $e");
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // --- Helper Widget for Data Rows ---
Widget _buildInfoRow(
  String label,
  String value, {
  double labelSize = 35,
  double valueSize = 35,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelSize,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    String title = "PAYMENT";
    if (widget.biz == "PARKING") {
      title = AppLocalizations.of(context)!.titleReceiptParking;
    } else if (widget.biz == "LESEN") {
      title = AppLocalizations.of(context)!.titleReceiptLicense;
    } else if (widget.biz == "SAMAN") {
      title = "SAMAN PAYMENT";
    } else if (widget.biz == "CUKAI") {
      title = AppLocalizations.of(context)!.titleReceiptTax;
    } else if (widget.biz == "MULTICOMPOUND") {
      title = AppLocalizations.of(context)!.titleReceiptMultipleCompound;
    } else if (widget.biz == "SINGLECOMPOUND") {
      title = AppLocalizations.of(context)!.titleReceiptSingleCompound;
    }else if (widget.biz == "SEWAAN") {
      title = AppLocalizations.of(context)!.titleReceiptSewaan;
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background (Unchanged)
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

          // 2. Title (Unchanged Style)
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 3. MAIN NEW UI CONTAINER (The Receipt Card)
          Positioned(
            top: 250,
            left: 100,
            right: 100,
            bottom: 350,
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Dynamic Plate/License Info
                    if (widget.biz == "PARKING") ...[
                      _buildInfoRow(loc.receiptPlateLabel2, widget.data.plate ?? 'N/A'),
                        _buildInfoRow(
                          loc.receiptDurationLabel2,
                          widget.data.hour != null
                              ? loc.receiptDurationValue(widget.data.hour!)
                              : "N/A",
                        ),
                      _buildInfoRow(loc.receiptStartTimeLabel2, startTimeStr),
                      _buildInfoRow(loc.receiptEndTimeLabel2, endTimeStr),
                    ],
                    // if (pegeOrderNo != null && pegeOrderNo!.isNotEmpty)
                    //   _buildInfoRow(
                    //     "Order No",
                    //     pegeOrderNo ?? "N/A",
                    //     labelSize: 35,
                    //     valueSize: 30,
                    //   ),

                    if (pegeBankTrxNo != null && pegeBankTrxNo!.isNotEmpty)
                      _buildInfoRow(
                        "Bank Trx No",
                        pegeBankTrxNo ?? "N/A",
                        labelSize: 35,
                        valueSize: 25,
                      ),

                    // if (widget.biz == "LESEN")
                    //   _buildInfoRow(
                    //       "License No", widget.data.licenseNo ?? 'N/A'),

                    // Amount Section (Larger)
                    const Divider(height: 40, thickness: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(loc.receiptAmountLabel2,
                            style: TextStyle(
                                fontSize: 35, fontWeight: FontWeight.bold)),
                        Text(
                          "RM ${widget.data.amount != null ? double.parse(widget.data.amount!).toStringAsFixed(2) : '0.00'}",
                          style: const TextStyle(
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // QR Code Section
                    Text(
                      AppLocalizations.of(context)!.receiptScanQrText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 35, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 25),
                    if (qrImageBytes != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.memory(
                          qrImageBytes!,
                          width: 400,
                          height: 400,
                          fit: BoxFit.contain,
                        ),
                      )
                    else
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),

          // 4. Countdown Timer (Maintained Function)
          Positioned(
            bottom: 270,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.receiptAutoReturn(_remainingSeconds),
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // 5. Back Button (Unchanged Style)
          Positioned(
            bottom: 120,
            left: 300,
            right: 300,
            child: KioskHomeButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: '/p1'),
                    builder: (_) => const P1BentongPage(),
                  ),
                  (route) => false,
                );
              },
            ),
          ),

          // 6. Copyright (Unchanged)
           Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}