import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';

/// Call MediaKit.ensureInitialized() once in main(), before runApp().
class PaymentVideoGuide extends StatefulWidget {
  const PaymentVideoGuide({super.key});

  @override
  State<PaymentVideoGuide> createState() => _PaymentVideoGuideState();
}

class _PaymentVideoGuideState extends State<PaymentVideoGuide> {
  late final Player _player = Player();
  late final VideoController _controller = VideoController(_player);

  // 0 = DuitNow QR, 1 = Card
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _play(0);
  }

  Future<void> _play(int index) async {
    if (_selected == index && _player.state.playing) return;

    setState(() => _selected = index);

    final name = index == 0
        ? 'duitnow_video.mp4'
        : 'card_payment_video.mp4';

    try {
      await _player.setPlaylistMode(PlaylistMode.single);
      await _player.open(
        Media('asset:///lib/videos/$name'),
        play: true,
      );
    } catch (error) {
      debugPrint('Payment tutorial video could not be opened: $error');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    const blue = Color(0xFF0759C9);
    const darkBlue = Color(0xFF12365F);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFE),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x330B2547),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F0FF),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline_rounded,
                    color: blue,
                    size: 37,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.paymentGuideTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  loc.paymentGuideSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF60738C),
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 22),

                // Tutorial selection
                Row(
                  children: [
                    Expanded(
                      child: _methodButton(
                        index: 0,
                        label: loc.paymentGuideQr,
                        icon: Icons.qr_code_rounded,
                        blue: blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _methodButton(
                        index: 1,
                        label: loc.paymentGuideCard,
                        icon: Icons.credit_card_rounded,
                        blue: blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Fixed video proportion prevents the large black area.
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ColoredBox(
                      color: Colors.black,
                      child: IgnorePointer(
                        child: Video(
                          controller: _controller,
                          fit: BoxFit.contain,
                          controls: NoVideoControls,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                SizedBox(
                  width: 270,
                  height: 66,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      loc.paymentGuideOk,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
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

  Widget _methodButton({
    required int index,
    required String label,
    required IconData icon,
    required Color blue,
  }) {
    final selected = _selected == index;

    return SizedBox(
      height: 72,
      child: FilledButton.icon(
        onPressed: () => _play(index),
        style: FilledButton.styleFrom(
          backgroundColor: selected
              ? blue
              : const Color(0xFFE8F0FC),
          foregroundColor: selected
              ? Colors.white
              : const Color(0xFF1555A3),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: selected
                  ? blue
                  : const Color(0xFFCBDCF2),
              width: 2,
            ),
          ),
        ),
        icon: Icon(icon, size: 27),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}