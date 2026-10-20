import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/taksiran/taksiran_service_bentong.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/pbt/newp4.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';
import 'package:frontend_v1/pages/payment/payment.dart';
import 'package:frontend_v1/model/taksiran/taksiran_payment_item.dart';
enum TaksiranPaymentPeriod { sepenggal, setahun }
class P5TaksiranBentongScreen extends StatefulWidget {
  const P5TaksiranBentongScreen({super.key});
  @override
  State<P5TaksiranBentongScreen> createState() =>
      _P5TaksiranBentongScreenState();
}
class _P5TaksiranBentongScreenState extends State<P5TaksiranBentongScreen> {
  static const _ink = Color(0xFF163A65);
  static const _muted = Color(0xFF52657A);
  static const _blue = Color(0xFF1976D2);
  static const _line = Color(0xFFB8CEE5);
  static const _green = Color(0xFF16813B);
  static const _pale = Color(0xFFE7F2FF);
  late final List<Map<String, dynamic>> _items;
  final Set<String> _selected = <String>{};
  TaksiranPaymentPeriod? _period;
  bool _openingPayment = false;
  int _stepIndex = 0;
  @override
  void initState() {
    super.initState();
    // Keep the existing API/service as the source of account records.
    _items = TaksiranServiceBentong.taksiranList
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  String _value(Map<String, dynamic> item, String key) {
    final text = item[key]?.toString().trim() ?? '';
    return _missing(text) ? '-' : text;
  }
  bool _missing(String value) =>
      ['', '-', 'null', 'n/a', 'none'].contains(value.trim().toLowerCase());
  String _address(Map<String, dynamic> item, List<String> keys) {
    final parts = keys.map((key) => _value(item, key))
        .where((value) => !_missing(value));
    return parts.isEmpty ? '-' : parts.join(', ');
  }
  String _propertyAddress(Map<String, dynamic> item) => _address(item, [
        'no_rumah', 'lorong_name', 'jalan_name', 'postcode',
        'prop_pekan_name', 'negeri',
      ]);
  // Use API totals directly. Never calculate setahun as 2 x sepenggal.
  // Missing/invalid amounts remain unavailable rather than becoming RM 0.00.
  int? _cents(Map<String, dynamic> item, String key) {
    final raw = item[key]?.toString().trim() ?? '';
    final number = double.tryParse(raw.replaceAll(',', ''));
    if (number == null || !number.isFinite || number < 0) return null;
    return (number * 100).round();
  }
  bool _accountHasPayment(Map<String, dynamic> item) {
    final half = _cents(item, 'jumlah_sepenggal');
    final year = _cents(item, 'jumlah_setahun');
    return (half != null && half > 0) || (year != null && year > 0);
  }
  bool _accountHasNoPayment(Map<String, dynamic> item) =>
      _cents(item, 'jumlah_sepenggal') == 0 &&
      _cents(item, 'jumlah_setahun') == 0;
  bool get _hasMixedPeriods => _selectedItems.length > 1 &&
      _periodTotal(TaksiranPaymentPeriod.sepenggal) == null &&
      _periodTotal(TaksiranPaymentPeriod.setahun) == null;
  Widget _notice(String message, {bool warning = true}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: warning ? const Color(0xFFFFF5E5) : const Color(0xFFEAF3FF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: warning ? const Color(0xFFE5C58D) : _line),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline_rounded,
        color: warning ? const Color(0xFF986000) : _blue, size: 30),
      const SizedBox(width: 10),
      Expanded(child: Text(message, style: _text(23,
        color: warning ? const Color(0xFF805000) : _ink,
        weight: FontWeight.w700))),
    ]),
  );
  String _rm(int cents) {
    final whole = (cents ~/ 100).toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',',
    );
    return 'RM $whole.${(cents % 100).toString().padLeft(2, '0')}';
  }
  String get _amountKey => _period == TaksiranPaymentPeriod.sepenggal
      ? 'jumlah_sepenggal' : 'jumlah_setahun';
  List<Map<String, dynamic>> get _selectedItems => _items
      .where((item) => _selected.contains(_value(item, 'account_no'))).toList();
  // Every selected account must have a positive amount for the SAME period.
  // Never combine Sepenggal from one account with Setahun from another.
  int? _periodTotal(TaksiranPaymentPeriod period) {
    if (_selectedItems.isEmpty) return null;
    final key = period == TaksiranPaymentPeriod.sepenggal
        ? 'jumlah_sepenggal' : 'jumlah_setahun';
    final amounts = _selectedItems.map((item) => _cents(item, key)).toList();
    if (amounts.any((value) => value == null)) return null;
    if (amounts.any((value) => value == 0) &&
        amounts.any((value) => value! > 0)) return null;
    return amounts.fold<int>(0, (sum, value) => sum + value!);
  }
  int? get _totalCents {
    if (_period == null) return null;
    var sum = 0;
    for (final item in _selectedItems) {
      final cents = _cents(item, _amountKey);
      if (cents == null || cents <= 0) return null;
      sum += cents;
    }
    return sum;
  }
  bool get _canContinue => !_openingPayment && _selected.isNotEmpty &&
      _period != null && (_totalCents ?? 0) > 0;
  String _periodLabel(AppLocalizations loc) =>
      _period == TaksiranPaymentPeriod.sepenggal
          ? loc.taksiranHalfYearAmount : loc.taksiranAnnualAmount;
  void _toggle(Map<String, dynamic> item) {
    if (_openingPayment || !_accountHasPayment(item)) return;
    final account = _value(item, 'account_no');
    if (_missing(account)) return;
    setState(() {
      if (!_selected.remove(account)) _selected.add(account);
      _period = null;
    });
  }
  // void _back() {
  //   if (_openingPayment) return;
  //   final loc = AppLocalizations.of(context)!;
  //   Navigator.pushReplacement(context, MaterialPageRoute(
  //     builder: (_) => NEWP4PAGE(
  //       title: loc.taksiranTitle, type: 'PBT',
  //       hint: loc.inputTaxHint, biz: 'CUKAI',
  //     ),
  //   ));
  // }

  void _back() {
    if (_openingPayment) return;
    if (_stepIndex == 1) {
      setState(() => _stepIndex = 0);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _proceed() async {
    if (!_canContinue) return;
    final cents = _totalCents!;
    final selectedItems = _selectedItems.map((item) => TaksiranPaymentItem(
      noPendaftaran: _value(item, 'pdaftaran'),
      accountNo: _value(item, 'account_no'),
      amount: _cents(item, _amountKey)! / 100.0,
      ownerName: _value(item, 'name'),
      propertyAddress: _propertyAddress(item),
    )).toList();
    setState(() => _openingPayment = true);
    try {
      await Navigator.push(context, MaterialPageRoute(
        settings: const RouteSettings(name: '/payment'),
        builder: (_) => PAYMENTPAGE(
          biz: 'CUKAI',
          data: PaymentData(
            amount: (cents / 100.0).toStringAsFixed(2),
            taksiranItems: selectedItems,
          ),
        ),
      ));
    } finally {
      if (mounted) setState(() => _openingPayment = false);
    }
  }
  TextStyle _text(double size, {Color color = _ink,
      FontWeight weight = FontWeight.w600}) =>
      TextStyle(fontSize: size, color: color, fontWeight: weight, height: 1.3);
  BoxDecoration _surface({bool selected = false}) => BoxDecoration(
    color: selected ? _pale : Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: selected ? _blue : _line,
        width: selected ? 3 : 1.5),
    boxShadow: const [BoxShadow(color: Color(0x0C17324D),
        blurRadius: 12, offset: Offset(0, 4))],
  );
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(
          image: AssetImage('lib/images/pnew.png'), fit: BoxFit.cover)),
        child: SafeArea(child: LayoutBuilder(builder: (context, size) {
          final pad = size.maxWidth < 600 ? 14.0 : 22.0;
          return AbsorbPointer(absorbing: _openingPayment, child: Padding(
            padding: EdgeInsets.all(pad), child: Column(children: [
              _header(loc), const SizedBox(height: 18),
              _progress(loc), const SizedBox(height: 20),
              Expanded(child: _stepIndex == 0
                ? _accountSelectionContent(loc)
                : _reviewContent(loc)),
              const SizedBox(height: 12), _newFooter(loc),
              const SizedBox(height: 8), _copyright(),
            ]),
          ));
        })),
      ),
    );
  }
  // Step 1: same scroll panel style as Sewaan PBT.
  // Keep the heading outside the scroll area; only account cards scroll.
  Widget _accountSelectionContent(AppLocalizations loc) => Column(children: [
    _accountHeading(loc),
    Expanded(child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF3FA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line, width: 1.5),
      ),
      child: _KioskScroll(
        key: const ValueKey('taksiran-account-scroll'),
        downLabel: loc.scrolldown,
        upLabel: loc.scrollup,
        scrollHint: loc.scrollForMoreInformation,
        children: [
          if (_items.isEmpty) _empty(loc),
          for (final item in _items) _accountCard(item, loc),
        ],
      ),
    )),
  ]);

  Widget _progress(AppLocalizations loc) => Row(children: [
    Expanded(child: _progressPart('1', loc.taksiranStepAccount, _stepIndex == 0)),
    const SizedBox(width: 14),
    Expanded(child: _progressPart('2', loc.taksiranStepPeriod, _stepIndex == 1)),
  ]);
  Widget _progressPart(String n, String label, bool active) => Container(
    height: 82, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: active ? _blue : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: active ? _blue : _line, width: 1.5),
      boxShadow: const [BoxShadow(color: Color(0x1516324D), blurRadius: 8, offset: Offset(0, 3))],
    ),
    child: Row(children: [
      CircleAvatar(radius: 18, backgroundColor: active ? Colors.white : _pale,
        child: Text(n, style: _text(25, color: _blue, weight: FontWeight.w800))),
      const SizedBox(width: 9),
      Expanded(child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis,
        style: _text(23, color: active ? Colors.white : _ink, weight: FontWeight.w800))),
    ]),
  );
