import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:frontend_v1/pages/payment/bill/gamecredits_qr_payment_page.dart';

import 'package:frontend_v1/services/iimmpact/iimmpact_catalog_service.dart';

// ============================================================================
// GAME CREDITS PAGE 5
//
// PURPOSE:
//
// - Review selected game credit package
// - Read product fields from /v2/catalog
// - Detect role == account dynamically
// - If account/player ID is required:
//      ask user to enter it
// - If no account field:
//      no input required
// - Continue to GameCreditsQrPaymentPage
//
// CURRENT CATALOG EXAMPLES:
//
// FCMOBILEFC:
//   package only
//   no account required
//
// FF:
//   player_id
//   role = account
//   input_mode = numeric
//
// Nothing below hardcodes FF or FCMOBILEFC.
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

  final TextEditingController _accountController =
      TextEditingController();

  final FocusNode _accountFocusNode =
      FocusNode();

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
  // BASIC VALUES
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
  // ACCOUNT FIELD
  // ==========================================================================

  bool get _accountRequired =>
      _accountField != null &&
      _accountField?['required'] == true;

  String get _accountFieldId =>
      _accountField?['id']
              ?.toString()
              .trim() ??
          '';

  String get _accountFieldLabel {
    final String value =
        _accountField?['label']
                ?.toString()
                .trim() ??
            '';

    return value;
  }

  String get _accountPlaceholder {
    final String value =
        _accountField?['placeholder']
                ?.toString()
                .trim() ??
            '';

    return value;
  }

  String get _accountInputMode =>
      _accountField?['input_mode']
              ?.toString()
              .trim()
              .toLowerCase() ??
          'text';

  bool get _numericAccount =>
      _accountInputMode == 'numeric' ||
      _accountInputMode == 'number' ||
      _accountInputMode == 'tel';

  // ==========================================================================
  // VALIDATION
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

  String get _validationMessage {
    final dynamic validationRaw =
        _accountField?['validation'];

    if (validationRaw is! Map) {
      return '';
    }

    return validationRaw['message']
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
    _accountController.dispose();
    _accountFocusNode.dispose();

    super.dispose();
  }

  // ==========================================================================
  // LOAD PRODUCT
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
          await IimmpactCatalogService
              .getCatalog();

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
      // FIND ACCOUNT FIELD
      //
      // role == account
      // ======================================================================

      Map<String, dynamic>? accountField;

      final dynamic fieldsRaw =
          product['fields'];

      if (fieldsRaw is List) {
        for (final dynamic rawField
            in fieldsRaw) {
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
            accountField =
                field;

            break;
          }
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _product =
            product;

        _accountField =
            accountField;

        _isLoading =
            false;

        _errorMessage =
            null;
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
        'Product       : $_code',
      );
      debugPrint(
        'Account Field : $_accountFieldId',
      );
      debugPrint(
        'Account Req   : $_accountRequired',
      );
      debugPrint(
        'Input Mode    : $_accountInputMode',
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
        'Game Credits Page 5 error: '
        '$error',
      );

      debugPrintStack(
        stackTrace:
            stackTrace,
      );

      _setError(
        error.toString(),
      );
    }
  }

  void _setError(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage =
          message;

      _isLoading =
          false;
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

  String _formatSignedMoney(
    double amount,
  ) {
    final String sign =
        amount >= 0
            ? '+'
            : '-';

    return '$sign RM '
        '${amount.abs().toStringAsFixed(2)}';
  }

  // ==========================================================================
  // KEYPAD
  // ==========================================================================

  void _addNumber(
    String number,
  ) {
    final String current =
        _accountController.text;

    if (current.length >= 30) {
      return;
    }

    setState(() {
      _accountController.text =
          '$current$number';

      _accountController.selection =
          TextSelection.collapsed(
        offset:
            _accountController
                .text.length,
      );
    });
  }

  void _backspace() {
    final String current =
        _accountController.text;

    if (current.isEmpty) {
      return;
    }

    setState(() {
      _accountController.text =
          current.substring(
        0,
        current.length - 1,
      );

      _accountController.selection =
          TextSelection.collapsed(
        offset:
            _accountController
                .text.length,
      );
    });
  }

  void _clearAccount() {
    setState(() {
      _accountController.clear();
    });
  }

  // ==========================================================================
  // VALIDATE ACCOUNT
  // ==========================================================================

  bool _validateAccount() {
    if (!_accountRequired) {
      return true;
    }

    final String value =
        _accountController.text.trim();

    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    if (value.isEmpty) {
      _showMessage(
        loc.gameCreditsAccountRequired,
      );

      return false;
    }

    final String pattern =
        _validationPattern;

    if (pattern.isNotEmpty) {
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
          'Invalid account regex from catalog: '
          '$pattern | $error',
        );
      }
    }

    return true;
  }

  // ==========================================================================
  // CONTINUE
  // ==========================================================================

  Future<void> _handleContinue() async {
    if (!_validateAccount()) {
      return;
    }

    final String account =
        _accountRequired
            ? _accountController
                .text
                .trim()
            : '';

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
          // IMPORTANT
          //
          // Game Credit fulfillment in catalog:
          //
          // selected option
          //      ↓
          // price.amount
          //      ↓
          // amount sent to IIMMPACT
          //
          // Therefore this is baseAmount.
          // ================================================================

          iimmpactAmount:
              widget.baseAmount,

          baseAmount:
              widget.baseAmount,

          serviceAdjustment:
              widget.adjustmentAmount,

          totalAmount:
              widget.totalAmount,

          account:
              account,

          accountRequired:
              _accountRequired,

          accountLabel:
              _accountFieldLabel,

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
              fit:
                  BoxFit.cover,
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
                                strokeWidth:
                                    6,
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
        horizontal:
            32,
        vertical:
            22,
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
            Color(
              0xFF087A70,
            ),
            Color(
              0xFF009688,
            ),
            Color(
              0xFF35B7A8,
            ),
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
              color:
                  Colors.white,
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
            width:
                24,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _productName
                      .toUpperCase(),
                  maxLines:
                      2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize:
                        35,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height:
                      6,
                ),

                Text(
                  loc.gameCreditsReviewTitle,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize:
                        23,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons
                .verified_user_rounded,
            color:
                Colors.white,
            size:
                58,
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
            height:
                26,
          ),

          if (_accountRequired)
            _buildAccountCard(
              loc,
            )
          else
            _buildNoAccountCard(
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
        color:
            Colors.white,
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
          width:
              2,
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
              fontSize:
                  33,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height:
                24,
          ),

          _infoRow(
            loc.gameCreditsProductLabel,
            _productName,
          ),

          const Divider(
            height:
                34,
          ),

          _infoRow(
            loc.gameCreditsSelectedOptionLabel,
            widget.optionName,
          ),

          if (widget.optionDescription
              .trim()
              .isNotEmpty) ...[
            const Divider(
              height:
                  34,
            ),

            _infoRow(
              loc.gameCreditsCreditLabel,
              widget.optionDescription,
            ),
          ],

          const Divider(
            height:
                34,
          ),

          _infoRow(
            loc.gameCreditsTotalAmountLabel,
            _formatMoney(
              widget.totalAmount,
            ),
            highlight:
                true,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ACCOUNT INPUT
  // ==========================================================================

  Widget _buildAccountCard(
    AppLocalizations loc,
  ) {
    final String title =
        _accountFieldLabel.isNotEmpty
            ? _accountFieldLabel
            : loc.gameCreditsAccountLabel;

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        30,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        border:
            Border.all(
          color:
              _primaryColor
                  .withOpacity(
            0.35,
          ),
          width:
              2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons
                .person_search_rounded,
            color:
                _primaryColor,
            size:
                72,
          ),

          const SizedBox(
            height:
                18,
          ),

          Text(
            loc.gameCreditsEnterAccountTitle,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF102A43,
              ),
              fontSize:
                  34,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height:
                10,
          ),

          Text(
            loc.gameCreditsEnterAccountSubtitle,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF66758A,
              ),
              fontSize:
                  28,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height:
                26,
          ),

          Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              title,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),
                fontSize:
                    30,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(
            height:
                20,
          ),

          TextField(
            controller:
                _accountController,
            focusNode:
                _accountFocusNode,
            readOnly:
                _numericAccount,
            keyboardType:
                _numericAccount
                    ? TextInputType.none
                    : TextInputType.text,
            inputFormatters:
                _numericAccount
                    ? <TextInputFormatter>[
                        FilteringTextInputFormatter
                            .digitsOnly,
                      ]
                    : null,
            style:
                const TextStyle(
              fontSize:
                  34,
              fontWeight:
                  FontWeight.w900,
            ),
            decoration:
                InputDecoration(
              hintText:
                  _accountPlaceholder.isNotEmpty
                      ? _accountPlaceholder
                      : loc.gameCreditsAccountHint,
              hintStyle:
                  const TextStyle(
                fontSize:
                    30,
                color:
                    Color(
                  0xFF8A98A8,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal:
                    24,
                vertical:
                    24,
              ),
              filled:
                  true,
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
                  width:
                      2,
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
                  width:
                      3,
                ),
              ),
            ),
          ),

          if (_numericAccount) ...[
            const SizedBox(
              height:
                  24,
            ),

            _buildKeypad(
              loc,
            ),
          ],

          const SizedBox(
            height:
                40,
          ),

          Text(
            loc.gameCreditsCheckAccountMessage,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF657386,
              ),
              fontSize:
                  30,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // NO ACCOUNT REQUIRED
  // ==========================================================================

  Widget _buildNoAccountCard(
    AppLocalizations loc,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        34,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFEAF8F3,
        ),
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFF87CDB4,
          ),
          width:
              2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons
                .check_circle_rounded,
            color:
                _greenColor,
            size:
                78,
          ),

          const SizedBox(
            height:
                16,
          ),

          Text(
            loc.gameCreditsNoAccountRequiredTitle,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF12613D,
              ),
              fontSize:
                  30,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height:
                10,
          ),

          Text(
            loc.gameCreditsNoAccountRequiredMessage,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF376552,
              ),
              fontSize:
                  22,
              height:
                  1.35,
              fontWeight:
                  FontWeight.w600,
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
        // ================================================================
        // ROW 1
        // ================================================================

        Row(
          children: [
            Expanded(
              child: _keypadButton(
                '1',
                () => _addNumber('1'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _keypadButton(
                '2',
                () => _addNumber('2'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _keypadButton(
                '3',
                () => _addNumber('3'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ================================================================
        // ROW 2
        // ================================================================

        Row(
          children: [
            Expanded(
              child: _keypadButton(
                '4',
                () => _addNumber('4'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _keypadButton(
                '5',
                () => _addNumber('5'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _keypadButton(
                '6',
                () => _addNumber('6'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ================================================================
        // ROW 3
        // ================================================================

        Row(
          children: [
            Expanded(
              child: _keypadButton(
                '7',
                () => _addNumber('7'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _keypadButton(
                '8',
                () => _addNumber('8'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _keypadButton(
                '9',
                () => _addNumber('9'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ================================================================
        // ROW 4
        //
        // ALL THREE USE EXACTLY THE SAME SIZE
        // ================================================================

        Row(
          children: [
            Expanded(
              child: _keypadActionButton(
                loc.keyboardClearAll,
                Icons.delete_sweep_rounded,
                _clearAccount,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _keypadButton(
                '0',
                () => _addNumber('0'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _keypadActionButton(
                loc.keyboardBackspace,
                Icons.backspace_outlined,
                _backspace,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _keypadButton(
    String text,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,

      // Change this to control keypad button height
      height: 112,

      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: const Color(
            0xFFF4F7FA,
          ),
          foregroundColor: const Color(
            0xFF17283E,
          ),
          elevation: 0,
          side: const BorderSide(
            color: Color(
              0xFFC9D5E2,
            ),
            width: 2.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            // Bigger number
            fontSize: 44,
            fontWeight: FontWeight.w900,
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
      width: double.infinity,
      height: 112, // SAME height as number buttons

      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          backgroundColor: const Color(
            0xFFE2EAF2,
          ),
          foregroundColor: const Color(
            0xFF17283E,
          ),
          elevation: 0,
          side: const BorderSide(
            color: Color(
              0xFFC9D5E2,
            ),
            width: 2.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ============================================================
            // BIGGER ICON
            // ============================================================

            Icon(
              icon,
              size: 40,
            ),

            const SizedBox(
              height: 5,
            ),

            // ============================================================
            // BIGGER PADAM SEMUA / PADAM TEXT
            // ============================================================

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
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
          child:
              Text(
            label,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF66758A,
              ),
              fontSize:
                  24,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(
          width:
              20,
        ),

        Expanded(
          child:
              Text(
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
                  height:
                      95,
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon:
                        const Icon(
                      Icons
                          .arrow_back_rounded,
                      size:
                          32,
                    ),
                    label:
                        Text(
                      loc.buttonBack,
                      style:
                          const TextStyle(
                        fontSize:
                            34,
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
                        width:
                            2,
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
                width:
                    24,
              ),

              Expanded(
                child:
                    SizedBox(
                  height:
                      95,
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
                      size:
                          32,
                    ),
                    label:
                        Text(
                      loc.gameCreditsContinuePayment,
                      style:
                          const TextStyle(
                        fontSize:
                            25,
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
            height:
                30,
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
              fontSize:
                  20,
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
        width:
            680,
        padding:
            const EdgeInsets.all(
          40,
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
                const Color(
              0xFFE57373,
            ),
            width:
                2,
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .cloud_off_rounded,
              color:
                  _redColor,
              size:
                  80,
            ),

            const SizedBox(
              height:
                  20,
            ),

            Text(
              loc.gameCreditsUnableToLoadDetails,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF17283E,
                ),
                fontSize:
                    30,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height:
                  25,
            ),

            SizedBox(
              height:
                  75,
              width:
                  300,
              child:
                  ElevatedButton.icon(
                onPressed:
                    _loadProduct,
                icon:
                    const Icon(
                  Icons
                      .refresh_rounded,
                ),
                label:
                    Text(
                  loc.retryButton,
                  style:
                      const TextStyle(
                    fontSize:
                        23,
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
        Icons
            .videogame_asset_rounded,
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
          Icons
              .videogame_asset_rounded,
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
      context:
          context,
      barrierDismissible:
          false,
      builder:
          (
        dialogContext,
      ) {
        return AlertDialog(
          title:
              Text(
            loc.gameCreditsInformation,
          ),
          content:
              Text(
            message,
            style:
                const TextStyle(
              fontSize:
                  24,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  Text(
                loc.electricOk,
              ),
            ),
          ],
        );
      },
    );
  }
}