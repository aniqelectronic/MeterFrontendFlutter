import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'p2.dart';
import 'p4optioncompound.dart';
import 'p4.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';

class PBT3PAGE extends StatelessWidget {
  const PBT3PAGE({super.key});

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
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.p3Title,
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
                AppLocalizations.of(context)!.p3Subtitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 62, 62, 62),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ================= PARKING BUTTON =================
          Positioned(
            top: 500,
            left: -500,
            right: 0,
            child: _KioskMainButton(
              width: 400,   // button width
              height: 400, 
              icon: IconData(0xe39d, fontFamily: 'MaterialIcons'),
              label: AppLocalizations.of(context)!.parkirButton,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => P4PAGE(
                    title: AppLocalizations.of(context)!.parkirButton,
                    type:"PBT",
                    hint: AppLocalizations.of(context)!.inputPlateHint,
                    biz: "PARKING",
                  ),
                ),
              );
            },
            ),
          ),

          // ================= KOMPAUN BUTTON =================
          Positioned(
            top: 500,
            left: 0,
            right: -500,
            child: _KioskMainButton(
              width: 400,   // button width
              height: 400,               
              icon: IconData(0xf03d3, fontFamily: 'MaterialIcons'),
              label: AppLocalizations.of(context)!.compoundButton,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const P4OPTIONCOMPOUND(),
                ),
              );
            },
            ),
          ),

          // ================= CUKAI BUTTON =================
          Positioned(
            top: 1000,
            left: -500,
            right: 0,
            child: _KioskMainButton(
              width: 400,   // button width
              height: 400,               
              icon: IconData(0xe63c, fontFamily: 'MaterialIcons'),
              label: AppLocalizations.of(context)!.taxButton,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => P4PAGE(
                    title: AppLocalizations.of(context)!.taxButton,
                    type:"PBT",
                    hint: AppLocalizations.of(context)!.inputICHint,
                    biz: "CUKAI",
                  ),
                ),
              );
            },
            ),
          ),

          // ================= LESEN BUTTON =================
          Positioned(
            top: 1000,
            left: 0,
            right: -500,
            child: _KioskMainButton(
              width: 400,   // button width
              height: 400,               
              imagePath: "lib/images/lesen.png",
              label: AppLocalizations.of(context)!.licenseButton,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => P4PAGE(
                    title: AppLocalizations.of(context)!.licenseButton,
                    type:"PBT",
                    hint: AppLocalizations.of(context)!.inputICHint,
                    biz: "LESEN",
                  ),
                ),
              );
            },
            ),
          ),

          // ================= BACK BUTTON =================
          Positioned(
            bottom: 200,
            left: 300,
            right: 300,
            child: SizedBox(
              width: 300,   // Set the button width
              height: 120,  // Set the button height
            child: ElevatedButton(
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const P2Page(),
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
                padding: const EdgeInsets.symmetric(vertical: 15),
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

/// =======================================================
/// REUSABLE KIOSK BUTTON (BLACK BORDER, SHADOW, ICON/IMAGE)
/// =======================================================
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
                          fontSize: 40,
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