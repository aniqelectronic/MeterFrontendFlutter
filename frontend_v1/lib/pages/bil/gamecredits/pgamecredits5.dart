import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/payment/bill/gamecredits_qr_payment_page.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

// ============================================================================
// GAME CREDITS PAGE 5
//
// NEW FLOW:
//
// IF catalog has:
//   role == account
//
// Example:
//   Free Fire
//   player_id
//
// THEN:
//   Ask for actual game account / Player ID.
//
// OTHERWISE:
//   Ask for Malaysian phone number.
//   Phone number is only a transaction/reference number.
//   It is NOT described as the user's game account.
//
// Both values are sent to IIMMPACT through the "account" parameter because
// /v2/topup expects an account/reference value.
// ============================================================================

class PGAMECREDITS5PAGE extends StatefulWidget {
  final String productCode;
  final String productName;
  final String imageUrl;

  final String fieldId;

  final String optionCode;
  final String optionName;
  final String optionDescription;

  final double baseAmount;
  final double adjustmentAmount;
  final double totalAmount;

  final String processingTime;
  final double iimmpactAmount;


  const PGAMECREDITS5PAGE({
    super.key,
    required this.productCode,
    required this.productName,
    required this.imageUrl,
    required this.fieldId,
    required this.optionCode,
    required this.optionName,
    required this.optionDescription,
    required this.baseAmount,
    required this.adjustmentAmount,
    required this.totalAmount,
    required this.processingTime,
    required this.iimmpactAmount,
  });

  @override
  State<PGAMECREDITS5PAGE> createState() =>
      _PGAMECREDITS5PAGEState();
}

