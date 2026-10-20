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


  static const Color _blue = Color(0xFF1976D2);
  static const Color _deepBlue = Color(0xFF0D47A1);
  static const Color _green = Color(0xFF16813B);
  static const Color _ink = Color(0xFF203044);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('lib/images/pnew.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: loading
              ? const Center(child: CircularProgressIndicator(color: _blue, strokeWidth: 6))
              : Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    children: [
                      _header(loc),
                      const SizedBox(height: 8),
                      Expanded(child: _compoundPanel(loc)),
                      const SizedBox(height: 8),
                      _paymentFooter(loc),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _header(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_deepBlue, _blue, Color(0xFF42A5F5)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: _deepBlue.withOpacity(.27), blurRadius: 18, offset: const Offset(0, 7))],
      ),
      child: Row(children: [
        Container(width: 92, height: 92,
          decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 60)),
        const SizedBox(width: 18),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(loc.p5MultiCompoundTitle, maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 39, fontWeight: FontWeight.w900, height: 1.05)),
          const SizedBox(height: 8),
          Text(loc.p5MultiCompoundSubtitle, maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700, height: 1.15)),
        ])),
      ]),
    );
  }

  Widget _compoundPanel(AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.98),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF263849), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.13), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(children: [
        // Enlarged premium dashboard; the original top header is unchanged.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFF0F7FF), Colors.white]),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Container(
                width: 76, height: 76,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_deepBlue, _blue]),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.fact_check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(loc.p5MultiCompoundTitle, maxLines: 2,
                  style: const TextStyle(fontSize: 33, fontWeight: FontWeight.w900,
                    color: _ink, height: 1.08)),
                const SizedBox(height: 6),
                Text(loc.p5MultiCompoundSubtitle, maxLines: 3,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: Color(0xFF52667F), height: 1.15)),
              ])),
            ]),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Container(
                height: 142,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F7FF),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF90B2D7), width: 2),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(loc.compoundAvailableCountLabel, maxLines: 3,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                        color: Color(0xFF52667F), height: 1.1)),
                    const SizedBox(height: 7),
                    Text('${compounds.length}',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900,
                        color: _deepBlue, height: 1.05)),
                  ]),
              )),
              const SizedBox(width: 12),
              Expanded(child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: compounds.isEmpty ? null : () => _toggleSelectAll(!selectAll),
                  borderRadius: BorderRadius.circular(15),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 142,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: selectAll
                        ? [const Color(0xFF0D47A1), const Color(0xFF1565C0)]
                        : [const Color(0xFF1565C0), const Color(0xFF2196F3)]),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: _deepBlue, width: 2),
                      boxShadow: [BoxShadow(color: _blue.withOpacity(.22),
                        blurRadius: 9, offset: const Offset(0, 4))],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(selectAll ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                        size: 46, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(selectAll ? loc.multiCompoundUnselectAll : loc.multiCompoundSelectAll,
                        maxLines: 3, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900,
                          color: Colors.white, height: 1.05)),
                    ]),
                  ),
                ),
              )),
            ]),
          ]),
        ),
        Expanded(child: compounds.isEmpty
          ? Center(child: Text(loc.alertNoCompoundRecord, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)))
          : ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(const Color(0xFF202020)),
                trackColor: MaterialStateProperty.all(const Color(0xFFE2E6EB)),
                trackBorderColor: MaterialStateProperty.all(const Color(0xFF606873)),
              ),
              child: Scrollbar(controller: _scrollController, thumbVisibility: true,
                trackVisibility: true, thickness: 22, radius: const Radius.circular(12),
                child: ListView.separated(controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 12, 39, 14),
                  itemCount: compounds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 17),
                  itemBuilder: (_, index) => _compoundCard(compounds[index], loc)),
              ),
            )),
        if (compounds.length > 2)
          Container(margin: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFE5F1FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF82B3EA), width: 1.5)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.swipe_up_rounded, size: 34, color: _deepBlue),
              SizedBox(width: 6),
              Flexible(child: Text('Skrol untuk lihat kompaun lain', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23, color: _deepBlue, fontWeight: FontWeight.w900))),
              Icon(Icons.keyboard_double_arrow_down_rounded, size: 33, color: _deepBlue),
            ])),
      ]),
    );
  }

  Widget _compoundCard(MultiCompoundModel c, AppLocalizations loc) {
    final selected = selectedCompounds.contains(c.compoundNum);
    return AnimatedContainer(duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE7F2FF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? _blue : const Color(0xFF343E49), width: selected ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ]),
      child: Column(children: [
        Material(color: Colors.transparent, child: InkWell(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
          onTap: () => _toggleCompound(c.compoundNum, !selected),
          child: Padding(padding: const EdgeInsets.fromLTRB(15, 16, 15, 12),
            child: Column(children: [
              Row(children: [
                Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 53, color: selected ? _blue : const Color(0xFF849CB3)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(loc.multiCompoundHeaderNo.toUpperCase(),
                    style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Color(0xFF4D627B))),
                  Text(c.compoundNum, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 37, fontWeight: FontWeight.w900, color: _ink)),
                ])),
              ]),
              const SizedBox(height: 14),
              Container(width: double.infinity, padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: selected ? const Color(0xFFF6FAFF) : const Color(0xFFF1F5FA),
                  borderRadius: BorderRadius.circular(13)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _modernField(loc.multiCompoundHeaderOffense, c.perintah ?? '-')),
                  const SizedBox(width: 12),
                  Expanded(child: _modernField(loc.multiCompoundHeaderDate, c.date ?? '-')),
                ])),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(loc.multiCompoundHeaderAmount, maxLines: 2,
                  style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Color(0xFF53677D)))),
                const SizedBox(width: 8),
                Flexible(child: FittedBox(fit: BoxFit.scaleDown,
                  child: Text('RM ${c.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: _green)))),
              ]),
            ]),
          ),
        )),
        Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: SizedBox(width: double.infinity, height: 76,
            child: ElevatedButton.icon(
              onPressed: () => _showDetailPopup(c),
              icon: const Icon(Icons.info_outline_rounded, size: 36),
              label: Text(loc.detailCompoundText, maxLines: 2, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white,
                elevation: 2, side: const BorderSide(color: _deepBlue, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          )),
      ]),
    );
  }

  Widget _modernField(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), maxLines: 2,
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Color(0xFF4D627B))),
      const SizedBox(height: 6),
      Text(value, maxLines: 3, overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: _ink)),
    ]);
  }

  Widget _paymentFooter(AppLocalizations loc) {
    final canProceed = selectedCompounds.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.98),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF263849), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 16, offset: const Offset(0, 7))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7EF),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF9DC9AC), width: 1.6),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Container(
                width: 62, height: 62,
                decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 38),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(loc.totalPaymentAmount, maxLines: 2,
                  style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: _ink, height: 1.1)),
                const SizedBox(height: 5),
                Text(loc.compoundSelectedCount(selectedCompounds.length), maxLines: 3,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                    color: Color(0xFF285B3D), height: 1.12)),
              ])),
            ]),
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFA7CEB6), thickness: 1.5, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    loc.amountPayable.toUpperCase(),
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF41634F),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        'RM ${total.toStringAsFixed(2)}',
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 43,
                          fontWeight: FontWeight.w900,
                          color: _green,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: SizedBox(height: 100, child: ElevatedButton(
            onPressed: () { if (Navigator.of(context).canPop()) Navigator.of(context).pop(); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE9EDF2), foregroundColor: _ink,
              side: const BorderSide(color: Color(0xFF263849), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.arrow_back_rounded, size: 34),
              Text(loc.backButton, maxLines: 2, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
            ])))),
          const SizedBox(width: 12),
          Expanded(child: SizedBox(height: 100, child: ElevatedButton(
            onPressed: canProceed ? _proceed : null,
            style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFB6C1CA), disabledForegroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF263849), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.arrow_forward_rounded, size: 34),
              Text(loc.makePaymentButton, maxLines: 2, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
            ])))),
        ]),
      ]),
    );
  }

  void _showDetailPopup(MultiCompoundModel c) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFF263849), width: 1.5)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 740,
            maxHeight: MediaQuery.of(dialogContext).size.height * .88),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_deepBlue, _blue, Color(0xFF42A5F5)]),
                  borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.receipt_long_rounded, size: 45, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(loc.detailCompoundText, maxLines: 3,
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white))),
                ])),
              const SizedBox(height: 14),
              Flexible(child: SingleChildScrollView(
                child: Container(width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: const Color(0xFFF3F7FF),
                    borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    _largeDetailItem(loc.multiCompoundHeaderNo, c.compoundNum, Icons.confirmation_number_rounded),
                    _largeDetailItem(loc.multiCompoundHeaderOffense, c.offense ?? '-', Icons.gavel_rounded),
                    _largeDetailItem(loc.perintah, c.perintah ?? '-', Icons.rule_rounded),
                    _largeDetailItem(loc.multiCompoundHeaderDate, c.date ?? '-', Icons.calendar_month_rounded),
                    _largeDetailItem(loc.masa, c.time ?? '-', Icons.access_time_rounded),
                    _largeDetailItem(loc.multiCompoundHeaderAmount,
                      'RM ${c.amount.toStringAsFixed(2)}', Icons.payments_rounded, isAmount: true),
                  ])))),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 76,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close_rounded, size: 34),
                  label: Text(loc.closetext, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94B55),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                )),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _largeDetailItem(String label, String value, IconData icon, {bool isAmount = false}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 48, height: 48,
            decoration: const BoxDecoration(color: Color(0xFFE1EDFF), shape: BoxShape.circle),
            child: Icon(icon, color: _blue, size: 35)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(
            fontSize: 30, fontWeight: FontWeight.w900, color: _ink))),
        ]),
        const SizedBox(height: 7),
        Padding(padding: const EdgeInsets.only(left: 60),
          child: Text(value, style: TextStyle(fontSize: isAmount ? 38 : 30,
            fontWeight: isAmount ? FontWeight.w900 : FontWeight.w600,
            color: isAmount ? _green : const Color(0xFF26384D), height: 1.28))),
        const SizedBox(height: 10),
        const Divider(height: 1, color: Color(0xFFD7E2EF)),
      ]));
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
