import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';

// ============================================================================
// COMMON PROVIDER NETWORK STATUS
// ============================================================================

enum ProviderNetworkStatus {
  loading,
  healthy,
  interruption,
  unavailable,
}

// ============================================================================
// MODERN PROVIDER CARD
// ============================================================================

class ModernProviderCard extends StatefulWidget {
  // ==========================================================================
  // BASIC DATA
  // ==========================================================================

  final String imageUrl;
  final String label;
  final VoidCallback onPressed;

  // ==========================================================================
  // COLORS
  // ==========================================================================

  final Color accentColor;
  final Color lightAccentColor;

  // ==========================================================================
  // NETWORK
  // ==========================================================================

  final ProviderNetworkStatus networkStatus;
  final String networkLabel;

  // ==========================================================================
  // PROCESSING TIME
  // ==========================================================================

  final String processingTime;
  final String processingLabel;

  // ==========================================================================
  // FALLBACK ICON
  // ==========================================================================

  final IconData fallbackIcon;

  // ==========================================================================
  // CARD HEIGHT
  // ==========================================================================

  final double height;

  // ==========================================================================
  // OPTIONAL CUSTOM PROCESSING TIME FORMATTER
  // ==========================================================================

  final String Function(
    BuildContext context,
    String value,
  )? processingTimeFormatter;

  // ==========================================================================
  // ALLOW TAP WHEN UNAVAILABLE
  // ==========================================================================

  final bool allowTapWhenUnavailable;

  // ==========================================================================
  // CONSTRUCTOR
  // ==========================================================================

  const ModernProviderCard({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.onPressed,
    required this.accentColor,
    required this.lightAccentColor,
    required this.networkStatus,
    required this.networkLabel,
    required this.processingTime,
    required this.processingLabel,
    required this.fallbackIcon,
    this.height = 510,
    this.processingTimeFormatter,
    this.allowTapWhenUnavailable = false,
  });

  @override
  State<ModernProviderCard> createState() =>
      _ModernProviderCardState();
}

// ============================================================================
// MODERN PROVIDER CARD STATE
// ============================================================================

class _ModernProviderCardState extends State<ModernProviderCard> {
  bool _isPressed = false;

  // ==========================================================================
  // PRESS STATE
  // ==========================================================================

  void _changePressedState(bool value) {
    if (!mounted) return;

    setState(() {
      _isPressed = value;
    });
  }

  // ==========================================================================
  // DEFAULT PROCESSING TIME FORMATTER
  // ==========================================================================

  String _formatProcessingTime(
    BuildContext context,
    String value,
  ) {
    final loc = AppLocalizations.of(context)!;

    final String normalized = value.toLowerCase().trim();

    switch (normalized) {
      case 'instant':
        return loc.processingInstant;

      case '24_hours':
        return loc.processing24Hours;

      case '3_days':
        return loc.processing3Days;

      case 'pin':
        return 'PIN';

      case 'link':
        return 'LINK';

      default:
        return value.replaceAll('_', ' ');
    }
  }

  // ==========================================================================
  // FINAL PROCESSING TIME TEXT
  // ==========================================================================

