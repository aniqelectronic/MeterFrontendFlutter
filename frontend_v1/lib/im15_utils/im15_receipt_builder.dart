import '../im15_model/im15_response_model.dart';

class IM15ReceiptBuilder {
  static String buildReceipt(IM15ResponseModel? model) {
    if (model == null) return "❌ Invalid transaction data.";

    String maskCard(String? card) {
      if (card == null || card.length < 4) return "****";
      return "**** **** **** ${card.substring(card.length - 4)}";
    }

    return '''
======= CARD RECEIPT =======
Card Number : ${maskCard(model.cardNumber)}
Expiry Date : ${model.expireDate}
Approval    : ${model.approvalCode}
RRN         : ${model.rrn}
Trace No    : ${model.traceNo}
Batch No    : ${model.batchNo}
Terminal ID : ${model.terminalId}
Merchant ID : ${model.merchantId}
AID         : ${model.aid}
============================
''';
  }
}
