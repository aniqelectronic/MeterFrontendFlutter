/// Holds parsed response data from IM15 terminal
class IM15ResponseModel {
  // Card details
  String? cardNumber;     // Masked card number
  String? expireDate;     // Card expiry (YYMM)
  String? aid;            // Application Identifier (AID)

  // Transaction status
  String? statusCode;     // Response code (00 = approved)
  String? approvalCode;   // Bank approval code
  String? rrn;            // Retrieval Reference Number
  String? traceNo;        // Trace number

  // Terminal / merchant info
  String? batchNo;        // Batch number
  String? hostNo;         // Host number
  String? terminalId;     // Terminal ID
  String? merchantId;     // Merchant ID

  // Amount & settlement info
  String? amount;         // Transaction amount
  String? batchCount;     // Total transactions in batch
  String? batchAmount;    // Total batch amount
  String? batchNumber;    // Optional batch number (future use)
}