  String _getProcessingTimeText(
    BuildContext context,
  ) {
    final customFormatter = widget.processingTimeFormatter;

    if (customFormatter != null) {
      return customFormatter(
        context,
        widget.processingTime,
      );
    }

    return _formatProcessingTime(
      context,
      widget.processingTime,
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final bool isEnabled =
        widget.allowTapWhenUnavailable ||
        widget.networkStatus != ProviderNetworkStatus.unavailable;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      // ======================================================================
      // PRESS DOWN
      // ======================================================================

      onTapDown: isEnabled
          ? (_) {
              _changePressedState(true);
            }
          : null,

      // ======================================================================
      // PRESS UP
      // ======================================================================

      onTapUp: isEnabled
          ? (_) {
              _changePressedState(false);
            }
          : null,

      // ======================================================================
      // PRESS CANCEL
      // ======================================================================

      onTapCancel: isEnabled
          ? () {
              _changePressedState(false);
            }
          : null,

      // ======================================================================
      // TAP
      // ======================================================================

      onTap: isEnabled ? widget.onPressed : null,

      child: AnimatedScale(
        scale: _isPressed ? 0.965 : 1.0,

        duration: const Duration(
          milliseconds: 130,
        ),

        curve: Curves.easeOut,

        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 170,
          ),

          curve: Curves.easeOut,

          height: widget.height,

          // ==================================================================
          // CARD
          // ==================================================================

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              isEnabled ? 0.96 : 0.72,
            ),

            borderRadius: BorderRadius.circular(40),

            border: Border.all(
              color: _isPressed
                  ? widget.accentColor
                  : Colors.black,

              width: _isPressed ? 4 : 3,
            ),

            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF19375C).withOpacity(0.16),
                      blurRadius: 30,
                      spreadRadius: 1,
                      offset: const Offset(0, 15),
                    ),
                  ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(37),

            child: Stack(
              children: [
                // ============================================================
                // DECORATIVE BACKGROUND CIRCLE
                // ============================================================

                Positioned(
                  right: -50,
                  top: -50,

                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 180,
                    ),

                    width: _isPressed ? 225 : 210,
                    height: _isPressed ? 225 : 210,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: widget.lightAccentColor.withOpacity(
                        0.90,
                      ),
                    ),
                  ),
                ),

                // ============================================================
                // CONTENT
                // ============================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    27,
                    25,
                    27,
                    22,
                  ),

                  child: Opacity(
                    opacity: isEnabled ? 1.0 : 0.55,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // ====================================================
                        // LOGO
                        // ====================================================

                        Container(
                          width: double.infinity,
                          height: 205,

                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.94),

                            borderRadius: BorderRadius.circular(28),

                            border: Border.all(
                              color: widget.accentColor.withOpacity(0.20),
                              width: 2,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: widget.accentColor.withOpacity(0.10),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),

                          child: _buildLogo(),
                        ),

                        const SizedBox(height: 23),

                        // ====================================================
                        // PROVIDER NAME
                        // ====================================================

                        Text(
                          widget.label,

                          maxLines: 2,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Color(0xFF142D4E),

                            fontSize: 30,

                            fontWeight: FontWeight.w900,

                            height: 1.15,
                          ),
                        ),

                        const Spacer(),

                        // ====================================================
                        // NEW COMBINED STATUS PANEL
                        //
                        // RANGKAIAN     | MASA PEMPROSESAN
                        // ● BAIK        | ◷ LINK
                        // ====================================================

                        _ProviderServiceInfoPanel(
                          networkStatus: widget.networkStatus,

                          networkLabel: widget.networkLabel,

                          processingLabel:
                              widget.processingLabel,

                          processingValue:
                              _getProcessingTimeText(context),

                          showProcessing:
                              widget.processingTime.trim().isNotEmpty,

                          accentColor:
                              widget.accentColor,
                        ),

                        const SizedBox(height: 13),

                        // ====================================================
                        // DECORATIVE BOTTOM LINE
                        // ====================================================

                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 7,

                              decoration: BoxDecoration(
                                color: widget.accentColor,

                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),

                            const SizedBox(width: 8),

                            Container(
                              width: 13,
                              height: 7,

                              decoration: BoxDecoration(
                                color:
                                    widget.accentColor.withOpacity(0.28),

                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // ==========================================================================
  // LOGO
  // ==========================================================================

  Widget _buildLogo() {
    // =========================================================================
    // EMPTY IMAGE
    // =========================================================================

    if (widget.imageUrl.trim().isEmpty) {
      return Icon(
        widget.fallbackIcon,
        size: 90,
        color: widget.accentColor,
      );
    }

    // =========================================================================
    // NETWORK IMAGE
    // =========================================================================

    return Image.network(
      widget.imageUrl,

      fit: BoxFit.contain,

      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: widget.accentColor,
          ),
        );
      },

      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        debugPrint(
          'Failed to load provider logo: ${widget.imageUrl}',
        );

        return Icon(
          widget.fallbackIcon,
          size: 90,
          color: widget.accentColor,
        );
      },
    );
  }
}

// ============================================================================
// COMBINED SERVICE INFORMATION PANEL
//
// DESIGN:
//
// ╭──────────────────────────────────────────╮
// │  RANGKAIAN       │   MASA PEMPROSESAN   │
// │  ● BAIK          │   ◷ LINK              │
// ╰──────────────────────────────────────────╯
//
// One panel.
// Two equal sections.
// Labels above.
// Values below.
// ============================================================================

class _ProviderServiceInfoPanel extends StatelessWidget {
  final ProviderNetworkStatus networkStatus;

  final String networkLabel;

  final String processingLabel;

  final String processingValue;

  final bool showProcessing;

  final Color accentColor;

  const _ProviderServiceInfoPanel({
    required this.networkStatus,
    required this.networkLabel,
    required this.processingLabel,
    required this.processingValue,
    required this.showProcessing,
    required this.accentColor,
  });

