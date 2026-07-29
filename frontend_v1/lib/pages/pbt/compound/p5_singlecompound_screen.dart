import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/compound/compound_model.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/pbt/p4.dart';
import 'package:frontend_v1/pages/payment/payment.dart';
import 'package:intl/intl.dart';

class P5SingleCompoundScreen extends StatelessWidget {
  final CompoundModel compound;

  const P5SingleCompoundScreen({
    super.key,
    required this.compound,
  });

  static const Color _primaryBlue = Color(0xFF075FD8);
  static const Color _darkBlue = Color(0xFF102A4C);
  static const Color _softBlue = Color(0xFFF1F7FF);
  static const Color _successGreen = Color(0xFF168A45);
  static const Color _softGreen = Color(0xFFECF8F0);
  static const Color _warningOrange = Color(0xFFE97022);

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '-';

    try {
      final parsed = DateFormat('HH:mm:ss').parseLoose(time);
      return DateFormat('hh:mm a').format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat('HH:mm').parseLoose(time);
        return DateFormat('hh:mm a').format(parsed);
      } catch (_) {
        return time;
      }
    }
  }

  String _safe(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildTitle(loc),
          _buildCompoundCard(context, loc),
          _buildBottomButtons(context, loc),
          _buildCopyright(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/pnew.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations loc) {
    return Positioned(
      top: 70,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            loc.p5SingleCompoundTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _primaryBlue,
              fontSize: 64,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 110,
            height: 6,
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompoundCard(
    BuildContext context,
    AppLocalizations loc,
  ) {
    return Positioned(
      top: 350,
      left: 50,
      right: 50,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.98),
          borderRadius: BorderRadius.circular(38),
          border: Border.all(
            color: _primaryBlue,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: _darkBlue.withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCardHeader(loc),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  30,
                  28,
                  30,
                  30,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _infoTile(
                            icon: Icons.person_rounded,
                            label: loc.singleCompoundOffenderName,
                            value: _safe(compound.compName),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _infoTile(
                            icon: Icons.directions_car_filled_rounded,
                            label: loc.singleCompoundPlateNo,
                            value: _safe(compound.compPlateNo),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _infoTile(
                            icon: Icons.calendar_month_rounded,
                            label: loc.singleCompoundDate,
                            value: _safe(compound.compDate),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _infoTile(
                            icon: Icons.schedule_rounded,
                            label: loc.singleCompoundTime,
                            value: _formatTime(compound.compTime),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _infoTile(
                            icon: Icons.rule_rounded,
                            label: loc.singleCompoundKodHasil,
                            value: _safe(compound.kodhasil),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _infoTile(
                            icon: Icons.receipt_long_rounded,
                            label: loc.singleCompoundNo,
                            value: _safe(compound.compNo),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildOffenseCard(loc),
                    const SizedBox(height: 20),
                    _buildAmountCard(loc),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        32,
        24,
        32,
        24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEEF5FF),
            Color(0xFFF8FBFF),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFDCE9F8),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withOpacity(0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.singleCompoundNo,
                  style: const TextStyle(
                    color: Color(0xFF60728A),
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _safe(compound.compNo),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _darkBlue,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: _softGreen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFBDE7CA),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: _successGreen,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Text(
                  'RM ${compound.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: _successGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      height: 145,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: _primaryBlue,
              size: 31,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF68798E),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _darkBlue,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffenseCard(AppLocalizations loc) {
    final offense = [
      _safe(compound.violationDesc),
      _safe(compound.compType),
    ].where((item) => item != '-').join(' - ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6C8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: _warningOrange,
              size: 36,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.singleCompoundOffense,
                  style: const TextStyle(
                    color: Color(0xFF6B5329),
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  offense.isEmpty ? '-' : offense,
                  style: const TextStyle(
                    color: Color(0xFF3E3422),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 26,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF1F8F4),
            Color(0xFFE3F5E9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _successGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              loc.amountPayable,
              style: const TextStyle(
                color: Color(0xFF567064),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            'RM ${compound.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: _successGreen,
              fontSize: 46,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(
    BuildContext context,
    AppLocalizations loc,
  ) {
    return Positioned(
      bottom: 215,
      left: 78,
      right: 78,
      child: Row(
        children: [
          Expanded(
            child: _bottomActionButton(
              label: loc.backButton,
              icon: Icons.arrow_back_rounded,
              backgroundColor: const Color(0xFFF2F3F5),
              foregroundColor: const Color(0xFF20242A),
              borderColor: const Color(0xFF5D6269),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => P4PAGE(
                      title: loc.singlecompoundTitle,
                      type: 'PBT',
                      hint: loc.inputCompoundHint,
                      biz: 'SINGLECOMPOUND',
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 34),
          Expanded(
            child: _bottomActionButton(
              label: loc.continueButton,
              icon: Icons.arrow_forward_rounded,
              iconOnRight: true,
              backgroundColor: _successGreen,
              foregroundColor: Colors.white,
              borderColor: const Color(0xFF0F6D35),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(
                      name: '/payment',
                    ),
                    builder: (_) => PAYMENTPAGE(
                      biz: 'SINGLECOMPOUND',
                      data: PaymentData(
                        amount: compound.amount.toStringAsFixed(2),
                        compoundNos: [?compound.compNo],
                        plate: compound.compPlateNo,
                        offenderName: compound.compName,
                        violationType: compound.compType,
                        kodhasil: compound.kodhasil,
                        date: compound.compDate,
                        time: compound.compTime,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomActionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required Color borderColor,
    required VoidCallback onPressed,
    bool iconOnRight = false,
  }) {
    final items = <Widget>[
      Icon(
        icon,
        size: 40,
      ),
      const SizedBox(width: 13),
      Flexible(
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
      ),
    ];

    return SizedBox(
      height: 102,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.28),
          side: BorderSide(
            color: borderColor,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: iconOnRight
              ? items.reversed.toList()
              : items,
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Positioned(
      bottom: 62,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          Data.copyrightText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
