import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/home/p1bentong.dart';
import 'package:frontend_v1/widgets/kiosk_home_button.dart';

// ============================================================================
// PTPTN RECEIPT DATA
// ============================================================================

class PtptnReceiptData {
  // ==========================================================================
  // PROVIDER / PRODUCT
  // ==========================================================================

  final String providerName;
  final String productCode;

  // ==========================================================================
  // PTPTN ACCOUNT
  // ==========================================================================

  final String nric;

  final String subproductCode;

  final String accountType;

  final String accountCategory;

  final String accountNumber;

  // ==========================================================================
  // PAYMENT
  // ==========================================================================

  final double paymentAmount;

  final double serviceAdjustment;

  final double totalAmount;

  // ==========================================================================
  // TRANSACTION
  // ==========================================================================

  final String refId;

  final String orderNo;

  final String bankTransactionNo;

  final String paymentMethod;

  final String providerStatus;

  final DateTime paidAt;

  const PtptnReceiptData({
    required this.providerName,
    required this.productCode,
    required this.nric,
    required this.subproductCode,
    required this.accountType,
    required this.accountCategory,
    required this.accountNumber,
    required this.paymentAmount,
    required this.serviceAdjustment,
    required this.totalAmount,
    required this.refId,
    required this.orderNo,
    required this.bankTransactionNo,
    required this.paymentMethod,
    required this.providerStatus,
    required this.paidAt,
  });
}

// ============================================================================
// PTPTN RECEIPT PAGE
// ============================================================================

class PtptnReceiptPage extends StatelessWidget {
  final PtptnReceiptData data;