Widget _reviewContent(AppLocalizations loc) => LayoutBuilder(
  builder: (context, constraints) {
    final manyAccounts = _selectedItems.length > 1;
    final largeText =
        MediaQuery.textScalerOf(context).scale(30) > 34.5;

    final fallback = constraints.maxHeight < 760 ||
        constraints.maxWidth < 650 ||
        largeText ||
        _hasMixedPeriods;

    // One account: cards fit their content.
    // Also allows scrolling if long text cannot fit the screen.
    if (!manyAccounts || fallback) {
      return _KioskScroll(
        key: const ValueKey('taksiran-review-natural'),
        downLabel: loc.scrolldown,
        upLabel: loc.scrollup,
        scrollHint: loc.scrollForMoreInformation,
        children: [
          _selectedSummary(loc),
          const SizedBox(height: 14),
          _periodPanel(loc),
          const SizedBox(height: 14),
          _paymentBreakdown(loc),
        ],
      );
    }

    // Multiple accounts: capped panels with independent scrolling.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: 5,
          fit: FlexFit.loose,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 340, // Maximum Akaun Dipilih card height.
            ),
            child: _selectedSummary(loc, bounded: true),
          ),
        ),
        const SizedBox(height: 14),

        _periodPanel(loc),

        const SizedBox(height: 14),
        if (_period == null)
          // No payment selected: show a compact instruction and total.
          _paymentBreakdown(loc)
        else
          Flexible(
            flex: 6,
            fit: FlexFit.loose,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 300, // Maximum Pecahan Bayaran card height.
              ),
              child: _paymentBreakdown(loc, bounded: true),
            ),
          ),
      ],
    );
  },
);

  Widget _selectedAccountRow(Map<String, dynamic> item) => Container(
    margin: const EdgeInsets.only(bottom: 10, right: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFFF1F7FE),
      borderRadius: BorderRadius.circular(14), border: Border.all(color: _line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_value(item, 'account_no'), style: _text(34, weight: FontWeight.w800)),
      Text(_value(item, 'name'), style: _text(29)),
      Text(_propertyAddress(item), style: _text(26, color: _muted)),
    ]),
  );

  Widget _selectedSummary(AppLocalizations loc, {bool bounded = false}) {
    final rows = [for (final item in _selectedItems) _selectedAccountRow(item)];
    return Container(
      padding: const EdgeInsets.all(16), decoration: _surface(),
      child: Column(mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(loc.taksiranSelectedAccountsTitle,
                style: _text(33, weight: FontWeight.w800))),
            TextButton(onPressed: () => setState(() => _stepIndex = 0),
              child: Text(loc.taksiranChangeAccounts,
                  style: _text(29, color: _blue))),
          ]),
          Text(loc.selectedAccountCount(_selected.length),
              style: _text(29, color: _muted)),
          const SizedBox(height: 10),
          if (bounded)
            Expanded(child: _ReviewList(
              key: const ValueKey('selected-account-list'),
              upLabel: loc.scrollup, downLabel: loc.scrolldown, children: rows,
            ))
          else ...rows,
        ],
      ),
    );
  }

  Widget _breakdownRow(Map<String, dynamic> item, AppLocalizations loc) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
    child: Wrap(alignment: WrapAlignment.spaceBetween,
      spacing: 16, runSpacing: 5, children: [
        Text(_value(item, 'account_no'), style: _text(30)),
        Text(_cents(item, _amountKey) == null
            ? loc.taksiranKioskAmountUnavailable : _rm(_cents(item, _amountKey)!),
            style: _text(31, color: _green, weight: FontWeight.w800)),
      ],
    ),
  );

  Widget _paymentBreakdown(AppLocalizations loc, {bool bounded = false}) {
    final rows = <Widget>[
      if (_period == null)
        Padding(padding: const EdgeInsets.only(right: 12, top: 8),
          child: Text(loc.taksiranSelectPeriodFirst, style: _text(27, color: _muted)))
      else
        for (final item in _selectedItems) _breakdownRow(item, loc),
    ];
    return Container(
      padding: const EdgeInsets.all(16), decoration: _surface(),
      child: Column(mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(loc.taksiranPaymentBreakdown,
              style: _text(34, weight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (bounded)
            Expanded(child: _ReviewList(
              key: const ValueKey('payment-breakdown-list'),
              upLabel: loc.scrollup, downLabel: loc.scrolldown, children: rows,
            ))
          else ...rows,
          const Divider(height: 16),
          // Total stays outside the scrollable account charges.
          Wrap(alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14, runSpacing: 4, children: [
              Text(loc.amountPayable, style: _text(29, weight: FontWeight.w700)),
              Text(_totalCents == null ? '—' : _rm(_totalCents!),
                  style: _text(42, color: _green, weight: FontWeight.w900)),
            ],
          ),
          if (_period != null && _totalCents == null)
            Text(loc.taksiranKioskInvalidSelection,
                style: _text(29, color: Colors.deepOrange)),
        ],
      ),
    );
  }
  Widget _newFooter(AppLocalizations loc) => Container(
    padding: const EdgeInsets.all(14), decoration: _surface(),
    child: Column(children: [
      if (_stepIndex == 0) Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(_selected.isEmpty ? loc.taksiranSelectAlert
          : loc.selectedAccountCount(_selected.length),
          style: _text(30, color: _ink, weight: FontWeight.w800)),
      ),
      Row(children: [
        Expanded(child: _action(loc.back.toUpperCase(), Icons.arrow_back_rounded,
          _openingPayment ? null : _back, primary: false)),
        const SizedBox(width: 12),
        Expanded(child: _action(
          _stepIndex == 0 ? loc.continueText : loc.paymenttax,
          Icons.arrow_forward_rounded,
          _stepIndex == 0
            ? (_selected.isEmpty ? null : () => setState(() { _stepIndex = 1; _period = null; }))
            : (_canContinue ? _proceed : null),
        )),
      ]),
    ]),
  );
  Widget _copyright() => Text(
    Data.copyrightText,
    textAlign: TextAlign.center,
    style: _text(18, color: const Color(0xFF26364A), weight: FontWeight.w800),
  );
  Widget _header(AppLocalizations loc) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)]),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [BoxShadow(color: Color(0x2616324D), blurRadius: 14, offset: Offset(0, 5))],
    ),
    child: Row(children: [
      Container(width: 64, height: 64, alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0x2BFFFFFF),
          border: Border.all(color: const Color(0x55FFFFFF)),
          borderRadius: BorderRadius.circular(17)),
        child: const Icon(Icons.home_work_outlined, color: Colors.white, size: 39)),
      const SizedBox(width: 18),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(loc.taksiranTitle, style: _text(35, color: Colors.white, weight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(loc.taksiranKioskIntro, style: _text(25, color: const Color(0xFFEAF4FF))),
      ])),
    ]),
  );
  Widget _step(String number, String title) => Row(children: [
    Container(width: 36, height: 36, alignment: Alignment.center,
      decoration: const BoxDecoration(color: _blue, shape: BoxShape.circle),
      child: Text(number, style: _text(30, color: Colors.white)),
    ),
    const SizedBox(width: 12),
    Expanded(child: Text(title, style: _text(32, weight: FontWeight.w800))),
  ]);
  Widget _accountHeading(AppLocalizations loc) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: _surface(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _step('1', loc.taksiranKioskChooseAccounts),
      const SizedBox(height: 5),
      Text(loc.taksiranKioskAccountHint, style: _text(27, color: _muted)),
    ]),
  );
  Widget _empty(AppLocalizations loc) => Container(
    padding: const EdgeInsets.all(32), decoration: _surface(),
    child: Column(children: [
      const Icon(Icons.search_off_rounded, size: 64, color: _muted),
      const SizedBox(height: 18),
      Text(loc.taksiranNoData, textAlign: TextAlign.center, style: _text(26)),
    ]),
  );
  Widget _accountCard(Map<String, dynamic> item, AppLocalizations loc) {
    final account = _value(item, 'account_no');
    final selected = _selected.contains(account);
    final valid = !_missing(account) && _accountHasPayment(item);
    final address = _propertyAddress(item);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 10),
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEAF4FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? const Color(0xFF1976D2)
                : const Color(0xFFD5E2EF),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0x281976D2)
                  : const Color(0x2416324D),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Semantics(
                label: '${loc.accountNo} $account', checked: selected,
                enabled: valid, onTap: valid ? () => _toggle(item) : null,
                child: InkWell(
                  excludeFromSemantics: true,
                  onTap: valid ? () => _toggle(item) : null,
                  splashColor: const Color(0x301976D2),
                  highlightColor: const Color(0x181976D2),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Icon(
                            !valid ? Icons.block_rounded
                                : selected ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            size: 54, color: valid ? _blue : _muted),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(loc.accountNo, style: _text(26, color: _muted)),
                            Text(account, style: _text(38,
                                weight: FontWeight.w800)),
                            if (!_missing(_value(item, 'name'))) ...[
                              const SizedBox(height: 5),
                              Text(_value(item, 'name'), style: _text(29)),
                            ],
                            if (!_missing(address)) ...[
                              const SizedBox(height: 5),
                              Text(address, style: _text(27, color: _muted)),
                            ],
                            const SizedBox(height: 16),

                            Wrap(
                              spacing: 32,
                              runSpacing: 16,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.startDate,
                                      style: _text(26, color: _muted),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _value(item, 'start_date'),
                                      style: _text(
                                        30,
                                        color: _ink,
                                        weight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.endDate,
                                      style: _text(26, color: _muted),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _value(item, 'end_date'),
                                      style: _text(
                                        30,
                                        color: _ink,
                                        weight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(builder: (context, constraints) {
                  final amounts = [
                    _amountTile(loc.taksiranHalfYearAmount,
                        _cents(item, 'jumlah_sepenggal'), loc),
                    _amountTile(loc.taksiranAnnualAmount,
                        _cents(item, 'jumlah_setahun'), loc),
                  ];
                  if (constraints.maxWidth < 450) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [amounts[0], const SizedBox(height: 8), amounts[1]]);
                  }
                  return Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Expanded(child: amounts[0]),
                      const SizedBox(width: 12), Expanded(child: amounts[1])]);
                }),
              ),
              if (!_accountHasPayment(item))
                Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _notice(_accountHasNoPayment(item)
                    ? loc.taksiranAccountNoPayment
                    : loc.taksiranAccountAmountUnavailable)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Align(alignment: Alignment.centerRight,
                  child: TextButton.icon(
                      onPressed: () => _showDetails(item),
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        size: 32,
                      ),
                      label: Text(
                        loc.taksiranKioskViewDetails,
                        style: _text(
                          28,
                          color: _blue,
                          weight: FontWeight.w800,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: _blue,
                        minimumSize: const Size(0, 72),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                ),
              ),
            ],
            ),
          ),
          ),
        ),
      ),
    );
  }
