import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/license/license_model.dart';
import 'package:frontend_v1/controllers/license/license_service.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/payment/payment.dart';

class P5LicenseScreen extends StatefulWidget {
  final String ownerIC;

  const P5LicenseScreen({
    super.key,
    required this.ownerIC,
  });

  @override
  State<P5LicenseScreen> createState() => _P5LicenseScreenState();
}

class _P5LicenseScreenState extends State<P5LicenseScreen> {
  final ScrollController _scrollController = ScrollController();

  List<LicenseModel> licenses = [];
  Set<String> selectedLicenses = {};
  bool selectAll = false;
  double total = 0.0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchLicenses();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchLicenses() async {
    final data = await LicenseService.getLicensesByIC(widget.ownerIC);

    if (!mounted) return;

    setState(() {
      licenses = data;
      loading = false;
    });
  }

  void _updateTotal() {
    total = licenses
        .where(
          (license) =>
              selectedLicenses.contains(license.licenseNo),
        )
        .fold(
          0.0,
          (sum, license) => sum + license.amount,
        );

    LicenseModel.totalAmount = total;
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;

      selectedLicenses = value
          ? licenses.map((license) => license.licenseNo).toSet()
          : {};

      _updateTotal();
    });
  }

  void _toggleLicense(
    String licenseNo,
    bool value,
  ) {
    setState(() {
      if (value) {
        selectedLicenses.add(licenseNo);
      } else {
        selectedLicenses.remove(licenseNo);
      }

      selectAll =
          licenses.isNotEmpty &&
          selectedLicenses.length == licenses.length;

      _updateTotal();
    });
  }

  void _proceed() {
    final loc = AppLocalizations.of(context)!;

    if (selectedLicenses.isEmpty) {
      _showAlert(
        loc.licenseAlertTitle,
        loc.licenseAlertSelectAtLeastOne,
      );
      return;
    }

    final licensesList = selectedLicenses
        .where((value) => value.trim().isNotEmpty)
        .map((value) => value.trim())
        .toList();

    LicenseService.setSelectedLicenses(licensesList);

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(
          name: '/payment',
        ),
        builder: (_) => PAYMENTPAGE(
          biz: 'LESEN',
          data: PaymentData(
            biz: 'LESEN',
            amount: total.toStringAsFixed(2),
            licenseNos: licensesList,
          ),
        ),
      ),
    );
  }

  void _showAlert(
    String title,
    String message,
  ) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Alert',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(
        milliseconds: 250,
      ),
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
                width: 800,
                padding: const EdgeInsets.fromLTRB(
                  50,
                  45,
                  50,
                  45,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: const Color(0xFF1976D2)
                        .withOpacity(0.25),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.30),
                      blurRadius: 35,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 135,
                      height: 135,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2)
                            .withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 82,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF143B67),
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: 115,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF525E6D),
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 38),
                    SizedBox(
                      width: double.infinity,
                      height: 95,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pop(dialogContext),
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 40,
                        ),
                        label: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20),
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
      },
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.88,
              end: 1,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final rowTextSize =
        screenWidth >= 900 ? 25.0 : 14.0;

    if (loading) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/pnew.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 7,
              color: Color(0xFF1976D2),
            ),
          ),
        ),
      );
    }

    if (licenses.isEmpty) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/pnew.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              width: 760,
              padding: const EdgeInsets.symmetric(
                horizontal: 45,
                vertical: 55,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.97),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: const Color(0xFFBBD9FF),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0359D2)
                          .withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.badge_rounded,
                      size: 76,
                      color: Color(0xFF0359D2),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    loc.alertNoLicenseRecord,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF163A65),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/pnew.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                35,
                40,
                35,
                470,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 38,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0D47A1),
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D47A1)
                              .withOpacity(0.25),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.badge_rounded,
                            color: Colors.white,
                            size: 58,
                          ),
                        ),

                        const SizedBox(width: 28),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.p5LicenseTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                loc.p5LicenseSubtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      Colors.white.withOpacity(0.90),
                                  fontSize: 29,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${selectedLicenses.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                loc.total,
                                style: TextStyle(
                                  color:
                                      Colors.white.withOpacity(0.90),
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.96),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Column(
                          children: [
                            _tableHeader(rowTextSize),
                            Expanded(
                              child: Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                thickness: 16,
                                radius: const Radius.circular(20),
                                child: ListView.separated(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    20,
                                    30,
                                    25,
                                  ),
                                  itemCount: licenses.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (_, index) {
                                    return _licenseRow(
                                      licenses[index],
                                      rowTextSize,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 35,
            right: 35,
            bottom: 80,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                30,
                24,
                30,
                28,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.98),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF1F8F4),
                          Color(0xFFE3F5E9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16813B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.amountPayable,
                                style: const TextStyle(
                                  color: Color(0xFF567064),
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${selectedLicenses.length} ${loc.licenseButton}',
                                style: const TextStyle(
                                  color: Color(0xFF273E34),
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          'RM ${total.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Color(0xFF16813B),
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.6,
                        child: Checkbox(
                          value: selectAll,
                          activeColor: const Color(0xFF1976D2),
                          onChanged: licenses.isEmpty
                              ? null
                              : (value) => _toggleSelectAll(
                                    value ?? false,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectAll
                              ? loc.licenseUnselectAll
                              : loc.licenseSelectAll,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2D3743),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 105,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 42,
                            ),
                            label: Text(
                              loc.licenseBackButton,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                height: 1.05,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFE0E0E0),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              side: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 50),

                      Expanded(
                        child: SizedBox(
                          height: 105,
                          child: ElevatedButton(
                            onPressed: _proceed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF16813B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              side: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    loc.licenseProceedButton,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      height: 1.05,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 42,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    Data.copyrightText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
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

  Widget _tableHeader(double fontSize) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      height: 105,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 90,
            child: Center(
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),

          Expanded(
            flex: 22,
            child: _responsiveHeader(
              loc.licenseHeaderNo,
              fontSize,
            ),
          ),

          Expanded(
            flex: 24,
            child: _responsiveHeader(
              loc.licenseHeaderType,
              fontSize,
            ),
          ),

          Expanded(
            flex: 18,
            child: _responsiveHeader(
              loc.licenseHeaderEndDate,
              fontSize,
            ),
          ),

          Expanded(
            flex: 18,
            child: _responsiveHeader(
              loc.licenseHeaderAmount,
              fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _licenseRow(
    LicenseModel license,
    double fontSize,
  ) {
    final selected =
        selectedLicenses.contains(license.licenseNo);

    final endDate = license.endDate.contains('T')
        ? license.endDate.split('T')[0]
        : license.endDate;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          _toggleLicense(
            license.licenseNo,
            !selected,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(
            minHeight: 120,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE7F2FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1565C0)
                  : Colors.black,
              width: selected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Center(
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 180),
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF1976D2)
                          : const Color(0xFFF1F4F8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF1976D2)
                            : const Color(0xFFB8C4D1),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      selected
                          ? Icons.check_rounded
                          : Icons.circle_outlined,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF7A8A9A),
                      size: 36,
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 22,
                child: _responsiveCell(
                  license.licenseNo,
                  fontSize,
                  bold: true,
                ),
              ),

              Expanded(
                flex: 24,
                child: _responsiveCell(
                  license.licenseType,
                  fontSize,
                ),
              ),

              Expanded(
                flex: 18,
                child: _responsiveCell(
                  endDate,
                  fontSize,
                ),
              ),

              Expanded(
                flex: 18,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE2F3E8)
                          : const Color(0xFFF1F7F3),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'RM ${license.amount.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: fontSize + 2,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF16813B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _responsiveHeader(
    String text,
    double fontSize,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _responsiveCell(
    String text,
    double fontSize, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold
                ? FontWeight.w800
                : FontWeight.w600,
            color: const Color(0xFF2D3743),
            height: 1.15,
          ),
        ),
      ),
    );
  }
}
