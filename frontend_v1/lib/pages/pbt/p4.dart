import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/compound/multiple_compound_controller.dart';
import 'package:frontend_v1/controllers/license/license_service.dart';
import 'package:frontend_v1/controllers/parking/parking_controller.dart';
import 'package:frontend_v1/controllers/taksiran/taksiran_service_bentong.dart';
import 'package:frontend_v1/controllers/tax/tax_service.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/option/p2.dart';
import 'package:frontend_v1/pages/pbt/cukai/p5_taksiran_bentong_screen.dart';
import 'package:frontend_v1/pages/pbt/cukai/p5_tax_screen.dart';
import 'package:frontend_v1/pages/pbt/parking/p5extendparking.dart';
import 'package:frontend_v1/pages/pbt/parking/p5parking.dart';
import 'package:frontend_v1/pages/pbt/lesen/p5_license_screen.dart';
import 'package:frontend_v1/pages/pbt/compound/p5_multiplecompound.dart';
import 'package:frontend_v1/controllers/compound/compound_service.dart';
import 'package:frontend_v1/pages/pbt/compound/p5_singlecompound_screen.dart';
import 'package:frontend_v1/pages/pbt/sewaan/p5sewaanPBTbentong.dart';
import 'package:frontend_v1/pages/option/pbt3.dart';
import 'package:frontend_v1/controllers/sewaan/sewaan_service_bentong.dart';
import 'package:frontend_v1/controllers/taksiran/semakan_cukai_taksiran_bentong_service.dart';
import 'package:frontend_v1/pages/pbt/cukai/p5_semakan_cukaitaksiran_bentong.dart';

import 'package:frontend_v1/controllers/sewaan/semakan_sewaan_bentong_service.dart';
import 'package:frontend_v1/pages/pbt/sewaan/p5_semakan_sewaan_bentong.dart';

class P4PAGE extends StatefulWidget {
  final String title;
  final String hint;
  final String biz;
  final String type;

  const P4PAGE({
    super.key,
    required this.title,
    required this.hint,
    required this.biz,
    required this.type,
  });

  @override
  State<P4PAGE> createState() => _P4PAGEState();
}

class _P4PAGEState extends State<P4PAGE> {
  final TextEditingController _controller = TextEditingController();

  String? _activeKey;
  Offset? _activeKeyPosition;

  bool _isLoading = false;

  void _addText(String value) {
    if (_isLoading) return;

    setState(() {
      int maxLength = 100; // default

      switch (widget.biz) {
        case "PARKING":
          maxLength = 15;
          break;

        case "CUKAI":
        case "SEWAAN PBT":
        case "SEMAKAN CUKAI":
        case "SEMAKAN SEWAAN":
          maxLength = 20;
          break;

        case "LESEN":
        case "TAX":
          maxLength = 12;
          break;

        case "SINGLECOMPOUND":
          maxLength = 20;
          break;

        case "MULTICOMPOUND":
          maxLength = 15;
          break;
      }

      if (_controller.text.length >= maxLength) return;

      _controller.text += value;
    });
  }

  bool _isAfter6PM() {
    final now = DateTime.now();
    return now.hour >= 18;
  }

  void _showParkingClosedAlert() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.alertTitle,
          style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.parkingExpiredAfter6pm,
          style: const TextStyle(fontSize: 40),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.buttonBack,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

void _showAlert(
  String title,
  String message, {
  IconData icon = Icons.info_outline_rounded,
  Color iconColor = const Color.fromARGB(255, 3, 89, 210),
}) {
  if (!mounted) return;

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Alert",
    barrierColor: Colors.black.withOpacity(0.65),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
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
              padding: const EdgeInsets.fromLTRB(55, 45, 55, 45),
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
                          color: Color.fromARGB(255, 65, 72, 82),
                          fontSize: 50,
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
                        "OK",
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

  void _backspace() {
    if (_isLoading) return;

    if (_controller.text.isNotEmpty) {
      setState(() {
        _controller.text =
            _controller.text.substring(0, _controller.text.length - 1);
      });
    }
  }

  void _clearAll() {
    if (_isLoading) return;

    setState(() {
      _controller.clear();
    });
  }

  Future<void> _handleContinue() async {
    if (_isLoading) return;

    final input = _controller.text.trim();

    setState(() => _isLoading = true);

    try {
      if (widget.biz == "PARKING") {
        if (input.isEmpty) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.alertEnterInfo,
          );
          return;
        }

        if (_isAfter6PM()) {
          _showParkingClosedAlert();
          return;
        }

        final isActive = await ParkingController.checkActiveParking(input);

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isActive
                ? P5EXTENDPARKINGPAGE(
                    plate: input,
                    biz: "EXTENDPARKING",
                  )
                : P5PARKINGPAGE(
                    plate: input,
                    biz: widget.biz,
                  ),
          ),
        );

