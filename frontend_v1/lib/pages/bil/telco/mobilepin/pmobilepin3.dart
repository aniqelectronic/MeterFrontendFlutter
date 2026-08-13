import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/telco/ptelco4.dart';
import 'package:frontend_v1/pages/bil/telco/services/ptelcoprovider3.dart';

class PMOBILEPIN3PAGE extends StatelessWidget {
  const PMOBILEPIN3PAGE({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return PTELCOPROVIDER3PAGE(
      serviceLabel: loc.mobilePinServiceLabel,
      title: loc.mobilePinProviderTitle,
      subtitle: loc.mobilePinProviderSubtitle,
      headerIcon: Icons.phone_android_rounded,
      headerColor: const Color(0xFF1769D2),

      inputType: TelcoInputType.mobilePin,

      providers: const [
        TelcoProviderItem(
          productCode: 'CP',
          name: 'Celcom Pin',
          imageUrl:
              'https://dashboard.iimmpact.com/img/CP.png',
          accentColor: Color(0xFF1469E8),
          lightAccentColor: Color(0xFFE5F0FF),
        ),

        TelcoProviderItem(
          productCode: 'DIP',
          name: 'Digi Internet Pin',
          imageUrl:
              'https://dashboard.iimmpact.com/img/DIP.png',
          accentColor: Color(0xFFFFB800),
          lightAccentColor: Color(0xFFFFF4D5),
        ),

        TelcoProviderItem(
          productCode: 'DP',
          name: 'Digi Pin',
          imageUrl:
              'https://dashboard.iimmpact.com/img/DP.png',
          accentColor: Color(0xFFE5A100),
          lightAccentColor: Color(0xFFFFF4D5),
        ),

        TelcoProviderItem(
          productCode: 'MCP',
          name: 'HelloSim Pin',
          imageUrl:
              'https://dashboard.iimmpact.com/img/MCP.png',
          accentColor: Color(0xFF8A55D8),
          lightAccentColor: Color(0xFFF0E8FF),
        ),

        TelcoProviderItem(
          productCode: 'MP',
          name: 'Maxis Pin',
          imageUrl:
              'https://dashboard.iimmpact.com/img/MP.png',
          accentColor: Color(0xFF15946B),
          lightAccentColor: Color(0xFFE2F7EF),
        ),

        TelcoProviderItem(
          productCode: 'RP',
          name: 'RedOne Pin',
          imageUrl:
              'https://dashboard.iimmpact.com/img/RP.png',
          accentColor: Color(0xFFE53935),
          lightAccentColor: Color(0xFFFFE8E7),
        ),

        TelcoProviderItem(
          productCode: 'S',
          name: 'SpeakOut Pin',
          imageUrl:
              'https://dashboard.iimmpact.com/img/S.png',
          accentColor: Color(0xFF7356D8),
          lightAccentColor: Color(0xFFEDE9FF),
        ),

        TelcoProviderItem(
          productCode: 'TP',
          name: 'TuneTalk Pin',
          imageUrl:
              'https://dashboard.iimmpact.com/img/TP.png',
          accentColor: Color(0xFF15946B),
          lightAccentColor: Color(0xFFE2F7EF),
        ),

        TelcoProviderItem(
          productCode: 'UNP',
          name: 'Unifi Mobile Pin',
          imageUrl:
              'https://dashboard.iimmpact.com/img/UNP.png',
          accentColor: Color(0xFFD64D8B),
          lightAccentColor: Color(0xFFFFE6F2),
        ),

        TelcoProviderItem(
          productCode: 'UP',
          name: 'U Mobile Pin',
          imageUrl:
              'https://dashboard.iimmpact.com/img/UP.png',
          accentColor: Color(0xFFE56B21),
          lightAccentColor: Color(0xFFFFECDD),
        ),

        TelcoProviderItem(
          productCode: 'XP',
          name: 'XOX Pin',
          imageUrl:
              'https://dashboard.iimmpact.com/img/XP.png',
          accentColor: Color(0xFF5F43B2),
          lightAccentColor: Color(0xFFEDE8FF),
        ),

        TelcoProviderItem(
          productCode: 'YESP',
          name: 'Yes Pin',
          imageUrl:
              'https://dashboard.iimmpact.com/img/YESP.png',
          accentColor: Color(0xFF1687D9),
          lightAccentColor: Color(0xFFE3F3FF),
        ),
      ],
    );
  }
}