  // ==========================================================================
  // NETWORK CONFIG
  // ==========================================================================

  _NetworkVisualData _getNetworkVisualData(
    BuildContext context,
  ) {
    final loc = AppLocalizations.of(context)!;

    switch (networkStatus) {
      // ======================================================================
      // LOADING
      // ======================================================================

      case ProviderNetworkStatus.loading:
        return _NetworkVisualData(
          text: loc.networkStatusChecking,

          color: const Color(
            0xFF52667C,
          ),

          softColor: const Color(
            0xFFE9EEF3,
          ),
        );

      // ======================================================================
      // HEALTHY
      // ======================================================================

      case ProviderNetworkStatus.healthy:
        return _NetworkVisualData(
          text: loc.networkStatusGood,

          color: const Color(
            0xFF078345,
          ),

          softColor: const Color(
            0xFFE3F6EB,
          ),
        );

      // ======================================================================
      // INTERRUPTION
      // ======================================================================

      case ProviderNetworkStatus.interruption:
        return _NetworkVisualData(
          text: loc.networkStatusSlow,

          color: const Color(
            0xFFB76500,
          ),

          softColor: const Color(
            0xFFFFEED6,
          ),
        );

      // ======================================================================
      // UNAVAILABLE
      // ======================================================================

      case ProviderNetworkStatus.unavailable:
        return _NetworkVisualData(
          text: loc.networkStatusUnknown,

          color: const Color(
            0xFF66717D,
          ),

          softColor: const Color(
            0xFFEAEDF0,
          ),
        );
    }
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final _NetworkVisualData network =
        _getNetworkVisualData(context);

    final Color processingSoftColor =
        Color.lerp(
              accentColor,
              Colors.white,
              0.87,
            ) ??
            const Color(0xFFF2F5F8);

    return Container(
      width: double.infinity,

      // =========================================================================
      // HEIGHT
      // =========================================================================

      constraints: const BoxConstraints(
        minHeight: 88,
      ),

      // =========================================================================
      // BACKGROUND
      // =========================================================================

      decoration: BoxDecoration(
        color: const Color(
          0xFFF8FAFC,
        ),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: const Color(
            0xFFD9E1EA,
          ),

          width: 1.5,
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF173A66,
            ).withOpacity(0.055),

            blurRadius: 12,

            offset: const Offset(
              0,
              5,
            ),
          ),
        ],
      ),

      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // =================================================================
            // NETWORK
            // =================================================================

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  13,
                  13,
                  13,
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // =========================================================
                    // NETWORK LABEL
                    // =========================================================

                    Text(
                      networkLabel.toUpperCase(),

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Color(
                          0xFF6F7C8D,
                        ),

                        fontSize: 13,

                        fontWeight: FontWeight.w800,

                        letterSpacing: 0.55,

                        height: 1.0,
                      ),
                    ),

                    const SizedBox(height: 9),

                    // =========================================================
                    // NETWORK VALUE
                    // =========================================================

                    Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        // =====================================================
                        // LOADING
                        // =====================================================

                        if (networkStatus ==
                            ProviderNetworkStatus.loading)
                          Container(
                            width: 25,
                            height: 25,

                            padding: const EdgeInsets.all(5),

                            decoration: BoxDecoration(
                              color: network.softColor,

                              shape: BoxShape.circle,
                            ),

                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,

                              color: network.color,
                            ),
                          )

                        // =====================================================
                        // STATUS DOT
                        // =====================================================

                        else
                          Container(
                            width: 13,
                            height: 13,

                            decoration: BoxDecoration(
                              color: network.color,

                              shape: BoxShape.circle,

                              boxShadow: [
                                BoxShadow(
                                  color:
                                      network.color.withOpacity(0.28),

                                  blurRadius: 6,

                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(width: 9),

                        // =====================================================
                        // STATUS TEXT
                        // =====================================================

                        Flexible(
                          child: Text(
                            network.text.toUpperCase(),

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              color: network.color,

                              fontSize: 20,

                              fontWeight: FontWeight.w900,

                              height: 1.0,

                              letterSpacing: 0.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // =================================================================
            // DIVIDER
            // =================================================================

            if (showProcessing)
              Container(
                width: 1.5,

                margin: const EdgeInsets.symmetric(
                  vertical: 14,
                ),

                decoration: BoxDecoration(
                  color: const Color(
                    0xFFD7DFE8,
                  ),

                  borderRadius: BorderRadius.circular(20),
                ),
              ),

            // =================================================================
            // PROCESSING TIME
            // =================================================================

            if (showProcessing)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    15,
                    13,
                    14,
                    13,
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // =======================================================
                      // PROCESSING LABEL
                      // =======================================================

                      Text(
                        processingLabel.toUpperCase(),

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Color(
                            0xFF6F7C8D,
                          ),

                          fontSize: 12,

                          fontWeight: FontWeight.w800,

                          letterSpacing: 0.35,

                          height: 1.0,
                        ),
                      ),

                      const SizedBox(height: 9),

                      // =======================================================
                      // PROCESSING VALUE
                      // =======================================================

                      Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          // ===================================================
                          // CLOCK ICON
                          // ===================================================

                          Container(
                            width: 27,
                            height: 27,

                            decoration: BoxDecoration(
                              color: processingSoftColor,

                              shape: BoxShape.circle,
                            ),

                            child: Icon(
                              Icons.schedule_rounded,

                              color: accentColor,

                              size: 18,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // ===================================================
                          // VALUE
                          // ===================================================

                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,

                              child: Text(
                                processingValue.toUpperCase(),

                                maxLines: 1,

                                style: const TextStyle(
                                  color: Color(
                                    0xFF25384D,
                                  ),

                                  fontSize: 19,

                                  fontWeight: FontWeight.w900,

                                  height: 1.0,

                                  letterSpacing: 0.10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// NETWORK VISUAL DATA
// ============================================================================

class _NetworkVisualData {
  final String text;

  final Color color;

  final Color softColor;

  const _NetworkVisualData({
    required this.text,
    required this.color,
    required this.softColor,
  });
}

// ============================================================================
// PUBLIC NETWORK STATUS BADGE
//
// IMPORTANT:
// Keep this because some of your other pages may use
// ProviderNetworkStatusBadge directly.
//
// Its functionality remains available even though ModernProviderCard now uses
// the combined information panel.
// ============================================================================

class ProviderNetworkStatusBadge extends StatelessWidget {
  final ProviderNetworkStatus status;

  final String label;

  const ProviderNetworkStatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    late final String statusText;

    late final Color textColor;

    late final Color backgroundColor;

    late final Color borderColor;

    late final IconData icon;

    switch (status) {
      // ======================================================================
      // LOADING
      // ======================================================================

      case ProviderNetworkStatus.loading:
        statusText = loc.networkStatusChecking;

        textColor = const Color(
          0xFF5D6877,
        );

        backgroundColor = const Color(
          0xFFF3F5F7,
        );

        borderColor = const Color(
          0xFFD7DDE3,
        );

        icon = Icons.sync_rounded;

        break;

      // ======================================================================
      // HEALTHY
      // ======================================================================

      case ProviderNetworkStatus.healthy:
        statusText = loc.networkStatusGood;

        textColor = const Color(
          0xFF08783E,
        );

        backgroundColor = const Color(
          0xFFE7F8EE,
        );

        borderColor = const Color(
          0xFFA8E1C0,
        );

        icon = Icons.check_circle_rounded;

        break;

      // ======================================================================
      // INTERRUPTION
      // ======================================================================

      case ProviderNetworkStatus.interruption:
        statusText = loc.networkStatusSlow;

        textColor = const Color(
          0xFFB65D00,
        );

        backgroundColor = const Color(
          0xFFFFF1DD,
        );

        borderColor = const Color(
          0xFFF1C98C,
        );

        icon = Icons.warning_amber_rounded;

        break;

      // ======================================================================
      // UNAVAILABLE
      // ======================================================================

      case ProviderNetworkStatus.unavailable:
        statusText = loc.networkStatusUnknown;

        textColor = const Color(
          0xFF59616B,
        );

        backgroundColor = const Color(
          0xFFF0F1F3,
        );

        borderColor = const Color(
          0xFFD0D4D9,
        );

        icon = Icons.help_outline_rounded;

        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 11,
      ),

      decoration: BoxDecoration(
        color: backgroundColor,

        borderRadius: BorderRadius.circular(100),

        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          // ==================================================================
          // ICON
          // ==================================================================

          if (status == ProviderNetworkStatus.loading)
            SizedBox(
              width: 19,
              height: 19,

              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: textColor,
              ),
            )
          else
            Icon(
              icon,
              size: 21,
              color: textColor,
            ),

          const SizedBox(width: 8),

          // ==================================================================
          // TEXT
          // ==================================================================

          Flexible(
            child: Text(
              '$label: $statusText'.toUpperCase(),

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                color: textColor,

                fontSize: 17,

                fontWeight: FontWeight.w900,

                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}