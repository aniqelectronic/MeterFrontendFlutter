import 'package:frontend_v1/widgets/knowledge_slider.dart';

import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';

import 'package:frontend_v1/pages/bil/broadband/pbroadbandbill3.dart';

import 'package:frontend_v1/pages/bil/electric/pelectricbill3.dart';

import 'package:frontend_v1/pages/bil/entertainment/pentertainmentbill3.dart';

import 'package:frontend_v1/pages/bil/water/pwaterbill3.dart';

import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/widgets/kiosk_back_button.dart';

import 'package:frontend_v1/pages/bil/telco/ptelco3.dart';

import 'package:frontend_v1/pages/bil/ewallet/pewallet3.dart';

import 'package:frontend_v1/pages/bil/loan/ploan3.dart';

import 'package:frontend_v1/pages/bil/digitalvoucher/pdigitalvoucher3.dart';

import 'p2.dart';

import 'package:frontend_v1/pages/bil/gaming/pgaming3.dart';

import 'package:frontend_v1/pages/bil/idd/piddbill3.dart';

import 'package:frontend_v1/pages/bil/gamecredits/pgamecredits3.dart';

import 'package:frontend_v1/pages/bil/consolestores/pconsolestores3.dart';

import 'package:frontend_v1/pages/bil/fuel/pfuel3.dart';

import 'package:frontend_v1/pages/bil/foodbeverage/pfoodbeverage3.dart';

class PBIL3PAGE extends StatefulWidget {

  const PBIL3PAGE({super.key});

  @override

  State<PBIL3PAGE> createState() => _PBIL3PAGEState();

}

class _PBIL3PAGEState extends State<PBIL3PAGE> {

  final ScrollController _scrollController = ScrollController();

  bool showScrollUp = false;

  bool showScrollDown = true;

  @override

