import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/telco/ptelco4.dart';
import 'package:frontend_v1/pages/bil/telco/services/ptelcoprovider3.dart';

class PMOBILEPIN3PAGE extends StatelessWidget {
  const PMOBILEPIN3PAGE({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    return PTELCOPROVIDER3PAGE(
      serviceLabel:
          loc.mobilePinServiceLabel,

      title:
          loc.mobilePinProviderTitle,

      subtitle:
          loc.mobilePinProviderSubtitle,

      headerIcon:
          Icons.phone_android_rounded,

      headerColor:
          const Color(
        0xFF1769D2,
      ),

      // ================================================================
      // IMPORTANT
      //
      // No provider list anymore.
      //
      // Provider codes come from /v2/catalog.
      // ================================================================

      categoryId:
          'MOBILE_PIN',

      inputType:
          TelcoInputType.mobilePin,
    );
  }
}