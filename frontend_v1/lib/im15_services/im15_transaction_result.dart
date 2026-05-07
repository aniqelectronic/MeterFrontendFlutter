import '../im15_model/im15_response_model.dart';

class TransactionResult {
  final bool success;
  final String? errorMessage;
  final IM15ResponseModel? response;

  // Constructor for successful transactions
  TransactionResult.success(this.response) 
      : success = true, 
        errorMessage = null;

  // Constructor for failed transactions
  TransactionResult.failure(this.errorMessage) 
      : success = false, 
        response = null;
}