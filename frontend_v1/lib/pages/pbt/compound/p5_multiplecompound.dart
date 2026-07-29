import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/compound/kesalahan_controller.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/model/compound/multi_compound_model.dart';
import 'package:frontend_v1/controllers/compound/multiple_compound_controller.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';
import 'package:frontend_v1/pages/payment/payment.dart';

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
    final loc = AppLocalizations.of(context)!;

    if (loading) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/images/pnew.png"),
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

    if (compounds.isEmpty) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/images/pnew.png"),
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
                      color: const Color(0xFF0359D2).withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.gavel_rounded,
                      size: 76,
                      color: Color(0xFF0359D2),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    loc.alertNoCompoundRecord,
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

    final screenWidth = MediaQuery.of(context).size.width;
    final rowTextSize = screenWidth >= 900 ? 25.0 : 14.0;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
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
                          color: const Color(0xFF0D47A1).withOpacity(0.25),
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
                            Icons.gavel_rounded,
                            color: Colors.white,
                            size: 58,
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.p5MultiCompoundTitle,
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
                                loc.p5MultiCompoundSubtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.90),
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
                                "${selectedCompounds.length}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                loc.total,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.90),
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
                                  itemCount: compounds.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (_, index) {
                                    return _compoundRow(
                                      compounds[index],
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                "${selectedCompounds.length} ${loc.compoundButton}",
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
                          "RM ${total.toStringAsFixed(2)}",
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
                          onChanged: compounds.isEmpty
                              ? null
                              : (value) => _toggleSelectAll(value ?? false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectAll
                              ? loc.multiCompoundUnselectAll
                              : loc.multiCompoundSelectAll,
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
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => P4PAGE(
                                    title: loc.multicompoundTitle,
                                    type: "PBT",
                                    hint: loc.inputPlateHint,
                                    biz: "MULTICOMPOUND",
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 42,
                            ),
                            label: Text(
                              loc.backButton,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                height: 1.05,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE0E0E0),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              side: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
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
                              backgroundColor: const Color(0xFF16813B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              side: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    loc.continueButton,
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
              loc.multiCompoundHeaderNo,
              fontSize,
            ),
          ),
          Expanded(
            flex: 24,
            child: _responsiveHeader(
              loc.multiCompoundHeaderOffense,
              fontSize,
            ),
          ),
          Expanded(
            flex: 16,
            child: _responsiveHeader(
              loc.multiCompoundHeaderDate,
              fontSize,
            ),
          ),
          Expanded(
            flex: 16,
            child: _responsiveHeader(
              loc.multiCompoundHeaderAmount,
              fontSize,
            ),
          ),
          Expanded(
            flex: 10,
            child: _responsiveHeader(
              loc.info,
              fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _compoundRow(
    MultiCompoundModel c,
    double fontSize,
  ) {
    final selected = selectedCompounds.contains(c.compoundNum);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          _toggleCompound(
            c.compoundNum,
            !selected,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.symmetric(vertical: 14),
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
                    duration: const Duration(milliseconds: 180),
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
                  c.compoundNum,
                  fontSize,
                  bold: true,
                ),
              ),

              Expanded(
                flex: 24,
                child: _responsiveCell(
                  c.perintah ?? "-",
                  fontSize,
                ),
              ),

              Expanded(
                flex: 16,
                child: _responsiveCell(
                  c.date ?? "-",
                  fontSize,
                ),
              ),

              Expanded(
                flex: 16,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE2F3E8)
                          : const Color(0xFFF1F7F3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "RM ${c.amount.toStringAsFixed(2)}",
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

              Expanded(
                flex: 10,
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      _showDetailPopup(c);
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1976D2).withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 31,
                        color: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 5),
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
      padding: const EdgeInsets.symmetric(horizontal: 5),
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
}
