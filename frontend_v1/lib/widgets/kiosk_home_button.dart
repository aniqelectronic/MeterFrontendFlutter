import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';

class KioskHomeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const KioskHomeButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(35),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.black.withOpacity(0.08),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Home icon at far left
                Positioned(
                  left: 25,
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.06),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      size: 38,
                      color: Colors.black,
                    ),
                  ),
                ),

                // Centered text
                Text(
                  //AppLocalizations.of(context)!.homeButton,
                  "HOME",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 1.2,
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