import 'dart:convert';

import 'dart:typed_data';



import 'package:flutter/material.dart';

import 'package:frontend_v1/controllers/compound/multiple_compound_controller.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';

import 'package:frontend_v1/model/tax/payment_tax_item.dart';

import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';

import 'p1.dart';

import 'dart:async';





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



  String? offenderName;

  String? violationType;

  String? kodhasil;

  String? date;

  String? time;



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

  });

}



class OLDRESITPAGE extends StatefulWidget {

  final String biz;

  final ResitData data;



  const OLDRESITPAGE({

    super.key,

    required this.biz,

    required this.data,

  });



  @override

  State<OLDRESITPAGE> createState() => _RESITSTATE();

}



class _RESITSTATE extends State<OLDRESITPAGE> {

  String startTimeStr = "Loading...";

  String endTimeStr = "Loading...";

  Uint8List? qrImageBytes;



  final String baseUrl = Config.baseUrl;



  Timer? _countdownTimer;

  int _remainingSeconds = 100;





  @override

  void initState() {

    super.initState();

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



      final timeInRaw = jsonData['time_in'] ?? "";

      final timeOutRaw = jsonData['time_out'] ?? "";



      final inputFmt = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

      final outputFmt = DateFormat("hh:mm a");



      setState(() {

        if (timeInRaw.isNotEmpty) {

          widget.data.startTime = inputFmt.parse(timeInRaw);

          startTimeStr = outputFmt.format(widget.data.startTime!);

        } else {

          startTimeStr = "N/A";

        }



        if (timeOutRaw.isNotEmpty) {

           widget.data.endTime = inputFmt.parse(timeOutRaw);

         

           // Clamp end time to 6:00 PM

           final maxEndTime = DateTime(

             widget.data.endTime!.year,

             widget.data.endTime!.month,

             widget.data.endTime!.day,

             18, // 6 PM

             0,

           );

         

          if (widget.data.endTime!.isAfter(maxEndTime)) {

             widget.data.endTime = maxEndTime;

           }

         

           endTimeStr = outputFmt.format(widget.data.endTime!);

         }else {

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

            builder: (_) => const P1Page()),

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



    /* ================= PARKING ================= */

    if (widget.biz == "PARKING") {

      response = await http.get(

        Uri.parse("$baseUrl/transactions/latest/qr"),

      );

    }



    /* ================= LICENSE ================= */

    else if (widget.biz == "LESEN") {

      final licenseNos = widget.data.licenseNos;

   

      if (licenseNos == null || licenseNos.isEmpty) return;

   

      response = await http.post(

        Uri.parse("$baseUrl/license/receipt/qr/multi"),

        headers: {

          "Content-Type": "application/json",

          "Accept": "image/png",

        },

        body: jsonEncode({

          "licenses": licenseNos,

        }),

      );

    }



    /* ================= SAMAN ================= */

    else if (widget.biz == "SAMAN") {

      response = await http.get(

        Uri.parse("$baseUrl/saman/latest/qr"),

      );

    }



    /* ================= TAX (MULTI) ================= */

    else if (widget.biz == "CUKAI") {

      final billNos =

          widget.data.taxItems!.map((e) => e.billNo).toList();



      response = await http.post(

        Uri.parse("$baseUrl/tax/receipt/qr/multi"),

        headers: {

          "Content-Type": "application/json",

          "Accept": "image/png",

        },

        body: jsonEncode({

          "bill_no": billNos,

        }),

      );

    }



    /* ================= MULTI COMPOUND ================= */

else if (widget.biz == "MULTICOMPOUND") {

  final compoundNos = widget.data.compoundNos;



  if (compoundNos == null || compoundNos.isEmpty) {

    debugPrint("No compounds to fetch QR");

    return;

  }

   final compoundMap = {

     for (var c in MultipleCompoundController.compoundList)

       c.compoundNum: c.amount

   };



  final totalAmount =

      double.tryParse(widget.data.amount ?? "0.00") ?? 0.0;



  final compoundsPayload = compoundNos

      .map((c) => {

            "compoundnum": c,

            "amount": compoundMap[c] ?? 0.0,

          })

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

  }



  /* ================= SINGLE COMPOUND ================= */

else if (widget.biz == "SINGLECOMPOUND") {





final compoundNum = widget.data.compoundNos?.first;

final totalAmount = double.tryParse(widget.data.amount ?? "0.00") ?? 0.0;



if (compoundNum == null) {

  debugPrint("No SINGLE COMPOUND number provided");

  return;

}



final singleCompoundPayload = {

    "compoundnum": compoundNum,

    "name": widget.data.offenderName ?? "N/A",

    "offense": widget.data.violationType ?? "Compound Payment",

    "plate": widget.data.plate ?? "",

    "date": widget.data.date ?? DateFormat("yyyy-MM-dd").format(DateTime.now()),

    "time": widget.data.time ?? DateFormat("HH:mm:ss").format(DateTime.now()),

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

}





    else {

      return;

    }



    if (response.statusCode == 200) {

      setState(() {

        qrImageBytes = response.bodyBytes;

      });

    } else {

      debugPrint("QR fetch failed: ${response.statusCode}");

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





  @override

  Widget build(BuildContext context) {

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



          // TITLE

          Positioned(

            top: 100,

            left: 0,

            right: 0,

            child: Center(

              child: // TITLE

               Text(

                 widget.biz == "PARKING"

                     ?  AppLocalizations.of(context)!.titleReceiptParking

                     : widget.biz == "LESEN"

                         ? AppLocalizations.of(context)!.titleReceiptLicense

                         : widget.biz == "SAMAN"

                             ? "SAMAN PAYMENT"

                             : widget.biz == "CUKAI"

                               ? AppLocalizations.of(context)!.titleReceiptTax

                               : widget.biz == "MULTICOMPOUND"

                                  ? AppLocalizations.of(context)!.titleReceiptMultipleCompound

                                    : widget.biz == "SINGLECOMPOUND"

                                      ? AppLocalizations.of(context)!.titleReceiptSingleCompound

                               : "PAYMENT",

                           

                 style: const TextStyle(

                   color: Color.fromARGB(255, 3, 89, 210),

                   fontSize: 60,

                   fontWeight: FontWeight.bold,

                 ),

               ),

            ),

          ),



          // Plate Number

          Positioned(

            top: 280,

            left: 0,

            right: 0,

            child: Center(

              child:Text(

               widget.biz == "PARKING"

                   ?   AppLocalizations.of(context)!.receiptPlateLabel( widget.data.plate ?? 'N/A',)

                           : "",

               style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),

              ),

             ),

          ),

             

          // Parking Duration

          Positioned(

            top: 360,

            left: 0,

            right: 0,

            child: Center(

              child: Text(

             widget.biz == "PARKING"

                   ?   AppLocalizations.of(context)!.receiptDurationLabel(widget.data.hour ?? 'N/A', )

                           : "",

               style: const TextStyle(fontSize: 50),

              ),

            ),

          ),



          // Amount

          Positioned(

            top: widget.biz == "PARKING" ? 450 : 350,

            left: 0,

            right: 0,

            child: Center(

              child: Text(

                AppLocalizations.of(context)!.receiptAmountLabel(widget.data.amount != null? double.parse(widget.data.amount!).toStringAsFixed(2)  : 'N/A', ),

                style: const TextStyle(fontSize: 50,  fontWeight: FontWeight.w500),

              ),

            ),

          ),



          // Text

          Positioned(

            top: widget.biz == "PARKING" ? 550 : 650,

            left: 0,

            right: 0,

            child: Center(

              child: Column(

                children: [

                  if (widget.biz == "PARKING") ...[

                    Text(

                      AppLocalizations.of(context)!.receiptStartTimeLabel(startTimeStr),

                      style: const TextStyle(fontSize: 50),

                    ),

                    Text(

                      AppLocalizations.of(context)!.receiptEndTimeLabel(endTimeStr),

                      style: const TextStyle(fontSize: 50),

                    ),

                    Text(

                      AppLocalizations.of(context)!.receiptScanQrText,

                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),

                      textAlign: TextAlign.center,

                    ),

                  ] else ...[

                    Text(

                      AppLocalizations.of(context)!.receiptScanQrText,

                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),

                      textAlign: TextAlign.center,

                    ),

                  ],

                ],

              ),

            ),

          ),



                      Positioned(

             bottom: 370,

             left: 0,

             right: 0,

             child: Center(

               child: Text(

                 AppLocalizations.of(context)!

                     .receiptAutoReturn(_remainingSeconds),

                 style: const TextStyle(

                   fontSize: 40,

                   fontWeight: FontWeight.w500,

                 ),

                 textAlign: TextAlign.center,

               ),

             ),

           ),



          // QR Image

          if (qrImageBytes != null)

            Positioned(

              top: widget.biz == "PARKING" ? 920 : 800,

              left: 0,

              right: 0,

              child: Center(

                child: Image.memory(

                  qrImageBytes!,

                  width: 500,

                  height: 500,

                  fit: BoxFit.contain,

                ),

              ),

            )

          else

            Positioned(

              top: 350,

              left: 0,

              right: 0,

              child: const Center(child: CircularProgressIndicator()),

            ),





          // Back Button

           Positioned(

             bottom: 200,

             left: 300,

             right: 300,

             child: ElevatedButton(

               onPressed: () {

                 Navigator.push(

                   context,

                   MaterialPageRoute(

                     settings: const RouteSettings(name: '/p1'),

                     builder: (_) => const P1Page(),

                   ),

                 );

               },

               style: ElevatedButton.styleFrom(

                 backgroundColor: Colors.grey[300], // light grey

                 foregroundColor: Colors.black,

                 elevation: 0,

                 shape: RoundedRectangleBorder(

                   borderRadius: BorderRadius.circular(8),

                 ),



                side: const BorderSide(

                  color: Colors.black, // ✅ black border

                  width: 2,            // thickness

                ),

                 padding: const EdgeInsets.symmetric(vertical: 40),

               ),

               child: Text(

                 AppLocalizations.of(context)!.homeButton,

                 style: const TextStyle(

                   fontSize: 30,

                   fontWeight: FontWeight.bold,

                 ),

               ),

             ),

           ),





          // Copyright

          Positioned(

            bottom: 100,

            left: 0,

            right: 0,

            child: Center(

              child: Text(

                Data.copyrightText,

                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

              ),

            ),

          ),

        ],

      ),

    );

  }

}