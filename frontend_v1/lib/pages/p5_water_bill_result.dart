import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/water/water_bill_model.dart';
import 'package:frontend_v1/pages/data.dart';

class P5WaterBillResultPage extends StatefulWidget {
  final WaterBillModel bill;

  const P5WaterBillResultPage({
    super.key,
    required this.bill,
  });

  @override
  State<P5WaterBillResultPage> createState() =>
      _P5WaterBillResultPageState();
}

class _P5WaterBillResultPageState
    extends State<P5WaterBillResultPage> {
  static const double _minimumAmount = 1;
  static const double _maximumAmount = 10000;
  static const double _amountStep = 1;

  final TextEditingController _amountController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  double _selectedAmount = 1;

  WaterBillModel get bill => widget.bill;

  // Add this value in Data:
  // static const double waterServiceFee = 1.00;
  double get _serviceFee => Data.waterServiceFee;

  double get _totalAmount => _selectedAmount + _serviceFee;

  @override
  void initState() {
    super.initState();

    final initialAmount = bill.outstandingAmount > 0
        ? bill.outstandingAmount.clamp(
            _minimumAmount,
            _maximumAmount,
          )
        : _minimumAmount;

    _setPaymentAmount(initialAmount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    return 'RM ${amount.abs().toStringAsFixed(2)}';
  }

  void _setPaymentAmount(double amount) {
    final safe = amount.clamp(
      _minimumAmount,
      _maximumAmount,
    );

    setState(() {
      _selectedAmount = safe;
      _amountController.text = safe.toStringAsFixed(2);
    });
  }

  void _increaseAmount() {
    final loc = AppLocalizations.of(context)!;

    if (_selectedAmount >= _maximumAmount) {
      _showMessage(
        loc.waterMaximumPayment(
          _formatAmount(_maximumAmount),
        ),
      );
      return;
    }

    _setPaymentAmount(_selectedAmount + _amountStep);
  }

  void _decreaseAmount() {
    final loc = AppLocalizations.of(context)!;

    if (_selectedAmount <= _minimumAmount) {
      _showMessage(
        loc.waterMinimumPayment(
          _formatAmount(_minimumAmount),
        ),
      );
      return;
    }

    _setPaymentAmount(_selectedAmount - _amountStep);
  }

  void _setFullOutstandingAmount() {
    final loc = AppLocalizations.of(context)!;

    if (bill.outstandingAmount <= 0) {
      _showMessage(loc.waterNoOutstandingBalance);
      return;
    }

    _setPaymentAmount(bill.outstandingAmount);
  }

  void _handleContinue() {
    final loc = AppLocalizations.of(context)!;

    if (_selectedAmount < _minimumAmount) {
      _showMessage(
        loc.waterMinimumPayment(
          _formatAmount(_minimumAmount),
        ),
      );
      return;
    }

    if (_selectedAmount > _maximumAmount) {
      _showMessage(
        loc.waterMaximumPayment(
          _formatAmount(_maximumAmount),
        ),
      );
      return;
    }

    Navigator.pop(context, _totalAmount);
  }

  void _showMessage(String message) {
    final loc = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF0277BD),
                size: 38,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  loc.waterInformation,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 24,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.waterOk,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAmountKeyboard() async {
    final controller = TextEditingController(
      text: _amountController.text,
    );

    final value = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            AppLocalizations.of(context)!
                .waterEnterPaymentAmount,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: SizedBox(
            width: 650,
            child: TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
              ),
              decoration: const InputDecoration(
                prefixText: 'RM ',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AppLocalizations.of(context)!.waterCancel,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = double.tryParse(
                  controller.text.trim(),
                );

                Navigator.pop(dialogContext, parsed);
              },
              child: Text(
                AppLocalizations.of(context)!.waterDone,
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (value != null) {
      _setPaymentAmount(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/pnew.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 12,
                      radius: const Radius.circular(20),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          70,
                          35,
                          70,
                          20,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(35),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.97),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              _buildBillInformationCard(),
                              const SizedBox(height: 30),
                              _buildAccountNumberSection(),
                              const SizedBox(height: 32),
                              _buildAmountSection(),
                              const SizedBox(height: 32),
                              _buildOrderSummary(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    70,
                    30,
                    70,
                    55,
                  ),
                  child: Column(
                    children: [
                      _buildActionButtons(),
                      const SizedBox(height: 18),
                      Text(
                        Data.copyrightText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF17375E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(70, 30, 70, 0),
      padding: const EdgeInsets.symmetric(
        horizontal: 34,
        vertical: 26,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF006064),
            Color(0xFF00838F),
            Color(0xFF26C6DA),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    bill.billerName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  loc.waterBillPayment,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.water_drop_rounded,
            color: Colors.white,
            size: 64,
          ),
        ],
      ),
    );
  }

  Widget _buildBillInformationCard() {
    final loc = AppLocalizations.of(context)!;
    final isCredit = bill.outstandingAmount < 0;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF00ACC1),
          width: 2.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.waterBillInformation,
            style: const TextStyle(
              color: Color(0xFF102A43),
              fontSize: 31,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: isCredit
                      ? loc.waterCreditBalance
                      : loc.waterOutstandingAmount,
                  value: _formatAmount(
                    bill.outstandingAmount,
                  ),
                  valueColor: isCredit
                      ? const Color(0xFF138A72)
                      : const Color(0xFF0097A7),
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_month_rounded,
                  label: loc.waterDueDate,
                  value: bill.dueDate,
                ),
              ),
            ],
          ),
          if (bill.customerName.trim().isNotEmpty) ...[
            const Divider(height: 35),
            _InfoItem(
              icon: Icons.person_outline_rounded,
              label: loc.waterCustomerName,
              value: bill.customerName,
            ),
          ],
          if (bill.customerAddress.trim().isNotEmpty) ...[
            const Divider(height: 35),
            _InfoItem(
              icon: Icons.home_outlined,
              label: loc.waterServiceAddress,
              value: bill.customerAddress,
            ),
          ],
          if (isCredit) ...[
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8F4),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                loc.waterCreditNotice,
                style: const TextStyle(
                  color: Color(0xFF096B59),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountNumberSection() {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.waterAccountNumber,
          style: const TextStyle(
            color: Color(0xFF102A43),
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 26,
            vertical: 24,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD4E1F5),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.numbers_rounded),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  bill.accountNumber,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.lock_outline_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.waterSelectPaymentAmount,
          style: const TextStyle(
            color: Color(0xFF102A43),
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Text(
              'RM',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: InkWell(
                onTap: _openAmountKeyboard,
                child: Container(
                  height: 95,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00838F),
                      width: 3,
                    ),
                  ),
                  child: Text(
                    _amountController.text,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            _AmountButton(
              icon: Icons.remove_rounded,
              onPressed: _decreaseAmount,
              backgroundColor: const Color(0xFFFFF3E0),
              foregroundColor: const Color(0xFFE65100),
            ),
            const SizedBox(width: 18),
            _AmountButton(
              icon: Icons.add_rounded,
              onPressed: _increaseAmount,
              backgroundColor: const Color(0xFFE8F5E9),
              foregroundColor: const Color(0xFF2E7D32),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final amount in [20, 50, 100, 200])
              _QuickAmountButton(
                label: 'RM $amount',
                onPressed: () =>
                    _setPaymentAmount(amount.toDouble()),
              ),
            if (bill.outstandingAmount > 0)
              _QuickAmountButton(
                label: loc.waterFull,
                emphasized: true,
                onPressed: _setFullOutstandingAmount,
              ),
          ],
        ),
      ],
    );
  }

  String _getBillUpdateTime(AppLocalizations loc) {
    return loc.waterUpdateWithinThreeDays;
  }

  Widget _buildOrderSummary() {
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD3DCE8),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              loc.waterOrderSummary,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 25),
          _SummaryRow(
            label: bill.billerName,
            value: _formatAmount(_selectedAmount),
          ),
          const Divider(height: 38),
          _SummaryRow(
            label: loc.waterServiceFee,
            value: _formatAmount(_serviceFee),
          ),
          const Divider(height: 38),
          _SummaryRow(
            label: loc.waterTotalAmount,
            value: _formatAmount(_totalAmount),
            isTotal: true,
          ),
          const Divider(height: 38),
          _SummaryRow(
            label: loc.waterPaymentUpdateTime,
            value: _getBillUpdateTime(loc),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final loc = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 90,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(
                loc.buttonBack,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: SizedBox(
            height: 90,
            child: ElevatedButton.icon(
              onPressed: _handleContinue,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                loc.waterContinue,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00838F),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 34),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                value.trim().isEmpty ? '-' : value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _AmountButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 105,
      height: 95,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 55),
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool emphasized;

  const _QuickAmountButton({
    required this.label,
    required this.onPressed,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: emphasized
              ? Colors.white
              : const Color(0xFF17375E),
          backgroundColor: emphasized
              ? const Color(0xFF00838F)
              : Colors.white,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 27 : 22,
              fontWeight:
                  isTotal ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Text(
          value,
          style: TextStyle(
            color: isTotal
                ? const Color(0xFF00838F)
                : const Color(0xFF102A43),
            fontSize: isTotal ? 29 : 23,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
