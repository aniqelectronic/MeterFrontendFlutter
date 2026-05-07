import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/compound/kesalahan_controller.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/model/compound/multi_compound_model.dart';
import 'package:frontend_v1/controllers/compound/multiple_compound_controller.dart';
import 'package:frontend_v1/pages/p4.dart';
import 'package:frontend_v1/pages/payment.dart';

class P5MULTIPLECompoundScreen extends StatefulWidget {
  final String plateNo;

  const P5MULTIPLECompoundScreen({super.key, required this.plateNo});

  @override
  State<P5MULTIPLECompoundScreen> createState() =>
      _P5MultipleCompoundScreenState();
}

class _P5MultipleCompoundScreenState extends State<P5MULTIPLECompoundScreen> {
  final ScrollController _scrollController = ScrollController();

  List<MultiCompoundModel> compounds = [];
  Set<String> selectedCompounds = {};
  bool selectAll = false;
  double total = 0.0;
  bool loading = true;

  static const double _noKompaunWidth = 280;

  @override
  void initState() {
    super.initState();
    _fetchCompounds();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCompounds() async {
    final success =
        await MultipleCompoundController.setPlateNumberMultiComp(widget.plateNo);
    if (!mounted) return;

    setState(() {
      compounds = success ? MultipleCompoundController.compoundList : [];
      loading = false;
    });
  }

  void _updateTotal() {
    total = compounds
        .where((c) => selectedCompounds.contains(c.compoundNum))
        .fold(0.0, (sum, c) => sum + c.amount);
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;
      selectedCompounds =
          value ? compounds.map((c) => c.compoundNum).toSet() : {};
      _updateTotal();
    });
  }

  void _toggleCompound(String compoundNo, bool value) {
    setState(() {
      value
          ? selectedCompounds.add(compoundNo)
          : selectedCompounds.remove(compoundNo);
      selectAll = selectedCompounds.length == compounds.length;
      _updateTotal();
    });
  }

  void _proceed() {
    if (selectedCompounds.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.alertTitle),
          content: Text(
            AppLocalizations.of(context)!
                .multiCompoundAlertSelectAtLeastOne,
          ),
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

    MultipleCompoundController.setSelectedCompounds(
      selectedCompounds.toList(),
      total,
    );

   Navigator.push(
     context,
     MaterialPageRoute(
      settings: const RouteSettings(name: '/payment'),
       builder: (_) => PAYMENTPAGE(
         biz: "MULTICOMPOUND",
         data: PaymentData(
           amount: total.toStringAsFixed(2),
           compoundNos: selectedCompounds.toList(),
         ),
       ),
     ),
   );

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    final titleSize = isWide ? 70.0 : 30.0;
    final subtitleSize = isWide ? 40.0 : 18.0;
    final rowTextSize = isWide ? 25.0 : 10.0;
    final totalSize = isWide ? 40.0 : 20.0;

    const double bottomPanelHeight = 800;


    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
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
                  const SizedBox(height: 80),

                  Text(
                    AppLocalizations.of(context)!.p5MultiCompoundTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 3, 89, 210),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    AppLocalizations.of(context)!.p5MultiCompoundSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 50),

                  _tableHeader(rowTextSize),

                  /// LIST
                  SizedBox(
                  height: MediaQuery.of(context).size.height
                      - bottomPanelHeight
                      - 250, // 👈 header + title + padding compensation
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 20,
                      radius: const Radius.circular(10),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: compounds.length,
                        itemBuilder: (_, i) =>
                            _compoundRow(compounds[i], rowTextSize),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// SELECT ALL + TOTAL + BUTTONS (same style as TAX)
          Positioned(
            bottom: 200,
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
                                .multiCompoundUnselectAll
                            : AppLocalizations.of(context)!
                                .multiCompoundSelectAll,
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
                        AppLocalizations.of(context)!.backButton,
                        Colors.grey.shade300,
                        rowTextSize,
                        () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => P4PAGE(
                              title: AppLocalizations.of(context)!
                                  .multicompoundTitle,
                              type:"PBT",
                              hint: AppLocalizations.of(context)!
                                  .inputPlateHint,
                              biz: "MULTICOMPOUND",
                            ),
                          ),
                        ),
                        textColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 100),
                    Expanded(
                      child: _bigButton(
                        AppLocalizations.of(context)!.continueButton,
                        Colors.green,
                        rowTextSize,
                        _proceed,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= TABLE =================

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
          AppLocalizations.of(context)!.multiCompoundHeaderNo,
          _noKompaunWidth,
          fontSize,
        ),
        _fixedHeader(
          AppLocalizations.of(context)!.multiCompoundHeaderOffense,
          250,
          fontSize,
        ),
        _fixedHeader(
          AppLocalizations.of(context)!.multiCompoundHeaderDate,
          160,
          fontSize,
        ),
        _fixedHeader(
          AppLocalizations.of(context)!.multiCompoundHeaderAmount,
          180,
          fontSize,
        ),
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


Widget _compoundRow(MultiCompoundModel c, double fontSize) {
  final selected = selectedCompounds.contains(c.compoundNum);

  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.symmetric(vertical: 16),
    constraints: const BoxConstraints(minHeight: 120),
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFE8F1FF) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: selected
            ? const Color(0xFF0359D2)
            : Colors.black12,
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
                _toggleCompound(c.compoundNum, v!),
          ),
        ),
      ),
    ),

    _fixedCell(c.compoundNum, 280, fontSize),
    _fixedCell(c.perintah ?? '-', 220, fontSize, wrap: true),
    _fixedCell(c.date ?? '-', 180, fontSize),

    SizedBox(
      width: 180,
      child: Center(
        child: Text(
          c.amount.toStringAsFixed(2),
          style: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),

    /// 👁️ ADD THIS
SizedBox(
  width: 90,
  child: Center(
    child: Tooltip(
      message: AppLocalizations.of(context)!.viewDetails, 
      textStyle: const TextStyle(fontSize: 18, color: Colors.white),
      decoration: BoxDecoration(
        color: const Color(0xFF0359D2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () => _showDetailPopup(c),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0359D2), Color(0xFF4A90E2)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              size: 34,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  ),
),
  ],
),
  );
}

