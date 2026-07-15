import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/p2.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/p4.dart';
import 'package:frontend_v1/pages/p_exploartion_jerantut.dart';
import 'package:frontend_v1/pages/p_exploration_bera.dart';
import 'package:frontend_v1/pages/p_exploration_cameronhighlands.dart';
import 'package:frontend_v1/pages/p_exploration_subangjaya.dart';
import 'package:frontend_v1/pages/p_exploration_tapah.dart';
import 'package:frontend_v1/pages/pbentongexploration.dart';
import 'package:frontend_v1/pages/pexploration_ipoh.dart';
import 'package:frontend_v1/pages/pexploration_kampar.dart';
import 'package:frontend_v1/pages/pexploration_melaka.dart';
import 'package:frontend_v1/pages/pexploration_rompin.dart';
import 'package:frontend_v1/pages/pmap.dart';
import 'package:frontend_v1/pages/pmapgoogle.dart';
import 'package:frontend_v1/pages/pnegerisembilan.dart';
import 'package:frontend_v1/pages/pwaktusolat.dart';
import 'package:frontend_v1/pages/p_exploration_temerloh.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';


class PTOURISTPAGE extends StatelessWidget {
  const PTOURISTPAGE({super.key});

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

          // Title
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.p3othersTitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Subtitle
          Positioned(
            top: 240,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.p3othersSubtitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 62, 62, 62),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // // ================= COMPLAINT BUTTON =================
          // Positioned(
          //   top: 500,
          //   left: -500,
          //   right: 0,
          //   child: _KioskMainButton(
          //     width: 400,   // button width
          //     height: 400, 
          //     icon: Icons.report_problem,
          //     label: AppLocalizations.of(context)!.p3aduanButton,
          //     onPressed: () {
          //                     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => P4PAGE(
          //           title: AppLocalizations.of(context)!.aduanTitle,
          //           type:"OTHERS",
          //           hint: AppLocalizations.of(context)!.inputICHint,
          //           biz: "ADUAN",
          //         ),
          //       ),
          //     );
          //     },
          //   ),
          // ),

          // ================= EXPLORATION BUTTON =================
          Positioned(
            top: 500,
            left: -500,
            right: 0,
            child: _KioskMainButton(
              width: 400,   // button width
              height: 400, 
              icon: Icons.travel_explore,
              label: AppLocalizations.of(context)!.p3eksplorasiButton,
              onPressed: () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (_) => const PExplorationIpohPage(),
               ),
             );
              },
            ),
          ),

          // ================= MAP BUTTON =================
          Positioned(
            top: 500,
            left: 0,
            right: -500,
            child: _KioskMainButton(
              width: 400,   // button width
              height: 400, 
              icon: Icons.place,
              label: AppLocalizations.of(context)!.p3map,
              onPressed: () {
              Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (_) => const PMAPGOOGLEPAGE(),
               ),
             );
              },
            ),
          ),

          // ================= WAKTU SOLAT BUTTON =================
          Positioned(
            top: 1000,
            left: -500,
            right: -500,
            child: _KioskMainButton(
              width: 400,   // button width
              height: 400, 
              icon: FlutterIslamicIcons.mosque,
              label: AppLocalizations.of(context)!.p3waktusolat,
              onPressed: () {
              Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (_) => const PWAKTUSOLATPAGE(),
               ),
             );
              },
            ),
          ),

          // ================= BACK BUTTON (UNCHANGED) =================
          Positioned(
            bottom: 200,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const P2Page(),
                  ),
                );
              },
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

class _KioskMainButton extends StatefulWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final bool comingSoon;

  const _KioskMainButton({
    super.key,
    this.icon,
    this.imagePath,
    required this.label,
    required this.onPressed,
    this.width = 200,
    this.height = 150,
    this.comingSoon = false,
  });

  @override
  State<_KioskMainButton> createState() => _KioskMainButtonState();
}

class _KioskMainButtonState extends State<_KioskMainButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !widget.comingSoon;

    return Center(
      child: GestureDetector(
        onTapDown: (_) => isEnabled ? setState(() => _isPressed = true) : null,
        onTapUp: (_) => isEnabled ? setState(() => _isPressed = false) : null,
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // MAIN BUTTON BODY
              Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  border: Border.all(
                    color: widget.comingSoon ? Colors.grey : Colors.black,
                    width: 4,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.comingSoon
                        ? [const Color(0xFFE0E0E0), const Color(0xFFBDBDBD)]
                        : [const Color(0xFFF4F8FF), const Color(0xFFCCD9F2)],
                  ),
                  boxShadow: _isPressed || widget.comingSoon
                      ? []
                      : [
                          const BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 12),
                            blurRadius: 0,
                          ),
                        ],
                ),
                child: Opacity(
                  opacity: widget.comingSoon ? 0.5 : 1.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ICON POD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: widget.icon != null
                            ? Icon(widget.icon, size: 140, color: Colors.black)
                            : Image.asset(widget.imagePath!, height: 140),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        widget.label.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // COMING SOON OVERLAY
              if (widget.comingSoon)
                Positioned.fill(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        width: widget.width * 1.1,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Text(
                          AppLocalizations.of(context)!
                              .comingsoonText
                              .toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}