Widget _amountTile(
  String label,
  int? cents,
  AppLocalizations loc,
) => Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: const Color(0xFFF0F8F3),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: const Color(0xFFC7DECF),
      width: 1,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: _text(26, color: _muted)),
      const SizedBox(height: 3),
      Text(
        cents == null
            ? loc.taksiranKioskAmountUnavailable
            : _rm(cents),
        style: _text(
          34,
          color: const Color(0xFF16813B),
          weight: FontWeight.w800,
        ),
      ),
    ],
  ),
);
  Widget _periodPanel(AppLocalizations loc) => Container(
    padding: const EdgeInsets.all(22), decoration: _surface(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _step('2', loc.taksiranChoosePaymentAmount),
      const SizedBox(height: 5),
      Text(loc.taksiranChoosePaymentHint, style: _text(26, color: _muted)),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, constraints) {
        final half = _periodOption(TaksiranPaymentPeriod.sepenggal,
            loc.taksiranHalfYearAmount);
        final year = _periodOption(TaksiranPaymentPeriod.setahun,
            loc.taksiranAnnualAmount);
        if (constraints.maxWidth < 450) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [half, const SizedBox(height: 10), year]);
        }
        return IntrinsicHeight(child: Row(children: [
          Expanded(child: half), const SizedBox(width: 12),
          Expanded(child: year),
        ]));
      }),
      if (_hasMixedPeriods) ...[
        const SizedBox(height: 14),
        _notice(loc.taksiranMixedPeriodWarning),
      ],
    ]),
  );
