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
              image: AssetImage("lib/images/p1ipoh.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              /// ================= SMALL CLOCK TOP RIGHT =================
              Positioned(
                top: 10,
                right: -90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 600,
                      child: ClockCard(fontScale: 0.6),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.96),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.blue.shade100,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.desktop_windows_rounded,
                              color: Colors.blue.shade700,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "KIOSK INFORMATION",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: Colors.blue.shade700,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Icon(
                                    Icons.confirmation_number_outlined,
                                    size: 18,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Serial Number",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 2),

                              Text(
                                Config.terminalId,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  Icon(
                                    Icons.system_update_alt_rounded,
                                    size: 18,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Application Version Date",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 2),

                              Text(
                                Data.lastUpdatedDate,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
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