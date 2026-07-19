import 'package:flutter/material.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';

import 'package:flutter/material.dart';

import 'package:frontend_v1/controllers/electric/electric_bill_controller.dart';
import 'package:frontend_v1/controllers/electric/electric_bill_exception.dart';
import 'package:frontend_v1/controllers/electric/electric_bill_service.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/p5_electric_bill_result.dart';

class P4BILPAGE extends StatefulWidget {
  final String title;
  final String hint;

  /// Examples:
  /// TNB, SESCO, SESB, NUR
  final String productCode;

  /// Examples:
  /// Tenaga Nasional Berhad, Sarawak Energy
  final String billerName;

  const P4BILPAGE({
    super.key,
    required this.title,
    required this.hint,
    required this.productCode,
    required this.billerName,
  });

  @override
  State<P4BILPAGE> createState() => _P4BILPAGEState();
}

class _P4BILPAGEState extends State<P4BILPAGE> {
  final TextEditingController _controller = TextEditingController();

  String? _activeKey;
  Offset? _activeKeyPosition;

  bool _isLoading = false;

  // =========================================================
  // ACCOUNT NUMBER LENGTH
  // =========================================================

  int get _maximumInputLength {
    switch (widget.productCode.toUpperCase()) {
      case 'TNB':
        return 20;

      case 'SESCO':
        return 20;

      case 'SESB':
        return 20;

      case 'NUR':
        return 20;

      default:
        return 30;
    }
  }

  // =========================================================
  // KEYBOARD FUNCTIONS
  // =========================================================

  void _addText(String value) {
    if (_isLoading) return;

    if (_controller.text.length >= _maximumInputLength) {
      return;
    }

    setState(() {
      _controller.text += value;
    });
  }

  void _backspace() {
    if (_isLoading) return;

    if (_controller.text.isEmpty) {
      return;
    }

    setState(() {
      _controller.text = _controller.text.substring(
        0,
        _controller.text.length - 1,
      );
    });
  }

  void _clearAll() {
    if (_isLoading) return;

    setState(() {
      _controller.clear();
    });
  }

  // =========================================================
  // ALERT DIALOG
  // =========================================================

