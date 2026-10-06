import 'package:flutter/material.dart';

import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/language/pbahasa.dart';
import 'package:frontend_v1/widgets/home_clock_card.dart';

class P1BentongPage extends StatefulWidget {
  const P1BentongPage({
    super.key,
  });

  @override
  State<P1BentongPage> createState() =>
      _P1BentongPageState();
}

class _P1BentongPageState
    extends State<P1BentongPage> {
  /// ============================================================
  /// CLOCK POSITION / SIZE
  ///
  /// ADJUST THESE ONLY
  /// ============================================================

  static const double _clockTop = 30;
  static const double _clockRight = 25;

  static const double _clockWidth = 360;
  static const double _clockHeight = 180;

  /// ============================================================
  /// OPEN KIOSK INFORMATION
  /// ============================================================

  void _openKioskInformation() {
    showDialog(
      context: context,

      barrierDismissible: true,

      barrierColor:
          Colors.black.withOpacity(
        0.48,
      ),

      builder: (
        dialogContext,
      ) {
        return Dialog(
          backgroundColor:
              Colors.transparent,

          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),

          child: Container(
            width: double.infinity,

            padding:
                const EdgeInsets.fromLTRB(
              38,
              34,
              38,
              32,
            ),

            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.99,
              ),

              borderRadius:
                  BorderRadius.circular(
                38,
              ),

              border:
                  Border.all(
                color:
                    const Color(
                  0xFFD1E6F9,
                ),

                width: 2.5,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(
                    0.26,
                  ),

                  blurRadius: 45,

                  offset:
                      const Offset(
                    0,
                    18,
                  ),
                ),
              ],
            ),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                /// =================================================
                /// HEADER
                /// =================================================
                Row(
                  children: [
                    Container(
                      width: 90,
                      height: 90,

                      decoration:
                          const BoxDecoration(
                        color:
                            Color(
                          0xFFEAF4FF,
                        ),

                        shape:
                            BoxShape.circle,
                      ),

                      child:
                          const Icon(
                        Icons
                            .desktop_windows_rounded,

                        size: 50,

                        color:
                            Color(
                          0xFF0878F9,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 24,
                    ),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            'KIOSK INFORMATION',

                            style:
                                TextStyle(
                              fontSize:
                                  38,

                              height: 1,

                              fontWeight:
                                  FontWeight
                                      .w900,

                              color:
                                  Color(
                                0xFF071D49,
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 10,
                          ),

                          Text(
                            'Maklumat Peranti Kiosk',

                            style:
                                TextStyle(
                              fontSize:
                                  25,

                              fontWeight:
                                  FontWeight
                                      .w600,

                              color:
                                  Color(
                                0xFF708197,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    /// TOP CLOSE
                    Material(
                      color:
                          Colors.transparent,

                      child:
                          InkWell(
                        borderRadius:
                            BorderRadius
                                .circular(
                          100,
                        ),

                        onTap: () {
                          Navigator.of(
                            dialogContext,
                          ).pop();
                        },

                        child:
                            Container(
                          width: 68,
                          height: 68,

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF3F7FB,
                            ),

                            shape:
                                BoxShape.circle,

                            border:
                                Border.all(
                              color:
                                  const Color(
                                0xFFDDE7F0,
                              ),

                              width:
                                  1.5,
                            ),
                          ),

                          child:
                              const Icon(
                            Icons
                                .close_rounded,

                            size: 38,

                            color:
                                Color(
                              0xFF52657C,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 30,
                ),

                Container(
                  width:
                      double.infinity,

                  height: 1.5,

                  color:
                      const Color(
                    0xFFE1EBF4,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                /// =================================================
                /// SERIAL NUMBER
                /// =================================================
                _KioskInfoLargeRow(
                  icon: Icons
                      .desktop_windows_rounded,

                  title:
                      'Serial Number',

                  value:
                      Config.terminalId,

                  iconColor:
                      const Color(
                    0xFF0878F9,
                  ),

                  iconBackground:
                      const Color(
                    0xFFEAF4FF,
                  ),

                  valueColor:
                      const Color(
                    0xFF071D49,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                /// =================================================
                /// VERSION DATE
                /// =================================================
                _KioskInfoLargeRow(
                  icon: Icons
                      .system_update_alt_rounded,

                  title:
                      'Application Version Date',

                  value: Data
                      .lastUpdatedDate,

                  iconColor:
                      const Color(
                    0xFF1FAF6D,
                  ),

                  iconBackground:
                      const Color(
                    0xFFECFAF3,
                  ),

                  valueColor:
                      const Color(
                    0xFF168A57,
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                /// =================================================
                /// CLOSE
                /// =================================================
                SizedBox(
                  width: 320,
                  height: 72,

                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(
                        dialogContext,
                      ).pop();
                    },

                    icon:
                        const Icon(
                      Icons.close_rounded,
                      size: 30,
                    ),

                    label:
                        const Text(
                      'TUTUP',

                      style:
                          TextStyle(
                        fontSize: 24,

                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF0878F9,
                      ),

                      foregroundColor:
                          Colors.white,

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: GestureDetector(
        behavior:
            HitTestBehavior.opaque,

        /// ========================================================
        /// NORMAL USER:
        ///
        /// TAP ANYWHERE EXCEPT CLOCK -> LANGUAGE PAGE
        /// ========================================================
        onTap: () {
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) =>
                  const PBAHASAPAGE(),
            ),
          );
        },

        child: Container(
          width: double.infinity,
          height: double.infinity,

          decoration:
              const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'lib/images/pmelaka.png',
              ),

              fit: BoxFit.cover,
            ),
          ),

          child: Stack(
            children: [
                /// ===================================================
                /// CLOCK
                ///
                /// HIDDEN TECHNICIAN ACCESS
                /// SINGLE TAP CLOCK -> KIOSK INFORMATION
                /// ===================================================
                Positioned(
                  top: _clockTop,
                  right: _clockRight,

                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,

                    onTap: _openKioskInformation,

                    child: const HomeClockCard(
                      width: _clockWidth,
                      height: _clockHeight,
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

/// =================================================================
/// LARGE KIOSK INFORMATION ROW
/// =================================================================

class _KioskInfoLargeRow
    extends StatelessWidget {
  final IconData icon;

  final String title;
  final String value;

  final Color iconColor;
  final Color iconBackground;
  final Color valueColor;

  const _KioskInfoLargeRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    required this.iconBackground,
    required this.valueColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 24,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFFAFCFE,
        ),

        borderRadius:
            BorderRadius.circular(
          24,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFE0EBF5,
          ),

          width: 1.5,
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,

        children: [
          Container(
            width: 88,
            height: 88,

            decoration:
                BoxDecoration(
              color:
                  iconBackground,

              borderRadius:
                  BorderRadius.circular(
                22,
              ),
            ),

            child: Icon(
              icon,

              size: 46,

              color:
                  iconColor,
            ),
          ),

          const SizedBox(
            width: 24,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style:
                      const TextStyle(
                    fontSize: 25,

                    height: 1.1,

                    color:
                        Color(
                      0xFF718197,
                    ),

                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                FittedBox(
                  fit:
                      BoxFit.scaleDown,

                  alignment:
                      Alignment.centerLeft,

                  child: Text(
                    value,
                    maxLines: 1,

                    style:
                        TextStyle(
                      fontSize: 34,

                      height: 1,

                      color:
                          valueColor,

                      fontWeight:
                          FontWeight
                              .w900,

                      letterSpacing:
                          0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}