void _showDetailPopup(MultiCompoundModel c) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            width: 900,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0359D2), Color(0xFF4A90E2)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long,
                          size: 40, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.detailCompoundText,
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// CONTENT BOX
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _modernDetailRow(
                        AppLocalizations.of(context)!.multiCompoundHeaderNo,
                        c.compoundNum,
                        Icons.confirmation_number,
                      ),
                      _modernDetailRow(
                        AppLocalizations.of(context)!.multiCompoundHeaderOffense,
                        c.offense ?? "-",
                        Icons.gavel,
                      ),
                      _modernDetailRow(
                        AppLocalizations.of(context)!.perintah,
                        c.perintah ?? "-",
                        Icons.rule,
                      ),
                      _modernDetailRow(
                        AppLocalizations.of(context)!.multiCompoundHeaderDate,
                        c.date ?? "-",
                        Icons.calendar_month,
                      ),
                      _modernDetailRow(
                        AppLocalizations.of(context)!.masa,
                        c.time ?? "-",
                        Icons.access_time,
                      ),
                      _modernDetailRow(
                        AppLocalizations.of(context)!.multiCompoundHeaderAmount,
                        "RM ${c.amount.toStringAsFixed(2)}",
                        Icons.payments,
                        bold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// CLOSE BUTTON
                SizedBox(
                  width: 250,
                  height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.close),
                    label: Text(
                      AppLocalizations.of(context)!.closetext,
                      style: const TextStyle(fontSize: 22),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _modernDetailRow(String label, String value, IconData icon,
    {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFF0359D2).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF0359D2), size: 24),
        ),
        const SizedBox(width: 15),

        SizedBox(
          width: 220,
          child: Text(
            "$label :",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? Colors.redAccent : Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _detailRow(String label, String? value, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        SizedBox(
          width: 250,
          child: Text(
            "$label :",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value ?? "-",
            style: TextStyle(
              fontSize: 28,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _fixedCell(
  String text,
  double width,
  double size, {
  bool wrap = false,
}) {
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
