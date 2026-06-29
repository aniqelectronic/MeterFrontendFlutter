import 'package:flutter/material.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/p1.dart';
import 'package:frontend_v1/pages/p1bentong.dart';
import 'package:frontend_v1/pages/p2.dart';
import 'package:frontend_v1/widgets/kiosk_home_button.dart';

class PBAHASAPAGE extends StatelessWidget {
  const PBAHASAPAGE({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/p1'),
        builder: (_) => page,
      ),
    );
  }

  Widget _languageButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required double width,
    required double titleSize,
    required Color mainColor,
    required Color lightColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(90),
      child: Container(
        width: width,
        height: 210,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(90),
          border: Border.all(
            color: mainColor,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 25),

            Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lightColor,
              ),
              child: Icon(
                icon,
                size: 85,
                color: mainColor,
              ),
            ),

            const SizedBox(width: 35),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      color: mainColor,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: mainColor.withOpacity(0.65),
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lightColor,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 45,
                color: mainColor,
              ),
            ),

            const SizedBox(width: 35),
          ],
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Title
          const Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "PILIH BAHASA",
                style: TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 90,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Subtitle
          const Positioned(
            top: 250,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Choose Language",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bahasa Melayu Button - wider
          Positioned(
            top: 610,
            left: 0,
            right: 0,
            child: Center(
              child: _languageButton(
                title: "BAHASA MELAYU",
                subtitle: "Tekan Untuk Meneruskan",
                icon: Icons.flag_rounded,
                width: 900,
                titleSize: 46,
                mainColor: const Color(0xFF6D4C41),
                lightColor: const Color(0xFFFFE0B2),
                onTap: () {
                  App.setLocale(context, const Locale('ms'));
                  _navigate(context, const P2Page());
                },
              ),
            ),
          ),

          // English Button - smaller
          Positioned(
            top: 880,
            left: 0,
            right: 0,
            child: Center(
              child: _languageButton(
                title: "ENGLISH",
                subtitle: "Press To Continue",
                icon: Icons.public_rounded,
                width: 900,
                titleSize: 54,
                mainColor: const Color(0xFF455A64),
                lightColor: const Color(0xFFECEFF1),
                onTap: () {
                  App.setLocale(context, const Locale('en'));
                  _navigate(context, const P2Page());
                },
              ),
            ),
          ),

          // HOME Button
          Positioned(
            bottom: 200,
            left: 300,
            right: 300,
            child: KioskHomeButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: '/p1'),
                    builder: (_) => const P1BentongPage(),
                  ),
                  (route) => false,
                );
              },
            ),
          ),

          // Footer
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                style: const TextStyle(
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