  const PtptnReceiptPage({
    super.key,
    required this.data,
  });

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF4054C7);

  static const Color _darkColor =
      Color(0xFF263A9E);

  static const Color _lightColor =
      Color(0xFFEEF1FF);

  static const Color _greenColor =
      Color(0xFF168A50);

  static const Color _textDark =
      Color(0xFF17283E);

  static const Color _textMuted =
      Color(0xFF68778B);

  static const Color _borderColor =
      Color(0xFFD6DFEA);

  // ==========================================================================
  // SAFE VALUE
  // ==========================================================================

  String _safeValue(
    String value,
  ) {
    final String trimmed =
        value.trim();

    return trimmed.isEmpty
        ? '-'
        : trimmed;
  }

  // ==========================================================================
  // AMOUNT
  // ==========================================================================

  String _formatAmount(
    double amount,
  ) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  String _formatSignedAmount(
    double amount,
  ) {
    if (amount == 0) {
      return 'RM 0.00';
    }

    final String sign =
        amount > 0
            ? '+'
            : '-';

    return '$sign RM '
        '${amount.abs().toStringAsFixed(2)}';
  }

  // ==========================================================================
  // DATE
  // ==========================================================================

  String _twoDigits(
    int value,
  ) {
    return value
        .toString()
        .padLeft(
          2,
          '0',
        );
  }

  String _formatDateTime(
    DateTime value,
  ) {
    final DateTime local =
        value.toLocal();

    return '${_twoDigits(local.day)}/'
        '${_twoDigits(local.month)}/'
        '${local.year} '
        '${_twoDigits(local.hour)}:'
        '${_twoDigits(local.minute)}';
  }
  // ==========================================================================
  // HOME
  // ==========================================================================

  void _goHome(
    BuildContext context,
  ) {
    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        settings:
            const RouteSettings(
          name: '/p1',
        ),
        builder:
            (_) =>
                const P1BentongPage(),
      ),
      (
        route,
      ) =>
          false,
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final loc =
        AppLocalizations.of(
      context,
    )!;

    return PopScope(
      canPop: false,

      child: Scaffold(
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ================================================================
              // FULL SCREEN BACKGROUND
              // ================================================================

              Image.asset(
                'lib/images/pnew.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

              // Optional light overlay
              Container(
                color: Colors.white.withOpacity(
                  0.04,
                ),
              ),

              // ================================================================
              // PAGE CONTENT
              // ================================================================

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    32,
                    28,
                    32,
                    110,
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(
                          loc,
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        _buildAccountCard(
                          loc,
                        ),

                        const SizedBox(
                          height: 26,
                        ),

                        _buildTransactionCard(
                          loc,
                        ),

                        const SizedBox(
                          height: 26,
                        ),

                        _buildTotalCard(
                          loc,
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // ================================================================
              // HOME BUTTON
              // ================================================================

              Positioned(
                left: 0,
                right: 0,


                bottom: 110,

                child: Center(
                  child: SizedBox(
                    width: 360,
                    height: 92,

                    child: KioskHomeButton(
                      onPressed: () =>
                          _goHome(
                        context,
                      ),
                    ),
                  ),
                ),
              ),              

              // ================================================================
              // COPYRIGHT
              // ================================================================

              Positioned(
                left: 0,
                right: 0,
                bottom: 24,

                child: Text(
                  Data.copyrightText,

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Color(
                      0xFF26364A,
                    ),

                    fontSize: 20,

                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 28,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.97,
        ),

        borderRadius:
            BorderRadius.circular(
          30,
        ),

        border:
            Border.all(
          color:
              _primaryColor,

          width: 2.5,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.08,
            ),

            blurRadius: 18,

            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,

            decoration:
                BoxDecoration(
              color:
                  _lightColor,

              borderRadius:
                  BorderRadius.circular(
                23,
              ),
            ),

            child:
                const Icon(
              Icons
                  .receipt_long_rounded,

              color:
                  _primaryColor,

              size: 48,
            ),
          ),

          const SizedBox(
            width: 22,
          ),

          Expanded(
            child: Text(
              loc.loanReceiptTitle
                  .toUpperCase(),

              style: const TextStyle(
                color: _darkColor,
                fontSize: 38,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

        ],
      ),
    );
  }

  // ==========================================================================
  // ACCOUNT CARD
  // ==========================================================================

  Widget _buildAccountCard(
    AppLocalizations loc,
  ) {
    return _sectionCard(
      title:
          loc.loanReceiptAccountDetails,

      icon:
          Icons.school_rounded,

      child: Column(
        children: [
          _detailRow(
            loc.loanReceiptProvider,
            data.providerName,
          ),

          _divider(),

          _detailRow(
            loc.loanReceiptNric,
            data.nric,
          ),

          _divider(),

          _detailRow(
            loc.loanReceiptAccountType,
            data.accountType,
          ),

          _divider(),

          _detailRow(
            loc.loanReceiptAccountNumber,
            data.accountNumber,
          ),

          _divider(),

          _detailRow(
            loc.loanReceiptCategory,
            data.accountCategory,
          ),

        ],
      ),
    );
  }

  // ==========================================================================
  // TRANSACTION CARD
  // ==========================================================================

  Widget _buildTransactionCard(
    AppLocalizations loc,
  ) {
    return _sectionCard(
      title:
          loc.loanReceiptTransactionDetails,

      icon:
          Icons.payments_rounded,

      child: Column(
        children: [
          _detailRow(
            loc.loanReceiptPaymentAmount,
            _formatAmount(
              data.paymentAmount,
            ),
          ),

          if (data.serviceAdjustment
                  .abs() >=
              0.005) ...[
            _divider(),

            _detailRow(
              loc.loanReceiptServiceAdjustment,
              _formatSignedAmount(
                data.serviceAdjustment,
              ),
            ),
          ],

          _divider(),

          _detailRow(
            loc.loanReceiptPaymentMethod,
            data.paymentMethod,
          ),

          _divider(),

          _detailRow(
            loc.loanReceiptPaymentDate,
            _formatDateTime(
              data.paidAt,
            ),
          ),


          if (data.bankTransactionNo
              .trim()
              .isNotEmpty) ...[
            _divider(),

            _detailRow(
              loc.loanReceiptBankTransaction,
              data.bankTransactionNo,
            ),
          ],

          if (data.refId
              .trim()
              .isNotEmpty) ...[
            _divider(),

            _detailRow(
              loc.loanReceiptReference,
              data.refId,
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // TOTAL CARD
  // ==========================================================================

  Widget _buildTotalCard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 28,
      ),

      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            _darkColor,
            _primaryColor,
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        boxShadow: [
          BoxShadow(
            color:
                _primaryColor.withOpacity(
              0.25,
            ),

            blurRadius: 20,

            offset:
                const Offset(
              0,
              10,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              loc.loanReceiptTotalPaid
                  .toUpperCase(),

              style:
                  const TextStyle(
                color:
                    Colors.white,

                fontSize: 27,

                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),

          Text(
            _formatAmount(
              data.totalAmount,
            ),

            style:
                const TextStyle(
              color:
                  Colors.white,

              fontSize: 38,

              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION CARD
  // ==========================================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        28,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.98,
        ),

        borderRadius:
            BorderRadius.circular(
          30,
        ),

        border:
            Border.all(
          color:
              _borderColor,

          width: 2,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.06,
            ),

            blurRadius: 15,

            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,

                decoration:
                    BoxDecoration(
                  color:
                      _lightColor,

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),

                child: Icon(
                  icon,

                  color:
                      _primaryColor,

                  size: 33,
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child: Text(
                  title,

                  style:
                      const TextStyle(
                    color:
                        _textDark,

                    fontSize: 30,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 22,
          ),

          child,
        ],
      ),
    );
  }

  // ==========================================================================
  // DETAIL ROW
  // ==========================================================================

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Expanded(
            flex: 4,

            child: Text(
              label,

              style:
                  const TextStyle(
                color:
                    _textMuted,

                fontSize: 21,

                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(
            width: 20,
          ),

          Expanded(
            flex: 6,

            child: Text(
              _safeValue(
                value,
              ),

              textAlign:
                  TextAlign.right,

              style:
                  const TextStyle(
                color:
                    _textDark,

                fontSize: 22,

                fontWeight:
                    FontWeight.w900,

                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 28,
      color: Color(
        0xFFE1E7EF,
      ),
    );
  }
}