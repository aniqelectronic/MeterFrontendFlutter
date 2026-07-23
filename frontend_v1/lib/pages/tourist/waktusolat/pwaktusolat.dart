import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/tourist/ptourist3.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PWAKTUSOLATPAGE extends StatefulWidget {
  const PWAKTUSOLATPAGE({
    super.key,
  });

  @override
  State<PWAKTUSOLATPAGE> createState() =>
      _PWAKTUSOLATPAGEState();
}

class _PWAKTUSOLATPAGEState
    extends State<PWAKTUSOLATPAGE> {
  Map<String, String> prayerTimes = {};

  bool _isLoading = true;

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

  // =========================================================
  // FETCH API
  // SAME AS YOUR ORIGINAL WORKING CODE
  // =========================================================

  Future<void> fetchPrayerTimes() async {
      setState(() {
    _isLoading = true;
  });
    final response = await http.get(
      Uri.parse(
        Data.waktusolaturldemo,
      ),
    );

    final data = json.decode(
      response.body,
    );

    final prayer =
        data["prayerTime"][0];

    hijriDate =
        prayer["hijri"] ?? "";

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

      _isLoading = false;
    });

    calculatePrayerStatus();
    startCountdown();
  }

  // =========================================================
  // FORMAT HIJRI DATE
  // SAME CONCEPT AS YOUR ORIGINAL CODE
  // =========================================================

  String formatHijri(
    String hijri,
  ) {
    if (hijri.isEmpty) {
      return "";
    }

    final parts =
        hijri.split("-");

    final year =
        parts[0];

    final month =
        int.parse(parts[1]);

    final day =
        parts[2];

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
      "Zulhijjah",
    ];

    return "$day ${months[month]} $year H";
  }

  // =========================================================
  // CALCULATE CURRENT AND NEXT PRAYER
  // SAME AS YOUR ORIGINAL WORKING CODE
  // =========================================================

  void calculatePrayerStatus() {
    final now =
        DateTime.now();

    List<MapEntry<String, DateTime>>
        prayerDateTimes = [];

    for (var entry
        in prayerTimes.entries) {
      final timeParts =
          entry.value.split(":");

      final prayerDateTime =
          DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(
          timeParts[0],
        ),
        int.parse(
          timeParts[1],
        ),
      );

      prayerDateTimes.add(
        MapEntry(
          entry.key,
          prayerDateTime,
        ),
      );
    }

    prayerDateTimes.sort(
      (a, b) =>
          a.value.compareTo(
        b.value,
      ),
    );

    for (int i = 0;
        i < prayerDateTimes.length;
        i++) {
      final current =
          prayerDateTimes[i];

      final next = i + 1 <
              prayerDateTimes.length
          ? prayerDateTimes[i + 1]
          : null;

      if (next != null) {
        if (now.isAfter(
              current.value,
            ) &&
            now.isBefore(
              next.value,
            )) {
          currentPrayer =
              current.key;

          nextPrayer =
              next.key;

          nextPrayerTime =
              next.value;

          break;
        }
      } else {
        // Last prayer stays active until tomorrow.
        if (now.isAfter(
          current.value,
        )) {
          currentPrayer =
              current.key;

          nextPrayer =
              prayerDateTimes[0].key;

          nextPrayerTime =
              prayerDateTimes[0]
                  .value
                  .add(
            const Duration(
              days: 1,
            ),
          );
        }
      }
    }

    setState(() {});
  }

  // =========================================================
  // COUNTDOWN
  // SAME AS YOUR ORIGINAL WORKING CODE
  // =========================================================

  void startCountdown() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (_) {
        if (nextPrayerTime == null) {
          return;
        }

        final now =
            DateTime.now();

        final difference =
            nextPrayerTime!
                .difference(
          now,
        );

        if (difference.isNegative) {
          calculatePrayerStatus();
        }

        setState(() {
          countdown = difference;
        });
      },
    );
  }

  String formatDuration(
    Duration duration,
  ) {
    String two(int number) {
      return number
          .toString()
          .padLeft(
            2,
            "0",
          );
    }

    return "${two(duration.inHours)}:"
        "${two(duration.inMinutes.remainder(60))}:"
        "${two(duration.inSeconds.remainder(60))}";
  }

  // =========================================================
  // PRAYER NAME LOCALIZATION
  // =========================================================

  String _localizedPrayerName(
    String prayerCode,
    AppLocalizations loc,
  ) {
    switch (prayerCode) {
      case "IMSAK":
        return loc.prayerImsak;

      case "SUBUH":
        return loc.prayerSubuh;

      case "SYURUK":
        return loc.prayerSyuruk;

      case "DHUHA":
        return loc.prayerDhuha;

      case "ZOHOR":
        return loc.prayerZohor;

      case "ASAR":
        return loc.prayerAsar;

      case "MAGHRIB":
        return loc.prayerMaghrib;

      case "ISYAK":
        return loc.prayerIsyak;

      default:
        return prayerCode;
    }
  }

  String _formatPrayerTime(
    String time,
  ) {
    if (time.isEmpty) {
      return "-";
    }

    return time.substring(
      0,
      5,
    );
  }

  // =========================================================
  // INFORMATION CARD
  // LOCATION, DATE AND HIJRI
  // =========================================================

    Widget _informationCard({
      required IconData icon,
      required String title,
      required String value,
      required Color accentColor,
    }) {
      final displayValue =
          value.trim().isEmpty
              ? "-"
              : value.trim();

      double fontSize = 27;

      if (displayValue.length > 45) {
        fontSize = 18;
      } else if (displayValue.length > 35) {
        fontSize = 20;
      } else if (displayValue.length > 25) {
        fontSize = 23;
      }

      return Container(
        height: 195,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: accentColor.withOpacity(0.45),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 34,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: accentColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Center(
                child: AutoSizeText(
                  displayValue,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  minFontSize: 16,
                  maxFontSize: 27,
                  style: const TextStyle(
                    color: Color(0xFF102A43),
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

  // =========================================================
  // NEXT PRAYER CARD
  // =========================================================

  Widget _nextPrayerCard(
    AppLocalizations loc,
  ) {
    final nextPrayerName =
        nextPrayer.isEmpty
            ? "-"
            : _localizedPrayerName(
                nextPrayer,
                loc,
              );

    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFBF1),
            Color(0xFFFFF0D8),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFFFA726),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.16),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Mosque icon
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE0B2),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFFFB74D),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: Color(0xFFE65100),
              size: 64,
            ),
          ),

          const SizedBox(width: 28),

          // Next prayer name
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    loc.prayerNextPrayer,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFF8A4B08),
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nextPrayerName,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 22),

          // Countdown
          Container(
            width: 365,
            height: 150,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(23),
              border: Border.all(
                color: const Color(0xFFFFCC80),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Color(0xFFD84315),
                      size: 27,
                    ),

                    const SizedBox(width: 8),

                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          loc.prayerCountdown,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xFF8A4B08),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        nextPrayerTime == null
                            ? "00:00:00"
                            : formatDuration(countdown),
                        maxLines: 1,
                        style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PRAYER CARD
  // =========================================================

  Widget prayerCard(
    String prayerCode,
    String time,
    AppLocalizations loc,
  ) {
    final isActive =
        prayerCode ==
            currentPrayer;

    final isNext =
        prayerCode ==
            nextPrayer;

    final prayerName =
        _localizedPrayerName(
      prayerCode,
      loc,
    );

    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 400,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors: [
                  Color(
                    0xFF0D47A1,
                  ),
                  Color(
                    0xFF1976D2,
                  ),
                  Color(
                    0xFF42A5F5,
                  ),
                ],
              )
            : null,
        color:
            isActive
                ? null
                : Colors.white,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        border: Border.all(
          color: isActive
              ? const Color(
                  0xFF0D47A1,
                )
              : isNext
                  ? const Color(
                      0xFFFFA000,
                    )
                  : const Color(
                      0xFFB8C8DA,
                    ),
          width: isActive ||
                  isNext
              ? 4
              : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? const Color(
                    0xFF1976D2,
                  ).withOpacity(
                    0.30,
                  )
                : Colors.black
                    .withOpacity(
                    0.08,
                  ),
            blurRadius:
                isActive
                    ? 22
                    : 11,
            spreadRadius:
                isActive
                    ? 2
                    : 0,
            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          if (isActive)
            _statusBadge(
              label:
                  loc.prayerCurrentBadge,
              backgroundColor:
                  Colors.white.withOpacity(
                0.18,
              ),
              textColor:
                  Colors.white,
            )
          else if (isNext)
            _statusBadge(
              label:
                  loc.prayerNextBadge,
              backgroundColor:
                  const Color(
                0xFFFFF3E0,
              ),
              textColor:
                  const Color(
                0xFFE65100,
              ),
            ),

          if (isActive ||
              isNext)
            const SizedBox(
              height: 9,
            ),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              prayerName,
              textAlign:
                  TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontSize: 27,
                fontWeight:
                    FontWeight.w900,
                color: isActive
                    ? Colors.white
                    : const Color(
                        0xFF102A43,
                      ),
              ),
            ),
          ),

          const SizedBox(
            height: 11,
          ),

          Text(
            _formatPrayerTime(
              time,
            ),
            style: TextStyle(
              fontSize: 31,
              fontWeight:
                  FontWeight.w900,
              color: isActive
                  ? Colors.white
                  : isNext
                      ? const Color(
                          0xFFE65100,
                        )
                      : const Color(
                          0xFF1976D2,
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge({
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight:
                FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
      ),
    );
  }
  


  

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    final localeCode =
        Localizations.localeOf(
      context,
    ).languageCode;

    final today =
        DateFormat(
      "dd MMMM yyyy",
      localeCode,
    ).format(
      DateTime.now(),
    );

    final location =
        Data.waktusolatplacedemo
            .toUpperCase();

    return Scaffold(
      body: Stack(
        children: [
          // ===================================================
          // BACKGROUND
          // ===================================================

          const Positioned.fill(
            child: DecoratedBox(
              decoration:
                  BoxDecoration(
                image:
                    DecorationImage(
                  image: AssetImage(
                    "lib/images/pnew.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // ===================================================
          // TITLE HEADER
          // ===================================================

          Positioned(
            top: 45,
            left: 65,
            right: 65,
            child: Container(
              height: 125,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 34,
                vertical: 20,
              ),
              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
                  colors: [
                    Color(
                      0xFF0D47A1,
                    ),
                    Color(
                      0xFF1976D2,
                    ),
                    Color(
                      0xFF42A5F5,
                    ),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black
                            .withOpacity(
                      0.15,
                    ),
                    blurRadius: 20,
                    offset:
                        const Offset(
                      0,
                      9,
                    ),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withOpacity(
                        0.16,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        21,
                      ),
                    ),
                    child: const Icon(
                      Icons.mosque_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),

                  const SizedBox(
                    width: 24,
                  ),

                  Expanded(
                    child: FittedBox(
                      fit:
                          BoxFit.scaleDown,
                      child: Text(
                        loc.pwaktusolattitle,
                        textAlign:
                            TextAlign.center,
                        maxLines: 1,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 52,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 24,
                  ),

                  const SizedBox(
                    width: 78,
                  ),
                ],
              ),
            ),
          ),

          // ===================================================
          // LOCATION, DATE AND HIJRI CARDS
          // ===================================================

          Positioned(
            top: 195,
            left: 65,
            right: 65,
            child: SizedBox(
              height: 195,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // LOCATION - BIGGER CARD
                  Expanded(
                    flex: 5,
                    child: _informationCard(
                      icon: Icons.location_on_rounded,
                      title: loc.prayerLocation,
                      value: location,
                      accentColor: const Color(0xFF1976D2),
                    ),
                  ),

                  const SizedBox(width: 18),

                  // DATE
                  Expanded(
                    flex: 3,
                    child: _informationCard(
                      icon: Icons.calendar_month_rounded,
                      title: loc.prayerDate,
                      value: today,
                      accentColor: const Color(0xFFE65100),
                    ),
                  ),

                  const SizedBox(width: 18),

                  // HIJRI DATE
                  Expanded(
                    flex: 3,
                    child: _informationCard(
                      icon: Icons.nights_stay_rounded,
                      title: loc.prayerHijriDate,
                      value: formatHijri(hijriDate),
                      accentColor: const Color(0xFF138A72),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===================================================
          // NEXT PRAYER CARD
          // ===================================================

          Positioned(
            top: 430,
            left: 65,
            right: 65,
            child:
                _nextPrayerCard(
              loc,
            ),
          ),

          // ===================================================
          // PRAYER GRID
          // ===================================================

          Positioned(
            top: 700,
            left: 65,
            right: 65,
            bottom: 750,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.94),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFB8C8DA),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _isLoading
                  ? const _PrayerLoadingWidget()
                  : GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: prayerTimes.length,
                      itemBuilder: (context, index) {
                        final entry = prayerTimes.entries.elementAt(index);

                        return prayerCard(
                          entry.key,
                          entry.value,
                          loc,
                        );
                      },
                    ),
            ),
          ),

          // ===================================================
          // DISCLAIMER AND QR
          // ===================================================

          Positioned(
            bottom: 365,
            left: 85,
            right: 85,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 20,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white.withOpacity(
                  0.98,
                ),
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
                border: Border.all(
                  color:
                      const Color(
                    0xFF90CAF9,
                  ),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black
                            .withOpacity(
                      0.12,
                    ),
                    blurRadius: 18,
                    offset:
                        const Offset(
                      0,
                      8,
                    ),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(
                      10,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                      border: Border.all(
                        color:
                            const Color(
                          0xFFD5DEE9,
                        ),
                        width: 2,
                      ),
                    ),
                    child: QrImageView(
                      data:
                          "https://www.e-solat.gov.my/",
                      version:
                          QrVersions.auto,
                      size: 115,
                      backgroundColor:
                          Colors.white,
                    ),
                  ),

                  const SizedBox(
                    width: 24,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFE3F2FD,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  13,
                                ),
                              ),
                              child:
                                  const Icon(
                                Icons.info_outline_rounded,
                                color:
                                    Color(
                                  0xFF1976D2,
                                ),
                                size: 28,
                              ),
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            Expanded(
                              child: Text(
                                loc.prayerTimeDisclaimerTitle,
                                style:
                                    const TextStyle(
                                  fontSize: 27,
                                  fontWeight:
                                      FontWeight.w900,
                                  color:
                                      Color(
                                    0xFF0D47A1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(
                          loc.prayerTimeDisclaimer,
                          style:
                              const TextStyle(
                            fontSize: 20,
                            height: 1.35,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                Color(
                              0xFF34495E,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 9,
                        ),

                        Text(
                          loc.prayerTimeQrInstruction,
                          style:
                              const TextStyle(
                            fontSize: 18,
                            color:
                                Color(
                              0xFF63758A,
                            ),
                            fontStyle:
                                FontStyle.italic,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===================================================
          // BACK BUTTON
          // ===================================================

          Positioned(
            bottom: 150,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PTOURISTPAGE(),
                  ),
                );
              },
            ),
          ),

          // ===================================================
          // FOOTER
          // ===================================================

          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _PrayerLoadingWidget extends StatelessWidget {
  const _PrayerLoadingWidget();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: Color(0xFF1976D2),
            ),
          ),

          const SizedBox(height: 30),

          const Icon(
            Icons.cloud_download_rounded,
            color: Color(0xFF1976D2),
            size: 60,
          ),

          const SizedBox(height: 20),

          Text(
            loc.fetchingPrayerTime,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Color(0xFF102A43),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            loc.fetchingPrayerTimeDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF63758A),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}