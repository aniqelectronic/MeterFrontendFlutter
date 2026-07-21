import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/parking/parking_controller.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/payment/payment.dart';
import 'package:frontend_v1/widgets/clock_card.dart';
import '../p4.dart';
import '../../config.dart';

class P6EXTENDPARKINGPAGE extends StatefulWidget {
  final String plate;
  final String biz;

  const P6EXTENDPARKINGPAGE({
    super.key,
    required this.plate,
    required this.biz,
  });

  @override
  State<P6EXTENDPARKINGPAGE> createState() => _P6EXTENDPARKINGPAGEState();
}

class _P6EXTENDPARKINGPAGEState extends State<P6EXTENDPARKINGPAGE> {
  int hours = 1;
  double rate = Data.ratePerHour;

  late DateTime startTime;

  @override
  void initState() {
    super.initState();
    startTime = _getStartTimeFromParkingController();

      WidgetsBinding.instance.addPostFrameCallback((_) {
    _showParkingRateInfoDialog();
  });
  }

   void _showParkingRateInfoDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: SizedBox(
          width: 900,
          child: Padding(
            padding: const EdgeInsets.all(35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_parking_rounded,
                  size: 80,
                  color: Color.fromARGB(255, 3, 89, 210),
                ),

                const SizedBox(height: 15),

                Text(
              AppLocalizations.of(context)!.parkingInfoTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 3, 89, 210),
              ),
            ),

                const Divider(height: 35, thickness: 2),

