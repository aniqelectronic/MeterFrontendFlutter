import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/pbahasa.dart';
import 'package:frontend_v1/widgets/clock_card.dart';
import 'config.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';

class P1Page extends StatefulWidget {
  const P1Page({super.key});

  @override
  State<P1Page> createState() => _P1PageState();
}

class _P1PageState extends State<P1Page> {

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
              image: AssetImage("lib/images/pnew.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              /// ================= CLOCK CARD =================
              Positioned(
                top: 200,
                left: 200,
                right: 200,
                child: ClockCard(fontScale: 1.2),
              ),

              /// ================= WELCOME =================
              const Positioned(
                top: 800,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "SELAMAT DATANG",
                    style: TextStyle(
                      fontSize: 75,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Color(0xFF1A1A1A)
                    ),
                  ),
                ),
              ),

              /// ================= INSTRUCTION =================
              const Positioned(
                top: 950,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "SILA SENTUH SKRIN UNTUK MULA",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ),
              ),

              /// ================= INFO BUTTON =================
              Positioned(
                top: 40,
                right: 30,
                child: _InfoButton(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => _InfoDialog(),
                    );
                  },
                ),
              ),
                      

          //we accept text + payment method image

          Positioned(
          top: 1350,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.weAcceptText,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 18),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20), // rounded image
                  child: Image.asset(
                    "lib/images/Payment_Method.png",
                    width: 520,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
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
                    style: TextStyle(
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

/// ========================= INFO BUTTON =========================
class _InfoButton extends StatelessWidget {
  final VoidCallback onTap;
  const _InfoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shape: const CircleBorder(),
      color: Colors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 120,
          height: 120,
          child: Icon(Icons.info_outline, size: 80),
        ),
      ),
    );
  }
}

/// ========================= INFO DIALOG =========================
class _InfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Transparent to allow custom shape/blur
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            padding: const EdgeInsets.fromLTRB(30, 80, 30, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    "MESIN PEMBAYARAN & INFORMASI",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 3, 89, 210),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const Divider(height: 80, thickness: 2),
                
                // --- Service Icons Row ---
                Wrap(
                  spacing: 30,
                  runSpacing: 30,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildServiceIcon(Icons.local_parking, "Parking"),
                    _buildServiceIcon(Icons.assignment_late, "Kompaun"),
                    _buildServiceIcon(Icons.badge, "Lesen"),
                    _buildServiceIcon(Icons.home_work, "Sewaan"),
                    _buildServiceIcon(Icons.receipt_long, "Cukai"),
                    _buildServiceIcon(Icons.water_drop, "Bil Air"),
                    _buildServiceIcon(Icons.electric_bolt, "Bil Api"),
                    _buildServiceIcon(Icons.phone_android, "Topup"),
                  //  _buildServiceIcon(Icons.account_balance_wallet, "E-Wallet"),
                  ],
                ),
                const SizedBox(height: 60),

                _buildInfoCard(
                title: "Perkhidmatan Tersedia",
                subtitle: "Available Services",
                value: "9+",
                icon: Icons.payments,
              ),
              const SizedBox(height: 20),

                // --- Info Cards ---
                _buildInfoCard(
                  title: "Kadar Bayaran Parking",
                  subtitle: "Parking rate per hour",
                  value: "RM${Data.ratePerHour.toStringAsFixed(2)} ",
                  icon: Icons.timer,
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: "Hubungi Kami",
                  subtitle: "Contact Us for assistance",
                  value: Data.telefonNo,
                  icon: Icons.phone_android,
                ),

                const SizedBox(height: 50),

                // --- Huge Kiosk Button ---
                SizedBox(
                  width: double.infinity,
                  height: 90,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 89, 210),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "HOME",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // --- Floating Top Icon ---
          Positioned(
            top: -50,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color.fromARGB(255, 3, 89, 210),
              child: const Icon(Icons.info_rounded, size: 70, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 50, color: Colors.blueGrey),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required String subtitle, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: const Color.fromARGB(255, 3, 89, 210)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.black54)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87)),
        ],
      ),
    );
  }
}