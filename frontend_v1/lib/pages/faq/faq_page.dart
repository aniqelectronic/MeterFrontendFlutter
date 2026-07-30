import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';

class FaqPage extends StatelessWidget {
  final String councilHotlineNumber;
  final String operationsHotlineNumber;

  const FaqPage({
    super.key,
    this.councilHotlineNumber = 'SILA MASUKKAN NOMBOR MAJLIS',
    this.operationsHotlineNumber = 'SILA MASUKKAN NOMBOR OPERASI',
  });

  static const Color primaryBlue = Color(0xFF0B63D8);
  static const Color darkBlue = Color(0xFF173459);
  static const Color softBlue = Color(0xFFF2F7FF);

  List<_FaqItem> _items(AppLocalizations loc) {
    return [
      _FaqItem(
        icon: Icons.info_outline_rounded,
        title: loc.faqWhatIsKioskTitle,
        content: loc.faqWhatIsKioskContent,
        accentColor: const Color(0xFF1565C0),
        softColor: const Color(0xFFEAF3FF),
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
        softColor: const Color(0xFFE5F8F2),
      ),
      _FaqItem(
        icon: Icons.qr_code_2_rounded,
        title: loc.faqReceiptTitle,
        content: loc.faqReceiptContent,
        accentColor: const Color(0xFF7A4DD8),
        softColor: const Color(0xFFF1EBFF),
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
        accentColor: const Color(0xFFD65A31),
        softColor: const Color(0xFFFFEEE8),
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
    final ScrollController pageScrollController = ScrollController();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
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
                    Colors.white.withOpacity(0.90),
                    const Color(0xFFF2F6FB).withOpacity(0.97),
                    Colors.white.withOpacity(0.94),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(30, 24, 30, 24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF083B8C),
                          Color(0xFF0B63D8),
                          Color(0xFF2196F3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF083B8C).withOpacity(0.34),
                          blurRadius: 34,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.48),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.12),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.help_center_rounded,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.faqTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 46,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                loc.faqSubtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.90),
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 10, 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.99),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFFB9C9DA),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF173459).withOpacity(0.18),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Scrollbar(
                        controller: pageScrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        interactive: true,
                        scrollbarOrientation: ScrollbarOrientation.right,
                        thickness: 14,
                        radius: const Radius.circular(20),
                        child: GridView.builder(
                          controller: pageScrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(right: 14),
                          itemCount: faqItems.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.78,
                          ),
                          itemBuilder: (context, index) {
                            final item = faqItems[index];

                            return _FaqQuestionCard(
                              item: item,
                              onTap: () {
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
                  ),

                  const SizedBox(height: 60),

                  SizedBox(
                    width: double.infinity,
                    height: 88,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 36,
                      ),
                      label: Text(
                        loc.backButton,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF102A43),
                        elevation: 4,
                        shadowColor: const Color(0xFF173459).withOpacity(0.20),
                        side: const BorderSide(
                          color: Color(0xFF8FA6BE),
                          width: 2.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    Data.copyrightText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF34465D),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 770,
                constraints: const BoxConstraints(
                  maxHeight: 980,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 42,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFB9C9DA),
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
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          32,
                          30,
                          24,
                          28,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              item.softColor,
                              Colors.white,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: item.accentColor,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: item.accentColor.withOpacity(0.22),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item.icon,
                                color: Colors.white,
                                size: 46,
                              ),
                            ),
                            const SizedBox(width: 20),
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
                              color: const Color(0xFFF1F3F6),
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () => Navigator.pop(dialogContext),
                                customBorder: const CircleBorder(),
                                child: const SizedBox(
                                  width: 56,
                                  height: 56,
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
                      Flexible(
                        child: Stack(
                          children: [
                            Scrollbar(
                              controller: dialogScrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              thickness: 12,
                              radius: const Radius.circular(20),
                              child: SingleChildScrollView(
                                controller: dialogScrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  34,
                                  32,
                                  60,
                                  34,
                                ),
                                child: item.isHelp
                                    ? _buildHelpDialogContent(loc, item)
                                    : Text(
                                        item.content,
                                        style: const TextStyle(
                                          color: Color(0xFF1E2F43),
                                          fontSize: 30,
                                          fontWeight: FontWeight.w700,
                                          height: 1.50,
                                        ),
                                      ),
                              ),
                            ),

                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: IgnorePointer(
                                // child: Container(
                                //   width: 46,
                                //   height: 46,
                                //   decoration: BoxDecoration(
                                //     color: item.accentColor,
                                //     shape: BoxShape.circle,
                                //     boxShadow: [
                                //       BoxShadow(
                                //         color: item.accentColor.withOpacity(0.35),
                                //         blurRadius: 12,
                                //         offset: const Offset(0, 5),
                                //       ),
                                //     ],
                                //   ),
                                //   child: const Icon(
                                //     Icons.keyboard_double_arrow_down_rounded,
                                //     color: Colors.white,
                                //     size: 30,
                                //   ),
                                // ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          30,
                          0,
                          30,
                          28,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 86,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item.accentColor,
                              foregroundColor: Colors.white,
                              elevation: 6,
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
            fontSize: 31,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _contactCard(
          icon: Icons.account_balance_rounded,
          title: loc.parkingCouncilHotline,
          number: councilHotlineNumber,
        ),
        const SizedBox(height: 16),
        _contactCard(
          icon: Icons.engineering_rounded,
          title: loc.parkingCityCarParkHotline,
          number: operationsHotlineNumber,
        ),
      ],
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String number,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5B66F),
          width: 1.7,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7C5),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFC96813),
              size: 32,
            ),
          ),
          const SizedBox(width: 17),
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
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.phone_in_talk_rounded,
            color: Color(0xFF168A45),
            size: 34,
          ),
        ],
      ),
    );
  }
}

class _FaqQuestionCard extends StatefulWidget {
  final _FaqItem item;
  final VoidCallback onTap;

  const _FaqQuestionCard({
    required this.item,
    required this.onTap,
  });

  @override
  State<_FaqQuestionCard> createState() => _FaqQuestionCardState();
}

class _FaqQuestionCardState extends State<_FaqQuestionCard> {
  bool isPressed = false;

  void setPressed(bool value) {
    if (!mounted) return;
    setState(() => isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setPressed(true),
      onTapUp: (_) => setPressed(false),
      onTapCancel: () => setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: isPressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isPressed
                ? widget.item.softColor.withOpacity(0.92)
                : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isPressed
                  ? widget.item.accentColor
                  : widget.item.accentColor.withOpacity(0.34),
              width: isPressed ? 2.8 : 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: isPressed
                    ? widget.item.accentColor.withOpacity(0.28)
                    : const Color(0xFF173459).withOpacity(0.12),
                blurRadius: isPressed ? 20 : 13,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: isPressed ? 10 : 7,
                    color: widget.item.accentColor,
                  ),
                ),
                Positioned(
                  top: -28,
                  right: -22,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: widget.item.softColor.withOpacity(0.80),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 14, 16),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isPressed
                              ? widget.item.accentColor
                              : widget.item.softColor,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: widget.item.accentColor.withOpacity(0.28),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.item.accentColor.withOpacity(0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.item.icon,
                          color: isPressed
                              ? Colors.white
                              : widget.item.accentColor,
                          size: 33,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          widget.item.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF102A43),
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            height: 1.14,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: isPressed ? 48 : 44,
                        height: isPressed ? 48 : 44,
                        decoration: BoxDecoration(
                          color: widget.item.accentColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.item.accentColor.withOpacity(0.34),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
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
