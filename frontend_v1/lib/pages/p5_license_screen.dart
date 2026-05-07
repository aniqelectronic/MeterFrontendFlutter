import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/license/license_model.dart';
import 'package:frontend_v1/controllers/license/license_service.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/payment.dart';

class P5LicenseScreen extends StatefulWidget {
  final String ownerIC;

  const P5LicenseScreen({super.key, required this.ownerIC});

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
        .where((l) => selectedLicenses.contains(l.licenseNo))
        .fold(0.0, (sum, l) => sum + l.amount);

    LicenseModel.totalAmount = total;
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;
      selectedLicenses =
          value ? licenses.map((l) => l.licenseNo).toSet() : {};
      _updateTotal();
    });
  }

  void _toggleLicense(String licenseNo, bool value) {
    setState(() {
      value
          ? selectedLicenses.add(licenseNo)
          : selectedLicenses.remove(licenseNo);
      selectAll = selectedLicenses.length == licenses.length;
      _updateTotal();
    });
  }

  void _proceed() {
    if (selectedLicenses.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.licenseAlertTitle),
          content:
              Text(AppLocalizations.of(context)!.licenseAlertSelectAtLeastOne),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
      return;
    }

    final licensesList = selectedLicenses
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.trim())
        .toList();

    LicenseService.setSelectedLicenses(licensesList);

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/payment'),
        builder: (_) => PAYMENTPAGE(
          biz: "LESEN",
          data: PaymentData(
            biz: "LESEN",
            amount: total.toStringAsFixed(2),
            licenseNos: licensesList,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    final titleSize = isWide ? 80.0 : 30.0;
    final subtitleSize = isWide ? 40.0 : 18.0;
    final rowTextSize = isWide ? 30.0 : 12.0;
    final totalSize = isWide ? 40.0 : 20.0;
    final buttonTextSize = isWide ? 40.0 : 16.0;

    const double bottomPanelHeight = 800;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  Text(
                    AppLocalizations.of(context)!.p5LicenseTitle,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 3, 89, 210),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    AppLocalizations.of(context)!.p5LicenseSubtitle,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 50),

                  /// TABLE HEADER
                  _tableHeader(rowTextSize),

                  /// LIST
                  SizedBox(
                    height: MediaQuery.of(context).size.height -
                        bottomPanelHeight -
                        380,
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            thickness: 12,
                            radius: const Radius.circular(10),
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: licenses.length,
                              itemBuilder: (_, i) =>
                                  _licenseRow(licenses[i], rowTextSize),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          /// BOTTOM PANEL
          Positioned(
            bottom: 150,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  children: [
                    Transform.scale(
                      scale: 2,
                      child: Checkbox(
                        value: selectAll,
                        onChanged: (v) => _toggleSelectAll(v!),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        selectAll
                            ? AppLocalizations.of(context)!
                                .licenseUnselectAll
                            : AppLocalizations.of(context)!
                                .licenseSelectAll,
                        style: TextStyle(fontSize: rowTextSize,
                        fontWeight: FontWeight.bold,),
                      ),
                    ),
                    Text(
                      'RM ${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: totalSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _bigButton(
                        AppLocalizations.of(context)!.licenseBackButton,
                        Colors.grey.shade300,
                        buttonTextSize,
                        () => Navigator.pop(context),
                        textColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 100),
                    Expanded(
                      child: _bigButton(
                        AppLocalizations.of(context)!.licenseProceedButton,
                        Colors.green,
                        buttonTextSize,
                        _proceed,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                 Center(
                  child: Text(
                    Data.copyrightText,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= TABLE UI =================

  Widget _tableHeader(double fontSize) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0359D2).withOpacity(0.85),
            const Color(0xFF0359D2).withOpacity(0.65),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 80),
          _fixedHeader(
              AppLocalizations.of(context)!.licenseHeaderNo, 250, fontSize),
          _fixedHeader(
              AppLocalizations.of(context)!.licenseHeaderType, 250, fontSize),
          _fixedHeader(
              AppLocalizations.of(context)!.licenseHeaderEndDate, 220, fontSize),
          _fixedHeader(
              AppLocalizations.of(context)!.licenseHeaderAmount, 200, fontSize),
        ],
      ),
    );
  }

  Widget _fixedHeader(String text, double width, double size) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _licenseRow(LicenseModel license, double fontSize) {
    final selected = selectedLicenses.contains(license.licenseNo);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 16),
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8F1FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              selected ? const Color(0xFF0359D2) : Colors.black12,
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Center(
              child: Transform.scale(
                scale: 2.2,
                child: Checkbox(
                  value: selected,
                  activeColor: const Color(0xFF0359D2),
                  onChanged: (v) =>
                      _toggleLicense(license.licenseNo, v!),
                ),
              ),
            ),
          ),

          _fixedCell(license.licenseNo, 250, fontSize),
          _fixedCell(license.licenseType, 250, fontSize, wrap: true),
          _fixedCell(license.endDate.split('T')[0], 220, fontSize),

          SizedBox(
            width: 200,
            child: Center(
              child: Text(
                '${license.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: fontSize + 2,
                  fontWeight: FontWeight.bold,
                  color: selected
                      ? const Color(0xFF0359D2)
                      : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fixedCell(String text, double width, double size,
      {bool wrap = false}) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          softWrap: wrap,
          maxLines: wrap ? null : 1,
          overflow: wrap ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _bigButton(
    String text,
    Color color,
    double fontSize,
    VoidCallback onTap, {
    required Color textColor,
  }) {
    return SizedBox(
      height: 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          side: const BorderSide(color: Colors.black, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
