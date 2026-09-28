import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/widgets/kiosk_back_button.dart';

class FaqPage extends StatefulWidget {
  final String councilHotlineNumber;
  final String operationsHotlineNumber;

  const FaqPage({
    super.key,
    this.councilHotlineNumber = 'SILA MASUKKAN NOMBOR MAJLIS',
    this.operationsHotlineNumber = 'SILA MASUKKAN NOMBOR OPERASI',
  });

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  static const Color primaryBlue = Color(0xFF0B63D8);
  static const Color darkBlue = Color(0xFF173459);

  final ScrollController _scrollController = ScrollController();

  bool _showScrollUp = false;
  bool _showScrollDown = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleScroll();
    });
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || !mounted) return;

    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final current = position.pixels;

    final showUp = current > 10;
    final showDown = maxScroll > 10 && current < maxScroll - 10;

    if (_showScrollUp != showUp || _showScrollDown != showDown) {
      setState(() {
        _showScrollUp = showUp;
        _showScrollDown = showDown;
      });
    }
  }

  void _scrollUp() {
    if (!_scrollController.hasClients) return;

    final destination = (_scrollController.offset - 500).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      destination,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) return;

    final destination = (_scrollController.offset + 500).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      destination,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  List<_FaqItem> _items(AppLocalizations loc) {
    return [
      _FaqItem(
        icon: Icons.info_outline_rounded,
        title: loc.faqWhatIsKioskTitle,
        content: loc.faqWhatIsKioskContent,
        accentColor: const Color(0xFF1469E8),
        softColor: const Color(0xFFE6F0FF),
      ),
      _FaqItem(
        icon: Icons.account_balance_rounded,
        title: loc.faqCouncilServicesTitle,
        content: loc.faqCouncilServicesContent,
        accentColor: const Color(0xFF1769E0),
        softColor: const Color(0xFFE8F1FF),
      ),
      _FaqItem(
        icon: Icons.receipt_long_rounded,
        title: loc.faqBillServicesTitle,
        content: loc.faqBillServicesContent,
        accentColor: const Color(0xFF008F72),
        softColor: const Color(0xFFE0F8F1),
      ),
      _FaqItem(
        icon: Icons.qr_code_2_rounded,
        title: loc.faqReceiptTitle,
        content: loc.faqReceiptContent,
        accentColor: const Color(0xFF7B4DE3),
        softColor: const Color(0xFFF0E9FF),
      ),
      _FaqItem(
        icon: Icons.credit_card_rounded,
        title: loc.faqPaymentMethodsTitle,
        content: loc.faqPaymentMethodsContent,
        accentColor: const Color(0xFF00796B),
        softColor: const Color(0xFFE5F6F3),
      ),
      _FaqItem(
        icon: Icons.error_outline_rounded,
        title: loc.faqPaymentFailedTitle,
        content: loc.faqPaymentFailedContent,
        accentColor: const Color(0xFFE34E45),
        softColor: const Color(0xFFFFE7E5),
      ),
      _FaqItem(
        icon: Icons.security_rounded,
        title: loc.faqPaymentSafetyTitle,
        content: loc.faqPaymentSafetyContent,
        accentColor: const Color(0xFF168A45),
        softColor: const Color(0xFFE9F7EE),
      ),
      _FaqItem(
        icon: Icons.sync_rounded,
        title: loc.faqUpdateTimeTitle,
        content: loc.faqUpdateTimeContent,
        accentColor: const Color(0xFF2E7D32),
        softColor: const Color(0xFFECF7ED),
      ),
      _FaqItem(
        icon: Icons.lightbulb_outline_rounded,
        title: loc.faqTipsTitle,
        content: loc.faqTipsContent,
        accentColor: const Color(0xFFE58A12),
        softColor: const Color(0xFFFFF4DF),
      ),
      _FaqItem(
        icon: Icons.support_agent_rounded,
        title: loc.faqHelpTitle,
        content: loc.faqHelpContent,
        accentColor: const Color(0xFFC96813),
        softColor: const Color(0xFFFFEFD9),
        isHelp: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final faqItems = _items(loc);

    return Scaffold(
      body: Stack(
        children: [
          // ============================================================
          // BACKGROUND
          // ============================================================
          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),

          // ============================================================
          // SOFT OVERLAY - SAME FAMILY AS PBT3
          // ============================================================
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.16),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // HEADER
          // ============================================================
          Positioned(
            top: 45,
            left: 65,
            right: 65,
            child: _ModernFaqHeader(
              badgeText: loc.faqTitle,
              title: loc.faqTitle,
              subtitle: loc.faqSubtitle,
            ),
          ),

          // ============================================================
          // FAQ SERVICE AREA
          // ============================================================
          Positioned(
            top: 330,
            left: 60,
            right: 60,
            bottom: 300,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: false,
              thickness: 8,
              radius: const Radius.circular(20),
              child: GridView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.only(
                  top: 28,
                  right: 22,
                  bottom: 90,
                ),
                itemCount: faqItems.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 36,
                  mainAxisSpacing: 36,

                  // Taller cards like PBT3.
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final item = faqItems[index];

                  return _ModernFaqButton(
                    item: item,
                    onPressed: () {
                      _showFaqDialog(
                        context,
                        loc,
                        item,
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // ============================================================
          // SCROLL UP
          // ============================================================
          if (_showScrollUp)
            Positioned(
              right: 20,
              top: 360,
              child: _ScrollIndicatorButton(
                icon: Icons.keyboard_arrow_up_rounded,
                label: loc.scrollup,
                onPressed: _scrollUp,
              ),
            ),

          // ============================================================
          // SCROLL DOWN
          // ============================================================
          if (_showScrollDown)
            Positioned(
              right: 20,
              bottom: 300,
              child: _ScrollIndicatorButton(
                icon: Icons.keyboard_arrow_down_rounded,
                label: loc.scrolldown,
                onPressed: _scrollDown,
                iconBelowText: true,
              ),
            ),

          // ============================================================
          // BACK BUTTON
          // ============================================================
          Positioned(
            bottom: 100,
            left: 300,
            right: 300,
            child: KioskBackButton(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // ============================================================
          // COPYRIGHT
          // ============================================================
          Positioned(
            bottom: 20,
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

  // ==========================================================================
  // FAQ DIALOG
  // ==========================================================================

  Future<void> _showFaqDialog(
    BuildContext context,
    AppLocalizations loc,
    _FaqItem item,
  ) async {
    final ScrollController dialogScrollController = ScrollController();

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'FAQ',
      barrierColor: Colors.black.withOpacity(0.58),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (
        dialogContext,
        animation,
        secondaryAnimation,
      ) {
        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 720,
                constraints: const BoxConstraints(
                  maxHeight: 980,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 38,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFFD5E4F7),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 36,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ======================================================
                      // DIALOG HEADER
                      // ======================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          30,
                          28,
                          22,
                          28,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              item.softColor,
                              Colors.white,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 94,
                              height: 94,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    item.accentColor,
                                    Color.lerp(
                                      item.accentColor,
                                      Colors.white,
                                      0.18,
                                    )!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        item.accentColor.withOpacity(0.24),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item.icon,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                            const SizedBox(width: 22),
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  color: darkBlue,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  height: 1.15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            Material(
                              color: const Color(0xFFF1F4F8),
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(dialogContext);
                                },
                                customBorder: const CircleBorder(),
                                child: const SizedBox(
                                  width: 58,
                                  height: 58,
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFF2C3747),
                                    size: 34,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(
                        height: 1,
                        color: Color(0xFFDCE5EF),
                      ),

                      // ======================================================
                      // DIALOG CONTENT
                      // ======================================================
                      Flexible(
                        child: Scrollbar(
                          controller: dialogScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 11,
                          radius: const Radius.circular(20),
                          child: SingleChildScrollView(
                            controller: dialogScrollController,
                            padding: const EdgeInsets.fromLTRB(
                              34,
                              34,
                              55,
                              32,
                            ),
                            child: item.isHelp
                                ? _buildHelpDialogContent(
                                    loc,
                                    item,
                                  )
                                : Text(
                                    item.content,
                                    style: const TextStyle(
                                      color: Color(0xFF1E2F43),
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // ======================================================
                      // DIALOG OK BUTTON
                      // ======================================================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          30,
                          10,
                          30,
                          28,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 86,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item.accentColor,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shadowColor:
                                  item.accentColor.withOpacity(0.30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              loc.parkingInfoOk,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.94,
              end: 1.0,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

    dialogScrollController.dispose();
  }

  // ==========================================================================
  // HELP CONTENT
  // ==========================================================================

  Widget _buildHelpDialogContent(
    AppLocalizations loc,
    _FaqItem item,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.content,
          style: const TextStyle(
            color: Color(0xFF34465D),
            fontSize: 30,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),

        _contactCard(
          icon: Icons.account_balance_rounded,
          title: loc.parkingCouncilHotline,
          number: widget.councilHotlineNumber,
        ),

        const SizedBox(height: 18),

        _contactCard(
          icon: Icons.engineering_rounded,
          title: loc.parkingCityCarParkHotline,
          number: widget.operationsHotlineNumber,
        ),
      ],
    );
  }

  // ==========================================================================
  // CONTACT CARD
  // ==========================================================================

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String number,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8ED),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5B66F),
          width: 1.7,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7C5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFC96813),
              size: 34,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF73502D),
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  number,
                  style: const TextStyle(
                    color: Color(0xFF293544),
                    fontSize: 33,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.phone_in_talk_rounded,
            color: Color(0xFF168A45),
            size: 35,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MODERN HEADER - SAME DESIGN LANGUAGE AS PBT3
// =============================================================================

class _ModernFaqHeader extends StatelessWidget {
  final String badgeText;
  final String title;
  final String subtitle;

  const _ModernFaqHeader({
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
          // ===============================================================
          // LEFT ICON
          // ===============================================================
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
              Icons.help_center_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),

          const SizedBox(width: 28),

          // ===============================================================
          // TEXT AREA
          // ===============================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        Icons.question_answer_rounded,
                        size: 20,
                        color: Color(0xFF1265BC),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        badgeText.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF607188),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // ===============================================================
          // RIGHT ACCENT
          // ===============================================================
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

// =============================================================================
// FAQ BUTTON - PBT3 SERVICE CARD STYLE
// =============================================================================

class _ModernFaqButton extends StatefulWidget {
  final _FaqItem item;
  final VoidCallback onPressed;

  const _ModernFaqButton({
    required this.item,
    required this.onPressed,
  });

  @override
  State<_ModernFaqButton> createState() => _ModernFaqButtonState();
}

class _ModernFaqButtonState extends State<_ModernFaqButton> {
  bool _isPressed = false;
  bool _isFocused = false;

  void _setPressed(bool value) {
    if (!mounted) return;

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26);
    final emphasized = _isPressed || _isFocused;

    final borderColor = emphasized
        ? widget.item.accentColor
        : Color.lerp(
            const Color(0xFFB9C8DA),
            widget.item.accentColor,
            0.28,
          )!;

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF18324F).withOpacity(
                _isPressed ? 0.05 : 0.11,
              ),
              blurRadius: _isPressed ? 8 : 18,
              offset: Offset(
                0,
                _isPressed ? 2 : 7,
              ),
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
            onTap: widget.onPressed,
            onHighlightChanged: _setPressed,
            onFocusChange: (focused) {
              if (!mounted) return;

              setState(() {
                _isFocused = focused;
              });
            },
            splashColor:
                widget.item.accentColor.withOpacity(0.10),
            highlightColor:
                widget.item.accentColor.withOpacity(0.04),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // =====================================================
                    // TOP COLOURED AREA
                    // =====================================================
                    Expanded(
                      flex: 46,
                      child: LayoutBuilder(
                        builder: (context, bounds) {
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        widget.item.softColor,
                                        Color.lerp(
                                          Colors.white,
                                          widget.item.softColor,
                                          0.42,
                                        )!,
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Decorative circle
                              Positioned(
                                right: -35,
                                top: -35,
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    color: widget.item.accentColor
                                        .withOpacity(0.06),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),

                              Positioned(
                                left: 20,
                                right: 20,
                                top: 22,
                                bottom: 14,
                                child: IgnorePointer(
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 160),
                                    padding: const EdgeInsets.fromLTRB(
                                      18,
                                      16,
                                      18,
                                      16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color.lerp(
                                        Colors.white,
                                        widget.item.softColor,
                                        0.18,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(22),
                                      border: Border.all(
                                        color: widget.item.accentColor
                                            .withOpacity(0.22),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.item.accentColor
                                              .withOpacity(
                                            _isPressed ? 0.08 : 0.15,
                                          ),
                                          blurRadius:
                                              _isPressed ? 10 : 18,
                                          offset: Offset(
                                            0,
                                            _isPressed ? 3 : 7,
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Icon(
                                            widget.item.icon,
                                            size: 112,
                                            color:
                                                widget.item.accentColor,
                                          ),
                                        ),

                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color:
                                                  widget.item.accentColor,
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: widget
                                                      .item.accentColor
                                                      .withOpacity(0.25),
                                                  blurRadius: 10,
                                                  offset:
                                                      const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 27,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // =====================================================
                    // LOWER TEXT AREA
                    // =====================================================
                    Expanded(
                      flex: 54,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          24,
                          24,
                          24,
                          22,
                        ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.item.title.toUpperCase(),
                                        softWrap: true,
                                        style: const TextStyle(
                                          color: Color(0xFF142D4E),
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800,
                                          height: 1.17,
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      // Row(
                                      //   children: [
                                      //     Container(
                                      //       width: 8,
                                      //       height: 8,
                                      //       decoration: BoxDecoration(
                                      //         color:
                                      //             widget.item.accentColor,
                                      //         shape: BoxShape.circle,
                                      //       ),
                                      //     ),
                                      //     const SizedBox(width: 10),
                                      //     Expanded(
                                      //       child: Text(
                                      //         'FAQ',
                                      //         style: TextStyle(
                                      //           color: widget
                                      //               .item.accentColor,
                                      //           fontSize: 22,
                                      //           fontWeight:
                                      //               FontWeight.w800,
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
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

                // =========================================================
                // STRONGER BORDER WHEN PRESSED
                // =========================================================
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 160),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SCROLL INDICATOR
// =============================================================================

class _ScrollIndicatorButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool iconBelowText;

  const _ScrollIndicatorButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconBelowText = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 54,
      color: const Color(0xFF175EB9),
    );

    final textWidget = Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
        color: Color(0xFF24405F),
      ),
    );

    return Material(
      color: Colors.white.withOpacity(0.94),
      borderRadius: BorderRadius.circular(22),
      elevation: 5,
      shadowColor:
          const Color(0xFF14345A).withOpacity(0.25),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: iconBelowText
                ? [
                    textWidget,
                    iconWidget,
                  ]
                : [
                    iconWidget,
                    textWidget,
                  ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FAQ DATA MODEL
// =============================================================================

class _FaqItem {
  final IconData icon;
  final String title;
  final String content;
  final Color accentColor;
  final Color softColor;
  final bool isHelp;

  const _FaqItem({
    required this.icon,
    required this.title,
    required this.content,
    required this.accentColor,
    required this.softColor,
    this.isHelp = false,
  });
}