Widget _periodOption(TaksiranPaymentPeriod period, String label) {
  final loc = AppLocalizations.of(context)!;
  final cents = _periodTotal(period);
  final available = cents != null && cents > 0;
  final selected = _period == period;

  final amountText = cents == null
      ? (_hasMixedPeriods ? loc.taksiranCannotSelect : loc.taksiranKioskAmountUnavailable)
      : cents == 0
          ? loc.taksiranNoPayment
          : _rm(cents);

  final statusText = cents == null
      ? (_hasMixedPeriods ? loc.taksiranMixedPeriodShort : loc.taksiranPaymentUnavailable)
      : cents == 0
          ? loc.taksiranCannotSelect
          : selected
              ? loc.taksiranPaymentSelected
              : loc.taksiranSelectToPay;

  return Semantics(
    label: '$label, $amountText',
    checked: selected,
    enabled: available,
    inMutuallyExclusiveGroup: true,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: selected
                ? const Color(0x3516813B)
                : const Color(0x25163A65),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: selected
            ? const Color(0xFFE3F5E9)
            : available
                ? const Color(0xFFEAF3FF)
                : const Color(0xFFF0F2F4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? _green : available ? _blue : _line,
            width: selected ? 3 : 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: !available || _openingPayment
              ? null
              : () => setState(() => _period = period),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 175),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        period == TaksiranPaymentPeriod.sepenggal
                            ? Icons.receipt_long_rounded
                            : Icons.calendar_month_rounded,
                        color: available
                            ? selected ? _green : _blue
                            : _muted,
                        size: 36,
                      ),
                      const Spacer(),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : available
                                ? Icons.radio_button_unchecked_rounded
                                : Icons.block_rounded,
                        color: selected ? _green : _muted,
                        size: 34,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: _text(27, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 7),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      amountText,
                      style: _text(
                        36,
                        color: selected
                            ? _green
                            : available ? _ink : _muted,
                        weight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    statusText,
                    style: _text(
                      21,
                      color: selected ? _green : _muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
  Widget _footer(AppLocalizations loc) {
    String? hint;
    if (_items.isNotEmpty) {
      if (_selected.isEmpty) {
        hint = loc.taksiranSelectAlert;
      } else if (_period == null) {
        hint = loc.taksiranKioskPeriodRequired;
      } else if (_totalCents == null) {
        hint = loc.taksiranKioskInvalidSelection;
      }
    }
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF26364A), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x24000000), blurRadius: 22,
              offset: Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (_items.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF1F8F4), Color(0xFFE3F5E9)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF273E34), width: 1.5),
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              final description = Row(children: [
                Container(
                  width: 54, height: 54,
                  decoration: const BoxDecoration(color: _green,
                      shape: BoxShape.circle),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.amountPayable, style: _text(30,
                        color: const Color(0xFF273E34), weight: FontWeight.w800)),
                        const SizedBox(height: 12),

                        if (_selected.isEmpty)
                          Text(
                            loc.taksiranSelectAlert,
                            style: _text(
                              27,
                              color: _muted,
                              weight: FontWeight.w600,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              // Number of accounts included in this payment.
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFB6D8C1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: _green,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        loc.selectedAccountCount(_selected.length),
                                        style: _text(
                                          26,
                                          color: _ink,
                                          weight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Selected payment period.
                              if (_period != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE7F2FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFB8CEE5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_rounded,
                                        color: _blue,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          _periodLabel(loc),
                                          style: _text(
                                            26,
                                            color: _ink,
                                            weight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ],
                )),
              ]);
              final amount = Text(
                _selected.isEmpty || _totalCents == null
                ? '—'
                : _rm(_totalCents!),
                style: _text(44, color: _green, weight: FontWeight.w900),
              );
              // Allow long translations and large totals to wrap naturally.
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  description,
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: amount),
                ],
              );
            }),
          ),
          if (hint != null && _selected.isNotEmpty) Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(hint, style: _text(26,
                color: const Color(0xFF963A12))),
          ),
          const SizedBox(height: 18),
        ],
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _action(loc.back.toUpperCase(), Icons.arrow_back_rounded,
              _openingPayment ? null : _back, primary: false)),
          if (_items.isNotEmpty) ...[
            const SizedBox(width: 22),
            Expanded(child: _action(loc.continueText,
                Icons.arrow_forward_rounded, _canContinue ? _proceed : null)),
          ],
        ]),
      ]),
    );
  }
  Widget _action(String label, IconData icon, VoidCallback? onPressed,
      {bool primary = true}) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: primary ? _green : const Color(0xFFE0E0E0),
      foregroundColor: primary ? Colors.white : const Color(0xFF202A35),
      disabledBackgroundColor: const Color(0xFFE2E8F0),
      disabledForegroundColor: const Color(0xFF596B7E),
      minimumSize: const Size(0, 94), elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      side: const BorderSide(color: Color(0xFF26364A), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (!primary) ...[Icon(icon, size: 32), const SizedBox(width: 10)],
      Flexible(child: Text(label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
              height: 1.15))),
      if (primary) ...[const SizedBox(width: 10), Icon(icon, size: 32)],
    ]),
  );
  Future<void> _showDetails(Map<String, dynamic> item) async {
    if (_openingPayment) return;
    final loc = AppLocalizations.of(context)!;
    final accountRows = <Widget>[];
    final propertyRows = <Widget>[];
    final amountRows = <Widget>[];
    void field(List<Widget> rows, String label, String key,
        {bool money = false, bool percent = false}) {
      String value;
      if (money) {
        final cents = _cents(item, key);
        value = cents == null ? '-' : _rm(cents);
      } else {
        value = _value(item, key);
        if (percent && !_missing(value) && !value.endsWith('%')) value += '%';
      }
      if (!_missing(value)) {
        rows.add(_detailField(label, value, money: money));
      }
    }
    field(accountRows, loc.accountNo, 'account_no');
    field(accountRows, loc.oldAccountNo, 'old_account_no');
    field(accountRows, loc.invoiceNo, 'invoice_no');
    field(accountRows, loc.name, 'name');
    field(accountRows, loc.icNo, 'pdaftaran');
    field(accountRows, loc.startDate, 'start_date');
    field(accountRows, loc.endDate, 'end_date');
    final property = _propertyAddress(item);
    if (!_missing(property)) {
      propertyRows.add(_detailField(loc.propertyAddress, property));
    }
    field(propertyRows, loc.mukim, 'mukim');
    field(propertyRows, loc.lotNo, 'no_lot');
    field(propertyRows, loc.titleNo, 'no_hakmilik');
    final owner = _address(item, ['address1', 'address2', 'address3']);
    if (!_missing(owner)) propertyRows.add(_detailField(loc.ownerAddress, owner));
    field(propertyRows, loc.telephone, 'telephone');
    field(propertyRows, loc.email, 'email');
    field(amountRows, loc.annualValue, 'nilai_tahunan', money: true);
    field(amountRows, loc.rate, 'kadar', percent: true);
    field(amountRows, loc.annualTax, 'cukai_setahun', money: true);
    field(amountRows, loc.halfYearTax, 'cukai_sepenggal', money: true);
    field(amountRows, loc.currentTax, 'cukai_semasa', money: true);
    field(amountRows, loc.taxArrears, 'tunggakan_cukai', money: true);
    field(amountRows, loc.noticeE, 'notis_e', money: true);
    field(amountRows, loc.waranLod, 'waran_lod');
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xA600142B),
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        backgroundColor: const Color(0xFFF2F6FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 760,
          height: MediaQuery.of(dialogContext).size.height * 0.9,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF2196F3)],
                  ),
                ),
                child: Row(children: [
                  const Icon(Icons.home_work_rounded, color: Colors.white, size: 42),
                  const SizedBox(width: 16),
                  Expanded(child: Text(loc.taksiranDetailsTitle,
                      style: _text(36, color: Colors.white, weight: FontWeight.w800))),
                ]),
              ),
              Expanded(child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: _KioskScroll(
                  downLabel: loc.scrolldown, upLabel: loc.scrollup,
                  scrollHint: loc.scrollForMoreInformation,
                  children: [
                    if (accountRows.isNotEmpty)
                      _detailSection(loc.accountNo, Icons.badge_outlined, accountRows),
                    if (propertyRows.isNotEmpty)
                      _detailSection(loc.propertyAddress, Icons.home_outlined, propertyRows),
                    if (amountRows.isNotEmpty)
                      _detailTaxGrid(loc.taksiranTaxInformation, amountRows),
                  ],
                ),
              )),
              Padding(
                padding: const EdgeInsets.all(18),
                child: _action(loc.close, Icons.close_rounded,
                    () => Navigator.of(dialogContext).pop()),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Popup only: responsive two-column tax information card.
  Widget _detailTaxGrid(String title, List<Widget> rows) => Container(
    margin: const EdgeInsets.only(bottom: 18, right: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _line, width: 1.5),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.all(18),
        color: const Color(0xFFE3F5E9),
        child: Row(children: [
          const Icon(Icons.receipt_long_rounded, size: 32, color: _green),
          const SizedBox(width: 12),
          Expanded(child: Text(title,
              style: _text(30, color: _green, weight: FontWeight.w800))),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < 460) {
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rows);
          }
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rows.map((row) => SizedBox(
              width: (constraints.maxWidth - 8) / 2,
              child: row,
            )).toList(),
          );
        }),
      ),
    ]),
  );
  Widget _detailSection(String title, IconData icon, List<Widget> rows,
      {bool money = false}) => Container(
    margin: const EdgeInsets.only(bottom: 18, right: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _line, width: 1.5),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.all(18),
        color: money ? const Color(0xFFE3F5E9) : const Color(0xFFE7F2FF),
        child: Row(children: [
          Icon(icon, size: 32, color: money ? _green : _blue),
          const SizedBox(width: 12),
          Expanded(child: Text(title,
              style: _text(30, color: money ? _green : _ink,
                  weight: FontWeight.w800))),
        ]),
      ),
      for (var i = 0; i < rows.length; i++) ...[
        rows[i],
        if (i < rows.length - 1)
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 1, color: _line)),
      ],
    ]),
  );
  Widget _detailField(String label, String value, {bool money = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: _text(26, color: _muted)),
      const SizedBox(height: 8),
      Text(value, style: _text(32, color: money ? _green : _ink,
          weight: FontWeight.w800)),
    ]),
  );
}
// Scrollbar + large tap controls. The hint appears only when content overflows.
// No blurred layers, timers, or continuous animation are required.
  class _KioskScroll extends StatefulWidget {
    const _KioskScroll({
      super.key,
      required this.children,
      required this.downLabel,
      required this.upLabel,
      this.scrollHint,
    });

    final List<Widget> children;
    final String downLabel;
    final String upLabel;
    final String? scrollHint;

    @override
    State<_KioskScroll> createState() => _KioskScrollState();
  }

