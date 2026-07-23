import 'package:frontend_v1/controllers/electric/electric_bill_exception.dart';
import 'package:frontend_v1/controllers/electric/electric_bill_service.dart';
import 'package:frontend_v1/controllers/entertainment/entertainment_bill_exception.dart';
import 'package:frontend_v1/controllers/entertainment/entertainment_bill_inquiry_result.dart';
import 'package:frontend_v1/l10n/app_localizations.dart';

class EntertainmentBillService {
  EntertainmentBillService._();

  static Future<EntertainmentBillInquiryResult> inquiryBill({
    required String productCode,
    required String billerName,
    required String accountNumber,
    required AppLocalizations loc,
  }) async {
    final normalizedProductCode =
        productCode.trim().toUpperCase();

    final normalizedAccountNumber =
        accountNumber.trim();

    if (normalizedProductCode != 'ASB') {
      return EntertainmentBillInquiryResult.failure(
        message: loc.entertainmentProductUnavailable,
      );
    }

    if (!RegExp(r'^[0-9]{8,20}$')
        .hasMatch(normalizedAccountNumber)) {
      return EntertainmentBillInquiryResult.failure(
        message: loc.entertainmentAccountInvalid,
      );
    }

    try {
      final result =
          await ElectricBillService.inquiryBill(
        productCode: normalizedProductCode,
        billerName: billerName,
        accountNumber: normalizedAccountNumber,
        loc: loc,
      );

      if (!result.success || result.bill == null) {
        return EntertainmentBillInquiryResult.failure(
          message: result.message.isNotEmpty
              ? result.message
              : loc.entertainmentAccountNotFound,
        );
      }

      return EntertainmentBillInquiryResult.success(
        bill: result.bill!,
        message: result.message,
      );
    } on ElectricBillException catch (error) {
      throw EntertainmentBillException(
        message: error.message,
        statusCode: error.statusCode,
        responseBody: error.responseBody,
      );
    } catch (error) {
      throw EntertainmentBillException(
        message: loc.entertainmentInquiryFailed(
          error.toString(),
        ),
      );
    }
  }
}