  void _showAlert(
    String title,
    String message, {
    IconData icon = Icons.info_outline_rounded,
    Color iconColor = const Color.fromARGB(255, 3, 89, 210),
  }) {
    if (!mounted) return;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Alert',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (
        dialogContext,
        animation,
        secondaryAnimation,
      ) {
        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 850,
                constraints: const BoxConstraints(
                  minHeight: 520,
                  maxHeight: 1050,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 80,
                ),
                padding: const EdgeInsets.fromLTRB(
                  55,
                  45,
                  55,
                  45,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(
                    color: iconColor.withOpacity(0.25),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.30),
                      blurRadius: 35,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ================= ICON =================

                    Container(
                      width: 145,
                      height: 145,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 90,
                        color: iconColor,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ================= TITLE =================

                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 20, 45, 80),
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: 130,
                      height: 6,
                      decoration: BoxDecoration(
                        color: iconColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ================= MESSAGE =================

                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color.fromARGB(
                              255,
                              65,
                              72,
                              82,
                            ),
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 45),

                    // ================= OK BUTTON =================

                    SizedBox(
                      width: double.infinity,
                      height: 105,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 42,
                        ),
                        label: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: iconColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.85,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // =========================================================
  // CONTINUE
  // =========================================================

    Future<void> _handleContinue() async {
      if (_isLoading) return;

      final accountNumber =
          _controller.text.trim().toUpperCase();

      if (accountNumber.isEmpty) {
        _showAlert(
          AppLocalizations.of(context)!.alertTitle,
          AppLocalizations.of(context)!
              .electricAccountRequired,
          icon: Icons.electric_bolt_rounded,
          iconColor: const Color(0xFF1976D2),
        );

        return;
      }

      FocusScope.of(context).unfocus();

      setState(() {
        _isLoading = true;
      });

      try {
        final loc = AppLocalizations.of(context)!;

        final result =
            await ElectricBillService.inquiryBill(
          productCode: widget.productCode,
          billerName: widget.billerName,
          accountNumber: accountNumber,
          loc: loc,
        );

        if (!mounted) return;

        if (!result.success || result.bill == null) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            result.message.isNotEmpty
                ? result.message
                : AppLocalizations.of(context)!
                    .electricAccountNotFound,
            icon: Icons.search_off_rounded,
            iconColor: Colors.orange,
          );

          return;
        }

        final bill = result.bill!;

        ElectricBillController.setSelectedBill(bill);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => P5ElectricBillResultPage(
              bill: bill,
            ),
          ),
        );
      } on ElectricBillException catch (error) {
        if (!mounted) return;

        debugPrint(
          'ElectricBillException: ${error.message}',
        );

        _showAlert(
          AppLocalizations.of(context)!.alertTitle,
          error.message,
          icon: Icons.cloud_off_rounded,
          iconColor: Colors.red,
        );
      } catch (error, stackTrace) {
        if (!mounted) return;

        debugPrint(
          'Unexpected electric bill error: $error',
        );

        debugPrintStack(
          stackTrace: stackTrace,
        );

        _showAlert(
          AppLocalizations.of(context)!.alertTitle,
          AppLocalizations.of(context)!.connectionFailed,
          icon: Icons.error_outline_rounded,
          iconColor: Colors.red,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 80.0;
    const keySpacing = 15.0;
    const keyHeight = 135.0;
    const keyWidth = 135.0;

    final backspaceKey =
        AppLocalizations.of(context)!.keyboardBackspace;

    final clearAllKey =
        AppLocalizations.of(context)!.keyboardClearAll;

    final List<List<String>> keyboardRows = [
      ['A', 'B', 'C', 'D', 'E', 'F'],
      ['G', 'H', 'I', 'J', 'K', 'L'],
      ['M', 'N', 'O', 'P', 'Q', 'R'],
      ['S', 'T', 'U', 'V', 'W', 'X'],
      ['Y', 'Z', '-', backspaceKey, clearAllKey],
      ['0', '1', '2', '3', '4', '5'],
      ['6', '7', '8', '9'],
    ];

    return Scaffold(
      body: Stack(
        children: [
          // ===================================================
          // BACKGROUND
          // ===================================================

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/pnew.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ===================================================
          // TITLE
          // ===================================================

          Positioned(
            top: 45,
            left: 90,
            right: 90,
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 115,
                      ),
                      child: Text(
                        widget.billerName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 28,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.electric_bolt_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),


          // ===================================================
          // ACCOUNT NUMBER FIELD
          // ===================================================

          Positioned(
            top: 200,
            left: horizontalPadding,
            right: horizontalPadding,
            child: SizedBox(
              height: 130,
              child: TextField(
                controller: _controller,
                readOnly: true,
                showCursor: true,
                cursorColor: const Color(0xFF1976D2),
                cursorWidth: 4,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 30,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(
                      color: Color(0xFF1976D2),
                      width: 3,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(
                      color: Color(0xFF0D47A1),
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ===================================================
          // KEYBOARD
          // ===================================================

          Positioned(
            top: 410,
            left: 20,
            right: 20,
            bottom: 380,
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: Opacity(
                opacity: _isLoading ? 0.5 : 1.0,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ================= LETTERS =================

                      ...keyboardRows.take(5).map((row) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: keySpacing,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: row.map((key) {
                              final bool isBackspace =
                                  key == backspaceKey;

                              final bool isClearAll =
                                  key == clearAllKey;

                              final bool isActionKey =
                                  isBackspace || isClearAll;

                              double currentKeyWidth = keyWidth;

                              if (isBackspace) {
                                currentKeyWidth = keyWidth * 1.3;
                              }

                              if (isClearAll) {
                                currentKeyWidth = keyWidth * 1.8;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(
                                  right: keySpacing,
                                ),
                                child: Builder(
                                  builder: (buttonContext) {
                                    return Listener(
                                      onPointerDown: (details) {
                                        if (_isLoading) return;

                                        final renderObject =
                                            buttonContext
                                                .findRenderObject();

                                        if (renderObject
                                            is! RenderBox) {
                                          return;
                                        }

                                        final position =
                                            renderObject.localToGlobal(
                                          Offset.zero,
                                        );

                                        setState(() {
                                          _activeKey = key;
                                          _activeKeyPosition =
                                              position;
                                        });
                                      },
                                      onPointerUp: (details) {
                                        if (_isLoading) return;

                                        setState(() {
                                          _activeKey = null;
                                        });

                                        if (isBackspace) {
                                          _backspace();
                                        } else if (isClearAll) {
                                          _clearAll();
                                        } else {
                                          _addText(key);
                                        }
                                      },
                                      onPointerCancel: (details) {
                                        if (_isLoading) return;

                                        setState(() {
                                          _activeKey = null;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 80,
                                        ),
                                        width: currentKeyWidth,
                                        height: keyHeight,
                                        decoration: BoxDecoration(
                                          color: isActionKey
                                              ? const Color.fromARGB(
                                                  255,
                                                  3,
                                                  89,
                                                  210,
                                                )
                                              : _activeKey == key
                                                  ? Colors.grey[300]
                                                  : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 2,
                                          ),
                                          boxShadow:
                                              _activeKey == key
                                                  ? []
                                                  : const [
                                                      BoxShadow(
                                                        color:
                                                            Colors.black26,
                                                        offset:
                                                            Offset(0, 4),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                        ),
                                        child: Center(
                                          child: isBackspace
                                              ? const Icon(
                                                  Icons
                                                      .backspace_outlined,
                                                  color:
                                                      Colors.white,
                                                  size: 45,
                                                )
                                              : isClearAll
                                                  ? Text(
                                                      clearAllKey,
                                                      textAlign:
                                                          TextAlign
                                                              .center,
                                                      style:
                                                          const TextStyle(
                                                        color:
                                                            Colors.white,
                                                        fontSize: 23,
                                                        fontWeight:
                                                            FontWeight
                                                                .bold,
                                                      ),
                                                    )
                                                  : Text(
                                                      key,
                                                      style:
                                                          const TextStyle(
                                                        color:
                                                            Colors.black,
                                                        fontSize: 50,
                                                        fontWeight:
                                                            FontWeight
                                                                .bold,
                                                      ),
                                                    ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),

                      const SizedBox(height: 35),

                      Container(
                        width: 850,
                        height: 2,
                        color: Colors.grey.shade400,
                      ),

                      const SizedBox(height: 35),

                      // ================= NUMBERS =================

                      ...keyboardRows.skip(5).map((row) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: keySpacing,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: row.map((key) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  right: keySpacing,
                                ),
                                child: Builder(
                                  builder: (buttonContext) {
                                    return Listener(
                                      onPointerDown: (details) {
                                        if (_isLoading) return;

                                        final renderObject =
                                            buttonContext
                                                .findRenderObject();

                                        if (renderObject
                                            is! RenderBox) {
                                          return;
                                        }

                                        final position =
                                            renderObject.localToGlobal(
                                          Offset.zero,
                                        );

                                        setState(() {
                                          _activeKey = key;
                                          _activeKeyPosition =
                                              position;
                                        });
                                      },
                                      onPointerUp: (details) {
                                        if (_isLoading) return;

                                        setState(() {
                                          _activeKey = null;
                                        });

                                        _addText(key);
                                      },
                                      onPointerCancel: (details) {
                                        if (_isLoading) return;

                                        setState(() {
                                          _activeKey = null;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 80,
                                        ),
                                        width: keyWidth,
                                        height: keyHeight,
                                        decoration: BoxDecoration(
                                          color: _activeKey == key
                                              ? Colors.grey[300]
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 2,
                                          ),
                                          boxShadow:
                                              _activeKey == key
                                                  ? []
                                                  : const [
                                                      BoxShadow(
                                                        color:
                                                            Colors.black26,
                                                        offset:
                                                            Offset(0, 4),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            key,
                                            style: const TextStyle(
                                              fontSize: 50,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===================================================
          // KEY PRESS PREVIEW
          // ===================================================

          if (_activeKey != null &&
              _activeKeyPosition != null &&
              !_isLoading)
            Positioned(
              left: _activeKeyPosition!.dx - 10,
              top: _activeKeyPosition!.dy - 130,
              child: IgnorePointer(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          3,
                          89,
                          210,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _activeKey!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    CustomPaint(
                      size: const Size(30, 15),
                      painter: DrawTriangle(
                        const Color.fromARGB(
                          255,
                          3,
                          89,
                          210,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ===================================================
          // BACK AND CONTINUE BUTTONS
          // ===================================================

          Positioned(
            bottom: 200,
            left: 100,
            right: 100,
            child: Row(
              children: [
                // ================= BACK =================

                Expanded(
                  child: SizedBox(
                    height: 105,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 42,
                      ),
                      label: Text(
                        AppLocalizations.of(context)!
                            .buttonBack,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFE0E0E0),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                            Colors.grey[400],
                        disabledForegroundColor:
                            Colors.black54,
                        side: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 50),

                // ================= CONTINUE =================

                Expanded(
                  child: SizedBox(
                    height: 105,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF16813B),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            Colors.green.shade300,
                        disabledForegroundColor:
                            Colors.white,
                        side: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 50,
                              height: 50,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 6,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .buttonContinue,
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                const Icon(
                                  Icons
                                      .arrow_forward_rounded,
                                  size: 42,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===================================================
          // LOADING OVERLAY
          // ===================================================

          if (_isLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.08),
                  child: const Center(
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        strokeWidth: 8,
                        color: Color.fromARGB(
                          255,
                          3,
                          89,
                          210,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ===================================================
          // FOOTER
          // ===================================================

          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                Data.copyrightText,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// TRIANGLE FOR KEY PREVIEW
// ===========================================================

class DrawTriangle extends CustomPainter {
  final Color color;

  DrawTriangle(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(
      path,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant DrawTriangle oldDelegate) {
    return oldDelegate.color != color;
  }
}