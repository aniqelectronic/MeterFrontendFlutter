import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/compound/multiple_compound_controller.dart';
import 'package:frontend_v1/controllers/license/license_service.dart';
import 'package:frontend_v1/controllers/parking/parking_controller.dart';
import 'package:frontend_v1/controllers/taksiran/taksiran_service_bentong.dart';
import 'package:frontend_v1/controllers/tax/tax_service.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/p2.dart';
import 'package:frontend_v1/pages/p5_taksiran_bentong_screen.dart';
import 'package:frontend_v1/pages/p5_tax_screen.dart';
import 'package:frontend_v1/pages/p5extendparking.dart';
import 'package:frontend_v1/pages/p5parking.dart';
import 'package:frontend_v1/pages/p5_license_screen.dart';
import 'package:frontend_v1/pages/p5_multiplecompound.dart';
import 'package:frontend_v1/controllers/compound/compound_service.dart';
import 'package:frontend_v1/pages/p5_singlecompound_screen.dart';
import 'package:frontend_v1/pages/p5sewaanPBTbentong.dart';
import 'package:frontend_v1/pages/pbt3.dart';
import 'package:frontend_v1/controllers/sewaan/sewaan_service_bentong.dart';

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
      if (widget.biz == "PARKING") {
        if (_controller.text.length >= 15) return;
      }
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
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.parkingExpiredAfter6pm,
          style: const TextStyle(fontSize: 30),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.buttonBack,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAlert(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 30),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
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
            "Tiada rekod cukai taksiran dijumpai",
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

      _showAlert(
        AppLocalizations.of(context)!.alertTitle,
        "Servis tidak dikenali.",
      );
    } catch (e) {
      if (!mounted) return;

      _showAlert(
        AppLocalizations.of(context)!.alertTitle,
        "Sambungan gagal. Sila cuba lagi.",
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
    const keyHeight = 120.0;
    const keyWidth = 125.0;

    final backspaceKey = AppLocalizations.of(context)!.keyboardBackspace;
    final clearAllKey = AppLocalizations.of(context)!.keyboardClearAll;

    final List<List<String>> keyboardRows = [
      ["1", "2", "3", "4", "5", "6", "7"],
      ["8", "9", "0", "A", "B", "C", "D"],
      ["E", "F", "G", "H", "I", backspaceKey],
      ["J", "K", "L", "M", "N", clearAllKey],
      ["O", "P", "Q", "R", "S", "T", "U"],
      ["-", "V", "W", "X", "Y", "Z"],
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
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 89, 210),
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Positioned(
            top: 300,
            left: horizontalPadding,
            right: horizontalPadding,
            child: SizedBox(
              height: 400,
              child: TextField(
                controller: _controller,
                readOnly: true,
                style: const TextStyle(fontSize: 35),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: widget.hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 550,
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
                    children: keyboardRows.map((row) {
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
                                          btnContext.findRenderObject()
                                              as RenderBox;
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
                                      width: isActionKey
                                          ? keyWidth * 2.1
                                          : keyWidth,
                                      height: keyHeight,
                                      decoration: BoxDecoration(
                                        color: isActionKey
                                            ? const Color.fromARGB(
                                                255,
                                                3,
                                                89,
                                                210,
                                              )
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
                                            : [
                                                const BoxShadow(
                                                  color: Colors.black26,
                                                  offset: Offset(0, 4),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          key,
                                          style: TextStyle(
                                            color: isActionKey
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: isActionKey ? 20 : 50,
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
                    }).toList(),
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
            bottom: 300,
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