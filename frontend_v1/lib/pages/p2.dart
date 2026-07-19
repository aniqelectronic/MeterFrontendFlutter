import 'package:flutter/material.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/p4.dart';
import 'package:frontend_v1/pages/pbahasa.dart';
import 'package:frontend_v1/pages/ptourist3.dart';
import 'package:frontend_v1/pages/prent3.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';
import 'pbt3.dart';
import 'pbil3.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';

class P2Page extends StatefulWidget {
  const P2Page({super.key});

  @override
  State<P2Page> createState() => _P2PageState();
}

class _P2PageState extends State<P2Page> {
  final ScrollController _scrollController = ScrollController();

  bool showScrollUp = false;
  bool showScrollDown = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;

      setState(() {
        showScrollUp = current > 10;
        showScrollDown = current < (maxScroll - 10);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ================= BACKGROUND =================
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

          // ================= TITLE =================
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.p2Title,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ================= SUBTITLE =================
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

          // ================= SCROLLABLE BUTTON AREA =================
          Positioned(
            top: 430,
            left: 0,
            right: 0,
            bottom: 400,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                height: 1600,
                child: Stack(
                  children: [

                    // ================= PBT BUTTON =================
                    Positioned(
                      top: 50,
                      left: -500,
                      right: 0,
                      child: _KioskMainButton(
                        width: 400,
                        height: 400,
                        icon: Icons.directions_car,
                        label: AppLocalizations.of(context)!.pbtText,
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

                    // ================= BIL BUTTON =================
                    Positioned(
                      top: 50,
                      left: 0,
                      right: -500,
                      child: _KioskMainButton(
                        width: 400,
                        height: 400,
                        // imagePath: "lib/images/bil.png",
                        icon: Icons.receipt_long,
                        label: AppLocalizations.of(context)!.bilText,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PBIL3PAGE(),
                            ),
                          );
                        },
                      ),
                    ),

                    // ================= TOURIST BUTTON =================
                    Positioned(
                      top: 550,
                      left: -500,
                      right: 0,
                      child: _KioskMainButton(
                        width: 400,
                        height: 400,
                        icon: Icons.travel_explore,
                        label: AppLocalizations.of(context)!.touristText,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PTOURISTPAGE(),
                            ),
                          );
                        },
                      ),
                    ),                    

                    // ================= RENT BUTTON =================
                    Positioned(
                      top: 550,
                      left: 0,
                      right: -500,
                      child: _KioskMainButton(
                        width: 400,
                        height: 400,
                        icon: Icons.house,
                        label: AppLocalizations.of(context)!.rentText,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PRENT3PAGE(),
                            ),
                          );
                        },
                      ),
                    ),

                    // ================= COMPLAINT BUTTON =================

                    // Positioned(
                    //   top: 1050,
                    //   left: -500,
                    //   right: 0,
                    //   child: _KioskMainButton(
                    //     width: 400,
                    //     height: 400,
                    //     icon: Icons.report_problem,
                    //     label:
                    //         AppLocalizations.of(context)!
                    //             .p3aduanButton,
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (_) => P4PAGE(
                    //             title:
                    //                 AppLocalizations.of(context)!
                    //                     .aduanTitle,
                    //             type: "OTHERS",
                    //             hint:
                    //                 AppLocalizations.of(context)!
                    //                     .inputICHint,
                    //             biz: "ADUAN",
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),

          // ================= TOP SCROLL =================
          if (showScrollUp)
            Positioned(
              right: 430,
              top: 300,
              child: Column(
                children: [
                  const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 65,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)!
                                        .scrollup,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

          // ================= BOTTOM SCROLL =================
          if (showScrollDown)
            Positioned(
              right: 370,
              bottom: 230,
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!
                                        .scrolldown,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 65,
                    color: Colors.black,
                  ),
                ],
              ),
            ),

          // ================= BACK BUTTON =================
          Positioned(
            bottom: 100,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PBAHASAPAGE(),
                  ),
                );
              },
            ),
          ),

          // ================= FOOTER =================
          Positioned(
            bottom: 20,
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
                          fontSize: 30,
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

