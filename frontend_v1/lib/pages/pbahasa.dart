import 'package:flutter/material.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/p2.dart';
import 'package:frontend_v1/pages/p1.dart';

class PBAHASAPAGE extends StatelessWidget {
  const PBAHASAPAGE({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/p1'),
        builder: (_) => page),
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

          // ===============================
          // Bahasa Melayu Button (UPDATED)
          // ===============================
          Positioned(
            top: 600,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: () {
                  App.setLocale(context, const Locale('ms'));
                  _navigate(context, const P2Page());
                },
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: 820,
                  height: 220, // Slightly sleeker height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        offset: const Offset(0, 10),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 50),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: const Icon(Icons.language, size: 80, color: Colors.white),
                      ),
                      const SizedBox(width: 40),
                      const Text(
                        "BAHASA MELAYU",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 80, color: Colors.white54),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===============================
          // English Button (UPDATED)
          // ===============================
          Positioned(
            top: 880, // Adjusted gap
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: () {
                  App.setLocale(context, const Locale('en'));
                  _navigate(context, const P2Page());
                },
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: 820,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        offset: const Offset(0, 10),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 50),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: const Icon(Icons.public, size: 80, color: Colors.white),
                      ),
                      const SizedBox(width: 40),
                      const Text(
                        "ENGLISH",
                        style: TextStyle(
                          fontSize: 55,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 80, color: Colors.white54),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // HOME Button
          Positioned(
            bottom: 250,
            left: 300,
            right: 300,
            child: SizedBox(
              width: 100,
              height: 120,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/p1',
                  (route) => false,
                );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  elevation: 0,
                  side: const BorderSide(color: Colors.black, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "HOME",
                  style: TextStyle(
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
            child: Center(
              child: Text(
                Data.copyrightText,
                style: TextStyle(
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