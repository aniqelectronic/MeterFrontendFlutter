import 'package:flutter/material.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/bil/loan/services/ptptn_subproduct_service.dart';

// ============================================================================
// PTPTN PAGE 5
// ============================================================================
//
// FLOW:
//
// PTPTN
//   ↓
// NRIC
//   ↓
// GET /v2/subproducts already done in Page 4
//   ↓
// Receive initialAccounts
//   ↓
// Choose PTPTN / SSPN account
//   ↓
// NEXT:
// Enter payment amount
//
// ============================================================================

class PTPTN5PAGE extends StatefulWidget {
  final String productCode;
  final String providerName;
  final String providerImageUrl;
  final String nric;

  final List<PtptnSubproduct> initialAccounts;

  const PTPTN5PAGE({
    super.key,
    required this.productCode,
    required this.providerName,
    required this.providerImageUrl,
    required this.nric,
    required this.initialAccounts,
  });

  @override
  State<PTPTN5PAGE> createState() =>
      _PTPTN5PAGEState();
}

class _PTPTN5PAGEState
    extends State<PTPTN5PAGE> {
  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF4054C7);

  static const Color _darkColor =
      Color(0xFF263A9E);

  static const Color _primaryLight =
      Color(0xFFEEF1FF);

  static const Color _textDark =
      Color(0xFF17283E);

  static const Color _textMuted =
      Color(0xFF68778B);

  static const Color _borderColor =
      Color(0xFFD6DFEA);

  static const Color _greenColor =
      Color(0xFF168A50);

  // ==========================================================================
  // STATE
  // ==========================================================================

  bool _isLoading = true;

  String? _errorMessage;

  String? _emptyMessage;

  List<PtptnSubproduct> _accounts = [];

  PtptnSubproduct? _selectedAccount;

  bool _isNavigating = false;

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _accounts =
        List<PtptnSubproduct>.from(
      widget.initialAccounts,
    );

    if (_accounts.isNotEmpty) {
      _selectedAccount =
          _accounts.first;
    }

    _isLoading = false;
  }

  // ==========================================================================
  // OPTIONAL RELOAD
  // ==========================================================================

  Future<void> _loadAccounts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _emptyMessage = null;
        _accounts = [];
        _selectedAccount = null;
      });
    }

    try {
      final PtptnSubproductResult result =
          await PtptnSubproductService
              .getAccounts(
        nric: widget.nric,
      );

      if (!mounted) {
        return;
      }

      if (result.products.isEmpty) {
        setState(() {
          _isLoading = false;
          _accounts = [];

          _emptyMessage =
              result.message.isNotEmpty
                  ? result.message
                  : null;
        });

        return;
      }

      setState(() {
        _accounts = result.products;

        _selectedAccount =
            result.products.first;

        _isLoading = false;
      });
    } on PtptnSubproductException catch (
        error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected PTPTN options error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  // ==========================================================================
  // SELECT ACCOUNT
  // ==========================================================================

  void _selectAccount(
    PtptnSubproduct account,
  ) {
    if (_isNavigating) {
      return;
    }

    setState(() {
      _selectedAccount = account;
    });
  }

  // ==========================================================================
  // CONTINUE
  // ==========================================================================

  void _handleContinue() {
    final loc =
        AppLocalizations.of(context)!;

    if (_isNavigating) {
      return;
    }

    final PtptnSubproduct?
        selected =
        _selectedAccount;

    if (selected == null) {
      _showMessage(
        loc.loanAccountRequiredTitle,
        loc.loanAccountRequiredMessage,
      );

      return;
    }

    debugPrint('');
    debugPrint(
      '========================================',
    );
    debugPrint(
      'PTPTN ACCOUNT SELECTED',
    );
    debugPrint(
      '========================================',
    );

    debugPrint(
      'NRIC             : ${widget.nric}',
    );

    debugPrint(
      'Subproduct Code  : ${selected.subproductCode}',
    );

    debugPrint(
      'Category         : ${selected.description}',
    );

    debugPrint(
      'Display Name     : ${selected.displayName}',
    );

    debugPrint(
      'Account Number   : ${selected.accountNumber}',
    );

    debugPrint(
      '========================================',
    );
    debugPrint('');

    // ========================================================================
    // NEXT PAGE LATER
    //
    // Example:
    //
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => PLOAN6PAGE(
    //       productCode: widget.productCode,
    //       nric: widget.nric,
    //       subproductCode:
    //           selected.subproductCode,
    //       accountNumber:
    //           selected.accountNumber,
    //       accountName:
    //           selected.displayName,
    //       accountCategory:
    //           selected.description,
    //     ),
    //   ),
    // );
    //
    // ========================================================================

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          loc.loanAccountSelectedMessage,
        ),
      ),
    );
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  void _showMessage(
    String title,
    String message,
  ) {
    final loc =
        AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,

      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: Text(
            title,
          ),

          content: Text(
            message,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },

              child: Text(
                loc.loanOkButton,
              ),
            ),
          ],
        );
      },
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
        AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================

          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color:
                  Colors.white.withOpacity(
                0.04,
              ),
            ),
          ),

          // ==================================================================
          // PAGE
          // ==================================================================

          if (_isLoading)
            _buildLoading(
              loc,
            )
          else if (_errorMessage !=
              null)
            _buildError(
              loc,
            )
          else if (_accounts.isEmpty)
            _buildEmpty(
              loc,
            )
          else
            _buildAccountContent(
              loc,
            ),

          // ==================================================================
          // FOOTER
          // ==================================================================

          Positioned(
            bottom: 22,
            left: 0,
            right: 0,

            child: Text(
              Data.copyrightText,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF26364A,
                ),

                fontSize: 20,

                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MAIN ACCOUNT CONTENT
  // ==========================================================================

  Widget _buildAccountContent(
    AppLocalizations loc,
  ) {
    return Positioned(
      top: 80,
      left: 42,
      right: 42,
      bottom: 80,

      child: SingleChildScrollView(
        physics:
            const BouncingScrollPhysics(),

        child: Column(
          children: [
            // ================================================================
            // TOP TITLE CARD - OUTSIDE MAIN CARD
            // ================================================================

            Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 24,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white.withOpacity(
                  0.98,
                ),

                borderRadius:
                    BorderRadius.circular(
                  28,
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
                        _primaryColor.withOpacity(
                      0.16,
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
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  Container(
                    width: 66,
                    height: 66,

                    decoration:
                        BoxDecoration(
                      color:
                          _primaryLight,

                      borderRadius:
                          BorderRadius.circular(
                        19,
                      ),
                    ),

                    child:
                        const Icon(
                      Icons
                          .account_balance_rounded,

                      color:
                          _primaryColor,

                      size: 39,
                    ),
                  ),

                  const SizedBox(
                    width: 18,
                  ),

                  Flexible(
                    child: Text(
                      loc.loanAccountSelectionTitle
                          .toUpperCase(),

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            _darkColor,

                        fontSize: 40,

                        fontWeight:
                            FontWeight.w900,

                        letterSpacing:
                            0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 50,
            ),

            // ================================================================
            // MAIN CARD
            // ================================================================

            Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets.fromLTRB(
                30,
                30,
                30,
                32,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white.withOpacity(
                  0.98,
                ),

                borderRadius:
                    BorderRadius.circular(
                  34,
                ),

                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFD5DDEC,
                  ),

                  width: 2,
                ),

                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(
                      0xFF1F2F59,
                    ).withOpacity(
                      0.13,
                    ),

                    blurRadius: 28,

                    offset:
                        const Offset(
                      0,
                      13,
                    ),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==========================================================
                  // NRIC
                  // ==========================================================

                  Container(
                    width:
                        double.infinity,

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 20,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF7F9FD,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        22,
                      ),

                      border:
                          Border.all(
                        color:
                            const Color(
                          0xFFD8E0EA,
                        ),

                        width:
                            1.6,
                      ),
                    ),

                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,

                          decoration:
                              BoxDecoration(
                            color:
                                _primaryLight,

                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                          ),

                          child:
                              const Icon(
                            Icons
                                .badge_rounded,

                            color:
                                _primaryColor,

                            size: 60,
                          ),
                        ),

                        const SizedBox(
                          width: 18,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                loc.loanNricLabel
                                    .toUpperCase(),

                                style:
                                    const TextStyle(
                                  color:
                                      _textMuted,

                                  fontSize: 35,

                                  fontWeight:
                                      FontWeight
                                          .w900,

                                  letterSpacing:
                                      0.7,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                widget.nric,

                                style:
                                    const TextStyle(
                                  color:
                                      _textDark,

                                  fontSize: 45,

                                  fontWeight:
                                      FontWeight
                                          .w900,

                                  letterSpacing:
                                      1.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  // ==========================================================
                  // AVAILABLE ACCOUNT HEADER
                  // ==========================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            Text(
                              loc.loanAvailableAccountTitle
                                  .toUpperCase(),

                              style:
                                  const TextStyle(
                                color:
                                    _textDark,

                                fontSize: 45,

                                fontWeight:
                                    FontWeight
                                        .w900,

                                letterSpacing:
                                    0.3,
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            Text(
                              loc.loanSelectAccountSubtitle,

                              style:
                                  const TextStyle(
                                color:
                                    _textMuted,

                                fontSize: 35,

                                fontWeight:
                                    FontWeight
                                        .w700,

                                height:
                                    1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 45,
                  ),

                  // ==========================================================
                  // ACCOUNT OPTIONS
                  // ==========================================================

                  ..._accounts.map(
                    (
                      account,
                    ) {
                      final bool selected =
                          _selectedAccount ==
                              account;

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 30,
                        ),

                        child:
                            _buildModernAccountOption(
                          loc,
                          account,
                          selected,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 80,
            ),

            // ================================================================
            // BUTTONS OUTSIDE CARD
            // ================================================================

            _buildActions(
              loc,
            ),

            const SizedBox(
              height: 65,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // TITLE BOARD
  // ==========================================================================

  Widget _buildTitleBoard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 26,
        vertical: 20,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.97,
        ),

        borderRadius:
            BorderRadius.circular(
          28,
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
                _primaryColor.withOpacity(
              0.13,
            ),

            blurRadius: 18,

            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Container(
            width: 58,
            height: 58,

            decoration:
                BoxDecoration(
              color:
                  _primaryLight,

              borderRadius:
                  BorderRadius.circular(
                17,
              ),
            ),

            child:
                const Icon(
              Icons
                  .account_balance_rounded,

              color:
                  _primaryColor,

              size: 34,
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Text(
            loc.loanAccountStepLabel
                .toUpperCase(),

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  _darkColor,

              fontSize: 32,

              fontWeight:
                  FontWeight.w900,

              letterSpacing:
                  0.6,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // NRIC SUMMARY
  // ==========================================================================

  Widget _buildNricSummary(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 18,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.97,
        ),

        borderRadius:
            BorderRadius.circular(
          25,
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

            blurRadius: 14,

            offset:
                const Offset(
              0,
              6,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,

            decoration:
                BoxDecoration(
              color:
                  _primaryLight,

              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),

            child:
                const Icon(
              Icons.badge_rounded,

              color:
                  _primaryColor,

              size: 40,
            ),
          ),

          const SizedBox(
            width: 20,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  loc.loanNricLabel
                      .toUpperCase(),

                  style:
                      const TextStyle(
                    color:
                        _textMuted,

                    fontSize: 18,

                    fontWeight:
                        FontWeight.w900,

                    letterSpacing:
                        0.7,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  widget.nric,

                  style:
                      const TextStyle(
                    color:
                        _textDark,

                    fontSize: 32,

                    fontWeight:
                        FontWeight.w900,

                    letterSpacing:
                        1.7,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 9,
            ),

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE8F7EE,
              ),

              borderRadius:
                  BorderRadius.circular(
                30,
              ),
            ),

            child:
                const Icon(
              Icons
                  .check_circle_rounded,

              color:
                  _greenColor,

              size: 29,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INSTRUCTION
  // ==========================================================================

  Widget _buildInstructionBoard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 16,
      ),

      decoration:
          BoxDecoration(
        color:
            _primaryLight.withOpacity(
          0.92,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border:
            Border.all(
          color:
              _primaryColor.withOpacity(
            0.18,
          ),
          width: 1.5,
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,

        children: [
          Container(
            width: 45,
            height: 45,

            decoration:
                BoxDecoration(
              color:
                  Colors.white,

              shape:
                  BoxShape.circle,
            ),

            child:
                const Icon(
              Icons
                  .touch_app_rounded,

              color:
                  _primaryColor,

              size: 27,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Text(
              loc.loanSelectAccountSubtitle,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF43566F,
                ),

                fontSize: 23,

                fontWeight:
                    FontWeight.w800,

                height: 1.25,
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),

            decoration:
                BoxDecoration(
              color:
                  Colors.white,

              borderRadius:
                  BorderRadius.circular(
                30,
              ),

              border:
                  Border.all(
                color:
                    _primaryColor.withOpacity(
                  0.18,
                ),
              ),
            ),

            child: Text(
              '${_accounts.length}',

              style:
                  const TextStyle(
                color:
                    _primaryColor,

                fontSize: 21,

                fontWeight:
                    FontWeight.w900,
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
    PtptnSubproduct account,
    bool selected,
  ) {
    final bool isPtptn =
        account.description
            .toUpperCase()
            .contains(
          'PTPTN',
        );

    return Material(
      color:
          Colors.transparent,

      child: InkWell(
        onTap: () {
          _selectAccount(
            account,
          );
        },

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 180,
          ),

          width:
              double.infinity,

          padding:
              const EdgeInsets.fromLTRB(
            22,
            20,
            20,
            20,
          ),

          decoration:
              BoxDecoration(
            color:
                selected
                    ? const Color(
                        0xFFF1F3FF,
                      )
                    : Colors.white
                        .withOpacity(
                        0.98,
                      ),

            borderRadius:
                BorderRadius.circular(
              28,
            ),

            border:
                Border.all(
              color:
                  selected
                      ? _primaryColor
                      : _borderColor,

              width:
                  selected
                      ? 3.2
                      : 2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    selected
                        ? _primaryColor
                            .withOpacity(
                            0.14,
                          )
                        : Colors.black
                            .withOpacity(
                            0.07,
                          ),

                blurRadius:
                    selected
                        ? 18
                        : 13,

                offset:
                    const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              // ==============================================================
              // ICON
              // ==============================================================

              AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),

                width: 78,
                height: 78,

                decoration:
                    BoxDecoration(
                  color:
                      selected
                          ? _primaryColor
                          : _primaryLight,

                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                ),

                child: Icon(
                  isPtptn
                      ? Icons
                          .school_rounded
                      : Icons
                          .savings_rounded,

                  color:
                      selected
                          ? Colors.white
                          : _primaryColor,

                  size: 44,
                ),
              ),

              const SizedBox(
                width: 18,
              ),

              // ==============================================================
              // DETAILS
              // ==============================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    // ========================================================
                    // CATEGORY
                    // ========================================================

                    Text(
                      account.description
                              .isNotEmpty
                          ? account
                              .description
                          : loc
                              .loanAccountCategoryUnknown,

                      style:
                          const TextStyle(
                        color:
                            _primaryColor,

                        fontSize: 21,

                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    // ========================================================
                    // DISPLAY NAME
                    // ========================================================

                    Text(
                      account.displayName
                              .isNotEmpty
                          ? account
                              .displayName
                          : '-',

                      maxLines: 2,

                      overflow:
                          TextOverflow
                              .ellipsis,

                      style:
                          const TextStyle(
                        color:
                            _textDark,

                        fontSize: 27,

                        fontWeight:
                            FontWeight.w900,

                        height: 1.10,
                      ),
                    ),

                    const SizedBox(
                      height: 13,
                    ),

                    // ========================================================
                    // ACCOUNT NUMBER
                    // ========================================================

                    _buildDetailRow(
                      icon:
                          Icons
                              .account_balance_wallet_outlined,

                      label:
                          loc.loanAccountNumber,

                      value:
                          account.accountNumber,
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    // ========================================================
                    // TYPE
                    // ========================================================

                    _buildDetailRow(
                      icon:
                          Icons
                              .category_outlined,

                      label:
                          loc.loanAccountType,

                      value:
                          _getSubproductName(
                        loc,
                        account.subproductCode,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              // ==============================================================
              // CHECK
              // ==============================================================

              AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),

                width: 45,
                height: 45,

                decoration:
                    BoxDecoration(
                  color:
                      selected
                          ? _primaryColor
                          : Colors.white,

                  shape:
                      BoxShape.circle,

                  border:
                      Border.all(
                    color:
                        selected
                            ? _primaryColor
                            : const Color(
                                0xFFB8C4D2,
                              ),

                    width: 2.5,
                  ),
                ),

                child:
                    selected
                        ? const Icon(
                            Icons
                                .check_rounded,

                            color:
                                Colors.white,

                            size: 29,
                          )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // DETAIL ROW
  // ==========================================================================

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,

      children: [
        Icon(
          icon,

          color:
              const Color(
            0xFF718096,
          ),

          size: 21,
        ),

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child:
              RichText(
            text:
                TextSpan(
              style:
                  const TextStyle(
                color:
                    _textMuted,

                fontSize: 18,

                fontWeight:
                    FontWeight.w700,
              ),

              children: [
                TextSpan(
                  text:
                      '$label: ',

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                TextSpan(
                  text:
                      value,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF53677E,
                    ),

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // SUBPRODUCT NAME
  // ==========================================================================

  String _getSubproductName(
    AppLocalizations loc,
    String code,
  ) {
    switch (
        code.toUpperCase()) {
      case 'K':
        return loc
            .loanTypeConventional;

      case 'U':
        return loc
            .loanTypeUjrah;

      case 'S':
        return loc
            .loanTypeSspnPrime;

      case 'SP':
        return loc
            .loanTypeSspnPlus;

      default:
        return code;
    }
  }

  // ==========================================================================
  // ACTIONS
  // ==========================================================================

Widget _buildActions(
  AppLocalizations loc,
) {
  return Row(
    children: [
      // ============================================================
      // BACK BUTTON
      // ============================================================

      Expanded(
        flex: 4, // KEMBALI = 40%
        child: SizedBox(
          height: 100,
          child: OutlinedButton.icon(
            onPressed: _isNavigating
                ? null
                : () {
                    Navigator.pop(context);
                  },

            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 28,
            ),

            label: Text(
              loc.buttonBack.toUpperCase(),
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),

            style: OutlinedButton.styleFrom(
              foregroundColor: _textDark,
              backgroundColor: Colors.white,

              side: const BorderSide(
                color: _textDark,
                width: 2,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
              ),
            ),
          ),
        ),
      ),

      // ============================================================
      // GAP BETWEEN BUTTONS
      // ============================================================

      const SizedBox(
        width: 20,
      ),

      // ============================================================
      // CONTINUE BUTTON
      // ============================================================

      Expanded(
        flex: 6, // TERUSKAN = 60%
        child: SizedBox(
          height: 100,
          child: ElevatedButton.icon(
            onPressed:
                _selectedAccount == null || _isNavigating
                    ? null
                    : _handleContinue,

            icon: const Icon(
              Icons.arrow_forward_rounded,
              size: 29,
            ),

            label: Text(
              loc.loanContinue.toUpperCase(),
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),

            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

  // ==========================================================================
  // LOADING
  // ==========================================================================

  Widget _buildLoading(
    AppLocalizations loc,
  ) {
    return Center(
      child:
          Container(
        width: 650,

        padding:
            const EdgeInsets.all(
          45,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white.withOpacity(
            0.97,
          ),

          borderRadius:
              BorderRadius.circular(
            36,
          ),
        ),

        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const SizedBox(
              width: 90,
              height: 90,

              child:
                  CircularProgressIndicator(
                strokeWidth: 7,
                color:
                    _primaryColor,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            Text(
              loc.loanAccountLoadingTitle,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    _textDark,

                fontSize: 38,

                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              loc.loanAccountLoadingMessage,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    _textMuted,

                fontSize: 26,

                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildModernAccountOption(
  AppLocalizations loc,
  PtptnSubproduct account,
  bool selected,
) {
  final bool isPtptn =
      account.description
          .toUpperCase()
          .contains(
        'PTPTN',
      );

  return Material(
    color: Colors.transparent,

    child: InkWell(
      onTap: () {
        _selectAccount(
          account,
        );
      },

      borderRadius:
          BorderRadius.circular(
        22,
      ),

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),

        width:
            double.infinity,

        padding:
            const EdgeInsets.fromLTRB(
          20,
          18,
          18,
          18,
        ),

        decoration:
            BoxDecoration(
          color:
              selected
                  ? const Color(
                      0xFFF1F3FF,
                    )
                  : const Color(
                      0xFFFAFBFD,
                    ),

          borderRadius:
              BorderRadius.circular(
            22,
          ),

          border:
              Border.all(
            color:
                selected
                    ? _primaryColor
                    : const Color(
                        0xFFD6DEE8,
                      ),

            width:
                selected
                    ? 3
                    : 1.7,
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                selected
                    ? 0.09
                    : 0.04,
              ),

              blurRadius: 12,

              offset:
                  const Offset(
                0,
                5,
              ),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==============================================================
            // ICON
            // ==============================================================

            Container(
              width: 80,
              height: 80,

              decoration:
                  BoxDecoration(
                color:
                    selected
                        ? _primaryColor
                        : _primaryLight,

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: Icon(
                isPtptn
                    ? Icons
                        .school_rounded
                    : Icons
                        .savings_rounded,

                color:
                    selected
                        ? Colors.white
                        : _primaryColor,

                size: 45,
              ),
            ),

            const SizedBox(
              width: 25,
            ),

            // ==============================================================
            // DETAILS
            // ==============================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Text(
                    account.displayName
                            .isNotEmpty
                        ? account
                            .displayName
                        : '-',

                    maxLines: 2,

                    overflow:
                        TextOverflow
                            .ellipsis,

                    style:
                        const TextStyle(
                      color:
                          _textDark,

                      fontSize: 35,

                      fontWeight:
                          FontWeight
                              .w900,

                      height: 1.10,
                    ),
                  ),

                  const SizedBox(
                    height: 11,
                  ),

                  Text(
                    '${loc.loanAccountNumber}: '
                    '${account.accountNumber}',

                    style:
                        const TextStyle(
                      color:
                          _textMuted,

                      fontSize: 35,

                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    account.description
                            .isNotEmpty
                        ? account
                            .description
                        : _getSubproductName(
                            loc,
                            account
                                .subproductCode,
                          ),

                    style:
                        const TextStyle(
                      color:
                          _primaryColor,

                      fontSize: 35,

                      fontWeight:
                          FontWeight
                              .w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            // ==============================================================
            // RADIO / SELECT
            // ==============================================================

            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 180,
              ),

              width: 70,
              height: 70,

              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,

                color:
                    selected
                        ? _primaryColor
                        : Colors.white,

                border:
                    Border.all(
                  color:
                      selected
                          ? _primaryColor
                          : const Color(
                              0xFFB9C5D2,
                            ),

                  width: 2.4,
                ),
              ),

              child:
                  selected
                      ? const Icon(
                          Icons
                              .check_rounded,

                          color:
                              Colors.white,

                          size: 27,
                        )
                      : null,
            ),
          ],
        ),
      ),
    ),
  );
}

  // ==========================================================================
  // ERROR
  // ==========================================================================

  Widget _buildError(
    AppLocalizations loc,
  ) {
    return Center(
      child:
          Container(
        width: 700,

        padding:
            const EdgeInsets.all(
          45,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            38,
          ),

          border:
              Border.all(
            color:
                const Color(
              0xFFE57373,
            ),

            width: 2,
          ),
        ),

        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const Icon(
              Icons.cloud_off_rounded,

              color:
                  Color(
                0xFFD32F2F,
              ),

              size: 85,
            ),

            const SizedBox(
              height: 24,
            ),

            Text(
              loc.loanAccountErrorTitle,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    _textDark,

                fontSize: 39,

                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              loc.loanAccountErrorMessage,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 35,

                color:
                    _textMuted,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },

                    child:
                        Text(
                      loc.buttonBack,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 20,
                ),

                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        _loadAccounts,

                    icon:
                        const Icon(
                      Icons.refresh_rounded,
                    ),

                    label:
                        Text(
                      loc.loanRetry,
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _primaryColor,

                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // EMPTY
  // ==========================================================================

  Widget _buildEmpty(
    AppLocalizations loc,
  ) {
    return Center(
      child:
          Container(
        width: 700,

        padding:
            const EdgeInsets.all(
          45,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            38,
          ),

          border:
              Border.all(
            color:
                const Color(
              0xFFF1B95D,
            ),

            width: 2,
          ),
        ),

        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width: 120,
              height: 120,

              decoration:
                  const BoxDecoration(
                color:
                    Color(
                  0xFFFFF3D9,
                ),

                shape:
                    BoxShape.circle,
              ),

              child:
                  const Icon(
                Icons
                    .account_balance_wallet_outlined,

                color:
                    Color(
                  0xFFD87900,
                ),

                size: 66,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            Text(
              loc.loanNoAccountTitle,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    _textDark,

                fontSize: 39,

                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              _emptyMessage ??
                  loc.loanNoAccountMessage,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    _textMuted,

                fontSize: 26,

                fontWeight:
                    FontWeight.w600,

                height: 1.35,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width:
                  double.infinity,

              height: 80,

              child:
                  ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },

                icon:
                    const Icon(
                  Icons
                      .arrow_back_rounded,
                ),

                label:
                    Text(
                  loc.buttonBack,
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      _primaryColor,

                  foregroundColor:
                      Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}