        return;
      }

      if (widget.biz == "CUKAI") {
        if (input.isEmpty) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.alertEnterSewaan,
          );
          return;
        }

        final hasData = await TaksiranServiceBentong.inquiryTaksiran(input);

        if (!mounted) return;

        if (!hasData || TaksiranServiceBentong.taksiranList.isEmpty) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.noTaksiranRecordFound
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const P5TaksiranBentongScreen(),
          ),
        );

        return;
      }

      if (widget.biz == "SEMAKAN CUKAI") {
      if (input.isEmpty) {
        _showAlert(
          AppLocalizations.of(context)!.alertTitle,
          AppLocalizations.of(context)!.alertEnterSewaan,
        );
        return;
      }

      final hasData =
          await SemakanCukaiTaksiranBentongService.semakanBayaran(input);

      if (!mounted) return;

      if (!hasData ||
          SemakanCukaiTaksiranBentongService.paymentList.isEmpty) {
        _showAlert(
          AppLocalizations.of(context)!.alertTitle,
          AppLocalizations.of(context)!.noTaksiranPaymentRecordFound,
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const P5SemakanCukaiTaksiranBentongScreen(),
        ),
      );

      return;
    }

      if (widget.biz == "TAX") {
        if (input.isEmpty) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.alertEnterIC,
          );
          return;
        }

        final taxes = await TaxService.getTaxesByIC(input);

        if (!mounted) return;

        if (taxes.isEmpty) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.alertNoTaxRecord,
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => P5TaxScreen(ownerIC: input),
          ),
        );

        return;
      }

      if (widget.biz == "LESEN") {
        if (input.isEmpty) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.alertEnterIC,
          );
          return;
        }

        final licenses = await LicenseService.getLicensesByIC(input);

        if (!mounted) return;

        if (licenses.isEmpty) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.alertNoLicenseRecord,
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => P5LicenseScreen(ownerIC: input),
          ),
        );

        return;
      }

      if (widget.biz == "MULTICOMPOUND") {
        if (input.isEmpty) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.alertEnterPlateNo,
          );
          return;
        }

        final hasData =
            await MultipleCompoundController.setPlateNumberMultiComp(input);

        if (!mounted) return;

        if (!hasData || MultipleCompoundController.compoundList.isEmpty) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.alertNoCompoundRecord,
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => P5MULTIPLECompoundScreen(plateNo: input),
          ),
        );

        return;
      }

      if (widget.biz == "SINGLECOMPOUND") {
        if (input.isEmpty) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.alertEnterCompoundNo,
          );
          return;
        }

        final compound = await CompoundService.getSingleCompound(input);

        if (!mounted) return;

        if (compound == null) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.alertNoCompoundRecord,
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => P5SingleCompoundScreen(compound: compound),
          ),
        );

        return;
      }

      if (widget.biz == "SEWAAN PBT") {
        if (input.isEmpty) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.alertEnterSewaan,
          );
          return;
        }

        final hasData = await SewaanService.inquirySewaan(input);

        if (!mounted) return;

        if (!hasData || SewaanService.sewaanData == null) {
          _showAlert(
            AppLocalizations.of(context)!.alertTitle,
            AppLocalizations.of(context)!.alertNoSewaan,
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const P5SewaanPBTbentongScreen(),
          ),
        );

        return;
      }

      if (widget.biz == "SEMAKAN SEWAAN") {
  if (input.isEmpty) {
    _showAlert(
      AppLocalizations.of(context)!.alertTitle,
      AppLocalizations.of(context)!.alertEnterSewaan,
    );
    return;
  }

  final hasData =
      await SemakanSewaanBentongService.semakanBayaran(input);

  if (!mounted) return;

  if (!hasData || SemakanSewaanBentongService.paymentList.isEmpty) {
    _showAlert(
      AppLocalizations.of(context)!.alertTitle,
      AppLocalizations.of(context)!.noSewaanPaymentRecordFound
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const P5SemakanSewaanBentongScreen(),
    ),
  );

  return;
}

      _showAlert(
        AppLocalizations.of(context)!.alertTitle,
        AppLocalizations.of(context)!.unknownService
      );
    } catch (e) {
      if (!mounted) return;

      _showAlert(
        AppLocalizations.of(context)!.alertTitle,
        AppLocalizations.of(context)!.connectionFailed
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 80.0;
    const keySpacing = 15.0;
    const keyHeight = 135.0;
    const keyWidth = 135.0;

    final backspaceKey = AppLocalizations.of(context)!.keyboardBackspace;
    final clearAllKey = AppLocalizations.of(context)!.keyboardClearAll;

    // final List<List<String>> keyboardRows = [
    //   ["1", "2", "3", "4", "5", "6", "7"],
    //   ["8", "9", "0", "A", "B", "C", "D"],
    //   ["E", "F", "G", "H", "I", backspaceKey],
    //   ["J", "K", "L", "M", "N", clearAllKey],
    //   ["O", "P", "Q", "R", "S", "T", "U"],
    //   ["-", "V", "W", "X", "Y", "Z"],
    // ];


      final List<List<String>> keyboardRows = [
      ["A", "B", "C", "D", "E", "F"],
      ["G", "H", "I", "J", "K", "L"],
      ["M", "N", "O", "P", "Q", "R" ],
      ["S", "T", "U", "V", "W", "X", ],
      ["Y", "Z", "-", backspaceKey, clearAllKey,],
      ["0", "1", "2", "3", "4", "5"],
      ["6", "7", "8", "9"],
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/images/pnew.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

      Positioned(
        top: 45,
        left: 90,
        right: 90,
        child:Container(
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
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Keyboard icon on the left
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
                  Icons.keyboard_alt_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
            ),
          ],
        ),
      )
      ),

          Positioned(
            top: 230,
            left: horizontalPadding,
            right: horizontalPadding,
            child: SizedBox(
              height: 400,
              child: TextField(
                controller: _controller,
                readOnly: true,
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
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 400,
            left: 20,
            right: 20,
            bottom: 120,
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
                          padding: const EdgeInsets.only(bottom: keySpacing),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: row.map((key) {
                              final bool isActionKey =
                                  key == backspaceKey || key == clearAllKey;

                              return Padding(
                                padding: const EdgeInsets.only(right: keySpacing),
                                child: Builder(
                                  builder: (btnContext) {
                                    return Listener(
                                      onPointerDown: (details) {
                                        if (_isLoading) return;

                                        final RenderBox box =
                                            btnContext.findRenderObject() as RenderBox;
                                        final position =
                                            box.localToGlobal(Offset.zero);

                                        setState(() {
                                          _activeKey = key;
                                          _activeKeyPosition = position;
                                        });
                                      },
                                      onPointerUp: (details) {
                                        if (_isLoading) return;

                                        setState(() => _activeKey = null);

                                        if (key == backspaceKey) {
                                          _backspace();
                                        } else if (key == clearAllKey) {
                                          _clearAll();
                                        } else {
                                          _addText(key);
                                        }
                                      },
                                      onPointerCancel: (details) {
                                        if (_isLoading) return;
                                        setState(() => _activeKey = null);
                                      },
                                      child: Container(
                                        width: key == backspaceKey
                                            ? keyWidth * 1.3
                                            : key == clearAllKey
                                                ? keyWidth * 1.8
                                                : keyWidth,
                                        height: keyHeight,
                                        decoration: BoxDecoration(
                                          color: isActionKey
                                              ? const Color.fromARGB(255, 3, 89, 210)
                                              : (_activeKey == key
                                                  ? Colors.grey[300]
                                                  : Colors.white),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 2,
                                          ),
                                          boxShadow: _activeKey == key
                                              ? []
                                              : const [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    offset: Offset(0, 4),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                        ),
                                        child: Center(
                                          child: key == backspaceKey
                                              ? const Icon(
                                                  Icons.backspace_outlined,
                                                  color: Colors.white,
                                                  size: 45,
                                                )
                                              : key == clearAllKey
                                                  ? Text(
                                                      clearAllKey,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 23,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    )
                                                  : Text(
                                                      key,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 50,
                                                        fontWeight: FontWeight.bold,
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

                      // ================= SPACER =================
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
                          padding: const EdgeInsets.only(bottom: keySpacing),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: row.map((key) {
                              final bool isActionKey =
                                  key == backspaceKey || key == clearAllKey;

                              return Padding(
                                padding: const EdgeInsets.only(right: keySpacing),
                                child: Builder(
                                  builder: (btnContext) {
                                    return Listener(
                                      onPointerDown: (details) {
                                        if (_isLoading) return;

                                        final RenderBox box =
                                            btnContext.findRenderObject() as RenderBox;
                                        final position =
                                            box.localToGlobal(Offset.zero);

                                        setState(() {
                                          _activeKey = key;
                                          _activeKeyPosition = position;
                                        });
                                      },
                                      onPointerUp: (details) {
                                        if (_isLoading) return;

                                        setState(() => _activeKey = null);

                                        _addText(key);
                                      },
                                      onPointerCancel: (details) {
                                        if (_isLoading) return;
                                        setState(() => _activeKey = null);
                                      },
                                      child: Container(
                                        width: keyWidth,
                                        height: keyHeight,
                                        decoration: BoxDecoration(
                                          color: (_activeKey == key)
                                              ? Colors.grey[300]
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            key,
                                            style: const TextStyle(
                                              fontSize: 50,
                                              fontWeight: FontWeight.bold,
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

          if (_activeKey != null && _activeKeyPosition != null && !_isLoading)
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
                        color: const Color.fromARGB(255, 3, 89, 210),
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
                          style: const TextStyle(
                            fontSize: 70,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    CustomPaint(
                      size: const Size(30, 15),
                      painter: DrawTriangle(
                        const Color.fromARGB(255, 3, 89, 210),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: 200,
            left: 100,
            right: 100,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (widget.type == "PBT") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PBT3PAGE(),
                                ),
                              );
                            }

                            if (widget.type == "OTHERS") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const P2Page(),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey[400],
                      disabledForegroundColor: Colors.black54,
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        AppLocalizations.of(context)!.buttonBack,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 80),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.green.shade300,
                      disabledForegroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: _isLoading
                          ? const SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 6,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.buttonContinue,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                        color: Color.fromARGB(255, 3, 89, 210),
                      ),
                    ),
                  ),
                ),
              ),
            ),

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

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}