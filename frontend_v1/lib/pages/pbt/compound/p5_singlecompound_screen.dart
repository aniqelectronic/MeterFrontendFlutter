import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/compound/kesalahan_controller.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/compound/compound_model.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';
import 'package:frontend_v1/pages/payment/payment.dart';
import 'package:intl/intl.dart';

class P5SingleCompoundScreen extends StatelessWidget {
  final CompoundModel compound;

  const P5SingleCompoundScreen({
    super.key,
    required this.compound,
  });

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return "-";
    try {
      final parsed = DateFormat("HH:mm:ss").parseLoose(time);
      return DateFormat("hh:mm a").format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat("HH:mm").parseLoose(time);
        return DateFormat("hh:mm a").format(parsed);
      } catch (_) {
        return time;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    // ===== RESPONSIVE SIZES =====
    final double titleSize = isWide ? 60 : 30;
    final double labelSize = isWide ? 40 : 18;
    final double valueSize = isWide ? 32 : 18;
    final double buttonTextSize = isWide ? 28 : 18;

    final double buttonHeight = isWide ? 120 : 55;
    final double buttonWidth = isWide ? 400 : 180;
    final double borderRadius = isWide ? 12 : 8;
    final double horizontalPadding = isWide ? 40 : 20;

    Widget buildButton({
      required String text,
      required Color color,
      required VoidCallback onPressed,
    }) {
      return Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          height: buttonHeight,
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor:
                  color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              elevation: 0,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: buttonTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
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
            top: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.p5SingleCompoundTitle,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 3, 89, 210),
                ),
              ),
            ),
          ),

          /// CONTENT
          Positioned(
            top: isWide ? 350 : 120,
            left: horizontalPadding,
            right: horizontalPadding,
            child: Column(
              children: [
                _row(
                  AppLocalizations.of(context)!.singleCompoundOffenderName,
                  _truncate(compound.compName),
                  labelSize: labelSize,
                  valueSize: valueSize,
                ),
                _row(
                  AppLocalizations.of(context)!.singleCompoundNo,
                  compound.compNo,
                  labelSize: labelSize,
                  valueSize: valueSize,
                ),
                _row(
                  AppLocalizations.of(context)!.singleCompoundPlateNo,
                  compound.compPlateNo,
                  labelSize: labelSize,
                  valueSize: valueSize,
                ),
Padding(
  padding: const EdgeInsets.symmetric(vertical: 10),
  child: Row(
    children: [
      Expanded(
        flex: 4,
        child: Text(
          "${AppLocalizations.of(context)!.singleCompoundOffense} :",
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        flex: 6,
        child: Text(
          "${compound.violationDesc} - ${compound.compType}",
          style: TextStyle(
            fontSize: valueSize - 4, // 👈 smaller
          ),
          softWrap: true,
          maxLines: 7,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  ),
),
                _row(
                  AppLocalizations.of(context)!.singleCompoundDate,
                  compound.compDate,
                  labelSize: labelSize,
                  valueSize: valueSize,
                ),
                _row(
                  AppLocalizations.of(context)!.singleCompoundTime,
                  _formatTime(compound.compTime),
                  labelSize: labelSize,
                  valueSize: valueSize,
                ),
                _row(
                  AppLocalizations.of(context)!.singleCompoundKodHasil,
                  compound.kodhasil,
                  labelSize: labelSize,
                  valueSize: valueSize,
                ),
                _row(
                  AppLocalizations.of(context)!.singleCompoundAmount,
                  compound.amount.toStringAsFixed(2),
                  bold: true,
                  labelSize: labelSize,
                  valueSize: valueSize,
                ),
              ],
            ),
          ),

          /// BUTTONS
          Positioned(
            bottom: isWide ? 300 : 250,
            left: horizontalPadding,
            right: horizontalPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildButton(
                  text: AppLocalizations.of(context)!.backButton,
                  color: Colors.grey.shade300,
                  onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => P4PAGE(
                        title: AppLocalizations.of(context)!.singlecompoundTitle,
                        type:"PBT",
                        hint: AppLocalizations.of(context)!.inputCompoundHint,
                        biz: "SINGLECOMPOUND",
                      ),
                    ),
                  );
                  
                  },
                ),
                SizedBox(width: isWide ? 100 : 40),
                buildButton(
                  text: AppLocalizations.of(context)!.continueButton,
                  color: Colors.green,
                  onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/payment'),
                      builder: (_) => PAYMENTPAGE(
                        biz: "SINGLECOMPOUND",
                        data: PaymentData(
                          amount: compound.amount.toStringAsFixed(2),
                          compoundNos: [?compound.compNo],
                          plate: compound.compPlateNo,
                          offenderName: compound.compName,
                          violationType: compound.compType,
                          kodhasil: compound.kodhasil,
                          date: compound.compDate,
                          time: compound.compTime,
                        ),
                      ),
                    ),
                  );

                  },
                ),
              ],
            ),
          ),

          /// FOOTER
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                style: TextStyle(
                  fontSize: isWide ? 24 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String? value, {
    bool bold = false,
    required double labelSize,
    required double valueSize,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$label :",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              value ?? "-",
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _truncate(String? text) {
    if (text == null || text.isEmpty) return "-";
    return text.length > 30 ? "${text.substring(0, 30)}..." : text;
  }
}
