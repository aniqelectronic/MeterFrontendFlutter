import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend_v1/controllers/compound/multiple_compound_controller.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';
import 'package:frontend_v1/model/sewaan/sewaan_payment_item.dart';
import 'package:frontend_v1/model/taksiran/taksiran_payment_item.dart';
import 'package:frontend_v1/model/tax/payment_tax_item.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:frontend_v1/pages/home/p1bentong.dart';
import 'package:frontend_v1/widgets/kiosk_home_button.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// ============================================================================
// RECEIPT DATA MODEL
// ============================================================================
class ResitData {
  String? biz;
  String? plate;
  int? hour;
  String? amount;
  String? samanNo;
  String? licenseNo;
  String? accountNo;

  DateTime? startTime;
  DateTime? endTime;

  List<String>? licenseNos;
  List<String>? compoundNos;
  List<PaymentTaxItem>? taxItems;
  List<TaksiranPaymentItem>? taksiranItems;
  List<SewaanPaymentItem>? sewaanItems;

  String? offenderName;
  String? violationType;
  String? kodhasil;
  String? date;
  String? time;

  String? pegeOrderNo;
  String? pegeBankTrxNo;

  String? typePayment;

  ResitData({
    this.biz,
    this.plate,
    this.hour,
    this.amount,
    this.samanNo,
    this.licenseNo,
    this.accountNo,
    this.startTime,
    this.endTime,
    this.taxItems,
    this.licenseNos,
    this.compoundNos,
    this.offenderName,
    this.violationType,
    this.kodhasil,
    this.date,
    this.time,
    this.pegeOrderNo,
    this.pegeBankTrxNo,
    this.taksiranItems,
    this.typePayment,
    this.sewaanItems,
  });
}

// ============================================================================
// RECEIPT PAGE
// ============================================================================
class RESITPAGE extends StatefulWidget {
  final String biz;
  final ResitData data;

  const RESITPAGE({
    super.key,
    required this.biz,
    required this.data,
  });

  @override
  State<RESITPAGE> createState() => _RESITSTATE();
}

class _RESITSTATE extends State<RESITPAGE> {
  static const int _countdownDuration = 150;

  final String baseUrl = Config.baseUrl;

  String startTimeStr = 'Loading...';
  String endTimeStr = 'Loading...';

  Uint8List? qrImageBytes;

  Timer? _countdownTimer;
  int _remainingSeconds = _countdownDuration;

  String? pegeOrderNo;
  String? pegeBankTrxNo;

  bool _isQrLoading = true;
  bool _qrLoadFailed = false;

