import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'p2.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';

class PBIL3PAGE extends StatelessWidget {
  const PBIL3PAGE({super.key});

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
                AppLocalizations.of(context)!.pbil3Title,
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
                AppLocalizations.of(context)!.pbil3Subtitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 62, 62, 62),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ================= TNB BUTTON =================
          Positioned(
            top: 500,
            left: -500,
            right: 0,
            child: _KioskMainButton(
              width: 400,
              height: 400,
              imagePath: "lib/images/tnb.png",
              label: AppLocalizations.of(context)!.tnbButton,
              onPressed: () {},
              comingSoon: true,
            ),
          ),

          // ================= BIL AIR BUTTON =================
          Positioned(
            top: 500,
            left: 0,
            right: -500,
            child: _KioskMainButton(
              width: 400,
              height: 400,
              imagePath: "lib/images/water.png",
              label: AppLocalizations.of(context)!.waterButton,
              onPressed: () {},
              comingSoon: true,
            ),
          ),

          // ================= TM BUTTON =================
          Positioned(
            top: 1000,
            left: -500,
            right: 0,
            child: _KioskMainButton(
              width: 400,
              height: 400,
              imagePath: "lib/images/tm.png",
              label: AppLocalizations.of(context)!.tmButton,
              onPressed: () {},
              comingSoon: true,
            ),
          ),

          // ================= BIL TELKO BUTTON =================
          Positioned(
            top: 1000,
            left: 0,
            right: -500,
            child: _KioskMainButton(
              width: 400,
              height: 400,
              imagePath: "lib/images/telco.png",
              label: AppLocalizations.of(context)!.telkoButton,
              onPressed: () {},
              comingSoon: true,
            ),
          ),

          // ================= BACK BUTTON =================
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

/// =======================================================
/// REUSABLE KIOSK BUTTON
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