class _KioskScrollState extends State<_KioskScroll> {
  final _controller = ScrollController();
  bool _overflow = false;
  bool _up = false;
  bool _down = false;
  bool _syncPending = false;
  @override
  void initState() {
    super.initState();
    _controller.addListener(_scheduleSync);
    _scheduleSync();
  }
  @override
  void didUpdateWidget(covariant _KioskScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleSync();
  }
  void _scheduleSync() {
    if (_syncPending) return;
    _syncPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPending = false;
      if (!mounted || !_controller.hasClients ||
          !_controller.position.hasContentDimensions) return;
      final position = _controller.position;
      final overflow = position.maxScrollExtent > 1;
      final up = position.pixels > 1;
      final down = position.extentAfter > 1;
      if (overflow != _overflow || up != _up || down != _down) {
        setState(() { _overflow = overflow; _up = up; _down = down; });
      }
    });
  }
  void _move(bool down) {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final target = (position.pixels +
        (down ? 1 : -1) * position.viewportDimension * 0.72)
        .clamp(0.0, position.maxScrollExtent).toDouble();
    _controller.animateTo(target, duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut);
  }
  @override
  void dispose() {
    _controller.removeListener(_scheduleSync);
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) { _scheduleSync(); return false; },
      child: Scrollbar(
        controller: _controller, thumbVisibility: true, thickness: 12,
        radius: const Radius.circular(8),
        child: ListView(
          controller: _controller, primary: false,
          padding: EdgeInsets.zero, children: widget.children,
        ),
      ),
    )),
