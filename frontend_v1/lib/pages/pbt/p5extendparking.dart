import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/parking/parking_controller.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';
import 'package:frontend_v1/pages/pbt/p6extendparking.dart';
import 'package:frontend_v1/pages/resit/resit.dart';

class P5EXTENDPARKINGPAGE extends StatefulWidget {
  final String plate;
  final String biz;

  const P5EXTENDPARKINGPAGE({
    super.key,
    required this.plate,
    required this.biz,
  });

  @override
  State<P5EXTENDPARKINGPAGE> createState() => _P5EXTENDPARKINGSTATE();
}

class _P5EXTENDPARKINGSTATE extends State<P5EXTENDPARKINGPAGE> {

  void _goToExtendPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => P6EXTENDPARKINGPAGE(
          plate: widget.plate,
          biz: widget.biz,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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

          // Title
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.p5extendparkingTitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Subtitle
          Positioned(
            top: 340,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.p5extendparkingSubtitle,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          // ================= EXTEND BUTTON =================
          Positioned(
            top: 700,
            left: -500,
            right: 0,
            child: _KioskMainButton(
              width: 400,
              height: 400,
              icon: Icons.add_circle_outline,
              label: AppLocalizations.of(context)!.plusTimeButton,
              onPressed: () {

                String? endTimeStr = ParkingController.getParkingEndTime();

                if (endTimeStr == null || endTimeStr.isEmpty) {
                  _goToExtendPage();
                  return;
                }

                String today =
                    DateTime.now().toIso8601String().split("T")[0];

                DateTime endTime =
                    DateTime.parse("$today $endTimeStr");

                DateTime maxEndTime = DateTime(
                  endTime.year,
                  endTime.month,
                  endTime.day,
                  18,
                  0,
                );

                if (endTime.isBefore(maxEndTime)) {
                  _goToExtendPage();
                } else {

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                            AppLocalizations.of(context)!.alertTitle),
                        content: Text(
                            AppLocalizations.of(context)!
                                .parkingExpiredAfter6pm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),

          // ================= RECEIPT BUTTON =================
          Positioned(
            top: 700,
            left: 0,
            right: -500,
            child: _KioskMainButton(
              width: 400,
              height: 400,
              icon: Icons.receipt_long,
              label: AppLocalizations.of(context)!.receiptButton,
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RESITPAGE(
                      biz: "PARKING",
                      data: ResitData(
                        plate: widget.plate,
                        hour: ParkingController.getParkingHours() ?? 0,
                        amount:
                            ParkingController.getParkingAmount() ?? "0",
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ================= BACK BUTTON =================
          Positioned(
            bottom: 300,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 400,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => P4PAGE(
                          title:
                              AppLocalizations.of(context)!.parkirButton,
                          type: "PBT",
                          hint: AppLocalizations.of(context)!
                              .inputPlateHint,
                          biz: "PARKING",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 40),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.backText,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Footer
          Positioned(
            bottom: 100,
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
}

////////////////////////////////////////////////////////////
/// KIOSK MAIN BUTTON
////////////////////////////////////////////////////////////

class _KioskMainButton extends StatefulWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const _KioskMainButton({
    this.icon,
    required this.label,
    required this.onPressed,
    this.width = 200,
    this.height = 150,
  });

  @override
  State<_KioskMainButton> createState() => _KioskMainButtonState();
}

class _KioskMainButtonState extends State<_KioskMainButton> {

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {

    return Center(
      child: GestureDetector(

        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,

        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 100),

          child: Container(
            width: widget.width,
            height: widget.height,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              border: Border.all(color: Colors.black, width: 4),

              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF4F8FF),
                  Color(0xFFCCD9F2),
                ],
              ),

              boxShadow: _isPressed
                  ? []
                  : const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 12),
                        blurRadius: 0,
                      ),
                    ],
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 3),
                  ),

                  child: Icon(
                    widget.icon,
                    size: 140,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  widget.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
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