class _PGAMECREDITS5PAGEState
    extends State<PGAMECREDITS5PAGE> {
  // ==========================================================================
  // CONTROLLER
  // ==========================================================================

  final TextEditingController _referenceController =
      TextEditingController();

  // ==========================================================================
  // PRODUCT DATA
  // ==========================================================================

  Map<String, dynamic>? _product;

  Map<String, dynamic>? _accountField;

  bool _isLoading = true;

  String? _errorMessage;

  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color _primaryColor =
      Color(0xFF009688);

  static const Color _darkColor =
      Color(0xFF087A70);

  static const Color _lightColor =
      Color(0xFFE0F5F2);

  static const Color _greenColor =
      Color(0xFF16813B);

  static const Color _redColor =
      Color(0xFFD93A3A);

  // ==========================================================================
  // BASIC
  // ==========================================================================

  String get _code =>
      widget.productCode
          .trim()
          .toUpperCase();

  String get _productName {
    final String catalogName =
        _product?['name']
                ?.toString()
                .trim() ??
            '';

    return catalogName.isNotEmpty
        ? catalogName
        : widget.productName;
  }

  String get _imageUrl {
    final String catalogImage =
        _product?['image_url']
                ?.toString()
                .trim() ??
            '';

    return catalogImage.isNotEmpty
        ? catalogImage
        : widget.imageUrl;
  }

  // ==========================================================================
  // DOES THIS PRODUCT HAVE AN ACTUAL GAME ACCOUNT FIELD?
  //
  // We do NOT hardcode Free Fire.
  //
  // Catalog decides:
  // role == account
  // ==========================================================================

  bool get _hasGameAccountField =>
      _accountField != null;

  bool get _gameAccountRequired =>
      _accountField?['required'] == true;

  // ==========================================================================
  // CATALOG ACCOUNT FIELD
  // ==========================================================================

  String get _accountFieldId =>
      _accountField?['id']
              ?.toString()
              .trim() ??
          '';

  String get _catalogAccountLabel =>
      _accountField?['label']
              ?.toString()
              .trim() ??
          '';

  String get _catalogAccountPlaceholder =>
      _accountField?['placeholder']
              ?.toString()
              .trim() ??
          '';

  String get _catalogInputMode =>
      _accountField?['input_mode']
              ?.toString()
              .trim()
              .toLowerCase() ??
          'text';

  bool get _catalogNumeric =>
      _catalogInputMode == 'numeric' ||
      _catalogInputMode == 'number' ||
      _catalogInputMode == 'tel';

  // ==========================================================================
  // CATALOG VALIDATION
  // ==========================================================================

  String get _validationPattern {
    final dynamic validationRaw =
        _accountField?['validation'];

    if (validationRaw is! Map) {
      return '';
    }

    return validationRaw['pattern']
            ?.toString()
            .trim() ??
        '';
  }

  // ==========================================================================
  // LIFE CYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _loadProduct();
  }

  @override
  void dispose() {
    _referenceController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // LOAD CATALOG PRODUCT
  // ==========================================================================

  Future<void> _loadProduct() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final Map<String, dynamic> catalog =
          await IimmpactCatalogService.getCatalog();

      final dynamic productsRaw =
          catalog['products'];

      if (productsRaw is! Map) {
        throw Exception(
          'Catalog products missing.',
        );
      }

      final dynamic rawProduct =
          productsRaw[_code];

      if (rawProduct is! Map) {
        throw Exception(
          'Game credit product $_code not found.',
        );
      }

      final Map<String, dynamic> product =
          Map<String, dynamic>.from(
        rawProduct,
      );

      if (product['is_active'] != true) {
        throw Exception(
          'Game credit product $_code unavailable.',
        );
      }

      // ======================================================================
      // FIND ACTUAL GAME ACCOUNT FIELD
      //
      // Example:
      //
      // Free Fire:
      // {
      //   "id": "player_id",
      //   "label": "Player ID",
      //   "role": "account",
      //   "required": true
      // }
      // ======================================================================

      Map<String, dynamic>? accountField;

      final dynamic fieldsRaw =
          product['fields'];

      if (fieldsRaw is List) {
        for (final dynamic rawField in fieldsRaw) {
          if (rawField is! Map) {
            continue;
          }

          final Map<String, dynamic> field =
              Map<String, dynamic>.from(
            rawField,
          );

          final String role =
              field['role']
                      ?.toString()
                      .trim()
                      .toLowerCase() ??
                  '';

          if (role == 'account') {
            accountField = field;
            break;
          }
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;
        _accountField = accountField;

        _isLoading = false;
        _errorMessage = null;

        _referenceController.clear();
      });

      debugPrint('');
      debugPrint(
        '========================================',
      );
      debugPrint(
        'GAME CREDITS PAGE 5',
      );
      debugPrint(
        '========================================',
      );
      debugPrint(
        'Product            : $_code',
      );
      debugPrint(
        'Has Game Account   : $_hasGameAccountField',
      );
      debugPrint(
        'Account Field      : $_accountFieldId',
      );
      debugPrint(
        'Game Account Req   : $_gameAccountRequired',
      );
      debugPrint(
        'Reference Type     : '
        '${_hasGameAccountField ? 'GAME ACCOUNT' : 'PHONE REFERENCE'}',
      );
      debugPrint(
        '========================================',
      );
      debugPrint('');
    } on IimmpactCatalogException catch (error) {
      _setError(
        error.message,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Game Credits Page 5 error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _setError(
        error.toString(),
      );
    }
  }

  // ==========================================================================
  // ERROR
  // ==========================================================================

  void _setError(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  // ==========================================================================
  // MONEY
  // ==========================================================================

  String _formatMoney(
    double amount,
  ) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  // ==========================================================================
  // KEYPAD
  // ==========================================================================

  void _addNumber(
    String number,
  ) {
    final String current =
        _referenceController.text;

    // Phone max = 11.
    // Game account allows longer IDs.
    final int maxLength =
        _hasGameAccountField
            ? 30
            : 11;

    if (current.length >= maxLength) {
      return;
    }

    setState(() {
      _referenceController.text =
          '$current$number';

      _referenceController.selection =
          TextSelection.collapsed(
        offset:
            _referenceController
                .text
                .length,
      );
    });
  }

  void _backspace() {
    final String current =
        _referenceController.text;

    if (current.isEmpty) {
      return;
    }

    setState(() {
      _referenceController.text =
          current.substring(
        0,
        current.length - 1,
      );

      _referenceController.selection =
          TextSelection.collapsed(
        offset:
            _referenceController
                .text
                .length,
      );
    });
  }

  void _clearReference() {
    setState(() {
      _referenceController.clear();
    });
  }

  // ==========================================================================
  // VALIDATE
  // ==========================================================================

  bool _validateReference() {
    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    final String value =
        _referenceController.text.trim();

    // ========================================================================
    // GAME ACCOUNT MODE
    //
    // Use catalog validation.
    // ========================================================================

    if (_hasGameAccountField) {
      if (_gameAccountRequired &&
          value.isEmpty) {
        _showMessage(
          loc.gameCreditsAccountRequired,
        );

        return false;
      }

      final String pattern =
          _validationPattern;

      if (pattern.isNotEmpty &&
          value.isNotEmpty) {
        try {
          final RegExp regex =
              RegExp(
            pattern,
          );

          if (!regex.hasMatch(value)) {
            _showMessage(
              loc.gameCreditsAccountInvalid,
            );

            return false;
          }
        } catch (error) {
          debugPrint(
            'Invalid catalog account regex: '
            '$pattern | $error',
          );
        }
      }

      return true;
    }

    // ========================================================================
    // PHONE REFERENCE MODE
    //
    // Malaysian mobile:
    // - numeric
    // - starts 01
    // - 9 - 11 digits
    // ========================================================================

    if (value.isEmpty) {
      _showMessage(
        loc.gameCreditsPhoneRequired,
      );

      return false;
    }

    if (!RegExp(
      r'^01[0-9]{7,9}$',
    ).hasMatch(value)) {
      _showMessage(
        loc.gameCreditsPhoneInvalid,
      );

      return false;
    }

    return true;
  }

  // ==========================================================================
  // CONTINUE
  // ==========================================================================

  Future<void> _handleContinue() async {
    if (!_validateReference()) {
      return;
    }

    final String reference =
        _referenceController.text.trim();

    // ========================================================================
    // ACCOUNT LABEL FOR PAYMENT / RECEIPT
    //
    // Free Fire:
    // "Player ID"
    //
    // Other products:
    // localized "Phone Number Reference"
    // ========================================================================

    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    final String accountLabel =
        _hasGameAccountField
            ? (
                _catalogAccountLabel
                        .isNotEmpty
                    ? _catalogAccountLabel
                    : loc
                        .gameCreditsAccountLabel
              )
            : loc
                .gameCreditsPhoneReferenceLabel;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                GameCreditsQrPaymentPage(
          gameName:
              _productName,

          productCode:
              _code,

          optionCode:
              widget.optionCode,

          optionName:
              widget.optionName,

          optionDescription:
              widget.optionDescription,

          // ================================================================
          // DENOMINATION SENT TO IIMMPACT
          // MLBB example = 14
          // ================================================================

          iimmpactAmount:
              widget.iimmpactAmount,

          // ================================================================
          // FULFILLMENT AMOUNT
          // ================================================================
          baseAmount:
              widget.baseAmount,

          serviceAdjustment:
              widget.adjustmentAmount,

          totalAmount:
              widget.totalAmount,

          // ================================================================
          // IMPORTANT
          //
          // Free Fire:
          // account = Player ID
          //
          // Others:
          // account = phone reference
          // ================================================================

          account:
              reference,

          // Always true now because Page 5 always
          // provides either Player ID or phone reference.
          accountRequired:
              true,

          accountLabel:
              accountLabel,

          // Allows payment/receipt UI to distinguish
          // actual game account vs reference phone.
          isGameAccount:
              _hasGameAccountField,

          processingTime:
              widget.processingTime,
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/images/pnew.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(
                  loc,
                ),

                Expanded(
                  child:
                      _isLoading
                          ? const Center(
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 6,
                                color:
                                    _primaryColor,
                              ),
                            )
                          : _errorMessage != null
                              ? _buildError(
                                  loc,
                                )
                              : _buildContent(
                                  loc,
                                ),
                ),

                _buildBottomArea(
                  loc,
                ),
              ],
            ),
          ),
        ],
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
      margin:
          const EdgeInsets.fromLTRB(
        65,
        30,
        65,
        0,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 22,
      ),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF087A70),
            Color(0xFF009688),
            Color(0xFF35B7A8),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 105,
            height: 105,
            padding:
                const EdgeInsets.all(
              14,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                22,
              ),
            ),
            child:
                _buildLogo(
              60,
            ),
          ),

          const SizedBox(
            width: 24,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _productName.toUpperCase(),
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  loc.gameCreditsReviewTitle,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 23,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.verified_user_rounded,
            color: Colors.white,
            size: 58,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CONTENT
  // ==========================================================================

  Widget _buildContent(
    AppLocalizations loc,
  ) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        65,
        32,
        65,
        35,
      ),
      child: Column(
        children: [
          _buildSelectedPackageCard(
            loc,
          ),

          const SizedBox(
            height: 26,
          ),

          // ==================================================================
          // ALWAYS SHOW AN INPUT PAGE
          //
          // Actual account field:
          // Player ID etc.
          //
          // Otherwise:
          // Phone transaction reference.
          // ==================================================================

          _buildReferenceCard(
            loc,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SELECTED PACKAGE
  // ==========================================================================

  Widget _buildSelectedPackageCard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        30,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD3DCE8,
          ),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            loc.gameCreditsReviewSelection,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF102A43,
              ),
              fontSize: 33,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          _infoRow(
            loc.gameCreditsProductLabel,
            _productName,
          ),

          const Divider(
            height: 34,
          ),

          _infoRow(
            loc.gameCreditsSelectedOptionLabel,
            widget.optionName,
          ),

          if (widget.optionDescription
              .trim()
              .isNotEmpty) ...[
            const Divider(
              height: 34,
            ),

            _infoRow(
              loc.gameCreditsCreditLabel,
              widget.optionDescription,
            ),
          ],

          const Divider(
            height: 34,
          ),

          _infoRow(
            loc.gameCreditsTotalAmountLabel,
            _formatMoney(
              widget.totalAmount,
            ),
            highlight: true,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // REFERENCE CARD
  // ==========================================================================

  Widget _buildReferenceCard(
    AppLocalizations loc,
  ) {
    final bool gameAccount =
        _hasGameAccountField;

    final String fieldLabel =
        gameAccount
            ? (
                _catalogAccountLabel
                        .isNotEmpty
                    ? _catalogAccountLabel
                    : loc
                        .gameCreditsAccountLabel
              )
            : loc
                .gameCreditsPhoneReferenceLabel;

    final String hint =
        gameAccount
            ? (
                _catalogAccountPlaceholder
                        .isNotEmpty
                    ? _catalogAccountPlaceholder
                    : loc
                        .gameCreditsAccountHint
              )
            : loc
                .gameCreditsPhoneReferenceHint;

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        30,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        border:
            Border.all(
          color:
              _primaryColor.withOpacity(
            0.35,
          ),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            gameAccount
                ? Icons.person_search_rounded
                : Icons.phone_iphone_rounded,
            color:
                _primaryColor,
            size: 72,
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            gameAccount
                ? loc
                    .gameCreditsEnterAccountTitle
                : loc
                    .gameCreditsEnterPhoneReferenceTitle,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF102A43,
              ),
              fontSize: 34,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            gameAccount
                ? loc
                    .gameCreditsEnterAccountSubtitle
                : loc
                    .gameCreditsEnterPhoneReferenceSubtitle,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF66758A,
              ),
              fontSize: 28,
              height: 1.3,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 26,
          ),

          Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              fieldLabel,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),
                fontSize: 30,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // ==================================================================
          // INPUT
          //
          // Use kiosk keypad.
          // ==================================================================

          TextField(
            controller:
                _referenceController,

            readOnly: true,

            keyboardType:
                TextInputType.none,

            inputFormatters:
                <TextInputFormatter>[
              FilteringTextInputFormatter
                  .digitsOnly,
            ],

            style:
                const TextStyle(
              fontSize: 36,
              fontWeight:
                  FontWeight.w900,
            ),

            decoration:
                InputDecoration(
              hintText:
                  hint,

              hintStyle:
                  const TextStyle(
                fontSize: 28,
                color:
                    Color(
                  0xFF8A98A8,
                ),
                fontWeight:
                    FontWeight.w700,
              ),

              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 25,
              ),

              filled: true,

              fillColor:
                  const Color(
                0xFFF7FAFC,
              ),

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      Color(
                    0xFFC9D5E2,
                  ),
                  width: 2,
                ),
              ),

              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      _primaryColor,
                  width: 3,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          _buildKeypad(
            loc,
          ),

          const SizedBox(
            height: 35,
          ),

          // ==================================================================
          // EXPLANATION
          // ==================================================================

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets.all(
              18,
            ),
            decoration:
                BoxDecoration(
              color:
                  gameAccount
                      ? const Color(
                          0xFFFFF8E8,
                        )
                      : const Color(
                          0xFFEAF8F3,
                        ),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  gameAccount
                      ? Icons
                          .warning_amber_rounded
                      : Icons
                          .info_outline_rounded,
                  color:
                      gameAccount
                          ? const Color(
                              0xFFE38A00,
                            )
                          : _primaryColor,
                  size: 34,
                ),

                const SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: Text(
                    gameAccount
                        ? loc
                            .gameCreditsCheckAccountMessage
                        : loc
                            .gameCreditsPhoneReferenceNotice,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF4D6375,
                      ),
                      fontSize: 24,
                      height: 1.35,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // KEYPAD
  // ==========================================================================

  Widget _buildKeypad(
    AppLocalizations loc,
  ) {
    return Column(
      children: [
        _numberRow(
          '1',
          '2',
          '3',
        ),

        const SizedBox(
          height: 15,
        ),

        _numberRow(
          '4',
          '5',
          '6',
        ),

        const SizedBox(
          height: 15,
        ),

        _numberRow(
          '7',
          '8',
          '9',
        ),

        const SizedBox(
          height: 15,
        ),

        Row(
          children: [
            Expanded(
              child:
                  _keypadActionButton(
                loc.keyboardClearAll,
                Icons
                    .delete_sweep_rounded,
                _clearReference,
              ),
            ),

            const SizedBox(
              width: 15,
            ),

            Expanded(
              child:
                  _keypadButton(
                '0',
                () =>
                    _addNumber(
                  '0',
                ),
              ),
            ),

            const SizedBox(
              width: 15,
            ),

            Expanded(
              child:
                  _keypadActionButton(
                loc.keyboardBackspace,
                Icons
                    .backspace_outlined,
                _backspace,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _numberRow(
    String first,
    String second,
    String third,
  ) {
    return Row(
      children: [
        Expanded(
          child:
              _keypadButton(
            first,
            () => _addNumber(
              first,
            ),
          ),
        ),

        const SizedBox(
          width: 15,
        ),

        Expanded(
          child:
              _keypadButton(
            second,
            () => _addNumber(
              second,
            ),
          ),
        ),

        const SizedBox(
          width: 15,
        ),

        Expanded(
          child:
              _keypadButton(
            third,
            () => _addNumber(
              third,
            ),
          ),
        ),
      ],
    );
  }

  Widget _keypadButton(
    String text,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width:
          double.infinity,
      height: 112,
      child:
          ElevatedButton(
        onPressed:
            onPressed,
        style:
            ElevatedButton.styleFrom(
          padding:
              EdgeInsets.zero,
          backgroundColor:
              const Color(
            0xFFF4F7FA,
          ),
          foregroundColor:
              const Color(
            0xFF17283E,
          ),
          elevation: 0,
          side:
              const BorderSide(
            color:
                Color(
              0xFFC9D5E2,
            ),
            width: 2.5,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
        ),
        child: Text(
          text,
          style:
              const TextStyle(
            fontSize: 44,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _keypadActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width:
          double.infinity,
      height: 112,
      child:
          ElevatedButton(
        onPressed:
            onPressed,
        style:
            ElevatedButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          backgroundColor:
              const Color(
            0xFFE2EAF2,
          ),
          foregroundColor:
              const Color(
            0xFF17283E,
          ),
          elevation: 0,
          side:
              const BorderSide(
            color:
                Color(
              0xFFC9D5E2,
            ),
            width: 2.5,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
            ),

            const SizedBox(
              height: 5,
            ),

            FittedBox(
              fit:
                  BoxFit.scaleDown,
              child: Text(
                text,
                maxLines: 1,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // INFO ROW
  // ==========================================================================

  Widget _infoRow(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF66758A,
              ),
              fontSize: 24,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(
          width: 20,
        ),

        Expanded(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            style:
                TextStyle(
              color:
                  highlight
                      ? _primaryColor
                      : const Color(
                          0xFF17283E,
                        ),
              fontSize:
                  highlight
                      ? 30
                      : 26,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // BOTTOM
  // ==========================================================================

  Widget _buildBottomArea(
    AppLocalizations loc,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        65,
        18,
        65,
        55,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child:
                    SizedBox(
                  height: 95,
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
                      size: 32,
                    ),
                    label: Text(
                      loc.buttonBack,
                      style:
                          const TextStyle(
                        fontSize: 34,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.white,
                      foregroundColor:
                          Colors.black,
                      side:
                          const BorderSide(
                        color:
                            Color(
                          0xFFD5DCE5,
                        ),
                        width: 2,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 24,
              ),

              Expanded(
                child:
                    SizedBox(
                  height: 95,
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : _handleContinue,
                    icon:
                        const Icon(
                      Icons
                          .arrow_forward_rounded,
                      size: 32,
                    ),
                    label: Text(
                      loc
                          .gameCreditsContinuePayment,
                      style:
                          const TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _greenColor,
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 30,
          ),

          Text(
            Data.copyrightText,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF17375E,
              ),
              fontSize: 20,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
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
      child: Container(
        width: 680,
        padding:
            const EdgeInsets.all(
          40,
        ),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            30,
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
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: _redColor,
              size: 80,
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              loc
                  .gameCreditsUnableToLoadDetails,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),
                fontSize: 30,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            SizedBox(
              height: 75,
              width: 300,
              child:
                  ElevatedButton.icon(
                onPressed:
                    _loadProduct,
                icon:
                    const Icon(
                  Icons.refresh_rounded,
                ),
                label: Text(
                  loc.retryButton,
                  style:
                      const TextStyle(
                    fontSize: 23,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // LOGO
  // ==========================================================================

  Widget _buildLogo(
    double fallbackSize,
  ) {
    if (_imageUrl.isEmpty) {
      return Icon(
        Icons.videogame_asset_rounded,
        color:
            _primaryColor,
        size:
            fallbackSize,
      );
    }

    return Image.network(
      _imageUrl,
      fit:
          BoxFit.contain,
      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        return Icon(
          Icons.videogame_asset_rounded,
          color:
              _primaryColor,
          size:
              fallbackSize,
        );
      },
    );
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  void _showMessage(
    String message,
  ) {
    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      barrierDismissible:
          false,
      builder:
          (
        dialogContext,
      ) {
        return AlertDialog(
          title: Text(
            loc.gameCreditsInformation,
          ),
          content: Text(
            message,
            style:
                const TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: Text(
                loc.electricOk,
              ),
            ),
          ],
        );
      },
    );
  }
}