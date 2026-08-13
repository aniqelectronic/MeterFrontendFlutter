//page for Telco Bill Payment


import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/telco/ptelco4.dart';
import 'package:frontend_v1/pages/bil/telco/services/ptelcoprovider3.dart';

class PTELCOBILL3PAGE extends StatelessWidget {
  const PTELCOBILL3PAGE({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return PTELCOPROVIDER3PAGE(
      serviceLabel: loc.telcoBillServiceLabel,
      title: loc.telcoBillProviderTitle,
      subtitle: loc.telcoBillProviderSubtitle,
      headerIcon: Icons.receipt_long_rounded,
      headerColor: const Color(0xFF15946B),

      inputType: TelcoInputType.billPayment,

      providers: const [
        TelcoProviderItem(
          productCode: 'CB',
          name: 'Celcom Postpaid',
          imageUrl:
              'https://dashboard.iimmpact.com/img/CB.png',
          accentColor: Color(0xFF1469E8),
          lightAccentColor: Color(0xFFE5F0FF),
        ),

        TelcoProviderItem(
          productCode: 'DB',
          name: 'Digi Postpaid',
          imageUrl:
              'https://dashboard.iimmpact.com/img/DB.png',
          accentColor: Color(0xFFFFB800),
          lightAccentColor: Color(0xFFFFF4D5),
        ),

        TelcoProviderItem(
          productCode: 'RB',
          name: 'RedOne Postpaid',
          imageUrl:
              'https://dashboard.iimmpact.com/img/RB.png',
          accentColor: Color(0xFFE53935),
          lightAccentColor: Color(0xFFFFE8E7),
        ),

        TelcoProviderItem(
          productCode: 'UB',
          name: 'U Mobile Postpaid',
          imageUrl:
              'https://dashboard.iimmpact.com/img/UB.png',
          accentColor: Color(0xFFE56B21),
          lightAccentColor: Color(0xFFFFECDD),
        ),

        TelcoProviderItem(
          productCode: 'XB',
          name: 'XOX Postpaid',
          imageUrl:
              'https://dashboard.iimmpact.com/img/XB.png',
          accentColor: Color(0xFF5F43B2),
          lightAccentColor: Color(0xFFEDE8FF),
        ),

        TelcoProviderItem(
          productCode: 'YESB',
          name: 'Yes Postpaid',
          imageUrl:
              'https://dashboard.iimmpact.com/img/YESB.png',
          accentColor: Color(0xFF15946B),
          lightAccentColor: Color(0xFFE2F7EF),
        ),
      ],
    );
  }
}