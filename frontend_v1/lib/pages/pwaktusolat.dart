import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/ptourist3.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PWAKTUSOLATPAGE extends StatefulWidget {
  const PWAKTUSOLATPAGE({super.key});

  @override
  State<PWAKTUSOLATPAGE> createState() => _PWAKTUSOLATPAGEState();
}

class _PWAKTUSOLATPAGEState extends State<PWAKTUSOLATPAGE> {
  Map<String, String> prayerTimes = {};

  String currentPrayer = "";
  String nextPrayer = "";

  String hijriDate = "";

  DateTime? nextPrayerTime;
  Duration countdown = Duration.zero;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// ================= FETCH API =================
  Future<void> fetchPrayerTimes() async {
    final response = await http.get(Uri.parse(
        Config.waktusolaturl));

    final data = json.decode(response.body);
    final prayer = data["prayerTime"][0];

    hijriDate = prayer["hijri"] ?? "";

    setState(() {
      prayerTimes = {
        "IMSAK": prayer["imsak"],
        "SUBUH": prayer["fajr"],
        "SYURUK": prayer["syuruk"],
        "DHUHA": prayer["dhuha"],
        "ZOHOR": prayer["dhuhr"],
        "ASAR": prayer["asr"],
        "MAGHRIB": prayer["maghrib"],
        "ISYAK": prayer["isha"],
      };
    });

    calculatePrayerStatus();
    startCountdown();
  }


String formatHijri(String hijri) {
  if (hijri.isEmpty) return "";

  final parts = hijri.split("-");
  final year = parts[0];
  final month = int.parse(parts[1]);
  final day = parts[2];

  const months = [
    "",
    "Muharram",
    "Safar",
    "Rabiulawal",
    "Rabiulakhir",
    "Jamadilawal",
    "Jamadilakhir",
    "Rejab",
    "Syaaban",
    "Ramadhan",
    "Syawal",
    "Zulkaedah",
    "Zulhijjah"
  ];

  return "$day ${months[month]} $year H";
}
  /// ================= CALCULATE CURRENT + NEXT =================
  void calculatePrayerStatus() {
    final now = DateTime.now();

    List<MapEntry<String, DateTime>> prayerDateTimes = [];

    for (var entry in prayerTimes.entries) {
      final timeParts = entry.value.split(":");

      final prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      prayerDateTimes.add(MapEntry(entry.key, prayerDateTime));
    }

    prayerDateTimes.sort((a, b) => a.value.compareTo(b.value));

    for (int i = 0; i < prayerDateTimes.length; i++) {
      final current = prayerDateTimes[i];
      final next =
          (i + 1 < prayerDateTimes.length) ? prayerDateTimes[i + 1] : null;

      if (next != null) {
        if (now.isAfter(current.value) &&
            now.isBefore(next.value)) {
          currentPrayer = current.key;
          nextPrayer = next.key;
          nextPrayerTime = next.value;
          break;
        }
      } else {
        // Last prayer (ISYAK) active until tomorrow
        if (now.isAfter(current.value)) {
          currentPrayer = current.key;
          nextPrayer = prayerDateTimes[0].key;
          nextPrayerTime =
              prayerDateTimes[0].value.add(const Duration(days: 1));
        }
      }
    }

    setState(() {});
  }

  /// ================= COUNTDOWN =================
  void startCountdown() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (nextPrayerTime == null) return;

      final now = DateTime.now();
      final difference = nextPrayerTime!.difference(now);

      if (difference.isNegative) {
        calculatePrayerStatus(); // move to next prayer
      }

      setState(() {
        countdown = difference;
      });
    });
  }

  String formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  /// ================= PRAYER CARD =================
  Widget prayerCard(String name, String time) {
    final isActive = name == currentPrayer;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(20),

      border: Border.all(
        color: isActive ? Colors.blue.shade900 : Colors.grey.shade400,
        width: 3,
      ),

        boxShadow: [
          if (isActive)
            const BoxShadow(
              color: Colors.blueAccent,
              blurRadius: 25,
              spreadRadius: 3,
            )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            time.substring(0, 5),
            style: TextStyle(
              fontSize: 26,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    final today = DateFormat("dd MMMM yyyy").format(DateTime.now());

    return Scaffold(
      body: Stack(
        children: [
          /// Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// TITLE
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.pwaktusolattitle,
                style: const TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 3, 89, 210),
                ),
              ),
            ),
          ),

          /// LOCATION + DATE
          Positioned(
            top: 250,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // LOCATION BAR
                Text(
                  Config.waktusolatplace.toUpperCase(),
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),

                const SizedBox(height: 10),

                // DATES (Gregorian & Hijri Row)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(today, style: const TextStyle(fontSize: 35, color: Colors.black54)),
                    const SizedBox(width: 20),
                    const Text("|", style: TextStyle(fontSize: 35, color: Colors.black26)),
                    const SizedBox(width: 20),
                    Text(formatHijri(hijriDate), style: const TextStyle(fontSize: 35, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(height: 70),
              ],
            ),
          ),

          /// COUNTDOWN
          Positioned(
            top: 500,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "${AppLocalizations.of(context)!.textsolat1} $nextPrayer",
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  formatDuration(countdown),
                  style: const TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),

          /// PRAYER GRID
          Positioned(
            top: 800,
            left: 150,
            right: 150,
            bottom: 250,
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: prayerTimes.entries
                  .map((e) => prayerCard(e.key, e.value))
                  .toList(),
            ),
          ),

          /// DISCLAIMER + QR
          Positioned(
            bottom: 400,
            left: 120,
            right: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 22,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  QrImageView(
                    data: "https://www.e-solat.gov.my/",
                    version: QrVersions.auto,
                    size: 130,
                    backgroundColor: Colors.white,
                  ),

                  const SizedBox(width: 25),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .prayerTimeDisclaimerTitle,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          AppLocalizations.of(context)!
                              .prayerTimeDisclaimer,
                          style: const TextStyle(
                            fontSize: 22,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          AppLocalizations.of(context)!
                              .prayerTimeQrInstruction,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// BACK BUTTON
            Positioned(
              bottom: 150,
              left: 300,
              right: 300,
              child: KioskBackButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PTOURISTPAGE(),
                    ),
                  );
                },
              ),
            ),

          // Footer
          Positioned(
            bottom: 50,
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
