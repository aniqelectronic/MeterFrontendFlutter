import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/widgets/clock_card.dart';
import 'p4.dart';
import 'config.dart';
import 'package:frontend_v1/pages/payment.dart';

class P5PARKINGPAGE extends StatefulWidget {
  final String plate;
  final String biz;

  const P5PARKINGPAGE({
    super.key,
    required this.plate,
    required this.biz,
  });

  @override
  State<P5PARKINGPAGE> createState() => _P5PARKINGPAGEState();
}

class _P5PARKINGPAGEState extends State<P5PARKINGPAGE> {
  int hours = 1;
  double rate = Data.ratePerHour;
  DateTime startTime = DateTime.now();
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          startTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  DateTime get maxEndTime {
    return DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
      18,
      0,
    );
  }

  String formatTime(DateTime time) {
    int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  DateTime get endTime {
    DateTime calculated = startTime.add(Duration(hours: hours));
    return calculated.isAfter(maxEndTime) ? maxEndTime : calculated;
  }

  double get totalPrice {
    return hours * rate;
  }

  void _addHour() {
    final newEndTime = startTime.add(Duration(hours: hours + 1));
    if (!newEndTime.isAfter(maxEndTime)) {
      setState(() {
        hours++;
      });
    }
  }

  void _minusHour() {
    if (hours > 1) {
      setState(() {
        hours--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
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

          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "PARK&PAY",
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Positioned(
            top: 250,
            right: 250,
            left: 250,
            child: ClockCard(fontScale: 0.8),
          ),

          Positioned(
            top: 700,
            left: 60,
            right: 60,
            bottom: 350,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color.fromARGB(255, 3, 89, 210),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(46),
                        topRight: Radius.circular(46),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            loc.p5parkingNumberPlate,
                            style: TextStyle(
                              color: Colors.blueGrey[700],
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            widget.plate,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 60,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                loc.p5parkingText1,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _circularButton(
                                    Icons.remove,
                                    hours > 1 ? _minusHour : null,
                                  ),
                                  Container(
                                    width: 180,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "$hours",
                                      style: const TextStyle(
                                        fontSize: 120,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _circularButton(
                                    Icons.add,
                                    startTime
                                            .add(Duration(hours: hours + 1))
                                            .isBefore(maxEndTime) ||
                                        startTime
                                            .add(Duration(hours: hours + 1))
                                            .isAtSameMomentAs(maxEndTime)
                                        ? _addHour
                                        : null,
                                  ),
                                ],
                              ),
                              Text(
                                loc.time.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 30,
                                  letterSpacing: 4,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: 2,
                          height: 250,
                          color: Colors.grey[300],
                        ),

                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _timeInfoTile(
                                  Icons.play_circle_fill,
                                  loc.p5parkingStart,
                                  formatTime(startTime),
                                ),
                                const SizedBox(height: 25),
                                _timeInfoTile(
                                  Icons.stop_circle,
                                  loc.p5parkingEnd,
                                  formatTime(endTime),
                                ),
                                const SizedBox(height: 30),
                                const Divider(thickness: 2),
                                const SizedBox(height: 10),
                                Text(
                                  loc.p5parkingTotal,
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.blueGrey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "RM ${totalPrice.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 160,
            left: 100,
            right: 100,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => P4PAGE(
                            title: loc.parkirButton,
                            type: "PBT",
                            hint: loc.inputPlateHint,
                            biz: "PARKING",
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        loc.backButton,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showConfirmation(context, loc),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        loc.continueButton,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                style: const TextStyle(
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

  Widget _circularButton(IconData icon, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onPressed == null
              ? Colors.grey[300]
              : const Color.fromARGB(255, 3, 89, 210),
        ),
        child: Icon(icon, color: Colors.white, size: 50),
      ),
    );
  }

  Widget _timeInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 3, 89, 210), size: 40),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
      ],
    );
  }

  void _showConfirmation(BuildContext context, AppLocalizations loc) {
    Timer? dialogTimer;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            dialogTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
              if (mounted) {
                setState(() {
                  startTime = DateTime.now();
                });

                setDialogState(() {});
              }
            });

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: SizedBox(
                width: 1000,
                height: 720,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      Text(
                        loc.confirmDialogTitle,
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const Spacer(),
                      _dialogRow(loc.plateNumberLabel(""), widget.plate, true),
                      _dialogRow(loc.p5timeparking, "$hours ${loc.time}", false),
                      _dialogRow(
                        loc.p5tempoh,
                        "${formatTime(startTime)} - ${formatTime(endTime)}",
                        false,
                      ),
                      _dialogRow(
                        loc.p5Total,
                        "RM ${totalPrice.toStringAsFixed(2)}",
                        true,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                dialogTimer?.cancel();
                                Navigator.pop(dialogContext);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                padding: const EdgeInsets.all(20),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                loc.cancelButton,
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                dialogTimer?.cancel();

                                final payStartTime = startTime;
                                final payEndTime = endTime;

                                Navigator.pop(dialogContext);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    settings:
                                        const RouteSettings(name: '/payment'),
                                    builder: (_) => PAYMENTPAGE(
                                      biz: widget.biz,
                                    data: PaymentData(
                                      plate: widget.plate,
                                      hour: hours,
                                      amount: totalPrice.toStringAsFixed(2),
                                    ),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.all(20),
                              ),
                              child: const Text(
                                "OK",
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      dialogTimer?.cancel();
    });
  }

  Widget _dialogRow(String label, String value, bool bold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 40)),
          Text(
            value,
            style: TextStyle(
              fontSize: 40,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}