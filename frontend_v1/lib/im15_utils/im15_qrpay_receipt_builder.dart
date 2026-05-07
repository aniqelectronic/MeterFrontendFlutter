import '../im15_model/im15_response_model.dart';

class IM15QRPayReceiptBuilder {
  static String buildReceipt(IM15ResponseModel? model, String amount) {
    if (model == null) return "QR Payment Failed: No response.";

    String formatAmount(String amt) {
      try {
        int cents = int.parse(amt);
        return (cents / 100.0).toStringAsFixed(2);
      } catch (_) {
        return amt;
      }
    }

    return '''
=========== QR PAYMENT RECEIPT ===========
PAYMENT MODE : MBB QRPay
AMOUNT       : RM ${formatAmount(amount)}
------------------------------------------
STATUS CODE  : ${model.statusCode}
APPROVAL CODE: ${model.approvalCode}
RRN          : ${model.rrn}
TRACE NO     : ${model.traceNo}
BATCH NO     : ${model.batchNo}
TERMINAL ID  : ${model.terminalId}
MERCHANT ID  : ${model.merchantId}
HOST NO      : ${model.hostNo}
==========================================
                 Thank You                
==========================================
''';
  }
}