  @override
  void initState() {
    super.initState();

    pegeOrderNo = widget.data.pegeOrderNo;
    pegeBankTrxNo = widget.data.pegeBankTrxNo;

    fetchTransactionData();
    fetchQrImage();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ==========================================================================
  // FETCH LATEST TRANSACTION
  // ==========================================================================
  Future<void> fetchTransactionData() async {
    try {
      String urlString;

      if (widget.biz == 'PARKING') {
        urlString =
            '$baseUrl/transactions/latest/${widget.data.plate}';
      } else if (widget.biz == 'LESEN') {
        urlString =
            '$baseUrl/license/latest/${widget.data.licenseNo}';
      } else if (widget.biz == 'SAMAN') {
        urlString =
            '$baseUrl/saman/latest/${widget.data.samanNo}';
      } else {
        urlString =
            '$baseUrl/transactions/latest/${widget.data.plate}';
      }

      final Uri url = Uri.parse(urlString);

      final http.Response response = await http.get(url);

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);

        final String? backendOrderNo =
            jsonData['order_no']?.toString();

        final String? backendBankTrxNo =
            jsonData['bank_trx_no']?.toString();

        final String timeInRaw =
            jsonData['time_in']?.toString() ?? '';

        final String timeOutRaw =
            jsonData['time_out']?.toString() ?? '';

        final DateFormat inputFormat =
            DateFormat("yyyy-MM-dd'T'HH:mm:ss");

        final DateFormat outputFormat =
            DateFormat('hh:mm a');

        setState(() {
          if (backendOrderNo != null &&
              backendOrderNo.isNotEmpty &&
              backendOrderNo != 'null') {
            pegeOrderNo = backendOrderNo;
          }

          if (backendBankTrxNo != null &&
              backendBankTrxNo.isNotEmpty &&
              backendBankTrxNo != 'null') {
            pegeBankTrxNo = backendBankTrxNo;
          }

          if (timeInRaw.isNotEmpty) {
            widget.data.startTime =
                inputFormat.parse(timeInRaw);

            startTimeStr =
                outputFormat.format(widget.data.startTime!);
          } else {
            startTimeStr = 'N/A';
          }

          if (timeOutRaw.isNotEmpty) {
            widget.data.endTime =
                inputFormat.parse(timeOutRaw);

            final DateTime maximumEndTime = DateTime(
              widget.data.endTime!.year,
              widget.data.endTime!.month,
              widget.data.endTime!.day,
              18,
              0,
            );

            if (widget.data.endTime!.isAfter(maximumEndTime)) {
              widget.data.endTime = maximumEndTime;
            }

            endTimeStr =
                outputFormat.format(widget.data.endTime!);
          } else {
            endTimeStr = 'N/A';
          }
        });
      } else {
        setState(() {
          startTimeStr = 'N/A';
          endTimeStr = 'N/A';
        });
      }
    } catch (error) {
      debugPrint(
        'Failed to fetch transaction data: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        startTimeStr = 'N/A';
        endTimeStr = 'N/A';
      });
    }
  }

  // ==========================================================================
  // COUNTDOWN
  // ==========================================================================
  void _startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_remainingSeconds <= 0) {
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

  // ==========================================================================
  // GO HOME
  // ==========================================================================
  void _goHome() {
    _countdownTimer?.cancel();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(
          name: '/p1',
        ),
        builder: (_) => const P1BentongPage(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  // ==========================================================================
  // FETCH RECEIPT QR
  // ==========================================================================
  Future<void> fetchQrImage() async {
    if (mounted) {
      setState(() {
        _isQrLoading = true;
        _qrLoadFailed = false;
      });
    }

    try {
      late final http.Response response;

      // ----------------------------------------------------------------------
      // PARKING
      // ----------------------------------------------------------------------
      if (widget.biz == 'PARKING') {
        response = await http.get(
          Uri.parse(
            '$baseUrl/transactions/latest/qr',
          ),
        );
      }

      // ----------------------------------------------------------------------
      // LICENSE
      // ----------------------------------------------------------------------
      else if (widget.biz == 'LESEN') {
        final List<String>? licenseNos =
            widget.data.licenseNos;

        if (licenseNos == null || licenseNos.isEmpty) {
          _setQrFailure();
          return;
        }

        response = await http.post(
          Uri.parse(
            '$baseUrl/license/receipt/qr/multi',
          ),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'image/png',
          },
          body: jsonEncode({
            'licenses': licenseNos,
          }),
        );
      }

      // ----------------------------------------------------------------------
      // SAMAN
      // ----------------------------------------------------------------------
      else if (widget.biz == 'SAMAN') {
        response = await http.get(
          Uri.parse(
            '$baseUrl/saman/latest/qr',
          ),
        );
      }

      // ----------------------------------------------------------------------
      // CUKAI TAKSIRAN
      // ----------------------------------------------------------------------
      else if (widget.biz == 'CUKAI') {
        final List<TaksiranPaymentItem>? items =
            widget.data.taksiranItems;

        if (items == null || items.isEmpty) {
          debugPrint(
            'No taksiran items found for Bentong receipt QR',
          );

          _setQrFailure();
          return;
        }

        final List<Map<String, dynamic>> taxItemsPayload =
            items.map(
          (TaksiranPaymentItem item) {
            return {
              'account_number': item.accountNo,
              'owner_name': item.ownerName,
              'property_address': item.propertyAddress,
              'amount': item.amount,
            };
          },
        ).toList();

        response = await http.post(
          Uri.parse(
            '$baseUrl/tax/receipt/qr/bentong',
          ),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'image/png',
          },
          body: jsonEncode({
            'order_no':
                pegeOrderNo ??
                widget.data.pegeOrderNo ??
                '0',
            'paid_date':
                DateTime.now().toIso8601String(),
            'payment_method':
                widget.data.typePayment ?? ' ',
            'bank_trx_no':
                pegeBankTrxNo ??
                widget.data.pegeBankTrxNo ??
                '',
            'tax_items': taxItemsPayload,
          }),
        );
      }

      // ----------------------------------------------------------------------
      // SEWAAN
      // ----------------------------------------------------------------------
      else if (widget.biz == 'SEWAAN') {
        final List<SewaanPaymentItem>? items =
            widget.data.sewaanItems;

        if (items == null || items.isEmpty) {
          debugPrint(
            'No sewaan items found for Bentong receipt QR',
          );

          _setQrFailure();
          return;
        }

        final List<Map<String, dynamic>>
            sewaanItemsPayload =
            items.map(
          (SewaanPaymentItem item) {
            return {
              'account_number': item.accountNo,
              'tenant_name': item.tenantName,
              'registration_no': item.registrationNo,
              'start_date': item.startDate,
              'end_date': item.endDate,
              'premise_address': item.premiseAddress,
              'mailing_address': item.mailingAddress,
              'outstanding_rent': item.outstandingRent,
              'current_rent': item.currentRent,
              'amount': item.amount,
            };
          },
        ).toList();

        response = await http.post(
          Uri.parse(
            '$baseUrl/sewaan/receipt/qr/bentong',
          ),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'image/png',
          },
          body: jsonEncode({
            'order_no':
                pegeOrderNo ??
                widget.data.pegeOrderNo ??
                '0',
            'paid_date':
                DateTime.now().toIso8601String(),
            'payment_method':
                widget.data.typePayment ?? 'QR',
            'bank_trx_no':
                pegeBankTrxNo ??
                widget.data.pegeBankTrxNo ??
                '',
            'sewaan_items': sewaanItemsPayload,
          }),
        );
      }

      // ----------------------------------------------------------------------
      // MULTIPLE COMPOUND
      // ----------------------------------------------------------------------
      else if (widget.biz == 'MULTICOMPOUND') {
        final List<String>? compoundNos =
            widget.data.compoundNos;

        if (compoundNos == null || compoundNos.isEmpty) {
          _setQrFailure();
          return;
        }

        final Map<String, dynamic> compoundMap = {
          for (final compound
              in MultipleCompoundController.compoundList)
            compound.compoundNum: compound.amount,
        };

        final double totalAmount =
            double.tryParse(
                  widget.data.amount ?? '0.00',
                ) ??
                0.0;

        final List<Map<String, dynamic>>
            compoundsPayload =
            compoundNos.map(
          (String compoundNumber) {
            return {
              'compoundnum': compoundNumber,
              'amount':
                  compoundMap[compoundNumber] ?? 0.0,
            };
          },
        ).toList();

        response = await http.post(
          Uri.parse(
            '$baseUrl/compound/receipt/qr/multi',
          ),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'image/png',
          },
          body: jsonEncode({
            'compounds': compoundsPayload,
            'total_amount': totalAmount,
          }),
        );
      }

      // ----------------------------------------------------------------------
      // SINGLE COMPOUND
      // ----------------------------------------------------------------------
      else if (widget.biz == 'SINGLECOMPOUND') {
        final String? compoundNumber =
            widget.data.compoundNos?.firstOrNull;

        final double totalAmount =
            double.tryParse(
                  widget.data.amount ?? '0.00',
                ) ??
                0.0;

        if (compoundNumber == null) {
          _setQrFailure();
          return;
        }

        final Map<String, dynamic>
            singleCompoundPayload = {
          'compoundnum': compoundNumber,
          'name':
              widget.data.offenderName ?? 'N/A',
          'offense':
              widget.data.violationType ??
              'Compound Payment',
          'plate':
              widget.data.plate ?? '',
          'date':
              widget.data.date ??
              DateFormat('yyyy-MM-dd')
                  .format(DateTime.now()),
          'time':
              widget.data.time ??
              DateFormat('HH:mm:ss')
                  .format(DateTime.now()),
          'amount': totalAmount,
        };

        response = await http.post(
          Uri.parse(
            '$baseUrl/compound/receipt/qr/single',
          ),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'image/png',
          },
          body: jsonEncode(
            singleCompoundPayload,
          ),
        );
      } else {
        _setQrFailure();
        return;
      }

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200 &&
          response.bodyBytes.isNotEmpty) {
        setState(() {
          qrImageBytes = response.bodyBytes;
          _isQrLoading = false;
          _qrLoadFailed = false;
        });
      } else {
        debugPrint(
          'Receipt QR returned status '
          '${response.statusCode}',
        );

        _setQrFailure();
      }
    } catch (error) {
      debugPrint(
        'Failed to load QR image: $error',
      );

      _setQrFailure();
    }
  }

  void _setQrFailure() {
    if (!mounted) {
      return;
    }

    setState(() {
      qrImageBytes = null;
      _isQrLoading = false;
      _qrLoadFailed = true;
    });
  }

  // ==========================================================================
  // GET PAGE TITLE
  // ==========================================================================
  String _getPageTitle(
    AppLocalizations loc,
  ) {
    switch (widget.biz) {
      case 'PARKING':
        return loc.titleReceiptParking;

      case 'LESEN':
        return loc.titleReceiptLicense;

      case 'SAMAN':
        return loc.receiptSummonsTitle;

      case 'CUKAI':
        return loc.titleReceiptTax;

      case 'MULTICOMPOUND':
        return loc.titleReceiptMultipleCompound;

      case 'SINGLECOMPOUND':
        return loc.titleReceiptSingleCompound;

      case 'SEWAAN':
        return loc.titleReceiptSewaan;

      default:
        return loc.receiptPaymentTitle;
    }
  }

  // ==========================================================================
  // FORMAT AMOUNT
  // ==========================================================================
  String _formattedAmount() {
    final double amount =
        double.tryParse(
              widget.data.amount ?? '',
            ) ??
            0.0;

    return 'RM ${amount.toStringAsFixed(2)}';
  }

  // ==========================================================================
  // CHECK VALUE
  // ==========================================================================
  bool _hasValue(
    String? value,
  ) {
    if (value == null) {
      return false;
    }

    final String cleanValue =
        value.trim();

    return cleanValue.isNotEmpty &&
        cleanValue.toLowerCase() != 'null';
  }

  // ==========================================================================
  // BUILD RECEIPT INFORMATION
  // ==========================================================================
  List<Widget> _buildReceiptDetails(
    AppLocalizations loc,
  ) {
    final List<Widget> rows = [];

    // ------------------------------------------------------------------------
    // PARKING DETAILS
    // ------------------------------------------------------------------------
    if (widget.biz == 'PARKING') {
      rows.add(
        _ReceiptInfoRow(
          icon:
              Icons.directions_car_filled_rounded,
          label:
              loc.receiptPlateLabel2,
          value:
              widget.data.plate ?? 'N/A',
        ),
      );

      rows.add(
        _ReceiptInfoRow(
          icon:
              Icons.timer_rounded,
          label:
              loc.receiptDurationLabel2,
          value:
              widget.data.hour != null
                  ? loc.receiptDurationValue(
                      widget.data.hour!,
                    )
                  : 'N/A',
        ),
      );

      rows.add(
        _ReceiptInfoRow(
          icon:
              Icons.play_circle_outline_rounded,
          label:
              loc.receiptStartTimeLabel2,
          value:
              startTimeStr,
        ),
      );

      rows.add(
        _ReceiptInfoRow(
          icon:
              Icons.stop_circle_outlined,
          label:
              loc.receiptEndTimeLabel2,
          value:
              endTimeStr,
        ),
      );
    }

    // ------------------------------------------------------------------------
    // ORDER NUMBER
    // ------------------------------------------------------------------------
    if (_hasValue(pegeOrderNo)) {
      rows.add(
        _ReceiptInfoRow(
          icon:
              Icons.receipt_long_rounded,
          label:
              loc.receiptOrderNumberLabel,
          value:
              pegeOrderNo!,
          compactValue: true,
        ),
      );
    }

    // ------------------------------------------------------------------------
    // BANK TRANSACTION NUMBER
    // ------------------------------------------------------------------------
    if (_hasValue(pegeBankTrxNo)) {
      rows.add(
        _ReceiptInfoRow(
          icon:
              Icons.account_balance_rounded,
          label:
              loc.receiptBankTransactionLabel,
          value:
              pegeBankTrxNo!,
          compactValue: true,
        ),
      );
    }

    // ------------------------------------------------------------------------
    // DEFAULT STATUS
    // ------------------------------------------------------------------------
    if (rows.isEmpty) {
      rows.add(
        _ReceiptInfoRow(
          icon:
              Icons.check_circle_outline_rounded,
          label:
              loc.receiptPaymentStatusLabel,
          value:
              loc.receiptPaymentSuccessful,
        ),
      );
    }

    return rows;
  }

  // ==========================================================================
  // ADD DIVIDERS BETWEEN INFORMATION ROWS
  // ==========================================================================
  List<Widget> _insertRowDividers(
    List<Widget> rows,
  ) {
    final List<Widget> result = [];

    for (
      int index = 0;
      index < rows.length;
      index++
    ) {
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

  // ==========================================================================
  // BUILD QR AREA
  // ==========================================================================
  Widget _buildQrArea(
    AppLocalizations loc,
  ) {
    // ------------------------------------------------------------------------
    // QR LOADING
    // ------------------------------------------------------------------------
    if (_isQrLoading) {
      return Container(
        width: 360,
        height: 360,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FB),
          borderRadius:
              BorderRadius.circular(28),
          border: Border.all(
            color:
                const Color(0xFFD6DFE7),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 58,
              height: 58,
              child:
                  CircularProgressIndicator(
                strokeWidth: 6,
                color:
                    Color(0xFF2F6DA7),
              ),
            ),

            const SizedBox(
              height: 26,
            ),

            Text(
              loc.receiptQrLoading,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color:
                    Color(0xFF4D5D6D),
                fontSize: 32,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    // ------------------------------------------------------------------------
    // QR ERROR
    // ------------------------------------------------------------------------
    if (_qrLoadFailed ||
        qrImageBytes == null) {
      return Container(
        width: 480,
        padding:
            const EdgeInsets.fromLTRB(
          28,
          25,
          28,
          24,
        ),
        decoration: BoxDecoration(
          color:
              const Color(0xFFFFF0F0),
          borderRadius:
              BorderRadius.circular(28),
          border: Border.all(
            color:
                const Color(0xFFE08080),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.qr_code_scanner_rounded,
              color:
                  Color(0xFFC83C3C),
              size: 65,
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              loc.receiptQrLoadFailed,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color:
                    Color(0xFF9E2929),
                fontSize: 32,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            SizedBox(
              height: 56,
              child:
                  ElevatedButton.icon(
                onPressed:
                    fetchQrImage,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 27,
                ),
                label: Text(
                  loc.receiptTryAgain,
                  style:
                      const TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFFB93B3B,
                  ),
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 28,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ------------------------------------------------------------------------
    // QR IMAGE
    // ------------------------------------------------------------------------
    return Container(
      width: 400,
      height: 400,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color:
              const Color(0xFF243E59),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF243E59)
                    .withOpacity(0.15),
            blurRadius: 20,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),
      child: Image.memory(
        qrImageBytes!,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      ),
    );
  }

  // ==========================================================================
  // PAGE UI
  // ==========================================================================
  @override
  Widget build(
    BuildContext context,
  ) {
    final AppLocalizations loc =
        AppLocalizations.of(context)!;

    final String pageTitle =
        _getPageTitle(loc);

    final double countdownProgress =
        (_remainingSeconds /
                _countdownDuration)
            .clamp(0.0, 1.0);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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

          // ==================================================================
          // OUTDOOR READABILITY OVERLAY
          // ==================================================================
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:
                      Alignment.topCenter,
                  end:
                      Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(
                      0.20,
                    ),
                    Colors.white.withOpacity(
                      0.42,
                    ),
                    Colors.white.withOpacity(
                      0.30,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================================
          // HEADER
          //
          // PAYMENT SUCCESSFUL BADGE REMOVED TO SAVE SPACE.
          // ==================================================================
          Positioned(
            top: 80,
            left: 55,
            right: 55,
            child: _ReceiptHeader(
              title: pageTitle,
              subtitle:
                  loc.receiptThankYouMessage,
            ),
          ),

          // ==================================================================
          // MAIN RECEIPT CARD
          //
          // NO SINGLE CHILD SCROLL VIEW.
          // ALL CONTENT IS DISPLAYED DIRECTLY.
          // ==================================================================
          Positioned(
            top: 200,
            left: 38,
            right: 38,
            bottom: 320,
            child: Container(
              padding:
                  const EdgeInsets.fromLTRB(
                24,
                22,
                24,
                16,
              ),
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(
                  0.97,
                ),
                borderRadius:
                    BorderRadius.circular(42),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(
                      0xFF172B42,
                    ).withOpacity(0.18),
                    blurRadius: 34,
                    offset:
                        const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ==========================================================
                  // TRANSACTION DETAILS HEADER
                  // ==========================================================
                  _ReceiptSectionHeader(
                    icon:
                        Icons.description_rounded,
                    title:
                        loc.receiptTransactionDetailsTitle,
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  // ==========================================================
                  // TRANSACTION DETAILS CARD
                  // ==========================================================
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          const Color(
                        0xFFF5F8FB,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        26,
                      ),
                      border: Border.all(
                        color:
                            const Color(
                          0xFFD8E0E8,
                        ),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children:
                          _insertRowDividers(
                        _buildReceiptDetails(
                          loc,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  // ==========================================================
                  // TOTAL AMOUNT CARD
                  // ==========================================================
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(
                            0xFF183B63,
                          ),
                          Color(
                            0xFF2F6DA7,
                          ),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        26,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(
                            0xFF1D527E,
                          ).withOpacity(
                            0.22,
                          ),
                          blurRadius: 16,
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
                          width: 58,
                          height: 58,
                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(
                              0.16,
                            ),
                            shape:
                                BoxShape.circle,
                          ),
                          child:
                              const Icon(
                            Icons
                                .payments_rounded,
                            color:
                                Colors.white,
                            size: 40,
                          ),
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        Expanded(
                          child: Text(
                            loc.receiptAmountLabel2,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 35,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        Flexible(
                          child: FittedBox(
                            fit:
                                BoxFit.scaleDown,
                            alignment:
                                Alignment
                                    .centerRight,
                            child: Text(
                              _formattedAmount(),
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 45,
                                fontWeight:
                                    FontWeight
                                        .w900,
                                letterSpacing:
                                    0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  // ==========================================================
                  // DIGITAL RECEIPT HEADER
                  // ==========================================================
                  _ReceiptSectionHeader(
                    icon:
                        Icons.qr_code_2_rounded,
                    title:
                        loc.receiptDigitalReceiptTitle,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    loc.receiptScanQrText,
                    textAlign:
                        TextAlign.center,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF4E5D6D),
                      fontSize: 35,
                      height: 1.25,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // ==========================================================
                  // FLEXIBLE QR AREA
                  //
                  // The QR keeps a large maximum size, but it can shrink
                  // automatically when larger text uses more vertical space.
                  // This prevents the yellow/black overflow warning.
                  // ==========================================================
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child:Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _buildQrArea(
                            loc,
                          ),
                        ),
                      ),
                    ),
                  ),

                                    const SizedBox(
                    height: 30,
                  ),
                  
                  // ==========================================================
                  // QR INSTRUCTION
                  // ==========================================================
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          const Color(
                        0xFFFFF8E6,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                      border: Border.all(
                        color:
                            const Color(
                          0xFFE7C97A,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons
                              .info_outline_rounded,
                          color:
                              Color(
                            0xFF8A681A,
                          ),
                          size: 50,
                        ),

                        const SizedBox(
                          width: 9,
                        ),

                        Flexible(
                          child: Text(
                            loc.receiptQrInstruction,
                            textAlign:
                                TextAlign.center,
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF705616,
                              ),
                              fontSize: 30,
                              height: 1.2,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                                    const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ),

          

          // ==================================================================
          // AUTO RETURN COUNTDOWN
          // ==================================================================
          Positioned(
            bottom: 210,
            left: 90,
            right: 90,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(
                  0.95,
                ),
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color:
                      const Color(
                    0xFFD5DEE7,
                  ),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.09),
                    blurRadius: 16,
                    offset:
                        const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    alignment:
                        Alignment.center,
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child:
                            CircularProgressIndicator(
                          value:
                              countdownProgress,
                          strokeWidth: 6,
                          backgroundColor:
                              const Color(
                            0xFFE5EBF0,
                          ),
                          color:
                              _remainingSeconds <= 20
                                  ? const Color(
                                      0xFFD64545,
                                    )
                                  : const Color(
                                      0xFF2F6DA7,
                                    ),
                        ),
                      ),

                      Text(
                        '$_remainingSeconds',
                        style: TextStyle(
                          color:
                              _remainingSeconds <= 20
                                  ? const Color(
                                      0xFFC62828,
                                    )
                                  : const Color(
                                      0xFF244461,
                                    ),
                          fontSize: 25,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    width: 18,
                  ),

                  Expanded(
                    child: Text(
                      loc.receiptAutoReturn(
                        _remainingSeconds,
                      ),
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF334659,
                        ),
                        fontSize: 30,
                        height: 1.2,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==================================================================
          // HOME BUTTON
          // ==================================================================
          Positioned(
            bottom: 62,
            left: 300,
            right: 300,
            child: KioskHomeButton(
              onPressed: _goHome,
            ),
          ),

          // ==================================================================
          // COPYRIGHT FOOTER
          // ==================================================================
          Positioned(
            bottom: 10,
            left: 25,
            right: 25,
            child: Text(
              Data.copyrightText,
              textAlign:
                  TextAlign.center,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color:
                    Color(0xFF273747),
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// RECEIPT HEADER
//
// PAYMENT SUCCESSFUL BADGE HAS BEEN REMOVED.
// ============================================================================
class _ReceiptHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ReceiptHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        ShaderMask(
          blendMode:
              BlendMode.srcIn,
          shaderCallback:
              (Rect bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFF183B63),
                Color(0xFF5484AC),
              ],
            ).createShader(bounds);
          },
          child: Text(
            title,
            textAlign:
                TextAlign.center,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 55,
              height: 1.02,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),

        // const SizedBox(
        //   height: 30,
        // ),

        // Container(
        //   padding:
        //       const EdgeInsets.symmetric(
        //     horizontal: 28,
        //     vertical: 10,
        //   ),
        //   decoration: BoxDecoration(
        //     color:
        //         Colors.white.withOpacity(
        //       0.94,
        //     ),
        //     borderRadius:
        //         BorderRadius.circular(22),
        //     border: Border.all(
        //       color:
        //           const Color(
        //         0xFFD3DCE5,
        //       ),
        //       width: 1.5,
        //     ),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black
        //             .withOpacity(0.06),
        //         blurRadius: 10,
        //         offset:
        //             const Offset(0, 5),
        //       ),
        //     ],
        //   ),
        //   child: FittedBox(
        //     fit: BoxFit.scaleDown,
        //     child: Text(
        //       subtitle,
        //       textAlign: TextAlign.center,
        //       maxLines: 1,
        //       style: const TextStyle(
        //         color: Color(0xFF526273),
        //         fontSize: 30,
        //         height: 1.2,
        //         fontWeight: FontWeight.w700,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================
class _ReceiptSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ReceiptSectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration:
              const BoxDecoration(
            color:
                Color(0xFFE6EEF6),
            shape:
                BoxShape.circle,
          ),
          child: Icon(
            icon,
            color:
                const Color(
              0xFF315F8C,
            ),
            size: 40,
          ),
        ),

        const SizedBox(
          width: 13,
        ),

        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color:
                  Color(
                0xFF20364C,
              ),
              fontSize: 35,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// RECEIPT INFORMATION ROW
// ============================================================================
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
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 18,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color:
                const Color(
              0xFF61778C,
            ),
            size: 35,
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            flex: 5,
            child: Text(
              label,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF4D5D6D,
                ),
                fontSize: 32,
                height: 1.15,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              maxLines:
                  compactValue ? 2 : 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    const Color(
                  0xFF1D3043,
                ),
                fontSize:
                    compactValue ? 25 : 32,
                height: 1.15,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SAFE FIRST ITEM EXTENSION
// ============================================================================
extension FirstOrNullExtension<T> on List<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }

    return first;
  }
}