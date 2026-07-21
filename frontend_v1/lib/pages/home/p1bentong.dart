import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/language/pbahasa.dart';
import 'package:frontend_v1/widgets/clock_card.dart';
import 'package:frontend_v1/pages/config.dart';

class P1BentongPage extends StatefulWidget {
  const P1BentongPage({super.key});

  @override
  State<P1BentongPage> createState() => _P1BentongPageState();
}

class _P1BentongPageState extends State<P1BentongPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PBAHASAPAGE()),
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/images/p1bentong.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              /// ================= SMALL CLOCK TOP RIGHT =================
              Positioned(
                top: 40,
                right: -75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 600,
                      child: ClockCard(fontScale: 0.68),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "SERIAL NUMBER: ${Config.terminalId}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= FOOTER =================
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
                      color: Colors.black,
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