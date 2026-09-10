import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/bil/telco/ptelco4.dart';
import 'package:frontend_v1/pages/bil/telco/services/ptelcoprovider3.dart';

class PTELCOBILL3PAGE extends StatelessWidget {
  const PTELCOBILL3PAGE({
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
          loc.telcoBillServiceLabel,

      title:
          loc.telcoBillProviderTitle,

      subtitle:
          loc.telcoBillProviderSubtitle,

      headerIcon:
          Icons.receipt_long_rounded,

      headerColor:
          const Color(
        0xFF15946B,
      ),

      // ================================================================
      // IMPORTANT
      //
      // No provider list anymore.
      //
      // Provider codes come from /v2/catalog.
      // ================================================================

      categoryId:
          'MOBILE_POSTPAID',

      inputType:
          TelcoInputType.billPayment,
    );
  }
}