  void initState() {

    super.initState();

    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {

      _handleScroll();

    });

  }

  void _handleScroll() {

    if (!_scrollController.hasClients || !mounted) {

      return;

    }

    final double maxScroll =

        _scrollController.position.maxScrollExtent;

    final double currentScroll = _scrollController.offset;

    final bool shouldShowScrollUp = currentScroll > 10;

    final bool shouldShowScrollDown =

        currentScroll < maxScroll - 10;

    if (showScrollUp != shouldShowScrollUp ||

        showScrollDown != shouldShowScrollDown) {

      setState(() {

        showScrollUp = shouldShowScrollUp;

        showScrollDown = shouldShowScrollDown;

      });

    }

  }

  void _scrollUp() {

    if (!_scrollController.hasClients) return;

    final double destination =

        (_scrollController.offset - 600).clamp(

      0.0,

      _scrollController.position.maxScrollExtent,

    );

    _scrollController.animateTo(

      destination,

      duration: const Duration(milliseconds: 400),

      curve: Curves.easeOut,

    );

  }

  void _scrollDown() {

    if (!_scrollController.hasClients) return;

    final double destination =

        (_scrollController.offset + 600).clamp(

      0.0,

      _scrollController.position.maxScrollExtent,

    );

    _scrollController.animateTo(

      destination,

      duration: const Duration(milliseconds: 400),

      curve: Curves.easeOut,

    );

  }


  void _scrollToTop() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildScrollAction(AppLocalizations loc) {
    // TOP: only more content below
    if (!showScrollUp && showScrollDown) {
      return _ScrollDiscoveryControl(
        key: const ValueKey('top-more'),
        mode: _ScrollControlMode.more,
        label: loc.scrollViewMore,
        onPressed: _scrollDown,
      );
    }

    // MIDDLE: allow both directions
    if (showScrollUp && showScrollDown) {
      return Row(
        key: const ValueKey('middle-controls'),
        mainAxisSize: MainAxisSize.min,
        children: [
          _ScrollDiscoveryControl(
            mode: _ScrollControlMode.up,
            label: loc.scrollUpShort,
            onPressed: _scrollUp,
          ),
          const SizedBox(width: 22),
          _ScrollDiscoveryControl(
            mode: _ScrollControlMode.more,
            label: loc.scrollViewMore,
            onPressed: _scrollDown,
          ),
        ],
      );
    }

    // BOTTOM: go directly back to the top
    if (showScrollUp && !showScrollDown) {
      return _ScrollDiscoveryControl(
        key: const ValueKey('bottom-top'),
        mode: _ScrollControlMode.top,
        label: loc.scrollBackTop,
        onPressed: _scrollToTop,
      );
    }

    return const SizedBox.shrink();
  }

  @override

  void dispose() {

    _scrollController.removeListener(_handleScroll);

    _scrollController.dispose();

    super.dispose();

  }

  @override

  Widget build(BuildContext context) {

    final loc = AppLocalizations.of(context)!;

    return Scaffold(

      body: Stack(

        children: [

          Positioned.fill(

            child: Image.asset(

              'lib/images/pnew.png',

              fit: BoxFit.cover,

            ),

          ),

          Positioned.fill(

            child: Container(

              decoration: BoxDecoration(

                gradient: LinearGradient(

                  begin: Alignment.topCenter,

                  end: Alignment.bottomCenter,

                  colors: [

                    Colors.white.withOpacity(0.04),

                    Colors.white.withOpacity(0.14),

                    Colors.white.withOpacity(0.06),

                  ],

                ),

              ),

            ),

          ),

          // HEADER

          Positioned(

            top: 45,

            left: 65,

            right: 65,

            child: _ModernPageHeader(

              badgeText: loc.billPaymentServiceLabel,

              title: loc.pbil3Title,

              subtitle: loc.pbil3Subtitle,

            ),

          ),

          // KNOWLEDGE SLIDER

          Positioned(

            top: 300,

            left: 58,

            right: 58,

            child: const KnowledgeSlider(

              height: 250,

              titleFontSize: 32,

              subtitleFontSize: 25,

              factFontSize: 25,

              counterFontSize: 25,

              slideDuration: Duration(seconds: 8),

            ),

          ),

          // SERVICE AREA

          Positioned(

            top: 605,

            left: 45,

            right: 45,

            bottom: 300,

            child: Scrollbar(

              controller: _scrollController,

              thumbVisibility: true,

              trackVisibility: true,

              interactive: true,

              thickness: 11,

              radius: const Radius.circular(20),

              child: SingleChildScrollView(

                controller: _scrollController,

                physics: const BouncingScrollPhysics(),

                padding: const EdgeInsets.only(

                  right: 24,

                  bottom: 145,

                ),

                child: Column(

                  children: [

                    Row(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                      // ============================================================

                      // Electricity Bill

                      // ============================================================

                        Expanded(

                          child: _ModernServiceCard(

                            height: 455,

                            icon: Icons.electric_bolt_rounded,

                            label: loc.electricitybutton,

                            supportingText:

                                loc.electricityBillSupportingText,

                            accentColor: const Color(0xFFE0A100),

                            accentLightColor: const Color(0xFFFFF4D0),

                            onPressed: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>

                                      const PELECTRICBILL3PAGE(),

                                ),

                              );

                            },

                          ),

                        ),

                        const SizedBox(width: 34),

                      // ============================================================

                      //Water Bill

                      // ============================================================

                        Expanded(

                          child: _ModernServiceCard(

                            height: 455,

                            icon: Icons.water_drop_rounded,

                            label: loc.waterButton,

                            supportingText:

                                loc.waterBillSupportingText,

                            accentColor: const Color(0xFF1687D9),

                            accentLightColor: const Color(0xFFE3F3FF),

                            onPressed: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>

                                      const PWATERBILL3PAGE(),

                                ),

                              );

                            },

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(height: 34),

                    Row(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                      // ============================================================

                      // Broadband Bill (TM & UNIFI)

                      // ============================================================

                        Expanded(

                          child: _ModernServiceCard(

                            height: 455,

                            icon: Icons.router_rounded,

                            label: loc.billbroadbandButton,

                            supportingText:

                                loc.broadbandBillSupportingText,

                            accentColor: const Color(0xFF7356D8),

                            accentLightColor: const Color(0xFFEDE9FF),

                            onPressed: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>

                                      const PBROADBANDBILL3PAGE(),

                                ),

                              );

                            },

                          ),

                        ),

                      // ============================================================

                      // Entertainment (ASTRO, NJOI, etc.)

                      // ============================================================

                        const SizedBox(width: 34),

                        Expanded(

                          child: _ModernServiceCard(

                            height: 455,

                            icon: Icons.live_tv_rounded,

                            label: loc.billEntertainmentButton,

                            supportingText:

                                loc.entertainmentBillSupportingText,

                            accentColor: const Color(0xFFD64D8B),

                            accentLightColor: const Color(0xFFFFE6F2),

                            onPressed: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>

                                      const PENTERTAINMENTBILL3PAGE(),

                                ),

                              );

                            },

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(height: 34),

                  Row(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      // ============================================================

                      // TELCO

                      // ============================================================

                      Expanded(

                        child: _ModernServiceCard(

                          height: 455,

                          icon: Icons.sim_card_rounded,

                          label: loc.telkoButton,

                          supportingText: loc.telcoBillSupportingText,

                          accentColor: const Color(0xFF15946B),

                          accentLightColor: const Color(0xFFE2F7EF),

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) => const PTELCO3PAGE(),

                              ),

                            );

                          },

                          comingSoon: false,

                        ),

                      ),

                      const SizedBox(width: 34),

                      // ============================================================

                      // E-WALLET RELOADS

                      // ============================================================

                      Expanded(

                        child: _ModernServiceCard(

                          height: 455,

                          icon: Icons.account_balance_wallet_rounded,

                          label: loc.eWalletReloadButton,

                          supportingText: loc.eWalletReloadSupportingText,

                          accentColor: const Color(0xFFEF6C35),

                          accentLightColor: const Color(0xFFFFE9DF),

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) => const PEWALLET3PAGE(),

                              ),

                            );

                          },

                          comingSoon: false,

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: 34),

                  // ============================================================

                  // LOAN & EDUCATION

                  // ============================================================

                  Row(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Expanded(

                        child: _ModernServiceCard(

                          height: 455,

                          icon: Icons.school_rounded,

                          label: loc.loanEducationButton,

                          supportingText: loc.loanEducationSupportingText,

                          accentColor: const Color(0xFF3F51B5),

                          accentLightColor: const Color(0xFFE8EAF6),

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) => const PLOAN3PAGE(),

                              ),

                            );

                          },

                          comingSoon: false,

                        ),

                      ),

                      const SizedBox(width: 34),

                      // ============================================================

                      // GAMING PLATFORMS

                      // ============================================================

                      Expanded(

                        child: _ModernServiceCard(

                          height: 455,

                          icon: Icons.sports_esports_rounded,

                          label: loc.gamingPlatformButton,

                          supportingText: loc.gamingPlatformSupportingText,

                          accentColor: const Color(0xFF7C4DFF),

                          accentLightColor: const Color(0xFFEDE7FF),

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) => const PGAMING3PAGE(),

                              ),

                            );

                          },

                          comingSoon: false,

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: 34),

                  // ============================================================

                  // IDD + GAME CREDITS

                  // ============================================================

                  Row(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      // ============================================================

                      // INTERNATIONAL DIRECT DIALING

                      // ============================================================

                      Expanded(

                        child: _ModernServiceCard(

                          height: 455,

                          icon: Icons.public_rounded,

                          label: loc.iddButton,

                          supportingText: loc.iddBillSupportingText,

                          accentColor: const Color(0xFF1469E8),

                          accentLightColor: const Color(0xFFE3F0FF),

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) => const PIDDBILL3PAGE(),

                              ),

                            );

                          },

                          comingSoon: false,

                        ),

                      ),

                      const SizedBox(width: 34),

                      // ============================================================

                      // GAME CREDITS

                      // ============================================================

                      Expanded(

                        child: _ModernServiceCard(

                          height: 455,

                          icon: Icons.videogame_asset_rounded,

                          label: loc.gameCreditsButton,

                          supportingText: loc.gameCreditsSupportingText,

                          accentColor: const Color(0xFF009688),

                          accentLightColor: const Color(0xFFE0F5F2),

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) => const PGAMECREDITS3PAGE(),

                              ),

                            );

                          },

                          comingSoon: false,

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: 34),

                  // ============================================================

                  // CONSOLE & APP STORES

                  // ============================================================

                  Row(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Expanded(

                        child: _ModernServiceCard(

                          height: 455,

                          icon: Icons.devices_other_rounded,

                          label: loc.consoleStoresButton,

                          supportingText:

                              loc.consoleStoresSupportingText,

                          accentColor: const Color(0xFF3949AB),

                          accentLightColor: const Color(0xFFE8EAF6),

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>

                                    const PCONSOLESTORES3PAGE(),

                              ),

                            );

                          },

                          comingSoon: false,

                        ),

                      ),

                      const SizedBox(width: 34),

                      // ============================================================

                      // DIGITAL VOUCHER

                      // ============================================================

                      Expanded(

                        child: _ModernServiceCard(

                          height: 455,

                          icon: Icons.card_giftcard_rounded,

                          label: loc.digitalVoucherButton,

                          supportingText: loc.digitalVoucherSupportingText,

                          accentColor: const Color(0xFFE65175),

                          accentLightColor: const Color(0xFFFFE7EE),

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) => const PDIGITALVOUCHER3PAGE(),

                              ),

                            );

                          },

                          comingSoon: false,

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: 34),

                  // ============================================================
                  // FUEL + FOOD & BEVERAGE
                  // ============================================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========================================================
                      // FUEL
                      // ========================================================

                      Expanded(
                        child: _ModernServiceCard(
                          height: 455,
                          icon: Icons.local_gas_station_rounded,
                          label: loc.fuelButton,
                          supportingText: loc.fuelSupportingText,
                          accentColor: const Color(0xFFD62828),
                          accentLightColor: const Color(0xFFFFE5E5),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PFUEL3PAGE(),
                              ),
                            );
                          },
                          comingSoon: false,
                        ),
                      ),

                      const SizedBox(width: 34),

                      // ========================================================
                      // FOOD & BEVERAGE
                      // ========================================================

                      Expanded(
                        child: _ModernServiceCard(
                          height: 455,
                          icon: Icons.restaurant_rounded,
                          label: loc.foodBeverageButton,
                          supportingText: loc.foodBeverageSupportingText,
                          accentColor: const Color(0xFFE87522),
                          accentLightColor: const Color(0xFFFFEBD9),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PFOODBEVERAGE3PAGE(),
                              ),
                            );
                          },
                          comingSoon: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  ],

                ),

              ),

            ),

          ),

          // ============================================================
          // CONTENT FADE
          // Shows that more services continue below.
          // ============================================================
          if (showScrollDown)
            Positioned(
              left: 35,
              right: 35,
              bottom: 255,
              height: 175,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [
                        0.0,
                        0.30,
                        0.68,
                        1.0,
                      ],
                      colors: [
                        Colors.white.withOpacity(0.00),
                        Colors.white.withOpacity(0.14),
                        Colors.white.withOpacity(0.62),
                        Colors.white.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ============================================================
          // MODERN SCROLL CONTROLS
          //
          // TOP:
          // [ LIHAT LAGI  ↓ ]
          //
          // MIDDLE:
          // [ ↑  KE ATAS ]  [ LIHAT LAGI  ↓ ]
          //
          // BOTTOM:
          // [ ↑  KEMBALI KE ATAS ]
          // ============================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 255,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.94,
                        end: 1.0,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: _buildScrollAction(loc),
              ),
            ),
          ),

          Positioned(

            bottom: 105,

            left: 300,

            right: 300,

            child: KioskBackButton(

              onPressed: () {

                Navigator.pushReplacement(

                  context,

                  MaterialPageRoute(

                    builder: (_) => const P2Page(),

                  ),

                );

              },

            ),

          ),

          Positioned(

            bottom: 25,

            left: 0,

            right: 0,

            child: Center(

              child: Text(

                Data.copyrightText,

                textAlign: TextAlign.center,

                style: const TextStyle(

                  color: Color(0xFF26364A),

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

// ============================================================================

// KNOWLEDGE SLIDER

// ============================================================================

class _ModernPageHeader extends StatelessWidget {

  final String badgeText;

  final String title;

  final String subtitle;

  const _ModernPageHeader({

    required this.badgeText,

    required this.title,

    required this.subtitle,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.fromLTRB(

        30,

        24,

        30,

        24,

      ),

      decoration: BoxDecoration(

        color: Colors.white.withOpacity(0.95),

        borderRadius: BorderRadius.circular(32),

        border: Border.all(

          color: const Color(0xFFD5E4F7),

          width: 2,

        ),

        boxShadow: [

          BoxShadow(

            color: const Color(0xFF173A66).withOpacity(0.14),

            blurRadius: 30,

            offset: const Offset(0, 12),

          ),

        ],

      ),

      child: Row(

        children: [

          // ==========================================================

          // LEFT ICON

          // ==========================================================

          Container(

            width: 105,

            height: 105,

            decoration: BoxDecoration(

              gradient: const LinearGradient(

                begin: Alignment.topLeft,

                end: Alignment.bottomRight,

                colors: [

                  Color(0xFF064AA3),

                  Color(0xFF1478D4),

                ],

              ),

              borderRadius: BorderRadius.circular(30),

              boxShadow: [

                BoxShadow(

                  color: const Color(0xFF095AB8).withOpacity(0.28),

                  blurRadius: 20,

                  offset: const Offset(0, 8),

                ),

              ],

            ),

            child: const Icon(

              Icons.account_balance_rounded,

              color: Colors.white,

              size: 56,

            ),

          ),

          const SizedBox(width: 28),

          // ==========================================================

          // TEXT AREA

          // ==========================================================

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // Small service badge.

                Container(

                  padding: const EdgeInsets.symmetric(

                    horizontal: 18,

                    vertical: 7,

                  ),

                  decoration: BoxDecoration(

                    color: const Color(0xFFE9F3FF),

                    borderRadius: BorderRadius.circular(100),

                  ),

                  child: Row(

                    mainAxisSize: MainAxisSize.min,

                    children: [

                      const Icon(

                        Icons.apartment_rounded,

                        size: 20,

                        color: Color(0xFF1265BC),

                      ),

                      const SizedBox(width: 8),

                      Text(

                        badgeText.toUpperCase(),

                        style: const TextStyle(

                          color: Color(0xFF1265BC),

                          fontSize: 17,

                          fontWeight: FontWeight.w900,

                          letterSpacing: 1.1,

                        ),

                      ),

                    ],

                  ),

                ),

                const SizedBox(height: 12),

                // Main page title.

                Text(

                  title,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(

                    color: Color(0xFF122C4C),

                    fontSize: 52,

                    fontWeight: FontWeight.w900,

                    height: 1.02,

                    letterSpacing: -0.8,

                  ),

                ),

                const SizedBox(height: 9),

                // Subtitle.

                Text(

                  subtitle,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(

                    color: Color(0xFF607188),

                    fontSize: 30,

                    fontWeight: FontWeight.w600,

                    height: 1.25,

                  ),

                ),

              ],

            ),

          ),

          const SizedBox(width: 24),

          // ==========================================================

          // RIGHT ACCENT BAR

          // ==========================================================

          Container(

            width: 8,

            height: 105,

            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(20),

              gradient: const LinearGradient(

                begin: Alignment.topCenter,

                end: Alignment.bottomCenter,

                colors: [

                  Color(0xFF0751A8),

                  Color(0xFF2196E8),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }

}

// ============================================================================

// MODERN SERVICE CARD

// Button size and text styling are maintained from your original code.

// ============================================================================

class _ModernServiceCard extends StatefulWidget {

  final IconData? icon;

  final String? imagePath;

  final String label;

  final String supportingText;

  final VoidCallback onPressed;

  final Color accentColor;

  final Color accentLightColor;

  final double height;

  final bool comingSoon;

  const _ModernServiceCard({

    super.key,

    this.icon,

    this.imagePath,

    required this.label,

    required this.supportingText,

    required this.onPressed,

    required this.accentColor,

    required this.accentLightColor,

    this.height = 455,

    this.comingSoon = false,

  });

  @override

  State<_ModernServiceCard> createState() =>

      _ModernServiceCardState();

}

class _ModernServiceCardState extends State<_ModernServiceCard> {

  bool _isPressed = false;

  bool _isFocused = false;





  void _setPressed(bool value) {

    if (!mounted || widget.comingSoon) return;

    setState(() => _isPressed = value);

  }



  Widget _buildServiceIcons() {

    if (widget.icon != null) {

      return FittedBox(

        fit: BoxFit.contain,

        child: Icon(widget.icon, size: 300, color: widget.accentColor),

      );

    }

    if (widget.imagePath != null) {

      return Image.asset(widget.imagePath!, fit: BoxFit.contain);

    }

    return const SizedBox.shrink();

  }



  @override

  Widget build(BuildContext context) {

    final enabled = !widget.comingSoon;

    final radius = BorderRadius.circular(26);

    final emphasized = _isPressed || _isFocused;

    final borderColor = emphasized

        ? widget.accentColor

        : Color.lerp(const Color(0xFFB9C8DA), widget.accentColor, 0.28)!;



    return AnimatedScale(

      scale: _isPressed ? 0.985 : 1,

      duration: const Duration(milliseconds: 120),

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 160),

        height: widget.height,

        decoration: BoxDecoration(

          borderRadius: radius,

          boxShadow: [

            BoxShadow(

              color: const Color(0xFF18324F).withOpacity(

                _isPressed ? 0.05 : 0.11,

              ),

              blurRadius: _isPressed ? 8 : 18,

              offset: Offset(0, _isPressed ? 2 : 7),

            ),

          ],

        ),

        child: Material(

          color: Colors.white,

          clipBehavior: Clip.antiAlias,

          shape: RoundedRectangleBorder(

            borderRadius: radius,

            side: BorderSide(

              color: borderColor,

              width: 2,

            ),

          ),

          child: InkWell(

            onTap: enabled ? widget.onPressed : null,

            onHighlightChanged: _setPressed,

            onFocusChange: (focused) {

              if (mounted) setState(() => _isFocused = focused);

            },

            splashColor: widget.accentColor.withOpacity(0.10),

            highlightColor: widget.accentColor.withOpacity(0.04),

            child: Stack(

              fit: StackFit.expand,

              children: [

                Opacity(

                  opacity: enabled ? 1 : 0.45,

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [

                      // Raised icon panel overlaps the soft colour header.

                      SizedBox(

                        height: widget.height * 0.42,

                        child: LayoutBuilder(

                          builder: (context, headerBounds) {

                            return Stack(

                              children: [

                                Positioned(

                                  top: 0,

                                  left: 0,

                                  right: 0,

                                  height: headerBounds.maxHeight * 0.72,

                                  child: Ink(

                                    decoration: BoxDecoration(

                                      gradient: LinearGradient(

                                        begin: Alignment.topLeft,

                                        end: Alignment.bottomRight,

                                        colors: [

                                          widget.accentLightColor,

                                          Color.lerp(Colors.white,

                                              widget.accentLightColor, 0.40)!,

                                        ],

                                      ),

                                    ),

                                  ),

                                ),

                                Positioned(

                                  left: 20,

                                  right: 20,

                                  top: 22,

                                  bottom: 8,

                                  child: IgnorePointer(

                                    child: ExcludeSemantics(

                                      child: AnimatedContainer(

                                        duration: const Duration(milliseconds: 160),

                                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),

                                        decoration: BoxDecoration(

                                          color: Color.lerp(Colors.white,

                                              widget.accentLightColor, 0.18),

                                          borderRadius: BorderRadius.circular(22),

                                          border: Border.all(

                                            color: widget.accentColor.withOpacity(0.22),

                                            width: 1.5,

                                          ),

                                          boxShadow: [

                                            BoxShadow(

                                              color: widget.accentColor.withOpacity(

                                                _isPressed ? 0.08 : 0.15,

                                              ),

                                              blurRadius: _isPressed ? 10 : 18,

                                              offset: Offset(0, _isPressed ? 3 : 7),

                                            ),

                                          ],

                                        ),

                                        child: Row(

                                          crossAxisAlignment: CrossAxisAlignment.start,

                                          children: [

                                            Expanded(

                                              child: Center(

                                                child: SizedBox(

                                                  width: 126,

                                                  height: 126,

                                                  child: _buildServiceIcons(),

                                                ),

                                              ),

                                            ),

                                            const SizedBox(width: 8),

                                            Container(

                                              width: 38,

                                              height: 38,

                                              decoration: BoxDecoration(

                                                color: widget.accentColor,

                                                borderRadius: BorderRadius.circular(12),

                                              ),

                                              child: Icon(

                                                Icons.arrow_forward_rounded,

                                                color: Colors.white,

                                                size: 25,

                                              ),

                                            ),

                                          ],

                                        ),

                                      ),

                                    ),

                                  ),

                                ),

                              ],

                            );

                          },

                        ),

                      ),

                      Expanded(

                        child: Padding(

                          padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),

                          child: LayoutBuilder(

                            builder: (context, bounds) {

                              return SizedBox(

                                width: bounds.maxWidth,

                                height: bounds.maxHeight,

                                child: FittedBox(

                                  fit: BoxFit.scaleDown,

                                  alignment: Alignment.topLeft,

                                  child: SizedBox(

                                    width: bounds.maxWidth,

                                    child: Column(

                                      mainAxisSize: MainAxisSize.min,

                                      crossAxisAlignment: CrossAxisAlignment.start,

                                      children: [

                                        Text(

                                          widget.label.toUpperCase(),

                                          softWrap: true,

                                          style: const TextStyle(

                                            color: Color(0xFF142D4E),

                                            fontSize: 32,

                                            fontWeight: FontWeight.w800,

                                            height: 1.16,

                                            letterSpacing: 0,

                                          ),

                                        ),

                                        const SizedBox(height: 16),

                                        Text(

                                          widget.supportingText,

                                          softWrap: true,

                                          style: const TextStyle(

                                            color: Color(0xFF526175),

                                            fontSize: 30,

                                            fontWeight: FontWeight.w500,

                                            height: 1.35,

                                          ),

                                        ),

                                      ],

                                    ),

                                  ),

                                ),

                              );

                            },

                          ),

                        ),

                      ),

                    ],

                  ),

                ),

                Positioned.fill(

                  child: IgnorePointer(

                    child: AnimatedContainer(

                      duration: const Duration(milliseconds: 160),

                      decoration: BoxDecoration(

                        borderRadius: radius,

                        border: Border.all(

                          color: borderColor,

                          width: emphasized ? 3 : 2,

                        ),

                      ),

                    ),

                  ),

                ),

                if (widget.comingSoon)

                  Center(

                    child: Container(

                      margin: const EdgeInsets.all(18),

                      padding: const EdgeInsets.symmetric(

                        horizontal: 20, vertical: 14,

                      ),

                      decoration: BoxDecoration(

                        color: const Color(0xFF334155),

                        borderRadius: BorderRadius.circular(12),

                      ),

                      child: Text(

                        AppLocalizations.of(context)!

                            .comingsoonText.toUpperCase(),

                        textAlign: TextAlign.center,

                        style: const TextStyle(

                          color: Colors.white,

                          fontSize: 24,

                          fontWeight: FontWeight.w700,

                        ),

                      ),

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

enum _ScrollControlMode {
  up,
  more,
  top,
}

class _ScrollDiscoveryControl extends StatefulWidget {
  final _ScrollControlMode mode;
  final String label;
  final VoidCallback onPressed;

  const _ScrollDiscoveryControl({
    super.key,
    required this.mode,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_ScrollDiscoveryControl> createState() =>
      _ScrollDiscoveryControlState();
}

class _ScrollDiscoveryControlState
    extends State<_ScrollDiscoveryControl> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isUp =
        widget.mode == _ScrollControlMode.up ||
        widget.mode == _ScrollControlMode.top;

    final IconData arrow = isUp
        ? Icons.keyboard_arrow_up_rounded
        : Icons.keyboard_arrow_down_rounded;

    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onHighlightChanged: _setPressed,
          borderRadius: BorderRadius.circular(100),
          splashColor: const Color(0xFF1469E8).withOpacity(0.10),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            constraints: const BoxConstraints(
              minHeight: 88,
            ),
            padding: const EdgeInsets.fromLTRB(
              30,
              13,
              22,
              13,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.98),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: _pressed
                    ? const Color(0xFF1469E8)
                    : const Color(0xFFC4D8EE),
                width: _pressed ? 2.5 : 1.7,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF173B66).withOpacity(
                    _pressed ? 0.09 : 0.17,
                  ),
                  blurRadius: _pressed ? 8 : 20,
                  offset: Offset(
                    0,
                    _pressed ? 2 : 7,
                  ),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUp) ...[
                  _ScrollArrowCircle(
                    icon: arrow,
                    pressed: _pressed,
                  ),
                  const SizedBox(width: 14),
                ],

                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 88,
                    maxWidth: 190,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.label.toUpperCase(),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF163B67),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                if (!isUp) ...[
                  const SizedBox(width: 14),
                  _ScrollArrowCircle(
                    icon: arrow,
                    pressed: _pressed,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScrollArrowCircle extends StatelessWidget {
  final IconData icon;
  final bool pressed;

  const _ScrollArrowCircle({
    required this.icon,
    required this.pressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pressed
              ? const [
                  Color(0xFF0B4FAE),
                  Color(0xFF0A73E8),
                ]
              : const [
                  Color(0xFF1469E8),
                  Color(0xFF0A82F5),
                ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1469E8).withOpacity(0.30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 48,
      ),
    );
  }
}

