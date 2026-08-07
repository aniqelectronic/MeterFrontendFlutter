import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/home/p1bentong.dart';
import 'package:frontend_v1/services/iimmpact/bill_receipt_service.dart';
import 'package:frontend_v1/widgets/kiosk_home_button.dart';

class BillReceiptData {
  final String billType;
  final String billCode;
  final String accountNumber;
  final double billAmount;
  final double totalAmount;
  final String orderNo;
  final String bankTransactionNo;
  final String paymentMethod;
  final DateTime paidAt;

  const BillReceiptData({
    required this.billType,
    required this.billCode,
    required this.accountNumber,
    required this.billAmount,
    required this.totalAmount,
    required this.orderNo,
    required this.bankTransactionNo,
    this.paymentMethod = 'DuitNow QR',
    required this.paidAt,
  });
}

class BillReceiptPage extends StatefulWidget {
  final BillReceiptData data;

  const BillReceiptPage({
    super.key,
    required this.data,
  });

  @override
  State<BillReceiptPage> createState() =>
      _BillReceiptPageState();
}

class _BillReceiptPageState extends State<BillReceiptPage> {
  static const int _countdownDuration = 150;

  Timer? _countdownTimer;
  int _remainingSeconds = _countdownDuration;

  Uint8List? _receiptQrBytes;
  bool _isReceiptQrLoading = true;
  bool _receiptQrLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _fetchReceiptQr();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }


  Future<void> _fetchReceiptQr() async {
    setState(() {
      _isReceiptQrLoading = true;
      _receiptQrLoadFailed = false;
    });

    try {
      final Uint8List qrBytes =
          await BillReceiptService.generateReceiptQr(
        orderNo: widget.data.orderNo,
        paidDate: widget.data.paidAt,
        paymentMethod: widget.data.paymentMethod,
        bankTransactionNo: widget.data.bankTransactionNo,
        billType: widget.data.billType,
        billCode: widget.data.billCode,
        accountNumber: widget.data.accountNumber,
        billAmount: widget.data.billAmount,
        totalAmount: widget.data.totalAmount,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _receiptQrBytes = qrBytes;
        _isReceiptQrLoading = false;
        _receiptQrLoadFailed = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        '[BillReceiptPage] Receipt QR error: $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _receiptQrBytes = null;
        _isReceiptQrLoading = false;
        _receiptQrLoadFailed = true;
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_remainingSeconds <= 1) {
          timer.cancel();

          if (mounted) {
            _goHome();
          }

          return;
        }

        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      },
    );
  }

  void _goHome() {
    _countdownTimer?.cancel();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/p1'),
        builder: (_) => const P1BentongPage(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  String _safeValue(String value) {
    final cleanValue = value.trim();

    if (cleanValue.isEmpty ||
        cleanValue.toLowerCase() == 'null') {
      return '-';
    }

    return cleanValue;
  }

  String _formatAmount(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final double countdownProgress =
        (_remainingSeconds / _countdownDuration)
            .clamp(0.0, 1.0);

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.38),
                    Colors.white.withOpacity(0.28),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(loc),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 10,
                      radius: const Radius.circular(20),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          55,
                          34,
                          55,
                          28,
                        ),
                        child: _buildReceiptCard(loc),
                      ),
                    ),
                  ),
                ),
                _buildBottomSection(
                  loc,
                  countdownProgress,
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.fromLTRB(55, 32, 55, 0),
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF164FA5),
            Color(0xFF1D73CD),
            Color(0xFF39A5F4),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 43,
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Text(
              loc.receiptPaymentTitle.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 22),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 43,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        32,
        32,
        32,
        34,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: const Color(0xFFD2E2F2),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17375E).withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          // Container(
          //   width: 138,
          //   height: 138,
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFE7F8EE),
          //     shape: BoxShape.circle,
          //     border: Border.all(
          //       color: const Color(0xFF169B62),
          //       width: 5,
          //     ),
          //   ),
          //   child: const Icon(
          //     Icons.check_rounded,
          //     color: Color(0xFF169B62),
          //     size: 98,
          //   ),
          // ),
          // const SizedBox(height: 24),
          // Text(
          //   loc.paymentSuccessful,
          //   textAlign: TextAlign.center,
          //   style: const TextStyle(
          //     color: Color(0xFF087443),
          //     fontSize: 44,
          //     fontWeight: FontWeight.w900,
          //   ),
          // ),
          // const SizedBox(height: 10),
          // Text(
          //   loc.receiptThankYouMessage,
          //   textAlign: TextAlign.center,
          //   style: const TextStyle(
          //     color: Color(0xFF566778),
          //     fontSize: 27,
          //     fontWeight: FontWeight.w700,
          //     height: 1.3,
          //   ),
          // ),
          // const SizedBox(height: 30),
          const SizedBox(height: 8),
          _buildSectionTitle(
            icon: Icons.description_rounded,
            title: loc.receiptTransactionDetailsTitle,
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FB),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xFFD8E0E8),
                width: 1.5,
              ),
            ),
            child: Column(
              children: _insertDividers([
                _ReceiptInfoRow(
                  icon: Icons.business_rounded,
                  label: loc.billProvider,
                  value: _safeValue(widget.data.billType),
                ),
                _ReceiptInfoRow(
                  icon: Icons.code_rounded,
                  label: loc.billCode,
                  value: _safeValue(widget.data.billCode),
                ),
                _ReceiptInfoRow(
                  icon: Icons.numbers_rounded,
                  label: loc.accountNumber,
                  value: _safeValue(
                    widget.data.accountNumber,
                  ),
                ),
                _ReceiptInfoRow(
                  icon: Icons.qr_code_2_rounded,
                  label: loc.receiptPaymentMethodLabel,
                  value: _safeValue(
                    widget.data.paymentMethod,
                  ),
                ),
                _ReceiptInfoRow(
                  icon: Icons.receipt_long_rounded,
                  label: loc.receiptOrderNumberLabel,
                  value: _safeValue(widget.data.orderNo),
                  compactValue: true,
                ),
                if (_safeValue(
                      widget.data.bankTransactionNo,
                    ) !=
                    '-')
                  _ReceiptInfoRow(
                    icon: Icons.account_balance_rounded,
                    label:
                        loc.receiptBankTransactionLabel,
                    value: _safeValue(
                      widget.data.bankTransactionNo,
                    ),
                    compactValue: true,
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 26),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 25,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF183B63),
                  Color(0xFF2F6DA7),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D527E)
                      .withOpacity(0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: Colors.white,
                    size: 43,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    loc.receiptAmountLabel2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatAmount(
                        widget.data.totalAmount,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          _buildDigitalReceiptCard(loc),
        ],
      ),
    );
  }


  Widget _buildDigitalReceiptCard(
    AppLocalizations loc,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        28,
        28,
        28,
        26,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FBF7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF9DDAC5),
          width: 2.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F7EF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF118762),
                  size: 39,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.billReceiptDigitalTitle,
                      style: const TextStyle(
                        color: Color(0xFF0B6A4D),
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      loc.billReceiptDigitalSubtitle,
                      style: const TextStyle(
                        color: Color(0xFF407565),
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildQrContent(loc),
          ),
        ],
      ),
    );
  }

  Widget _buildQrContent(AppLocalizations loc) {
    if (_isReceiptQrLoading) {
      return Container(
        key: const ValueKey<String>('loading'),
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 270,
        ),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFC8E8DC),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 68,
              height: 68,
              child: CircularProgressIndicator(
                strokeWidth: 7,
                color: Color(0xFF118762),
                backgroundColor: Color(0xFFDDF1E9),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              loc.billReceiptQrLoading,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF155D49),
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    if (!_receiptQrLoadFailed && _receiptQrBytes != null) {
      return Container(
        key: const ValueKey<String>('success'),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFC8E8DC),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFD6E5DF),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 15,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Image.memory(
                _receiptQrBytes!,
                width: 320,
                height: 320,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color: Color(0xFF118762),
                  size: 31,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    loc.billReceiptQrScanInstruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF155D49),
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      key: const ValueKey<String>('error'),
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEF9A9A),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.qr_code_2_rounded,
            color: Color(0xFFC62828),
            size: 82,
          ),
          const SizedBox(height: 16),
          Text(
            loc.billReceiptQrError,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFC62828),
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: 300,
            height: 72,
            child: ElevatedButton.icon(
              onPressed: _fetchReceiptQr,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 30,
              ),
              label: Text(
                loc.billReceiptQrRetry,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF118762),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    AppLocalizations loc,
    double countdownProgress,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        70,
        18,
        70,
        32,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFD5DEE7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.09),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 58,
                      height: 58,
                      child: CircularProgressIndicator(
                        value: countdownProgress,
                        strokeWidth: 6,
                        backgroundColor:
                            const Color(0xFFE5EBF0),
                        color: _remainingSeconds <= 20
                            ? const Color(0xFFD64545)
                            : const Color(0xFF2F6DA7),
                      ),
                    ),
                    Text(
                      '$_remainingSeconds',
                      style: TextStyle(
                        color: _remainingSeconds <= 20
                            ? const Color(0xFFC62828)
                            : const Color(0xFF244461),
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    loc.receiptAutoReturn(
                      _remainingSeconds,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF334659),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 520,
            height: 96,
            child: KioskHomeButton(
              onPressed: _goHome,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            Data.copyrightText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF273747),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xFFE6EEF6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF315F8C),
            size: 39,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF20364C),
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _insertDividers(
    List<Widget> rows,
  ) {
    final result = <Widget>[];

    for (int index = 0; index < rows.length; index++) {
      result.add(rows[index]);

      if (index != rows.length - 1) {
        result.add(
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFDCE3E9),
          ),
        );
      }
    }

    return result;
  }
}

class _ReceiptInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool compactValue;

  const _ReceiptInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.compactValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF61778C),
            size: 35,
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 5,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF4D5D6D),
                fontSize: 29,
                height: 1.15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: compactValue ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF1D3043),
                fontSize: compactValue ? 24 : 30,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
