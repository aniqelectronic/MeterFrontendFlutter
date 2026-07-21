import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import '../../option/pbt3.dart';
import '../p4.dart';

class P4OPTIONCOMPOUND extends StatelessWidget {
  const P4OPTIONCOMPOUND({super.key});

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

          // P4OPTIONCOMPOUND Title Text
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.compoundTitle,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Second text
            Positioned(
              top: 240,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.compoundSubtitle,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 62, 62, 62),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),


             // NOMBOR KOMPAUN Button
             Positioned(
            top: 700,
            left: -500,
            right: 0,
            child: _KioskMainButton(
              width: 400,
              height: 400,
              label: AppLocalizations.of(context)!.singleCompoundButton,
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => P4PAGE(
                      title: AppLocalizations.of(context)!.singlecompoundTitle,
                      type: "PBT",
                      hint: AppLocalizations.of(context)!.inputCompoundHint,
                      biz: "SINGLECOMPOUND",
                    ),
                    transitionsBuilder: (_, animation, __, child) =>
                        FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
            ),
          ),
          
                     
          //NOMBOR PLAT Button
          Positioned(
            top: 700,
            left: 0,
            right: -500,
            child: _KioskMainButton(
              width: 400,
              height: 400,
              label: AppLocalizations.of(context)!.multiCompoundButton,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => P4PAGE(
                      title: AppLocalizations.of(context)!.multicompoundTitle,
                      type: "PBT",
                      hint: AppLocalizations.of(context)!.inputPlateHint,
                      biz: "MULTICOMPOUND",
                    ),
                  ),
                );
              },
            ),
          ),



            // Back Button
            Positioned(
              bottom: 200,
              left: 300,
              right: 300,
              child: KioskBackButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PBT3PAGE(),
                    ),
                  );
                },
              ),
            ),



              // Third text
               Positioned(
                 bottom: 60,
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
}


/// =======================================================
/// MAIN KIOSK BUTTON (WITH ORIGINAL BLACK BORDER)
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: widget.comingSoon
                        ? [const Color(0xFFE0E0E0), const Color(0xFFBDBDBD)]
                        : [const Color(0xFFF6F9FF), const Color(0xFFD1DFF3)],
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
                  opacity: widget.comingSoon ? 0.6 : 1.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null || widget.imagePath != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: widget.icon != null
                                ? Icon(widget.icon, size: 80, color: Colors.black)
                                : Image.asset(widget.imagePath!, height: 80),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Text(
                          widget.label.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // COMING SOON OVERLAY
              if (widget.comingSoon)
                Positioned.fill(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.15,
                      child: Container(
                        width: widget.width * 1.1,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Text(
                          AppLocalizations.of(context)
                                  ?.comingsoonText
                                  .toUpperCase() ??
                              "COMING SOON",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
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