                Text(
                AppLocalizations.of(context)!.parkingRateLabel,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

                const SizedBox(height: 10),

                Text(
                  AppLocalizations.of(context)!
                      .parkingRatePerHour(Data.ratePerHour.toStringAsFixed(2)),
                  style: const TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  AppLocalizations.of(context)!.parkingContactTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                _contactRow(
                  Icons.phone,
                  AppLocalizations.of(context)!.parkingCouncilHotline,
                  Data.aduanMajlisBentong,
                ),

                const SizedBox(height: 12),

                _contactRow(
                  Icons.local_phone_rounded,
                  AppLocalizations.of(context)!.parkingCityCarParkHotline,
                  Data.telefonNo,
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 89, 210),
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _contactRow(IconData icon, String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.blue.shade200,
        width: 1.5,
      ),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 38,
          color: const Color.fromARGB(255, 3, 89, 210),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}

  DateTime _getStartTimeFromParkingController() {
    String? endTimeStr = ParkingController.getParkingEndTime();

    if (endTimeStr == null || endTimeStr.isEmpty) {
      return DateTime.now();
    }

    String today = DateTime.now().toIso8601String().split("T")[0];
    return DateTime.parse("$today $endTimeStr");
  }

  String formatTime(DateTime time) {
    int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
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

  DateTime get endTime {
    DateTime calculated = startTime.add(Duration(hours: hours));
    return calculated.isAfter(maxEndTime) ? maxEndTime : calculated;
  }

  double get totalPrice {
    return hours * rate;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [

          /// BACKGROUND
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

          /// TITLE
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                loc.p6extendparkingTitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// CLOCK
          Positioned(
            top: 250,
            right: 250,
            left: 250,
            child: ClockCard(fontScale: 0.8),
          ),

          /// MAIN BOX
          Positioned(
            top: 700,
            left: 60,
            right: 60,
            bottom: 400,
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

                  /// PLATE SECTION
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

                  /// CONTENT
                  Expanded(
                    child: Row(
                      children: [

                        /// LEFT SIDE (Duration)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // Horizontal centering (The fix)
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Text(
                                loc.p5parkingText1,
                                textAlign: TextAlign.center, // Ensures multi-line text is centered
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
                                    hours > 1
                                        ? () => setState(() => hours--)
                                        : null,
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
                                    endTime.isBefore(maxEndTime)
                                        ? () => setState(() => hours++)
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

                        /// RIGHT SIDE INFO
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                _timeInfoTile(
                                  Icons.history,
                                  loc.currentParkingEnd.toUpperCase(),
                                  formatTime(startTime),
                                ),

                                const SizedBox(height: 20),

                                _timeInfoTile(
                                  Icons.update,
                                  loc.newParkingEnd.toUpperCase(),
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

          /// BOTTOM BUTTONS
          Positioned(
            bottom: 160,
            left: 100,
            right: 100,
            child: Row(
              children: [

                /// BACK
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        loc.backButton,
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 100),

                /// CONTINUE
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _showConfirmation(context, loc),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        loc.continueButton,
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// COPYRIGHT
          Positioned(
            bottom: 70,
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
        Icon(icon,
            color: const Color.fromARGB(255, 3, 89, 210), size: 40),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
            Text(value,
                style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

void _showConfirmation(BuildContext context, AppLocalizations loc) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 45,
          vertical: 40,
        ),
        child: Container(
          width: 950,
          height: 1100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(35),
            child: Column(
              children: [
                // ================= HEADER =================
                Row(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 3, 89, 210)
                            .withOpacity(0.10),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.update_rounded,
                        size: 38,
                        color: Color.fromARGB(255, 3, 89, 210),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        loc.confirmDialogTitle,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1.5,
                ),

                const SizedBox(height: 22),

                // ================= PLATE NUMBER =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 248, 253),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        loc.plateNumberLabel(""),
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.plate.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================= EXTENSION DURATION =================
                _simpleExtendInfoRow(
                  icon: Icons.timer_outlined,
                  label: loc.p5timeparking,
                  value: "$hours ${loc.time}",
                ),

                const SizedBox(height: 18),

                // ================= CURRENT / NEW END TIME =================
                Row(
                  children: [
                    Expanded(
                      child: _simpleExtendTimeCard(
                        label: loc.currentParkingEnd,
                        value: formatTime(startTime),
                        icon: Icons.history_rounded,
                        iconColor: Colors.orange,
                        backgroundColor:
                            const Color.fromARGB(255, 255, 248, 230),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _simpleExtendTimeCard(
                        label: loc.newParkingEnd,
                        value: formatTime(endTime),
                        icon: Icons.update_rounded,
                        iconColor:
                            const Color.fromARGB(255, 3, 89, 210),
                        backgroundColor:
                            const Color.fromARGB(255, 240, 246, 255),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= TIME CHANGE SUMMARY =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              formatTime(startTime),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              loc.currentParkingEnd,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 3, 89, 210)
                              .withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 38,
                          color: Color.fromARGB(255, 3, 89, 210),
                        ),
                      ),

                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              formatTime(endTime),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 3, 89, 210),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              loc.newParkingEnd,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================= TOTAL =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 238, 249, 242),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 42,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          loc.p5Total,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Text(
                        "RM ${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ================= BUTTONS =================
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 82,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(
                              color: Colors.grey.shade400,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            loc.cancelButton,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: SizedBox(
                        height: 82,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: const RouteSettings(
                                  name: '/payment',
                                ),
                                builder: (_) => PAYMENTPAGE(
                                  biz: "EXTENDPARKING",
                                  data: PaymentData(
                                    plate: widget.plate,
                                    hour: hours,
                                    amount:
                                        totalPrice.toStringAsFixed(2),
                                  ),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 3, 89, 210),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "OK",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _simpleExtendInfoRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 20,
    ),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.grey.shade200,
        width: 1.5,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 3, 89, 210)
                .withOpacity(0.10),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            size: 32,
            color: const Color.fromARGB(255, 3, 89, 210),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}

Widget _simpleExtendTimeCard({
  required String label,
  required String value,
  required IconData icon,
  required Color iconColor,
  required Color backgroundColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 22,
    ),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 32,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 22,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
      ],
    ),
  );
}

//   Widget _dialogRow(String label, String value, bool bold) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment:
//             MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 40)),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 40,
//               fontWeight: bold
//                   ? FontWeight.bold
//                   : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

}