if (_overflow)
  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: widget.scrollHint == null
        ? Row(
            children: [
              _scrollButton(
                widget.upLabel,
                Icons.keyboard_arrow_up_rounded,
                _up ? () => _move(false) : null,
              ),
              const SizedBox(width: 12),
              _scrollButton(
                widget.downLabel,
                Icons.keyboard_arrow_down_rounded,
                _down ? () => _move(true) : null,
              ),
            ],
          )
        : Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _popupScrollArrow(
                  label: widget.upLabel,
                  icon: Icons.keyboard_arrow_up_rounded,
                  onPressed: _up ? () => _move(false) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.scrollHint!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF163A65),
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _popupScrollArrow(
                  label: widget.downLabel,
                  icon: Icons.keyboard_arrow_down_rounded,
                  onPressed: _down ? () => _move(true) : null,
                ),
              ],
            ),
          ),
  ),
  ]);
  Widget _scrollButton(String label, IconData icon, VoidCallback? onTap) =>
      Expanded(child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1976D2),
          backgroundColor: Colors.white,
          minimumSize: const Size(0, 68),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          side: const BorderSide(color: Color(0xFF77899B)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 28), const SizedBox(width: 6),
          Flexible(child: Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800))),
        ]),
      ));

      Widget _popupScrollArrow({
        required String label,
        required IconData icon,
        required VoidCallback? onPressed,
      }) {
        return IconButton(
          tooltip: label,
          onPressed: onPressed,
          icon: Icon(icon, size: 38),
          style: IconButton.styleFrom(
            minimumSize: const Size(64, 64),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1976D2),
            disabledBackgroundColor: const Color(0xFFF0F4F8),
            disabledForegroundColor: const Color(0xFF9AAABA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
}

// Independent scroll area used only by the two review panels.
// Arrows occupy a side rail, leaving the total and headings stationary.
class _ReviewList extends StatefulWidget {
  const _ReviewList({super.key, required this.children,
    required this.upLabel, required this.downLabel});
  final List<Widget> children;
  final String upLabel;
  final String downLabel;
  @override
  State<_ReviewList> createState() => _ReviewListState();
}
class _ReviewListState extends State<_ReviewList> {
  final _controller = ScrollController();
  bool _overflow = false, _up = false, _down = false, _pending = false;
  @override
  void initState() {
    super.initState();
    _controller.addListener(_sync);
    _sync();
  }
  @override
  void didUpdateWidget(covariant _ReviewList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }
  void _sync() {
    if (_pending) return;
    _pending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pending = false;
      if (!mounted || !_controller.hasClients ||
          !_controller.position.hasContentDimensions) return;
      final p = _controller.position;
      final overflow = p.maxScrollExtent > 1;
      final up = p.extentBefore > 1, down = p.extentAfter > 1;
      if (overflow != _overflow || up != _up || down != _down) {
        setState(() { _overflow = overflow; _up = up; _down = down; });
      }
    });
  }
  void _move(bool down) {
    if (!_controller.hasClients) return;
    final p = _controller.position;
    final target = (p.pixels + (down ? 1 : -1) * p.viewportDimension * 0.75)
        .clamp(0.0, p.maxScrollExtent).toDouble();
    _controller.animateTo(target, duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut);
  }
  @override
  void dispose() {
    _controller.removeListener(_sync);
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, size) {
    return Row(children: [
      Expanded(child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (_) { _sync(); return false; },
        child: Scrollbar(controller: _controller, thumbVisibility: _overflow,
          thickness: 9, radius: const Radius.circular(8),
          child: ListView(controller: _controller, primary: false,
            padding: EdgeInsets.zero, children: widget.children),
        ),
      )),
      // Very short viewports retain touch scrolling and the scrollbar.
      if (_overflow && size.maxHeight >= 104) ...[
        const SizedBox(width: 8),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _arrow(widget.upLabel, Icons.keyboard_arrow_up_rounded,
              _up ? () => _move(false) : null),
          const SizedBox(height: 8),
          _arrow(widget.downLabel, Icons.keyboard_arrow_down_rounded,
              _down ? () => _move(true) : null),
        ]),
      ],
    ]);
  });
  Widget _arrow(String label, IconData icon, VoidCallback? onPressed) => IconButton(
    tooltip: label, onPressed: onPressed, icon: Icon(icon, size: 32),
    style: IconButton.styleFrom(minimumSize: const Size(48, 48),
      maximumSize: const Size(48, 48), padding: EdgeInsets.zero,
      backgroundColor: const Color(0xFFE7F2FF),
      foregroundColor: const Color(0xFF1976D2),
      disabledBackgroundColor: const Color(0xFFF0F3F7),
      disabledForegroundColor: const Color(0xFF9AAABA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  );
}
