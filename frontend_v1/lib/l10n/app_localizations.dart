import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms')
  ];

  /// No description provided for @bilText.
  ///
  /// In en, this message translates to:
  /// **'UTILITY BILLS'**
  String get bilText;

  /// No description provided for @otherText.
  ///
  /// In en, this message translates to:
  /// **'OTHERS'**
  String get otherText;

  /// No description provided for @touristText.
  ///
  /// In en, this message translates to:
  /// **'TOURIST GUIDE'**
  String get touristText;

  /// No description provided for @p2Title.
  ///
  /// In en, this message translates to:
  /// **'MULTIPLE SERVICES'**
  String get p2Title;

  /// No description provided for @pbtText.
  ///
  /// In en, this message translates to:
  /// **'COUNCIL SERVICES'**
  String get pbtText;

  /// No description provided for @rentText.
  ///
  /// In en, this message translates to:
  /// **'OTHER RENTALS'**
  String get rentText;

  /// No description provided for @rentPBTText.
  ///
  /// In en, this message translates to:
  /// **'COUNCIL RENTAL'**
  String get rentPBTText;

  /// No description provided for @backText.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get backText;

  /// No description provided for @processingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Payment successful.\nProcessing your receipt...\nPlease do not touch the screen.'**
  String get processingReceipt;

  /// No description provided for @noTaksiranRecordFound.
  ///
  /// In en, this message translates to:
  /// **'No assessment tax record found'**
  String get noTaksiranRecordFound;

  /// No description provided for @noSewaanRecordFound.
  ///
  /// In en, this message translates to:
  /// **'No rental record found'**
  String get noSewaanRecordFound;

  /// No description provided for @noSewaanPaymentRecordFound.
  ///
  /// In en, this message translates to:
  /// **'No rental payment record found'**
  String get noSewaanPaymentRecordFound;

  /// No description provided for @noTaksiranPaymentRecordFound.
  ///
  /// In en, this message translates to:
  /// **'No assessment tax payment record found'**
  String get noTaksiranPaymentRecordFound;

  /// No description provided for @unknownService.
  ///
  /// In en, this message translates to:
  /// **'Unknown service.'**
  String get unknownService;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed. Please try again.'**
  String get connectionFailed;

  /// No description provided for @inputRegistrationOrAccountNo.
  ///
  /// In en, this message translates to:
  /// **'Enter Registration No / Account No'**
  String get inputRegistrationOrAccountNo;

  /// No description provided for @inputSewaanRegistrationOrAccountNo.
  ///
  /// In en, this message translates to:
  /// **'Enter Rental Registration No / Account No'**
  String get inputSewaanRegistrationOrAccountNo;

  /// No description provided for @inputTaksiranRegistrationOrAccountNo.
  ///
  /// In en, this message translates to:
  /// **'Enter Assessment Registration No / Account No'**
  String get inputTaksiranRegistrationOrAccountNo;

  /// No description provided for @scrollup.
  ///
  /// In en, this message translates to:
  /// **'SCROLL UP'**
  String get scrollup;

  /// No description provided for @scrolldown.
  ///
  /// In en, this message translates to:
  /// **'SCROLL DOWN'**
  String get scrolldown;

  /// No description provided for @comingsoonText.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get comingsoonText;

  /// No description provided for @p3rentTitle.
  ///
  /// In en, this message translates to:
  /// **'RENT OPTIONS'**
  String get p3rentTitle;

  /// No description provided for @p3rentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PLEASE SELECT YOUR OPTION'**
  String get p3rentSubtitle;

  /// No description provided for @p3dewanButton.
  ///
  /// In en, this message translates to:
  /// **'HALL'**
  String get p3dewanButton;

  /// No description provided for @p3geraiButton.
  ///
  /// In en, this message translates to:
  /// **'STALL'**
  String get p3geraiButton;

  /// No description provided for @p3ruangniagaButton.
  ///
  /// In en, this message translates to:
  /// **'COMMERCIAL SPACES'**
  String get p3ruangniagaButton;

  /// No description provided for @p3othersTitle.
  ///
  /// In en, this message translates to:
  /// **'OTHERS OPTIONS'**
  String get p3othersTitle;

  /// No description provided for @p3othersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PLEASE SELECT YOUR OPTION'**
  String get p3othersSubtitle;

  /// No description provided for @p3aduanButton.
  ///
  /// In en, this message translates to:
  /// **'COMPLAINT'**
  String get p3aduanButton;

  /// No description provided for @p3eksplorasiButton.
  ///
  /// In en, this message translates to:
  /// **'EXPLORATION'**
  String get p3eksplorasiButton;

  /// No description provided for @p3waktusolat.
  ///
  /// In en, this message translates to:
  /// **'PRAYER TIME'**
  String get p3waktusolat;

  /// No description provided for @p3map.
  ///
  /// In en, this message translates to:
  /// **'MAP'**
  String get p3map;

  /// No description provided for @p4optioncukaiTitle.
  ///
  /// In en, this message translates to:
  /// **'ASSESSMENT TAX'**
  String get p4optioncukaiTitle;

  /// No description provided for @p4optioncukaiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PLEASE SELECT YOUR OPTION'**
  String get p4optioncukaiSubtitle;

  /// No description provided for @p4optionsewaanTitle.
  ///
  /// In en, this message translates to:
  /// **'COUNCIL RENTAL'**
  String get p4optionsewaanTitle;

  /// No description provided for @p4optionsewaanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PLEASE SELECT YOUR OPTION'**
  String get p4optionsewaanSubtitle;

  /// No description provided for @paymentsewaan.
  ///
  /// In en, this message translates to:
  /// **'MAKE PAYMENT'**
  String get paymentsewaan;

  /// No description provided for @semakansewaantitle.
  ///
  /// In en, this message translates to:
  /// **'RENT PAYMENT HISTORY'**
  String get semakansewaantitle;

  /// No description provided for @checkbuttonsewaan.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT HISTORY'**
  String get checkbuttonsewaan;

  /// No description provided for @checkbuttontax.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT HISTORY'**
  String get checkbuttontax;

  /// No description provided for @paymenttax.
  ///
  /// In en, this message translates to:
  /// **'MAKE PAYMENT'**
  String get paymenttax;

  /// No description provided for @semakancukaititle.
  ///
  /// In en, this message translates to:
  /// **'TAX PAYMENT HISTORY'**
  String get semakancukaititle;

  /// No description provided for @noPaymentRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No payment records found'**
  String get noPaymentRecordsFound;

  /// No description provided for @assessmentTaxPaymentTransactionList.
  ///
  /// In en, this message translates to:
  /// **'Assessment Tax Payment Transaction List'**
  String get assessmentTaxPaymentTransactionList;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @transactionNo.
  ///
  /// In en, this message translates to:
  /// **'Transaction No.'**
  String get transactionNo;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @transactionInformation.
  ///
  /// In en, this message translates to:
  /// **'Transaction Information'**
  String get transactionInformation;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @registrationNo.
  ///
  /// In en, this message translates to:
  /// **'Registration No'**
  String get registrationNo;

  /// No description provided for @accountNo.
  ///
  /// In en, this message translates to:
  /// **'Account No'**
  String get accountNo;

  /// No description provided for @ownerName.
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get ownerName;

  /// No description provided for @propertyAddress.
  ///
  /// In en, this message translates to:
  /// **'Property Address'**
  String get propertyAddress;

  /// No description provided for @orderNo.
  ///
  /// In en, this message translates to:
  /// **'Order No'**
  String get orderNo;

  /// No description provided for @bankTransactionNo.
  ///
  /// In en, this message translates to:
  /// **'Bank Transaction No'**
  String get bankTransactionNo;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @paidDate.
  ///
  /// In en, this message translates to:
  /// **'Paid Date'**
  String get paidDate;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @semakanWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Important Notice'**
  String get semakanWarningTitle;

  /// No description provided for @semakanWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment checking is only available for transactions made through this kiosk. Payments made through other channels may not be displayed.'**
  String get semakanWarningMessage;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelButton;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @semakanSewaanWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Important Notice'**
  String get semakanSewaanWarningTitle;

  /// No description provided for @semakanSewaanWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Rental payment checking is only available for transactions made through this kiosk. Payments made through other channels may not be displayed.'**
  String get semakanSewaanWarningMessage;

  /// No description provided for @pwaktusolattitle.
  ///
  /// In en, this message translates to:
  /// **'PRAYER TIME'**
  String get pwaktusolattitle;

  /// No description provided for @textsolat1.
  ///
  /// In en, this message translates to:
  /// **'NEXT PRAYER : '**
  String get textsolat1;

  /// No description provided for @maptitle.
  ///
  /// In en, this message translates to:
  /// **'LOCATION MAP'**
  String get maptitle;

  /// No description provided for @mapsubtitle.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE AND DISCOVER WHAT’S AROUND YOU'**
  String get mapsubtitle;

  /// No description provided for @p3Title.
  ///
  /// In en, this message translates to:
  /// **'COUNCIL SERVICES'**
  String get p3Title;

  /// No description provided for @p3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'PLEASE SELECT YOUR OPTION'**
  String get p3Subtitle;

  /// No description provided for @parkirButton.
  ///
  /// In en, this message translates to:
  /// **'PARKING'**
  String get parkirButton;

  /// No description provided for @compoundButton.
  ///
  /// In en, this message translates to:
  /// **'COMPOUND'**
  String get compoundButton;

  /// No description provided for @taxButton.
  ///
  /// In en, this message translates to:
  /// **'ASSESSMENT TAX'**
  String get taxButton;

  /// No description provided for @compoundTitle.
  ///
  /// In en, this message translates to:
  /// **'COMPOUND'**
  String get compoundTitle;

  /// No description provided for @aduanTitle.
  ///
  /// In en, this message translates to:
  /// **'COMPLAINT'**
  String get aduanTitle;

  /// No description provided for @singlecompoundTitle.
  ///
  /// In en, this message translates to:
  /// **'SINGLE COMPOUND'**
  String get singlecompoundTitle;

  /// No description provided for @multicompoundTitle.
  ///
  /// In en, this message translates to:
  /// **'MULTIPLE COMPOUND'**
  String get multicompoundTitle;

  /// No description provided for @compoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE SEARCH METHOD'**
  String get compoundSubtitle;

  /// No description provided for @singleCompoundButton.
  ///
  /// In en, this message translates to:
  /// **'COMPOUND NUMBER'**
  String get singleCompoundButton;

  /// No description provided for @multiCompoundButton.
  ///
  /// In en, this message translates to:
  /// **'PLATE NUMBER'**
  String get multiCompoundButton;

  /// No description provided for @licenseButton.
  ///
  /// In en, this message translates to:
  /// **'LICENSE'**
  String get licenseButton;

  /// No description provided for @inputPlateHint.
  ///
  /// In en, this message translates to:
  /// **'ENTER YOUR PLATE NUMBER'**
  String get inputPlateHint;

  /// No description provided for @inputICHint.
  ///
  /// In en, this message translates to:
  /// **'ENTER YOUR IC NUMBER'**
  String get inputICHint;

  /// No description provided for @inputCompoundHint.
  ///
  /// In en, this message translates to:
  /// **'ENTER COMPOUND NUMBER'**
  String get inputCompoundHint;

  /// No description provided for @inputTaxHint.
  ///
  /// In en, this message translates to:
  /// **'ENTER YOUR ACCOUNT/IC/SSM NUMBER'**
  String get inputTaxHint;

  /// No description provided for @pbil3Title.
  ///
  /// In en, this message translates to:
  /// **'BILL OPTIONS'**
  String get pbil3Title;

  /// No description provided for @pbilelectric3Title.
  ///
  /// In en, this message translates to:
  /// **'BILL ELECTRIC OPTIONS'**
  String get pbilelectric3Title;

  /// No description provided for @pbil3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'PLEASE SELECT YOUR OPTION'**
  String get pbil3Subtitle;

  /// No description provided for @electricitybutton.
  ///
  /// In en, this message translates to:
  /// **'ELECTRIC BILL'**
  String get electricitybutton;

  /// No description provided for @tnbButton.
  ///
  /// In en, this message translates to:
  /// **'TNB BILL'**
  String get tnbButton;

  /// No description provided for @sarawakenergyButton.
  ///
  /// In en, this message translates to:
  /// **'SARAWAK ENERGY BILL'**
  String get sarawakenergyButton;

  /// No description provided for @sabahelectricityButton.
  ///
  /// In en, this message translates to:
  /// **'SABAH ELECTRICITY BILL'**
  String get sabahelectricityButton;

  /// No description provided for @nurpowerButton.
  ///
  /// In en, this message translates to:
  /// **'NUR POWER BILL'**
  String get nurpowerButton;

  /// No description provided for @waterButton.
  ///
  /// In en, this message translates to:
  /// **'WATER BILL'**
  String get waterButton;

  /// No description provided for @tmButton.
  ///
  /// In en, this message translates to:
  /// **'TM BILL'**
  String get tmButton;

  /// No description provided for @telkoButton.
  ///
  /// In en, this message translates to:
  /// **'TELCO BILL'**
  String get telkoButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get backButton;

  /// No description provided for @alertTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get alertTitle;

  /// No description provided for @alertEnterInfo.
  ///
  /// In en, this message translates to:
  /// **'Please enter information before proceeding.'**
  String get alertEnterInfo;

  /// No description provided for @alertEnterIC.
  ///
  /// In en, this message translates to:
  /// **'Please enter IC number.'**
  String get alertEnterIC;

  /// No description provided for @alertNoTaxRecord.
  ///
  /// In en, this message translates to:
  /// **'No tax record found.'**
  String get alertNoTaxRecord;

  /// No description provided for @alertNoLicenseRecord.
  ///
  /// In en, this message translates to:
  /// **'No license record found.'**
  String get alertNoLicenseRecord;

  /// No description provided for @alertEnterPlateNo.
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle registration number.'**
  String get alertEnterPlateNo;

  /// No description provided for @alertNoCompoundRecord.
  ///
  /// In en, this message translates to:
  /// **'No compound record found.'**
  String get alertNoCompoundRecord;

  /// No description provided for @alertEnterCompoundNo.
  ///
  /// In en, this message translates to:
  /// **'Please enter compound number.'**
  String get alertEnterCompoundNo;

  /// No description provided for @alertEnterSewaan.
  ///
  /// In en, this message translates to:
  /// **'Please enter Account Number.'**
  String get alertEnterSewaan;

  /// No description provided for @alertNoSewaan.
  ///
  /// In en, this message translates to:
  /// **'No Rent Record Found.'**
  String get alertNoSewaan;

  /// No description provided for @keyboardBackspace.
  ///
  /// In en, this message translates to:
  /// **'BACKSPACE'**
  String get keyboardBackspace;

  /// No description provided for @keyboardClearAll.
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL'**
  String get keyboardClearAll;

  /// No description provided for @buttonBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get buttonBack;

  /// No description provided for @buttonContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get buttonContinue;

  /// No description provided for @p5parkingText1.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE PARKING DURATION'**
  String get p5parkingText1;

  /// No description provided for @p5parkingText2.
  ///
  /// In en, this message translates to:
  /// **'UNTIL'**
  String get p5parkingText2;

  /// No description provided for @p5parkingTitle.
  ///
  /// In en, this message translates to:
  /// **'SELECT PARKING DURATION'**
  String get p5parkingTitle;

  /// No description provided for @p5parkingTimeRange.
  ///
  /// In en, this message translates to:
  /// **'{startTime} UNTIL {endTime}'**
  String p5parkingTimeRange(Object endTime, Object startTime);

  /// No description provided for @p5parkingRatePerHour.
  ///
  /// In en, this message translates to:
  /// **'RATE PER HOUR = RM {ratePerHour}'**
  String p5parkingRatePerHour(Object ratePerHour);

  /// No description provided for @p5parkingTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT = RM {amount}'**
  String p5parkingTotalAmount(Object amount);

  /// No description provided for @parkingStartTimeDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer: The parking session start time will begin only after your payment has been successfully completed.'**
  String get parkingStartTimeDisclaimer;

  /// No description provided for @receiptDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{# Hour} other{# Hours}}'**
  String receiptDurationValue(int hours);

  /// No description provided for @p5parkingNumberPlate.
  ///
  /// In en, this message translates to:
  /// **'PLATE NUMBER'**
  String get p5parkingNumberPlate;

  /// No description provided for @p5parkingTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL PAYMENT'**
  String get p5parkingTotal;

  /// No description provided for @p5parkingStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get p5parkingStart;

  /// No description provided for @p5timeparking.
  ///
  /// In en, this message translates to:
  /// **'Parking Time:'**
  String get p5timeparking;

  /// No description provided for @p5parkingEnd.
  ///
  /// In en, this message translates to:
  /// **'END'**
  String get p5parkingEnd;

  /// No description provided for @p5tempoh.
  ///
  /// In en, this message translates to:
  /// **'Parking Period:'**
  String get p5tempoh;

  /// No description provided for @p5Total.
  ///
  /// In en, this message translates to:
  /// **'Total Payment:'**
  String get p5Total;

  /// No description provided for @newParkingEnd.
  ///
  /// In en, this message translates to:
  /// **'New Parking End Time'**
  String get newParkingEnd;

  /// No description provided for @currentParkingEnd.
  ///
  /// In en, this message translates to:
  /// **'Current Parking End Time'**
  String get currentParkingEnd;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'HOUR'**
  String get time;

  /// No description provided for @confirmDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'PRESS OK IF CONFIRMED'**
  String get confirmDialogTitle;

  /// No description provided for @plateNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate Number: {plate}'**
  String plateNumberLabel(Object plate);

  /// No description provided for @parkingDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'PARKING FOR {hours} HOURS'**
  String parkingDurationLabel(Object hours);

  /// No description provided for @parkingStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get parkingStartTimeLabel;

  /// No description provided for @parkingEndTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get parkingEndTimeLabel;

  /// No description provided for @timeRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'FROM {startTime} TO {endTime}'**
  String timeRangeLabel(Object endTime, Object startTime);

  /// No description provided for @totalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT: RM {total}'**
  String totalAmountLabel(Object total);

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get confirmButton;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT'**
  String get paymentTitle;

  /// No description provided for @paymentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PLEASE CHOOSE YOUR PAYMENT'**
  String get paymentSubtitle;

  /// No description provided for @totalAmountText.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get totalAmountText;

  /// No description provided for @cardButton.
  ///
  /// In en, this message translates to:
  /// **'PAY BY CARD'**
  String get cardButton;

  /// No description provided for @qrButton.
  ///
  /// In en, this message translates to:
  /// **'PAY WITH QR'**
  String get qrButton;

  /// No description provided for @weAcceptText.
  ///
  /// In en, this message translates to:
  /// **'WE ACCEPT :'**
  String get weAcceptText;

  /// No description provided for @cardConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Card Payment'**
  String get cardConfirmTitle;

  /// No description provided for @cardConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to pay using a Debit or Credit Card?\n\nBefore continuing:\n• Prepare your physical card.\n• Hold your card near the card reader when instructed.\n• Do not remove your card until you hear the beep sound.'**
  String get cardConfirmMessage;

  /// No description provided for @cardConfirmContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get cardConfirmContinue;

  /// No description provided for @cardConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cardConfirmCancel;

  /// No description provided for @paymentCancelling.
  ///
  /// In en, this message translates to:
  /// **'CANCELLING PAYMENT'**
  String get paymentCancelling;

  /// No description provided for @paymentCancellingInstruction.
  ///
  /// In en, this message translates to:
  /// **'No card detected.\nCancelling transaction...\nPlease wait.'**
  String get paymentCancellingInstruction;

  /// No description provided for @paymentTapYourCard.
  ///
  /// In en, this message translates to:
  /// **'TAP YOUR CARD'**
  String get paymentTapYourCard;

  /// No description provided for @paymentTapCardInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please tap on the card reader\nuntil \"Bip\" sound is heard'**
  String get paymentTapCardInstruction;

  /// No description provided for @paymentProcessing.
  ///
  /// In en, this message translates to:
  /// **'PROCESSING'**
  String get paymentProcessing;

  /// No description provided for @paymentProcessingInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we process\nyour payment...'**
  String get paymentProcessingInstruction;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT SUCCESSFUL'**
  String get paymentSuccessful;

  /// No description provided for @paymentSuccessInstruction.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to receipt...'**
  String get paymentSuccessInstruction;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT FAILED'**
  String get paymentFailed;

  /// No description provided for @paymentFailedInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get paymentFailedInstruction;

  /// No description provided for @titleReceiptParking.
  ///
  /// In en, this message translates to:
  /// **'PARKING RECEIPT'**
  String get titleReceiptParking;

  /// No description provided for @titleReceiptLicense.
  ///
  /// In en, this message translates to:
  /// **'LICENSE RECEIPT'**
  String get titleReceiptLicense;

  /// No description provided for @titleReceiptTax.
  ///
  /// In en, this message translates to:
  /// **'TAX RECEIPT'**
  String get titleReceiptTax;

  /// No description provided for @titleReceiptMultipleCompound.
  ///
  /// In en, this message translates to:
  /// **'MULTIPLE COMPOUND RECEIPT'**
  String get titleReceiptMultipleCompound;

  /// No description provided for @titleReceiptSingleCompound.
  ///
  /// In en, this message translates to:
  /// **'SINGLE COMPOUND RECEIPT'**
  String get titleReceiptSingleCompound;

  /// No description provided for @titleReceiptSewaan.
  ///
  /// In en, this message translates to:
  /// **'RENT RECEIPT'**
  String get titleReceiptSewaan;

  /// No description provided for @homeButton.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get homeButton;

  /// No description provided for @receiptPlateLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate No: {plate}'**
  String receiptPlateLabel(Object plate);

  /// No description provided for @receiptDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration: {hours} Hours'**
  String receiptDurationLabel(Object hours);

  /// No description provided for @receiptAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Payment: RM {amount}'**
  String receiptAmountLabel(Object amount);

  /// No description provided for @receiptStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Time: {time}'**
  String receiptStartTimeLabel(Object time);

  /// No description provided for @receiptEndTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'End Time: {time}'**
  String receiptEndTimeLabel(Object time);

  /// No description provided for @receiptPlateLabel2.
  ///
  /// In en, this message translates to:
  /// **'Plate No'**
  String get receiptPlateLabel2;

  /// No description provided for @receiptDurationLabel2.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get receiptDurationLabel2;

  /// No description provided for @receiptAmountLabel2.
  ///
  /// In en, this message translates to:
  /// **'Total Payment'**
  String get receiptAmountLabel2;

  /// No description provided for @receiptStartTimeLabel2.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get receiptStartTimeLabel2;

  /// No description provided for @receiptEndTimeLabel2.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get receiptEndTimeLabel2;

  /// No description provided for @receiptScanQrText2.
  ///
  /// In en, this message translates to:
  /// **'Please Scan the QR Code for Full Receipt Details'**
  String get receiptScanQrText2;

  /// No description provided for @receiptScanQrText.
  ///
  /// In en, this message translates to:
  /// **'Please Scan the QR Code for Full Receipt Details'**
  String get receiptScanQrText;

  /// No description provided for @p5extendparkingTitle.
  ///
  /// In en, this message translates to:
  /// **'EXTEND YOUR PARKING TIME'**
  String get p5extendparkingTitle;

  /// No description provided for @p5extendparkingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PLEASE SELECT AN OPTION'**
  String get p5extendparkingSubtitle;

  /// No description provided for @plusTimeButton.
  ///
  /// In en, this message translates to:
  /// **'ADD\nTIME'**
  String get plusTimeButton;

  /// No description provided for @receiptButton.
  ///
  /// In en, this message translates to:
  /// **'RECEIPT'**
  String get receiptButton;

  /// No description provided for @parkingExpiredAfter6pm.
  ///
  /// In en, this message translates to:
  /// **'Parking end time has reached or passed 6:00 PM. Additional time is not allowed.'**
  String get parkingExpiredAfter6pm;

  /// No description provided for @p6extendparkingTitle.
  ///
  /// In en, this message translates to:
  /// **'ADD ON PARKING TIME'**
  String get p6extendparkingTitle;

  /// No description provided for @p6extendparkingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'END TIME TICKET:'**
  String get p6extendparkingSubtitle;

  /// No description provided for @extendTimeUntil.
  ///
  /// In en, this message translates to:
  /// **'EXTENDED TIME UNTIL {time}'**
  String extendTimeUntil(Object time);

  /// No description provided for @p5TaxTitle.
  ///
  /// In en, this message translates to:
  /// **'TAX SELECTION'**
  String get p5TaxTitle;

  /// No description provided for @p5TaxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SELECT TAXES YOU WANT TO PAY'**
  String get p5TaxSubtitle;

  /// No description provided for @taxSelectAll.
  ///
  /// In en, this message translates to:
  /// **'SELECT ALL'**
  String get taxSelectAll;

  /// No description provided for @taxUnselectAll.
  ///
  /// In en, this message translates to:
  /// **'UNSELECT ALL'**
  String get taxUnselectAll;

  /// No description provided for @taxBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get taxBack;

  /// No description provided for @taxProceed.
  ///
  /// In en, this message translates to:
  /// **'PROCEED'**
  String get taxProceed;

  /// No description provided for @taxAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get taxAlertTitle;

  /// No description provided for @taxAlertSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one tax'**
  String get taxAlertSelectAtLeastOne;

  /// No description provided for @taxHeaderBillNo.
  ///
  /// In en, this message translates to:
  /// **'Bill No'**
  String get taxHeaderBillNo;

  /// No description provided for @taxHeaderProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get taxHeaderProperty;

  /// No description provided for @taxHeaderDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get taxHeaderDueDate;

  /// No description provided for @taxHeaderAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (RM)'**
  String get taxHeaderAmount;

  /// No description provided for @p5LicenseTitle.
  ///
  /// In en, this message translates to:
  /// **'LICENSE SELECTION'**
  String get p5LicenseTitle;

  /// No description provided for @p5LicenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SELECT LICENSE(S) YOU WANT TO PAY'**
  String get p5LicenseSubtitle;

  /// No description provided for @licenseSelectAll.
  ///
  /// In en, this message translates to:
  /// **'SELECT ALL'**
  String get licenseSelectAll;

  /// No description provided for @licenseUnselectAll.
  ///
  /// In en, this message translates to:
  /// **'UNSELECT ALL'**
  String get licenseUnselectAll;

  /// No description provided for @licenseHeaderNo.
  ///
  /// In en, this message translates to:
  /// **'License No'**
  String get licenseHeaderNo;

  /// No description provided for @licenseHeaderType.
  ///
  /// In en, this message translates to:
  /// **'License Type'**
  String get licenseHeaderType;

  /// No description provided for @licenseHeaderEndDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get licenseHeaderEndDate;

  /// No description provided for @licenseHeaderAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (RM)'**
  String get licenseHeaderAmount;

  /// No description provided for @licenseAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get licenseAlertTitle;

  /// No description provided for @licenseAlertSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one license'**
  String get licenseAlertSelectAtLeastOne;

  /// No description provided for @licenseBackButton.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get licenseBackButton;

  /// No description provided for @licenseProceedButton.
  ///
  /// In en, this message translates to:
  /// **'PROCEED'**
  String get licenseProceedButton;

  /// No description provided for @licenseTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'RM {amount}'**
  String licenseTotalAmount(Object amount);

  /// No description provided for @p5MultiCompoundTitle.
  ///
  /// In en, this message translates to:
  /// **'COMPOUND SELECTION'**
  String get p5MultiCompoundTitle;

  /// No description provided for @p5MultiCompoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SELECT COMPOUNDS YOU WANT TO PAY'**
  String get p5MultiCompoundSubtitle;

  /// No description provided for @multiCompoundAlertSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one compound'**
  String get multiCompoundAlertSelectAtLeastOne;

  /// No description provided for @multiCompoundHeaderNo.
  ///
  /// In en, this message translates to:
  /// **'Compound No.'**
  String get multiCompoundHeaderNo;

  /// No description provided for @multiCompoundHeaderOffense.
  ///
  /// In en, this message translates to:
  /// **'Offense'**
  String get multiCompoundHeaderOffense;

  /// No description provided for @detailCompoundText.
  ///
  /// In en, this message translates to:
  /// **'Butiran Kompaun'**
  String get detailCompoundText;

  /// No description provided for @perintah.
  ///
  /// In en, this message translates to:
  /// **'Offense Type'**
  String get perintah;

  /// No description provided for @masa.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get masa;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @multiCompoundHeaderDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get multiCompoundHeaderDate;

  /// No description provided for @multiCompoundHeaderAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (RM)'**
  String get multiCompoundHeaderAmount;

  /// No description provided for @multiCompoundSelectAll.
  ///
  /// In en, this message translates to:
  /// **'SELECT ALL'**
  String get multiCompoundSelectAll;

  /// No description provided for @multiCompoundUnselectAll.
  ///
  /// In en, this message translates to:
  /// **'UNSELECT ALL'**
  String get multiCompoundUnselectAll;

  /// No description provided for @multiCompoundTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'RM {amount}'**
  String multiCompoundTotalAmount(Object amount);

  /// No description provided for @p5SingleCompoundTitle.
  ///
  /// In en, this message translates to:
  /// **'COMPOUND INFORMATION'**
  String get p5SingleCompoundTitle;

  /// No description provided for @singleCompoundOffenderName.
  ///
  /// In en, this message translates to:
  /// **'Offender Name'**
  String get singleCompoundOffenderName;

  /// No description provided for @singleCompoundNo.
  ///
  /// In en, this message translates to:
  /// **'Compound No.'**
  String get singleCompoundNo;

  /// No description provided for @singleCompoundPlateNo.
  ///
  /// In en, this message translates to:
  /// **'Plate No.'**
  String get singleCompoundPlateNo;

  /// No description provided for @singleCompoundOffense.
  ///
  /// In en, this message translates to:
  /// **'Offense'**
  String get singleCompoundOffense;

  /// No description provided for @singleCompoundDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get singleCompoundDate;

  /// No description provided for @singleCompoundTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get singleCompoundTime;

  /// No description provided for @singleCompoundKodHasil.
  ///
  /// In en, this message translates to:
  /// **'Revenue Code'**
  String get singleCompoundKodHasil;

  /// No description provided for @singleCompoundAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (RM)'**
  String get singleCompoundAmount;

  /// No description provided for @closetext.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get closetext;

  /// No description provided for @scantext.
  ///
  /// In en, this message translates to:
  /// **'Imbas Untuk Mengemudi'**
  String get scantext;

  /// No description provided for @bentongExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Bentong Exploration'**
  String get bentongExplorationTitle;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'COPYRIGHT © 2025 ALL RIGHTS RESERVED.'**
  String get copyright;

  /// No description provided for @jomKeBentongGallery.
  ///
  /// In en, this message translates to:
  /// **'BENTONG GALLERY'**
  String get jomKeBentongGallery;

  /// No description provided for @jomKeBentongDesc.
  ///
  /// In en, this message translates to:
  /// **'Historical place in Bentong'**
  String get jomKeBentongDesc;

  /// No description provided for @jomKeBentongFull.
  ///
  /// In en, this message translates to:
  /// **'Jom Ke Bentong Gallery is a cultural and historical gallery that introduces visitors to the heritage of Bentong. It showcases old photographs, traditional tools, and stories about the town’s development from a mining settlement into a modern district.'**
  String get jomKeBentongFull;

  /// No description provided for @jandaBaikTitle.
  ///
  /// In en, this message translates to:
  /// **'JANDA BAIK, PAHANG'**
  String get jandaBaikTitle;

  /// No description provided for @jandaBaikDesc.
  ///
  /// In en, this message translates to:
  /// **'Let’s explore the scenery in Janda Baik'**
  String get jandaBaikDesc;

  /// No description provided for @jandaBaikFull.
  ///
  /// In en, this message translates to:
  /// **'Janda Baik is a peaceful eco-tourism village surrounded by rainforest, rivers, and waterfalls. It is popular for homestays, jungle trekking, and nature activities, offering visitors a calm escape from busy city life.'**
  String get jandaBaikFull;

  /// No description provided for @bentongWalkTitle.
  ///
  /// In en, this message translates to:
  /// **'BENTONG WALK'**
  String get bentongWalkTitle;

  /// No description provided for @bentongWalkDesc.
  ///
  /// In en, this message translates to:
  /// **'Let’s take a walk at Bentong Walk'**
  String get bentongWalkDesc;

  /// No description provided for @bentongWalkFull.
  ///
  /// In en, this message translates to:
  /// **'Bentong Walk is a modern public space with food stalls, cafes, and event areas. It is a popular gathering spot, especially during weekends and evenings.'**
  String get bentongWalkFull;

  /// No description provided for @lemangTokKiTitle.
  ///
  /// In en, this message translates to:
  /// **'LEMANG TOK KI'**
  String get lemangTokKiTitle;

  /// No description provided for @lemangTokKiDesc.
  ///
  /// In en, this message translates to:
  /// **'Famous lemang in Bentong'**
  String get lemangTokKiDesc;

  /// No description provided for @lemangTokKiFull.
  ///
  /// In en, this message translates to:
  /// **'Lemang Tok Ki is famous for traditional bamboo-cooked lemang made with glutinous rice and coconut milk. It is a must-visit food destination in Bentong.'**
  String get lemangTokKiFull;

  /// No description provided for @alorsetarExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Alor Setar Eksploration'**
  String get alorsetarExplorationTitle;

  /// No description provided for @muziumDirajaTitle.
  ///
  /// In en, this message translates to:
  /// **'Royal Kedah Museum'**
  String get muziumDirajaTitle;

  /// No description provided for @muziumDirajaDesc.
  ///
  /// In en, this message translates to:
  /// **'Former royal palace of Kedah.'**
  String get muziumDirajaDesc;

  /// No description provided for @muziumDirajaFull.
  ///
  /// In en, this message translates to:
  /// **'The Royal Kedah Museum was formerly a royal palace and now serves as a historical museum. It displays royal artifacts, historical documents, and information related to the Kedah Sultanate.'**
  String get muziumDirajaFull;

  /// No description provided for @menaraAlorSetarTitle.
  ///
  /// In en, this message translates to:
  /// **'Alor Setar Tower'**
  String get menaraAlorSetarTitle;

  /// No description provided for @menaraAlorSetarDesc.
  ///
  /// In en, this message translates to:
  /// **'An iconic landmark of Kedah.'**
  String get menaraAlorSetarDesc;

  /// No description provided for @menaraAlorSetarFull.
  ///
  /// In en, this message translates to:
  /// **'Alor Setar Tower is a telecommunications tower and one of Kedah’s main tourist attractions. Visitors can enjoy panoramic views of Alor Setar city and the surrounding areas from the observation deck.'**
  String get menaraAlorSetarFull;

  /// No description provided for @masjidZahirTitle.
  ///
  /// In en, this message translates to:
  /// **'Zahir Mosque'**
  String get masjidZahirTitle;

  /// No description provided for @masjidZahirDesc.
  ///
  /// In en, this message translates to:
  /// **'One of the oldest and most beautiful mosques in Malaysia.'**
  String get masjidZahirDesc;

  /// No description provided for @masjidZahirFull.
  ///
  /// In en, this message translates to:
  /// **'Zahir Mosque was built in 1912 and is renowned for its distinctive Moorish architecture. It serves as a major religious center and an important landmark in Kedah.'**
  String get masjidZahirFull;

  /// No description provided for @balaiBesarTitle.
  ///
  /// In en, this message translates to:
  /// **'Balai Besar'**
  String get balaiBesarTitle;

  /// No description provided for @balaiBesarDesc.
  ///
  /// In en, this message translates to:
  /// **'Royal ceremonial hall of Kedah.'**
  String get balaiBesarDesc;

  /// No description provided for @balaiBesarFull.
  ///
  /// In en, this message translates to:
  /// **'Balai Besar is used for royal ceremonies, official state events, and coronations. The building represents the rich royal heritage and history of the Kedah Sultanate.'**
  String get balaiBesarFull;

  /// No description provided for @mahathirHouseTitle.
  ///
  /// In en, this message translates to:
  /// **'Birthplace of Tun Dr. Mahathir'**
  String get mahathirHouseTitle;

  /// No description provided for @mahathirHouseDesc.
  ///
  /// In en, this message translates to:
  /// **'Birthplace of Malaysia’s 4th and 7th Prime Minister.'**
  String get mahathirHouseDesc;

  /// No description provided for @mahathirHouseFull.
  ///
  /// In en, this message translates to:
  /// **'This house is the birthplace of Tun Dr. Mahathir Mohamad and has been converted into a museum. It showcases his early life, personal background, and contributions to Malaysia’s development.'**
  String get mahathirHouseFull;

  /// No description provided for @muziumPadiTitle.
  ///
  /// In en, this message translates to:
  /// **'Paddy Museum'**
  String get muziumPadiTitle;

  /// No description provided for @muziumPadiDesc.
  ///
  /// In en, this message translates to:
  /// **'A unique museum showcasing the history of rice cultivation in Kedah.'**
  String get muziumPadiDesc;

  /// No description provided for @muziumPadiFull.
  ///
  /// In en, this message translates to:
  /// **'The Paddy Museum highlights Kedah’s heritage as the Rice Bowl of Malaysia. It features interactive exhibits, historical artifacts, and a panoramic gallery that illustrates the evolution of rice farming from traditional methods to modern agricultural technology.'**
  String get muziumPadiFull;

  /// No description provided for @tamanJubliTitle.
  ///
  /// In en, this message translates to:
  /// **'Golden Jubilee Park'**
  String get tamanJubliTitle;

  /// No description provided for @tamanJubliDesc.
  ///
  /// In en, this message translates to:
  /// **'A recreational park for families.'**
  String get tamanJubliDesc;

  /// No description provided for @tamanJubliFull.
  ///
  /// In en, this message translates to:
  /// **'Golden Jubilee Park is a green recreational space suitable for leisure activities such as jogging, walking, and family outings. It is a popular relaxation spot among locals.'**
  String get tamanJubliFull;

  /// No description provided for @pekanRabuTitle.
  ///
  /// In en, this message translates to:
  /// **'Pekan Rabu'**
  String get pekanRabuTitle;

  /// No description provided for @pekanRabuDesc.
  ///
  /// In en, this message translates to:
  /// **'A famous traditional market in Kedah.'**
  String get pekanRabuDesc;

  /// No description provided for @pekanRabuFull.
  ///
  /// In en, this message translates to:
  /// **'Pekan Rabu offers a variety of local products including traditional food, clothing, and handicrafts. It is a must-visit destination for tourists seeking an authentic local market experience.'**
  String get pekanRabuFull;

  /// No description provided for @kualaKedahTitle.
  ///
  /// In en, this message translates to:
  /// **'Kuala Kedah Beach'**
  String get kualaKedahTitle;

  /// No description provided for @kualaKedahDesc.
  ///
  /// In en, this message translates to:
  /// **'A well-known fishing village area.'**
  String get kualaKedahDesc;

  /// No description provided for @kualaKedahFull.
  ///
  /// In en, this message translates to:
  /// **'Kuala Kedah Beach is famous for its coastal views and fresh seafood. The area is a popular destination for visitors who want to enjoy local seafood and seaside scenery.'**
  String get kualaKedahFull;

  /// No description provided for @royaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Nasi Lemak Royale'**
  String get royaleTitle;

  /// No description provided for @royaleDesc.
  ///
  /// In en, this message translates to:
  /// **'A famous Kedah-style nasi lemak.'**
  String get royaleDesc;

  /// No description provided for @royaleFull.
  ///
  /// In en, this message translates to:
  /// **'Nasi Lemak Royale is well known for its fragrant rice served with rich curry gravy, fried chicken, and a variety of flavorful side dishes.'**
  String get royaleFull;

  /// No description provided for @meeShamTitle.
  ///
  /// In en, this message translates to:
  /// **'Mee Sham Roti Doll'**
  String get meeShamTitle;

  /// No description provided for @meeShamDesc.
  ///
  /// In en, this message translates to:
  /// **'A traditional noodle dish from Kedah.'**
  String get meeShamDesc;

  /// No description provided for @meeShamFull.
  ///
  /// In en, this message translates to:
  /// **'Mee Sham is a traditional Kedah noodle dish served with a sweet and thick gravy, often enjoyed together with roti doll or fritters.'**
  String get meeShamFull;

  /// No description provided for @laksaTelukKechaiTitle.
  ///
  /// In en, this message translates to:
  /// **'Laksa Teluk Kechai'**
  String get laksaTelukKechaiTitle;

  /// No description provided for @laksaTelukKechaiDesc.
  ///
  /// In en, this message translates to:
  /// **'A famous Kedah laksa with thick and tangy fish broth.'**
  String get laksaTelukKechaiDesc;

  /// No description provided for @laksaTelukKechaiFull.
  ///
  /// In en, this message translates to:
  /// **'Laksa Teluk Kechai is a popular Kedah dish known for its thick fish-based broth with a tangy flavor from tamarind and local spices. It is a favorite among locals and represents the unique laksa heritage of Kedah.'**
  String get laksaTelukKechaiFull;

  /// No description provided for @yasmeenTitle.
  ///
  /// In en, this message translates to:
  /// **'Yasmeen Nasi Kandar'**
  String get yasmeenTitle;

  /// No description provided for @yasmeenDesc.
  ///
  /// In en, this message translates to:
  /// **'Popular Indian Muslim cuisine in Alor Setar.'**
  String get yasmeenDesc;

  /// No description provided for @yasmeenFull.
  ///
  /// In en, this message translates to:
  /// **'Yasmeen Nasi Kandar is well known for its wide selection of curries and flavorful dishes. It is a favorite dining spot for lovers of Indian Muslim food.'**
  String get yasmeenFull;

  /// No description provided for @gulaiPanasTitle.
  ///
  /// In en, this message translates to:
  /// **'Gulai Panas Mak Teh'**
  String get gulaiPanasTitle;

  /// No description provided for @gulaiPanasDesc.
  ///
  /// In en, this message translates to:
  /// **'A famous traditional hot curry dish.'**
  String get gulaiPanasDesc;

  /// No description provided for @gulaiPanasFull.
  ///
  /// In en, this message translates to:
  /// **'Gulai Panas Mak Teh is renowned for its authentic taste and rich blend of local spices. It is a popular choice for visitors who want to experience traditional Kedah cuisine.'**
  String get gulaiPanasFull;

  /// No description provided for @skydeckTitle.
  ///
  /// In en, this message translates to:
  /// **'Skydeck Alor Setar Tower'**
  String get skydeckTitle;

  /// No description provided for @skydeckDesc.
  ///
  /// In en, this message translates to:
  /// **'A thrilling glass-floor observation deck.'**
  String get skydeckDesc;

  /// No description provided for @skydeckFull.
  ///
  /// In en, this message translates to:
  /// **'Skydeck Alor Setar Tower offers a unique experience with its glass floor, allowing visitors to enjoy breathtaking views of Alor Setar city from above. It is one of the main attractions for those seeking adventure and scenic views.'**
  String get skydeckFull;

  /// No description provided for @nsExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Negeri Sembilan'**
  String get nsExplorationTitle;

  /// No description provided for @nsIstanaTitle.
  ///
  /// In en, this message translates to:
  /// **'Istana Seri Menanti'**
  String get nsIstanaTitle;

  /// No description provided for @nsIstanaDesc.
  ///
  /// In en, this message translates to:
  /// **'Traditional Minangkabau royal palace.'**
  String get nsIstanaDesc;

  /// No description provided for @nsIstanaFull.
  ///
  /// In en, this message translates to:
  /// **'Istana Seri Menanti is the royal palace of Negeri Sembilan, built entirely without nails and showcasing Minangkabau architecture.'**
  String get nsIstanaFull;

  /// No description provided for @nsMuseumTitle.
  ///
  /// In en, this message translates to:
  /// **'Negeri Sembilan State Museum'**
  String get nsMuseumTitle;

  /// No description provided for @nsMuseumDesc.
  ///
  /// In en, this message translates to:
  /// **'Cultural and historical museum.'**
  String get nsMuseumDesc;

  /// No description provided for @nsMuseumFull.
  ///
  /// In en, this message translates to:
  /// **'The museum displays the history, culture and customs of Negeri Sembilan.'**
  String get nsMuseumFull;

  /// No description provided for @nsMasjidTitle.
  ///
  /// In en, this message translates to:
  /// **'Masjid Sri Sendayan'**
  String get nsMasjidTitle;

  /// No description provided for @nsMasjidDesc.
  ///
  /// In en, this message translates to:
  /// **'Iconic modern mosque.'**
  String get nsMasjidDesc;

  /// No description provided for @nsMasjidFull.
  ///
  /// In en, this message translates to:
  /// **'Masjid Sri Sendayan is one of the largest mosques in Negeri Sembilan with stunning architecture.'**
  String get nsMasjidFull;

  /// No description provided for @nsPortDicksonTitle.
  ///
  /// In en, this message translates to:
  /// **'Port Dickson Beach'**
  String get nsPortDicksonTitle;

  /// No description provided for @nsPortDicksonDesc.
  ///
  /// In en, this message translates to:
  /// **'Famous beach destination.'**
  String get nsPortDicksonDesc;

  /// No description provided for @nsPortDicksonFull.
  ///
  /// In en, this message translates to:
  /// **'Port Dickson is known for its beaches, resorts and seaside attractions.'**
  String get nsPortDicksonFull;

  /// No description provided for @nsGunungAngsiTitle.
  ///
  /// In en, this message translates to:
  /// **'Gunung Angsi'**
  String get nsGunungAngsiTitle;

  /// No description provided for @nsGunungAngsiDesc.
  ///
  /// In en, this message translates to:
  /// **'Popular hiking mountain.'**
  String get nsGunungAngsiDesc;

  /// No description provided for @nsGunungAngsiFull.
  ///
  /// In en, this message translates to:
  /// **'Gunung Angsi is a favourite hiking spot offering panoramic views.'**
  String get nsGunungAngsiFull;

  /// No description provided for @nsJeramTitle.
  ///
  /// In en, this message translates to:
  /// **'Jeram Toi Eco Park'**
  String get nsJeramTitle;

  /// No description provided for @nsJeramDesc.
  ///
  /// In en, this message translates to:
  /// **'Nature and waterfall park.'**
  String get nsJeramDesc;

  /// No description provided for @nsJeramFull.
  ///
  /// In en, this message translates to:
  /// **'Jeram Toi is an eco-park with rivers, waterfalls and jungle trails.'**
  String get nsJeramFull;

  /// No description provided for @nsKuwaahTitle.
  ///
  /// In en, this message translates to:
  /// **'Kuwaah Cafe'**
  String get nsKuwaahTitle;

  /// No description provided for @nsKuwaahDesc.
  ///
  /// In en, this message translates to:
  /// **'Modern cafe with local fusion food.'**
  String get nsKuwaahDesc;

  /// No description provided for @nsKuwaahFull.
  ///
  /// In en, this message translates to:
  /// **'Kuwaah Cafe offers a modern dining experience with local and western fusion dishes in a cozy atmosphere.'**
  String get nsKuwaahFull;

  /// No description provided for @nsRimbaTitle.
  ///
  /// In en, this message translates to:
  /// **'The Rimba,Lavender Heights'**
  String get nsRimbaTitle;

  /// No description provided for @nsRimbaDesc.
  ///
  /// In en, this message translates to:
  /// **'Nature-inspired dining experience.'**
  String get nsRimbaDesc;

  /// No description provided for @nsRimbaFull.
  ///
  /// In en, this message translates to:
  /// **'The Rimba provides a unique dining environment surrounded by greenery, perfect for relaxing meals.'**
  String get nsRimbaFull;

  /// No description provided for @nsZamiraTitle.
  ///
  /// In en, this message translates to:
  /// **'Zamira Dapur Kayu'**
  String get nsZamiraTitle;

  /// No description provided for @nsZamiraDesc.
  ///
  /// In en, this message translates to:
  /// **'Traditional Negeri Sembilan cuisine.'**
  String get nsZamiraDesc;

  /// No description provided for @nsZamiraFull.
  ///
  /// In en, this message translates to:
  /// **'Zamira Dapur Kayu serves authentic traditional dishes cooked using classic recipes and flavors.'**
  String get nsZamiraFull;

  /// No description provided for @nsHayyanTitle.
  ///
  /// In en, this message translates to:
  /// **'Hayyan Huda Opah\'s Kitchen'**
  String get nsHayyanTitle;

  /// No description provided for @nsHayyanDesc.
  ///
  /// In en, this message translates to:
  /// **'Home-style traditional cooking.'**
  String get nsHayyanDesc;

  /// No description provided for @nsHayyanFull.
  ///
  /// In en, this message translates to:
  /// **'Hayyan Huda Opah\'s Kitchen offers home-cooked traditional meals inspired by grandmother’s recipes.'**
  String get nsHayyanFull;

  /// No description provided for @receiptAutoReturn.
  ///
  /// In en, this message translates to:
  /// **'Returning to home in {seconds} seconds'**
  String receiptAutoReturn(int seconds);

  /// No description provided for @idleTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you still using this service?'**
  String get idleTitle;

  /// No description provided for @idleContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get idleContinue;

  /// No description provided for @idleGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get idleGoHome;

  /// No description provided for @idleMessage.
  ///
  /// In en, this message translates to:
  /// **'You will be returned to the main menu in {seconds} seconds.'**
  String idleMessage(int seconds);

  /// No description provided for @wildWestTitle.
  ///
  /// In en, this message translates to:
  /// **'Wild West Cowboy Indoor Theme Park'**
  String get wildWestTitle;

  /// No description provided for @wildWestDesc.
  ///
  /// In en, this message translates to:
  /// **'Fun indoor cowboy themed amusement park for all ages.'**
  String get wildWestDesc;

  /// No description provided for @wildWestFull.
  ///
  /// In en, this message translates to:
  /// **'Wild West Cowboy Indoor Theme Park is a unique indoor family amusement centre located in Dataran Segar, Port Dickson. It features colourful rides, interactive arcade games, thrilling 5D and 7D motion cinema experiences, escape rooms with themed puzzles, a variety of attractions such as Rodeo Bull rides and a game centre, as well as a cowboy café and souvenir shop — offering fun for both kids and adults throughout the year. Visitors can enjoy exciting attractions and immersive themes under one roof.'**
  String get wildWestFull;

  /// No description provided for @wetWorldTitle.
  ///
  /// In en, this message translates to:
  /// **'Wet World Resort Air Panas Pedas'**
  String get wetWorldTitle;

  /// No description provided for @wetWorldDesc.
  ///
  /// In en, this message translates to:
  /// **'Waterpark & natural hot springs destination with slides and relax pools.'**
  String get wetWorldDesc;

  /// No description provided for @wetWorldFull.
  ///
  /// In en, this message translates to:
  /// **'Wet World Resort Air Panas Pedas is a popular water theme park and hot spring attraction in Pedas, Negeri Sembilan. The park combines thrilling water rides and slides with soothing hot spring pools that are naturally heated and rich in mineral waters — believed to offer therapeutic benefits such as easing joint pains and relaxing muscles. The resort offers rides suitable for families as well as natural hot springs for visitors seeking relaxation and leisure.'**
  String get wetWorldFull;

  /// No description provided for @tnKenaboiTitle.
  ///
  /// In en, this message translates to:
  /// **'Taman Negeri Kenaboi'**
  String get tnKenaboiTitle;

  /// No description provided for @tnKenaboiDesc.
  ///
  /// In en, this message translates to:
  /// **'State forest park with rich biodiversity and nature trails.'**
  String get tnKenaboiDesc;

  /// No description provided for @tnKenaboiFull.
  ///
  /// In en, this message translates to:
  /// **'Taman Negeri Kenaboi is a protected forest reserve known for its lush rainforest habitat, wildlife, and outdoor trails. Visitors can explore scenic walks, observe diverse plant and animal life, and enjoy nature photography.'**
  String get tnKenaboiFull;

  /// No description provided for @eduEcoSungaiMenyalaTitle.
  ///
  /// In en, this message translates to:
  /// **'Pusat Edu-Ecotourism Sungai Menyala'**
  String get eduEcoSungaiMenyalaTitle;

  /// No description provided for @eduEcoSungaiMenyalaDesc.
  ///
  /// In en, this message translates to:
  /// **'Educational eco-tourism centre by the river.'**
  String get eduEcoSungaiMenyalaDesc;

  /// No description provided for @eduEcoSungaiMenyalaFull.
  ///
  /// In en, this message translates to:
  /// **'Pusat Edu-Ecotourism Sungai Menyala is an eco‑centric destination dedicated to conservation education along the Sungai Menyala river.'**
  String get eduEcoSungaiMenyalaFull;

  /// No description provided for @hutanRecTanjungTuanTitle.
  ///
  /// In en, this message translates to:
  /// **'Hutan Rekreasi Tanjung Tuan'**
  String get hutanRecTanjungTuanTitle;

  /// No description provided for @hutanRecTanjungTuanDesc.
  ///
  /// In en, this message translates to:
  /// **'Coastal forest park known for bird watching and nature trails.'**
  String get hutanRecTanjungTuanDesc;

  /// No description provided for @hutanRecTanjungTuanFull.
  ///
  /// In en, this message translates to:
  /// **'Hutan Rekreasi Tanjung Tuan is a scenic coastal forest park offering nature trails, headland views and seasonal bird migration observation — especially raptors that pass through on annual routes.'**
  String get hutanRecTanjungTuanFull;

  /// No description provided for @serembanHillParkTitle.
  ///
  /// In en, this message translates to:
  /// **'S2 Seremban Hill Park'**
  String get serembanHillParkTitle;

  /// No description provided for @serembanHillParkDesc.
  ///
  /// In en, this message translates to:
  /// **'Hill park with walking paths and scenic views.'**
  String get serembanHillParkDesc;

  /// No description provided for @serembanHillParkFull.
  ///
  /// In en, this message translates to:
  /// **'S2 Seremban Hill Park is a local recreational hill park featuring walking trails, lookout points with panoramic views of Seremban and surrounding valleys.'**
  String get serembanHillParkFull;

  /// No description provided for @pIkanHiasanPDTitle.
  ///
  /// In en, this message translates to:
  /// **'Pusat Ikan Hiasan Port Dickson'**
  String get pIkanHiasanPDTitle;

  /// No description provided for @pIkanHiasanPDDesc.
  ///
  /// In en, this message translates to:
  /// **'Aquarium showcasing marine ornamental species.'**
  String get pIkanHiasanPDDesc;

  /// No description provided for @pIkanHiasanPDFull.
  ///
  /// In en, this message translates to:
  /// **'Pusat Ikan Hiasan Port Dickson showcases a variety of coastal and marine ornamental fish species in well‑maintained aquarium exhibits — ideal for families and educational visits.'**
  String get pIkanHiasanPDFull;

  /// No description provided for @airTerjunLataKijangTitle.
  ///
  /// In en, this message translates to:
  /// **'Air Terjun Lata Kijang'**
  String get airTerjunLataKijangTitle;

  /// No description provided for @airTerjunLataKijangDesc.
  ///
  /// In en, this message translates to:
  /// **'Picturesque waterfall in a forest setting.'**
  String get airTerjunLataKijangDesc;

  /// No description provided for @airTerjunLataKijangFull.
  ///
  /// In en, this message translates to:
  /// **'Air Terjun Lata Kijang is a natural waterfall set amid lush forest — a refreshing destination for hikers, picnics and nature lovers.'**
  String get airTerjunLataKijangFull;

  /// No description provided for @hutanLipurJeramTengkekTitle.
  ///
  /// In en, this message translates to:
  /// **'Hutan Lipur Jeram Tengkek'**
  String get hutanLipurJeramTengkekTitle;

  /// No description provided for @hutanLipurJeramTengkekDesc.
  ///
  /// In en, this message translates to:
  /// **'Natural recreational forest with rapids and greenery.'**
  String get hutanLipurJeramTengkekDesc;

  /// No description provided for @hutanLipurJeramTengkekFull.
  ///
  /// In en, this message translates to:
  /// **'Hutan Lipur Jeram Tengkek is a natural forest recreation area where visitors can enjoy shaded trails, river rapids and lush greenery, perfect for outdoor outings. '**
  String get hutanLipurJeramTengkekFull;

  /// No description provided for @puncakBukitBatuPutihTitle.
  ///
  /// In en, this message translates to:
  /// **'Puncak Bukit Batu Putih'**
  String get puncakBukitBatuPutihTitle;

  /// No description provided for @puncakBukitBatuPutihDesc.
  ///
  /// In en, this message translates to:
  /// **'Hilltop destination with scenic views.'**
  String get puncakBukitBatuPutihDesc;

  /// No description provided for @puncakBukitBatuPutihFull.
  ///
  /// In en, this message translates to:
  /// **'Puncak Bukit Batu Putih offers visitors a scenic hilltop vantage point, ideal for hiking, photography and panoramic views of the surrounding landscapes. '**
  String get puncakBukitBatuPutihFull;

  /// No description provided for @muziumAstanaRajaMelawarTitle.
  ///
  /// In en, this message translates to:
  /// **'Muzium Replika Astana Raja Melawar'**
  String get muziumAstanaRajaMelawarTitle;

  /// No description provided for @muziumAstanaRajaMelawarDesc.
  ///
  /// In en, this message translates to:
  /// **'Replica museum of a historic palace.'**
  String get muziumAstanaRajaMelawarDesc;

  /// No description provided for @muziumAstanaRajaMelawarFull.
  ///
  /// In en, this message translates to:
  /// **'Muzium Replika Astana Raja Melawar is a cultural site featuring a detailed replica of the historic Astana Raja Melawar palace — offering insights into local heritage and architecture. '**
  String get muziumAstanaRajaMelawarFull;

  /// No description provided for @hutanSimpanGunungTampinTitle.
  ///
  /// In en, this message translates to:
  /// **'Hutan Simpan Gunung Tampin'**
  String get hutanSimpanGunungTampinTitle;

  /// No description provided for @hutanSimpanGunungTampinDesc.
  ///
  /// In en, this message translates to:
  /// **'Forest reserve with nature trails.'**
  String get hutanSimpanGunungTampinDesc;

  /// No description provided for @hutanSimpanGunungTampinFull.
  ///
  /// In en, this message translates to:
  /// **'Hutan Simpan Gunung Tampin is a forest reserve known for nature walks, endemic flora and fauna, and tranquil hiking routes. '**
  String get hutanSimpanGunungTampinFull;

  /// No description provided for @primalandTitle.
  ///
  /// In en, this message translates to:
  /// **'Taman Tema Air PRIMALAND'**
  String get primalandTitle;

  /// No description provided for @primalandDesc.
  ///
  /// In en, this message translates to:
  /// **'Water theme park with slides and pools.'**
  String get primalandDesc;

  /// No description provided for @primalandFull.
  ///
  /// In en, this message translates to:
  /// **'Taman Tema Air PRIMALAND is a family water theme park featuring thrilling water slides, pools, and recreation areas — great for cooling off and family fun. '**
  String get primalandFull;

  /// No description provided for @rantauEcoParkTitle.
  ///
  /// In en, this message translates to:
  /// **'Rantau Eco Park'**
  String get rantauEcoParkTitle;

  /// No description provided for @rantauEcoParkDesc.
  ///
  /// In en, this message translates to:
  /// **'Eco‑park with trails and nature activities.'**
  String get rantauEcoParkDesc;

  /// No description provided for @rantauEcoParkFull.
  ///
  /// In en, this message translates to:
  /// **'Rantau Eco Park is a natural park where visitors can enjoy gentle trails, picnic spots, and eco‑activities that promote recreation in nature.'**
  String get rantauEcoParkFull;

  /// No description provided for @royalGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Royal Gallery Tuanku Ja\'afar'**
  String get royalGalleryTitle;

  /// No description provided for @royalGalleryDesc.
  ///
  /// In en, this message translates to:
  /// **'A royal gallery showcasing the legacy of Negeri Sembilan\'s royal institution.'**
  String get royalGalleryDesc;

  /// No description provided for @royalGalleryFull.
  ///
  /// In en, this message translates to:
  /// **'The Royal Gallery Tuanku Ja\'afar in Seremban displays the history, royal regalia, personal collections, and achievements of Tuanku Ja\'afar ibni Almarhum Tuanku Abdul Rahman. It serves as an important cultural landmark reflecting the monarchy and governance of Negeri Sembilan.'**
  String get royalGalleryFull;

  /// No description provided for @centipedeTempleTitle.
  ///
  /// In en, this message translates to:
  /// **'Centipede Temple'**
  String get centipedeTempleTitle;

  /// No description provided for @centipedeTempleDesc.
  ///
  /// In en, this message translates to:
  /// **'A historic Chinese temple famous for its giant centipede statue.'**
  String get centipedeTempleDesc;

  /// No description provided for @centipedeTempleFull.
  ///
  /// In en, this message translates to:
  /// **'Centipede Temple, located in Port Dickson, is a well-known Taoist temple featuring a massive centipede sculpture. Built as a symbol of protection and spiritual belief, it attracts devotees and tourists seeking blessings and cultural experiences.'**
  String get centipedeTempleFull;

  /// No description provided for @armyMuseumPDTitle.
  ///
  /// In en, this message translates to:
  /// **'Army Museum Port Dickson'**
  String get armyMuseumPDTitle;

  /// No description provided for @armyMuseumPDDesc.
  ///
  /// In en, this message translates to:
  /// **'Malaysia’s main army museum showcasing military history.'**
  String get armyMuseumPDDesc;

  /// No description provided for @armyMuseumPDFull.
  ///
  /// In en, this message translates to:
  /// **'The Army Museum Port Dickson presents Malaysia’s military heritage through exhibitions of weapons, tanks, aircraft, uniforms, and historical documents. It plays an educational role in honoring the sacrifices of the Malaysian Armed Forces.'**
  String get armyMuseumPDFull;

  /// No description provided for @hayyanHudaTitle.
  ///
  /// In en, this message translates to:
  /// **'Hayyan Huda Opah’s Kitchen'**
  String get hayyanHudaTitle;

  /// No description provided for @hayyanHudaDesc.
  ///
  /// In en, this message translates to:
  /// **'Traditional Negeri Sembilan home-style cooking.'**
  String get hayyanHudaDesc;

  /// No description provided for @hayyanHudaFull.
  ///
  /// In en, this message translates to:
  /// **'Hayyan Huda Opah’s Kitchen is famous for authentic Negeri Sembilan dishes cooked using traditional recipes passed down through generations.'**
  String get hayyanHudaFull;

  /// No description provided for @kafeIkhwanTitle.
  ///
  /// In en, this message translates to:
  /// **'Kafe Ikhwan Nasi Ayam Hainan'**
  String get kafeIkhwanTitle;

  /// No description provided for @kafeIkhwanDesc.
  ///
  /// In en, this message translates to:
  /// **'Popular Hainanese chicken rice café.'**
  String get kafeIkhwanDesc;

  /// No description provided for @kafeIkhwanFull.
  ///
  /// In en, this message translates to:
  /// **'Kafe Ikhwan is well known for its fragrant Hainanese chicken rice served with flavorful sauces.'**
  String get kafeIkhwanFull;

  /// No description provided for @meeHirisTitle.
  ///
  /// In en, this message translates to:
  /// **'Mee Hiris China Muslim'**
  String get meeHirisTitle;

  /// No description provided for @meeHirisDesc.
  ///
  /// In en, this message translates to:
  /// **'Hand-pulled halal Chinese noodles.'**
  String get meeHirisDesc;

  /// No description provided for @meeHirisFull.
  ///
  /// In en, this message translates to:
  /// **'Mee Hiris China Muslim offers freshly hand-pulled noodles with rich soup and halal Chinese flavors.'**
  String get meeHirisFull;

  /// No description provided for @belqisTitle.
  ///
  /// In en, this message translates to:
  /// **'Restoran Belqis'**
  String get belqisTitle;

  /// No description provided for @belqisDesc.
  ///
  /// In en, this message translates to:
  /// **'Middle Eastern and local fusion cuisine.'**
  String get belqisDesc;

  /// No description provided for @belqisFull.
  ///
  /// In en, this message translates to:
  /// **'Restoran Belqis serves Middle Eastern dishes along with Malaysian favorites in a comfortable setting.'**
  String get belqisFull;

  /// No description provided for @seleraNogoriTitle.
  ///
  /// In en, this message translates to:
  /// **'Restoran Selera Nogori'**
  String get seleraNogoriTitle;

  /// No description provided for @seleraNogoriDesc.
  ///
  /// In en, this message translates to:
  /// **'Authentic Negeri Sembilan spicy dishes.'**
  String get seleraNogoriDesc;

  /// No description provided for @seleraNogoriFull.
  ///
  /// In en, this message translates to:
  /// **'Restoran Selera Nogori is famous for its masak lemak cili api and traditional Negeri Sembilan cuisine.'**
  String get seleraNogoriFull;

  /// No description provided for @kemangiTitle.
  ///
  /// In en, this message translates to:
  /// **'Restoren Kemangi'**
  String get kemangiTitle;

  /// No description provided for @kemangiDesc.
  ///
  /// In en, this message translates to:
  /// **'Indonesian and Malay cuisine.'**
  String get kemangiDesc;

  /// No description provided for @kemangiFull.
  ///
  /// In en, this message translates to:
  /// **'Restoren Kemangi offers Indonesian-inspired dishes with rich spices and aromatic flavors.'**
  String get kemangiFull;

  /// No description provided for @hajiShariffCendolTitle.
  ///
  /// In en, this message translates to:
  /// **'Haji Shariff’s Cendol'**
  String get hajiShariffCendolTitle;

  /// No description provided for @hajiShariffCendolDesc.
  ///
  /// In en, this message translates to:
  /// **'Classic Malaysian cendol dessert.'**
  String get hajiShariffCendolDesc;

  /// No description provided for @hajiShariffCendolFull.
  ///
  /// In en, this message translates to:
  /// **'Haji Shariff’s Cendol is a favorite dessert spot serving refreshing cendol with gula Melaka.'**
  String get hajiShariffCendolFull;

  /// No description provided for @nasiArabDamsyikTitle.
  ///
  /// In en, this message translates to:
  /// **'Nasi Arab Damsyik'**
  String get nasiArabDamsyikTitle;

  /// No description provided for @nasiArabDamsyikDesc.
  ///
  /// In en, this message translates to:
  /// **'Authentic Middle Eastern rice dishes.'**
  String get nasiArabDamsyikDesc;

  /// No description provided for @nasiArabDamsyikFull.
  ///
  /// In en, this message translates to:
  /// **'Nasi Arab Damsyik is known for flavorful Middle Eastern rice served with tender meats.'**
  String get nasiArabDamsyikFull;

  /// No description provided for @restoranDPantaiTitle.
  ///
  /// In en, this message translates to:
  /// **'Restoran D’Pantai'**
  String get restoranDPantaiTitle;

  /// No description provided for @restoranDPantaiDesc.
  ///
  /// In en, this message translates to:
  /// **'Seafood restaurant near the beach.'**
  String get restoranDPantaiDesc;

  /// No description provided for @restoranDPantaiFull.
  ///
  /// In en, this message translates to:
  /// **'Restoran D’Pantai offers fresh seafood with a relaxing seaside atmosphere.'**
  String get restoranDPantaiFull;

  /// No description provided for @nasiLemakSenawangTitle.
  ///
  /// In en, this message translates to:
  /// **'Nasi Lemak Senawang'**
  String get nasiLemakSenawangTitle;

  /// No description provided for @nasiLemakSenawangDesc.
  ///
  /// In en, this message translates to:
  /// **'Famous local nasi lemak spot.'**
  String get nasiLemakSenawangDesc;

  /// No description provided for @nasiLemakSenawangFull.
  ///
  /// In en, this message translates to:
  /// **'Nasi Lemak Senawang is popular for its fragrant rice, sambal, and variety of side dishes.'**
  String get nasiLemakSenawangFull;

  /// No description provided for @n9StickFactoryTitle.
  ///
  /// In en, this message translates to:
  /// **'N9 Stick Factory'**
  String get n9StickFactoryTitle;

  /// No description provided for @n9StickFactoryDesc.
  ///
  /// In en, this message translates to:
  /// **'A restaurant offering steamboat dining.'**
  String get n9StickFactoryDesc;

  /// No description provided for @n9StickFactoryFull.
  ///
  /// In en, this message translates to:
  /// **'N9 Stick Factory serves steamboat meals with a wide selection of fresh ingredients at affordable prices.'**
  String get n9StickFactoryFull;

  /// No description provided for @bayuVillageTitle.
  ///
  /// In en, this message translates to:
  /// **'Bayu Village Restaurant'**
  String get bayuVillageTitle;

  /// No description provided for @bayuVillageDesc.
  ///
  /// In en, this message translates to:
  /// **'Resort-style dining experience.'**
  String get bayuVillageDesc;

  /// No description provided for @bayuVillageFull.
  ///
  /// In en, this message translates to:
  /// **'Bayu Village Restaurant offers a relaxing dining experience with Malaysian and Western dishes.'**
  String get bayuVillageFull;

  /// No description provided for @pdFamousCendolTitle.
  ///
  /// In en, this message translates to:
  /// **'PD Famous Cendol Coconut Shake'**
  String get pdFamousCendolTitle;

  /// No description provided for @pdFamousCendolDesc.
  ///
  /// In en, this message translates to:
  /// **'Cendol with coconut shake specialty.'**
  String get pdFamousCendolDesc;

  /// No description provided for @pdFamousCendolFull.
  ///
  /// In en, this message translates to:
  /// **'PD Famous Cendol Coconut Shake is a must-try dessert combining creamy coconut shake with cendol.'**
  String get pdFamousCendolFull;

  /// No description provided for @beraExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Bera'**
  String get beraExplorationTitle;

  /// No description provided for @guaGelanggiTitle.
  ///
  /// In en, this message translates to:
  /// **'Gua Kota Gelanggi'**
  String get guaGelanggiTitle;

  /// No description provided for @guaGelanggiDesc.
  ///
  /// In en, this message translates to:
  /// **'Ancient limestone cave complex'**
  String get guaGelanggiDesc;

  /// No description provided for @guaGelanggiFull.
  ///
  /// In en, this message translates to:
  /// **'Gua Kota Gelanggi is an ancient limestone cave system believed to be over 100 million years old and rich with legends.'**
  String get guaGelanggiFull;

  /// No description provided for @beraSemelaiTitle.
  ///
  /// In en, this message translates to:
  /// **'Semelai Indigenous Village'**
  String get beraSemelaiTitle;

  /// No description provided for @beraSemelaiDesc.
  ///
  /// In en, this message translates to:
  /// **'Traditional Orang Asli settlement'**
  String get beraSemelaiDesc;

  /// No description provided for @beraSemelaiFull.
  ///
  /// In en, this message translates to:
  /// **'The Semelai people have lived around Tasik Bera for generations.'**
  String get beraSemelaiFull;

  /// No description provided for @beraMasjidTitle.
  ///
  /// In en, this message translates to:
  /// **'Old Kuala Bera Mosque'**
  String get beraMasjidTitle;

  /// No description provided for @beraMasjidDesc.
  ///
  /// In en, this message translates to:
  /// **'Early Islamic landmark in Bera'**
  String get beraMasjidDesc;

  /// No description provided for @beraMasjidFull.
  ///
  /// In en, this message translates to:
  /// **'One of the earliest mosques serving the local Muslim community.'**
  String get beraMasjidFull;

  /// No description provided for @bukitBertanggaTitle.
  ///
  /// In en, this message translates to:
  /// **'Bukit Bertangga'**
  String get bukitBertanggaTitle;

  /// No description provided for @bukitBertanggaDesc.
  ///
  /// In en, this message translates to:
  /// **'Hiking and nature view'**
  String get bukitBertanggaDesc;

  /// No description provided for @bukitBertanggaFull.
  ///
  /// In en, this message translates to:
  /// **'A peaceful hill suitable for eco tourism.'**
  String get bukitBertanggaFull;

  /// No description provided for @bukitSenorangTitle.
  ///
  /// In en, this message translates to:
  /// **'Bukit Senorang'**
  String get bukitSenorangTitle;

  /// No description provided for @bukitSenorangDesc.
  ///
  /// In en, this message translates to:
  /// **'Natural hill area'**
  String get bukitSenorangDesc;

  /// No description provided for @bukitSenorangFull.
  ///
  /// In en, this message translates to:
  /// **'Known for its greenery and calm environment.'**
  String get bukitSenorangFull;

  /// No description provided for @lamanLesungTitle.
  ///
  /// In en, this message translates to:
  /// **'Laman Lesung Kuala Bera'**
  String get lamanLesungTitle;

  /// No description provided for @lamanLesungDesc.
  ///
  /// In en, this message translates to:
  /// **'Traditional recreation area'**
  String get lamanLesungDesc;

  /// No description provided for @lamanLesungFull.
  ///
  /// In en, this message translates to:
  /// **'A traditional site featuring rice pounding activities and folk games.'**
  String get lamanLesungFull;

  /// No description provided for @warungPatinTitle.
  ///
  /// In en, this message translates to:
  /// **'Kedai Patin Tempoyak Mat Singah'**
  String get warungPatinTitle;

  /// No description provided for @warungPatinDesc.
  ///
  /// In en, this message translates to:
  /// **'Famous Patin Tempoyak'**
  String get warungPatinDesc;

  /// No description provided for @warungPatinFull.
  ///
  /// In en, this message translates to:
  /// **'Known for traditional Pahang fish dishes.'**
  String get warungPatinFull;

  /// No description provided for @makanBaratTitle.
  ///
  /// In en, this message translates to:
  /// **'Makan Barat by Kitchen Syaidris'**
  String get makanBaratTitle;

  /// No description provided for @makanBaratDesc.
  ///
  /// In en, this message translates to:
  /// **'Western food restaurant'**
  String get makanBaratDesc;

  /// No description provided for @makanBaratFull.
  ///
  /// In en, this message translates to:
  /// **'Serves a variety of western dishes for visitors.'**
  String get makanBaratFull;

  /// No description provided for @melakaExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Melaka'**
  String get melakaExplorationTitle;

  /// No description provided for @tabHistorical.
  ///
  /// In en, this message translates to:
  /// **'Historical Places'**
  String get tabHistorical;

  /// No description provided for @tabInteresting.
  ///
  /// In en, this message translates to:
  /// **'Interesting Places'**
  String get tabInteresting;

  /// No description provided for @tabEating.
  ///
  /// In en, this message translates to:
  /// **'Food Places'**
  String get tabEating;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @aFamosaDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore the ruins of a 16th-century Portuguese fortress.'**
  String get aFamosaDesc;

  /// No description provided for @aFamosaFull.
  ///
  /// In en, this message translates to:
  /// **'A Famosa is a Portuguese fortress built in 1511. It is one of the oldest surviving European architectural remains in Asia.'**
  String get aFamosaFull;

  /// No description provided for @perigiHangTuahDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover the legendary well of the Malay warrior Hang Tuah.'**
  String get perigiHangTuahDesc;

  /// No description provided for @perigiHangTuahFull.
  ///
  /// In en, this message translates to:
  /// **'Perigi Hang Tuah is believed to be the well used by the Malay warrior Hang Tuah and his companions.'**
  String get perigiHangTuahFull;

  /// No description provided for @istanaKesultananDesc.
  ///
  /// In en, this message translates to:
  /// **'Step inside a palace replica to see Melaka’s royal history.'**
  String get istanaKesultananDesc;

  /// No description provided for @istanaKesultananFull.
  ///
  /// In en, this message translates to:
  /// **'The museum is a replica of the Melaka Sultanate Palace, showcasing the history and culture of Melaka.'**
  String get istanaKesultananFull;

  /// No description provided for @babaNyonyaDesc.
  ///
  /// In en, this message translates to:
  /// **'Experience the vibrant culture of the Peranakan community.'**
  String get babaNyonyaDesc;

  /// No description provided for @babaNyonyaFull.
  ///
  /// In en, this message translates to:
  /// **'Baba & Nyonya Heritage Museum exhibits the rich history, costumes, and artifacts of the Peranakan community in Melaka.'**
  String get babaNyonyaFull;

  /// No description provided for @galeriWarisanDesc.
  ///
  /// In en, this message translates to:
  /// **'See traditional crafts and heritage of Melaka.'**
  String get galeriWarisanDesc;

  /// No description provided for @galeriWarisanFull.
  ///
  /// In en, this message translates to:
  /// **'Galeri Warisan Kota Melaka displays traditional tools, crafts, and cultural exhibits of Melaka.'**
  String get galeriWarisanFull;

  /// No description provided for @chengHoDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn about Admiral Cheng Ho and his epic voyages.'**
  String get chengHoDesc;

  /// No description provided for @chengHoFull.
  ///
  /// In en, this message translates to:
  /// **'Cheng Ho Cultural Museum presents the life of the famous Chinese Admiral and his voyages to Melaka in the 15th century.'**
  String get chengHoFull;

  /// No description provided for @samuderaDesc.
  ///
  /// In en, this message translates to:
  /// **'Dive into Melaka’s maritime trade history.'**
  String get samuderaDesc;

  /// No description provided for @samuderaFull.
  ///
  /// In en, this message translates to:
  /// **'Samudera Museum highlights Melaka\'s rich maritime trade history and colonial influence.'**
  String get samuderaFull;

  /// No description provided for @middelburgDesc.
  ///
  /// In en, this message translates to:
  /// **'Visit the remains of the Portuguese fortifications.'**
  String get middelburgDesc;

  /// No description provided for @middelburgFull.
  ///
  /// In en, this message translates to:
  /// **'Middelburg Bastion is part of the remaining fortifications of the Portuguese fortress, built in the 16th century.'**
  String get middelburgFull;

  /// No description provided for @ethnoDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore artifacts from Melaka’s diverse cultures.'**
  String get ethnoDesc;

  /// No description provided for @ethnoFull.
  ///
  /// In en, this message translates to:
  /// **'The museum explores Melaka\'s ethnographic and historical artifacts, reflecting its diverse cultural heritage.'**
  String get ethnoFull;

  /// No description provided for @zeroKmDesc.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo at Melaka’s historic 0 km marker.'**
  String get zeroKmDesc;

  /// No description provided for @zeroKmFull.
  ///
  /// In en, this message translates to:
  /// **'This monument marks the historic 0 km point of Melaka, a symbolic reference to the city center.'**
  String get zeroKmFull;

  /// No description provided for @stPaulDesc.
  ///
  /// In en, this message translates to:
  /// **'Visit one of Melaka’s oldest colonial-era churches.'**
  String get stPaulDesc;

  /// No description provided for @stPaulFull.
  ///
  /// In en, this message translates to:
  /// **'Church of Saint Paul was built in 1521 and is one of Melaka\'s oldest churches with rich colonial history.'**
  String get stPaulFull;

  /// No description provided for @hangJebatDesc.
  ///
  /// In en, this message translates to:
  /// **'Honor the legendary warrior Hang Jebat.'**
  String get hangJebatDesc;

  /// No description provided for @hangJebatFull.
  ///
  /// In en, this message translates to:
  /// **'Hang Jebat Mausoleum honors the Malay warrior Hang Jebat, renowned in Malay literature and history.'**
  String get hangJebatFull;

  /// No description provided for @zooDesc.
  ///
  /// In en, this message translates to:
  /// **'See animals and enjoy family fun at Zoo Melaka.'**
  String get zooDesc;

  /// No description provided for @zooFull.
  ///
  /// In en, this message translates to:
  /// **'Melaka Zoo houses various animals and provides educational and recreational activities for visitors.'**
  String get zooFull;

  /// No description provided for @riverDesc.
  ///
  /// In en, this message translates to:
  /// **'Relax on a scenic river cruise through Melaka town.'**
  String get riverDesc;

  /// No description provided for @riverFull.
  ///
  /// In en, this message translates to:
  /// **'Enjoy scenic views of Melaka town while cruising along the historic Melaka River.'**
  String get riverFull;

  /// No description provided for @crocDesc.
  ///
  /// In en, this message translates to:
  /// **'Get up close with crocodiles and reptiles.'**
  String get crocDesc;

  /// No description provided for @crocFull.
  ///
  /// In en, this message translates to:
  /// **'Taman Buaya & Rekreasi Melaka features crocodiles, reptiles, and fun recreational activities for the family.'**
  String get crocFull;

  /// No description provided for @magicDesc.
  ///
  /// In en, this message translates to:
  /// **'Take fun photos in a 3D optical illusion museum.'**
  String get magicDesc;

  /// No description provided for @magicFull.
  ///
  /// In en, this message translates to:
  /// **'The museum features 3D paintings that allow visitors to take creative and interactive photos.'**
  String get magicFull;

  /// No description provided for @breakoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Solve puzzles and escape the themed rooms.'**
  String get breakoutDesc;

  /// No description provided for @breakoutFull.
  ///
  /// In en, this message translates to:
  /// **'Breakout Melaka is a fun escape room and spy game experience for children and families.'**
  String get breakoutFull;

  /// No description provided for @waterDesc.
  ///
  /// In en, this message translates to:
  /// **'Splash around in an exciting water theme park.'**
  String get waterDesc;

  /// No description provided for @waterFull.
  ///
  /// In en, this message translates to:
  /// **'FULL'**
  String get waterFull;

  /// No description provided for @mocityDesc.
  ///
  /// In en, this message translates to:
  /// **'Play mini-games and enjoy interactive fun.'**
  String get mocityDesc;

  /// No description provided for @mocityFull.
  ///
  /// In en, this message translates to:
  /// **'MoCity Fun Park offers mini-games, playgrounds, and interactive fun for children.'**
  String get mocityFull;

  /// No description provided for @wonderlandDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy rides, pools, and resort activities.'**
  String get wonderlandDesc;

  /// No description provided for @wonderlandFull.
  ///
  /// In en, this message translates to:
  /// **'A full theme park with rides, pools, and resort facilities for families.'**
  String get wonderlandFull;

  /// No description provided for @wonderparkDesc.
  ///
  /// In en, this message translates to:
  /// **'Have a blast on thrilling rides for all ages.'**
  String get wonderparkDesc;

  /// No description provided for @wonderparkFull.
  ///
  /// In en, this message translates to:
  /// **'Wonderpark is an amusement park with exciting attractions and rides for all ages.'**
  String get wonderparkFull;

  /// No description provided for @ukfunDesc.
  ///
  /// In en, this message translates to:
  /// **'Family-friendly park with rides, games, and entertainment.'**
  String get ukfunDesc;

  /// No description provided for @ukfunFull.
  ///
  /// In en, this message translates to:
  /// **'A family-friendly fun park with rides, games, and entertainment.'**
  String get ukfunFull;

  /// No description provided for @safariDesc.
  ///
  /// In en, this message translates to:
  /// **'Meet exotic animals in a safari-themed park.'**
  String get safariDesc;

  /// No description provided for @safariFull.
  ///
  /// In en, this message translates to:
  /// **'Safari Wonderland is a wildlife-themed park with safari animals and interactive experiences.'**
  String get safariFull;

  /// No description provided for @asahanDesc.
  ///
  /// In en, this message translates to:
  /// **'Slide, swim, and play in the water park.'**
  String get asahanDesc;

  /// No description provided for @asahanFull.
  ///
  /// In en, this message translates to:
  /// **'Asahan Water Theme Park offers water slides and pools for family fun.'**
  String get asahanFull;

  /// No description provided for @bayouDesc.
  ///
  /// In en, this message translates to:
  /// **'Adventure rides and relaxing pools await you.'**
  String get bayouDesc;

  /// No description provided for @bayouFull.
  ///
  /// In en, this message translates to:
  /// **'Bayou Lagoon is a water park with adventure rides and relaxing pools.'**
  String get bayouFull;

  /// No description provided for @babaKayaDesc.
  ///
  /// In en, this message translates to:
  /// **'Taste authentic Peranakan dishes here.'**
  String get babaKayaDesc;

  /// No description provided for @babaKayaFull.
  ///
  /// In en, this message translates to:
  /// **'Restoran Baba Kaya serves traditional Peranakan cuisine and delicacies.'**
  String get babaKayaFull;

  /// No description provided for @asamSeleraDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy spicy and tangy traditional Asam Pedas.'**
  String get asamSeleraDesc;

  /// No description provided for @asamSeleraFull.
  ///
  /// In en, this message translates to:
  /// **'Specializing in Asam Pedas, a spicy and tangy fish dish popular in Melaka.'**
  String get asamSeleraFull;

  /// No description provided for @atlanticDesc.
  ///
  /// In en, this message translates to:
  /// **'Savor modern Nyonya flavors in heritage style.'**
  String get atlanticDesc;

  /// No description provided for @atlanticFull.
  ///
  /// In en, this message translates to:
  /// **'Authentic Nyonya cuisine served in a modern heritage setting.'**
  String get atlanticFull;

  /// No description provided for @cendolDesc.
  ///
  /// In en, this message translates to:
  /// **'Cool off with classic Melaka dessert cendol.'**
  String get cendolDesc;

  /// No description provided for @cendolFull.
  ///
  /// In en, this message translates to:
  /// **'Traditional Melaka dessert with shaved ice, gula Melaka syrup, and coconut milk.'**
  String get cendolFull;

  /// No description provided for @asamOrangDesc.
  ///
  /// In en, this message translates to:
  /// **'Homestyle Asam Pedas in a cozy atmosphere.'**
  String get asamOrangDesc;

  /// No description provided for @asamOrangFull.
  ///
  /// In en, this message translates to:
  /// **'Homestyle Asam Pedas dishes served in a cozy atmosphere.'**
  String get asamOrangFull;

  /// No description provided for @atasDesc.
  ///
  /// In en, this message translates to:
  /// **'Dine riverside with local delicacies.'**
  String get atasDesc;

  /// No description provided for @atasFull.
  ///
  /// In en, this message translates to:
  /// **'Fine dining restaurant overlooking Melaka River, serving local cuisine.'**
  String get atasFull;

  /// No description provided for @rooftopDesc.
  ///
  /// In en, this message translates to:
  /// **'Relax with city views and tasty meals.'**
  String get rooftopDesc;

  /// No description provided for @rooftopFull.
  ///
  /// In en, this message translates to:
  /// **'Relaxing cafe with city views, offering local and Western meals.'**
  String get rooftopFull;

  /// No description provided for @chefWanDesc.
  ///
  /// In en, this message translates to:
  /// **'Peranakan dishes by a celebrity chef.'**
  String get chefWanDesc;

  /// No description provided for @chefWanFull.
  ///
  /// In en, this message translates to:
  /// **'Celebrity chef-themed cafe offering Peranakan and Malaysian dishes.'**
  String get chefWanFull;

  /// No description provided for @calantheDesc.
  ///
  /// In en, this message translates to:
  /// **'Sip coffee and desserts in an artsy cafe.'**
  String get calantheDesc;

  /// No description provided for @calantheFull.
  ///
  /// In en, this message translates to:
  /// **'Popular cafe known for coffee and local desserts in a cozy art-inspired environment.'**
  String get calantheFull;

  /// No description provided for @papayunDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy traditional cuisine by the riverside.'**
  String get papayunDesc;

  /// No description provided for @papayunFull.
  ///
  /// In en, this message translates to:
  /// **'Traditional Melaka cuisine served along the riverbank in a serene setting.'**
  String get papayunFull;

  /// No description provided for @kamparExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Kampar Exploration'**
  String get kamparExplorationTitle;

  /// No description provided for @kintaTinDesc.
  ///
  /// In en, this message translates to:
  /// **'Tin mining history museum in Kampar.'**
  String get kintaTinDesc;

  /// No description provided for @kintaTinFull.
  ///
  /// In en, this message translates to:
  /// **'Kinta Tin Mining Museum showcases the history of tin mining in the Kinta Valley. Visitors can see mining equipment, gravel pump technology, and historical records of the tin industry that built Kampar.'**
  String get kintaTinFull;

  /// No description provided for @chimneyDesc.
  ///
  /// In en, this message translates to:
  /// **'Historic Japanese carbide chimney site.'**
  String get chimneyDesc;

  /// No description provided for @chimneyFull.
  ///
  /// In en, this message translates to:
  /// **'Japanese Carbide Chimney is a remaining industrial structure from early mining operations. It represents Kampar’s industrial heritage during the mining boom period.'**
  String get chimneyFull;

  /// No description provided for @kellieDesc.
  ///
  /// In en, this message translates to:
  /// **'Famous unfinished colonial castle.'**
  String get kellieDesc;

  /// No description provided for @kellieFull.
  ///
  /// In en, this message translates to:
  /// **'Kellie\'s Castle is a historic unfinished mansion built by William Kellie Smith. It is one of Perak’s most famous heritage landmarks with unique architecture and mystery stories.'**
  String get kellieFull;

  /// No description provided for @greenRidgeDesc.
  ///
  /// In en, this message translates to:
  /// **'World War II battle location.'**
  String get greenRidgeDesc;

  /// No description provided for @greenRidgeFull.
  ///
  /// In en, this message translates to:
  /// **'Green Ridge marks the Battle of Kampar site during World War II. It was a strategic defensive line and remains an important military history landmark.'**
  String get greenRidgeFull;

  /// No description provided for @clockDesc.
  ///
  /// In en, this message translates to:
  /// **'Iconic Kampar town clock tower.'**
  String get clockDesc;

  /// No description provided for @clockFull.
  ///
  /// In en, this message translates to:
  /// **'Menara Jam Kampar is a symbolic clock tower in Kampar town center and a popular meeting and photo spot.'**
  String get clockFull;

  /// No description provided for @gravelDesc.
  ///
  /// In en, this message translates to:
  /// **'Gravel pump mining heritage museum.'**
  String get gravelDesc;

  /// No description provided for @gravelFull.
  ///
  /// In en, this message translates to:
  /// **'The Gravel Pump Museum displays traditional gravel pump tin mining methods used widely in the Kinta Valley.'**
  String get gravelFull;

  /// No description provided for @westLakeDesc.
  ///
  /// In en, this message translates to:
  /// **'Scenic lake recreation area.'**
  String get westLakeDesc;

  /// No description provided for @westLakeFull.
  ///
  /// In en, this message translates to:
  /// **'West Lake Kampar is a popular recreational lake with jogging paths, sunset views, and relaxing scenery.'**
  String get westLakeFull;

  /// No description provided for @ilhamDesc.
  ///
  /// In en, this message translates to:
  /// **'Street mural art attraction.'**
  String get ilhamDesc;

  /// No description provided for @ilhamFull.
  ///
  /// In en, this message translates to:
  /// **'Ilham Seni Kampar features colorful murals and street art celebrating local culture and history.'**
  String get ilhamFull;

  /// No description provided for @pipelineDesc.
  ///
  /// In en, this message translates to:
  /// **'Historic pipeline bridge in Gopeng.'**
  String get pipelineDesc;

  /// No description provided for @pipelineFull.
  ///
  /// In en, this message translates to:
  /// **'Gopeng Pipeline Bridge is a historic pipeline structure and unique photography spot near Kampar.'**
  String get pipelineFull;

  /// No description provided for @tempurungDesc.
  ///
  /// In en, this message translates to:
  /// **'One of Malaysia’s longest caves.'**
  String get tempurungDesc;

  /// No description provided for @tempurungFull.
  ///
  /// In en, this message translates to:
  /// **'Gua Tempurung is one of the longest limestone caves in Peninsular Malaysia with guided adventure tours.'**
  String get tempurungFull;

  /// No description provided for @heritageDesc.
  ///
  /// In en, this message translates to:
  /// **'Traditional heritage house.'**
  String get heritageDesc;

  /// No description provided for @heritageFull.
  ///
  /// In en, this message translates to:
  /// **'Gopeng Heritage House preserves classic Perak architecture and antiques from early settlements.'**
  String get heritageFull;

  /// No description provided for @saluDesc.
  ///
  /// In en, this message translates to:
  /// **'Rainforest eco area.'**
  String get saluDesc;

  /// No description provided for @saluFull.
  ///
  /// In en, this message translates to:
  /// **'Sungai Salu Rainforest offers jungle trekking, rivers, and eco tourism experiences.'**
  String get saluFull;

  /// No description provided for @kanduDesc.
  ///
  /// In en, this message translates to:
  /// **'Adventure limestone cave.'**
  String get kanduDesc;

  /// No description provided for @kanduFull.
  ///
  /// In en, this message translates to:
  /// **'Gua Kandu is a limestone cave area popular for caving, camping, and jungle exploration.'**
  String get kanduFull;

  /// No description provided for @agaciaDesc.
  ///
  /// In en, this message translates to:
  /// **'Colorful European-style township.'**
  String get agaciaDesc;

  /// No description provided for @agaciaFull.
  ///
  /// In en, this message translates to:
  /// **'Agacia Land is known for colorful European-style buildings and photo spots, sometimes called Disney Avenue by visitors.'**
  String get agaciaFull;

  /// No description provided for @gaharuDesc.
  ///
  /// In en, this message translates to:
  /// **'Gaharu tea plantation.'**
  String get gaharuDesc;

  /// No description provided for @gaharuFull.
  ///
  /// In en, this message translates to:
  /// **'Gaharu Tea Valley is an agro tourism plantation producing gaharu tea with scenic hill views.'**
  String get gaharuFull;

  /// No description provided for @refarmDesc.
  ///
  /// In en, this message translates to:
  /// **'Family farm recreation park.'**
  String get refarmDesc;

  /// No description provided for @refarmFull.
  ///
  /// In en, this message translates to:
  /// **'Refarm Kampar offers farm animals, cycling, lakes, and family recreation activities.'**
  String get refarmFull;

  /// No description provided for @sahomDesc.
  ///
  /// In en, this message translates to:
  /// **'Eco agro resort village.'**
  String get sahomDesc;

  /// No description provided for @sahomFull.
  ///
  /// In en, this message translates to:
  /// **'Sahom Valley Resort is an eco village resort with river, kampung scenery, and outdoor activities.'**
  String get sahomFull;

  /// No description provided for @zaharaDesc.
  ///
  /// In en, this message translates to:
  /// **'Private garden attraction.'**
  String get zaharaDesc;

  /// No description provided for @zaharaFull.
  ///
  /// In en, this message translates to:
  /// **'Zahara Garden is a landscaped garden area used for leisure visits and photography.'**
  String get zaharaFull;

  /// No description provided for @buncitDesc.
  ///
  /// In en, this message translates to:
  /// **'Cafe serving salai dishes & western.'**
  String get buncitDesc;

  /// No description provided for @buncitFull.
  ///
  /// In en, this message translates to:
  /// **'Buncit Cafe is known for Gulai Lemak Daging Salai and western food options.'**
  String get buncitFull;

  /// No description provided for @lacottageDesc.
  ///
  /// In en, this message translates to:
  /// **'Cafe dining inside river.'**
  String get lacottageDesc;

  /// No description provided for @lacottageFull.
  ///
  /// In en, this message translates to:
  /// **'La’cottage Cafe offers viral river dining experience with chalet facilities.'**
  String get lacottageFull;

  /// No description provided for @kelapaDesc.
  ///
  /// In en, this message translates to:
  /// **'Coconut dessert shop.'**
  String get kelapaDesc;

  /// No description provided for @kelapaFull.
  ///
  /// In en, this message translates to:
  /// **'Kelapa Lelehhh serves coconut shakes and refreshing desserts.'**
  String get kelapaFull;

  /// No description provided for @nasi786Desc.
  ///
  /// In en, this message translates to:
  /// **'Popular nasi kandar.'**
  String get nasi786Desc;

  /// No description provided for @nasi786Full.
  ///
  /// In en, this message translates to:
  /// **'Nasi Kandar Beratur 786 is known for rich curries and long queues.'**
  String get nasi786Full;

  /// No description provided for @adilyDesc.
  ///
  /// In en, this message translates to:
  /// **'Local Malaysian restaurant.'**
  String get adilyDesc;

  /// No description provided for @adilyFull.
  ///
  /// In en, this message translates to:
  /// **'Restoran Adily serves local Malay dishes and daily meals.'**
  String get adilyFull;

  /// No description provided for @cousinDesc.
  ///
  /// In en, this message translates to:
  /// **'Modern cafe dining.'**
  String get cousinDesc;

  /// No description provided for @cousinFull.
  ///
  /// In en, this message translates to:
  /// **'Cousin\'ss Cafe offers trendy cafe menu and drinks.'**
  String get cousinFull;

  /// No description provided for @ahboyDesc.
  ///
  /// In en, this message translates to:
  /// **'Western diner style cafe.'**
  String get ahboyDesc;

  /// No description provided for @ahboyFull.
  ///
  /// In en, this message translates to:
  /// **'Ah Boy Diner serves western comfort food.'**
  String get ahboyFull;

  /// No description provided for @iqaDesc.
  ///
  /// In en, this message translates to:
  /// **'Nasi wanggey specialist.'**
  String get iqaDesc;

  /// No description provided for @iqaFull.
  ///
  /// In en, this message translates to:
  /// **'Iqa Corner is popular for nasi wanggey style dishes.'**
  String get iqaFull;

  /// No description provided for @jayneDesc.
  ///
  /// In en, this message translates to:
  /// **'Fried chicken nasi lemak.'**
  String get jayneDesc;

  /// No description provided for @jayneFull.
  ///
  /// In en, this message translates to:
  /// **'Jayne Kitchen specializes in golden fried chicken nasi lemak.'**
  String get jayneFull;

  /// No description provided for @peladangDesc.
  ///
  /// In en, this message translates to:
  /// **'Classic chicken rice.'**
  String get peladangDesc;

  /// No description provided for @peladangFull.
  ///
  /// In en, this message translates to:
  /// **'Nasi Ayam Peladang serves traditional chicken rice.'**
  String get peladangFull;

  /// No description provided for @rompinExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Rompin,Pahang Exploration'**
  String get rompinExplorationTitle;

  /// No description provided for @rompin0kmDesc.
  ///
  /// In en, this message translates to:
  /// **'The official starting point of Kuala Rompin town.'**
  String get rompin0kmDesc;

  /// No description provided for @rompin0kmFull.
  ///
  /// In en, this message translates to:
  /// **'0 KM Kuala Rompin marks the symbolic center of the town. It is often visited by tourists for photography and as a landmark representing the beginning of Rompin’s journey.'**
  String get rompin0kmFull;

  /// No description provided for @seriMahkotaDesc.
  ///
  /// In en, this message translates to:
  /// **'A beautiful waterfall surrounded by nature.'**
  String get seriMahkotaDesc;

  /// No description provided for @seriMahkotaFull.
  ///
  /// In en, this message translates to:
  /// **'Seri Mahkota Waterfall is a peaceful nature destination perfect for picnics, photography, and relaxation. The sound of flowing water creates a calming atmosphere for visitors.'**
  String get seriMahkotaFull;

  /// No description provided for @rompinTrailDesc.
  ///
  /// In en, this message translates to:
  /// **'A jungle trekking trail for adventure lovers.'**
  String get rompinTrailDesc;

  /// No description provided for @rompinTrailFull.
  ///
  /// In en, this message translates to:
  /// **'Rompin Trail offers exciting jungle trekking experiences with rich biodiversity. Visitors can explore rainforest scenery and enjoy outdoor adventure activities.'**
  String get rompinTrailFull;

  /// No description provided for @pantaiHiburanDesc.
  ///
  /// In en, this message translates to:
  /// **'A relaxing beach for family recreation.'**
  String get pantaiHiburanDesc;

  /// No description provided for @pantaiHiburanFull.
  ///
  /// In en, this message translates to:
  /// **'Pantai Hiburan is a popular beach in Rompin where families gather for picnics, fishing, and enjoying the sea breeze during evenings.'**
  String get pantaiHiburanFull;

  /// No description provided for @beachResortDesc.
  ///
  /// In en, this message translates to:
  /// **'A comfortable beachside accommodation.'**
  String get beachResortDesc;

  /// No description provided for @beachResortFull.
  ///
  /// In en, this message translates to:
  /// **'Rompin Beach Resort provides comfortable lodging with beautiful sea views, suitable for family vacations and peaceful getaways.'**
  String get beachResortFull;

  /// No description provided for @tamanNegeriDesc.
  ///
  /// In en, this message translates to:
  /// **'A protected rainforest reserve.'**
  String get tamanNegeriDesc;

  /// No description provided for @tamanNegeriFull.
  ///
  /// In en, this message translates to:
  /// **'Taman Negeri Rompin Pahang is one of Malaysia’s natural treasures, offering untouched rainforest ecosystems, wildlife, and eco-tourism experiences.'**
  String get tamanNegeriFull;

  /// No description provided for @rainforestLodgeDesc.
  ///
  /// In en, this message translates to:
  /// **'Nature stay in rainforest surroundings.'**
  String get rainforestLodgeDesc;

  /// No description provided for @rainforestLodgeFull.
  ///
  /// In en, this message translates to:
  /// **'Rompin Rainforest Lodge allows visitors to experience staying close to nature with guided tours and eco-activities.'**
  String get rainforestLodgeFull;

  /// No description provided for @cemaraDesc.
  ///
  /// In en, this message translates to:
  /// **'A riverside chalet experience.'**
  String get cemaraDesc;

  /// No description provided for @cemaraFull.
  ///
  /// In en, this message translates to:
  /// **'Cemara Riverview Chalet offers cozy accommodation beside the river, providing a relaxing and peaceful atmosphere.'**
  String get cemaraFull;

  /// No description provided for @jetiBernasDesc.
  ///
  /// In en, this message translates to:
  /// **'Public jetty for fishing and boat rides.'**
  String get jetiBernasDesc;

  /// No description provided for @jetiBernasFull.
  ///
  /// In en, this message translates to:
  /// **'Jeti Awam Pantai Bernas is commonly used for fishing activities and boat departures, especially for sea adventures.'**
  String get jetiBernasFull;

  /// No description provided for @food1Desc.
  ///
  /// In en, this message translates to:
  /// **'Popular satay spot.'**
  String get food1Desc;

  /// No description provided for @food1Full.
  ///
  /// In en, this message translates to:
  /// **'Sate Temeen Jerantut is famous for its tender grilled satay served with rich peanut sauce.'**
  String get food1Full;

  /// No description provided for @food2Desc.
  ///
  /// In en, this message translates to:
  /// **'Cozy garden cafe.'**
  String get food2Desc;

  /// No description provided for @food2Full.
  ///
  /// In en, this message translates to:
  /// **'Gypsy Garden Jerantut Cafe provides a relaxing garden ambiance with delicious drinks and meals.'**
  String get food2Full;

  /// No description provided for @food3Desc.
  ///
  /// In en, this message translates to:
  /// **'Traditional Malay eatery.'**
  String get food3Desc;

  /// No description provided for @food3Full.
  ///
  /// In en, this message translates to:
  /// **'Warong Gantong serves authentic Malay dishes loved by locals.'**
  String get food3Full;

  /// No description provided for @food4Desc.
  ///
  /// In en, this message translates to:
  /// **'Famous murtabak restaurant.'**
  String get food4Desc;

  /// No description provided for @food4Full.
  ///
  /// In en, this message translates to:
  /// **'Murtabak Jerantut Ferry Restaurant is known for its flavorful and crispy murtabak.'**
  String get food4Full;

  /// No description provided for @food5Desc.
  ///
  /// In en, this message translates to:
  /// **'Local dining spot.'**
  String get food5Desc;

  /// No description provided for @food5Full.
  ///
  /// In en, this message translates to:
  /// **'Kedai Makan Makan Di Jerantut offers affordable and tasty local dishes.'**
  String get food5Full;

  /// No description provided for @food6Desc.
  ///
  /// In en, this message translates to:
  /// **'Trendy coffee place.'**
  String get food6Desc;

  /// No description provided for @food6Full.
  ///
  /// In en, this message translates to:
  /// **'Kopi Chantek is a favorite coffee stop among youth and tourists.'**
  String get food6Full;

  /// No description provided for @food7Desc.
  ///
  /// In en, this message translates to:
  /// **'Modern cafe.'**
  String get food7Desc;

  /// No description provided for @food7Full.
  ///
  /// In en, this message translates to:
  /// **'Bojiocafe Jerantut Pahang offers stylish interiors and quality beverages.'**
  String get food7Full;

  /// No description provided for @food8Desc.
  ///
  /// In en, this message translates to:
  /// **'Classic kopitiam.'**
  String get food8Desc;

  /// No description provided for @food8Full.
  ///
  /// In en, this message translates to:
  /// **'Kedai Kopi Puteh serves traditional Malaysian breakfast and coffee.'**
  String get food8Full;

  /// No description provided for @food9Desc.
  ///
  /// In en, this message translates to:
  /// **'Crispy fried seafood snacks.'**
  String get food9Desc;

  /// No description provided for @food9Full.
  ///
  /// In en, this message translates to:
  /// **'Ikan Celup Tepung Qaseh Armani is famous for crispy fried seafood coated in light batter.'**
  String get food9Full;

  /// No description provided for @food10Desc.
  ///
  /// In en, this message translates to:
  /// **'Evening street food corner.'**
  String get food10Desc;

  /// No description provided for @food10Full.
  ///
  /// In en, this message translates to:
  /// **'Warung Celup Tepung Embun Corner is popular for fried seafood and evening snacks.'**
  String get food10Full;

  /// No description provided for @food11Desc.
  ///
  /// In en, this message translates to:
  /// **'Homestyle cooking.'**
  String get food11Desc;

  /// No description provided for @food11Full.
  ///
  /// In en, this message translates to:
  /// **'Gerai Makan Hajjah Rosminah offers home-style Malaysian dishes in a friendly atmosphere.'**
  String get food11Full;

  /// No description provided for @food12Desc.
  ///
  /// In en, this message translates to:
  /// **'Village-style food stall.'**
  String get food12Desc;

  /// No description provided for @food12Full.
  ///
  /// In en, this message translates to:
  /// **'Kedai Makan Pokok Manggis serves traditional kampung-style dishes.'**
  String get food12Full;

  /// No description provided for @food13Desc.
  ///
  /// In en, this message translates to:
  /// **'Freshwater prawn specialty.'**
  String get food13Desc;

  /// No description provided for @food13Full.
  ///
  /// In en, this message translates to:
  /// **'Mak Ngah Udang Galah Cawangan 2 continues serving its signature freshwater prawns.'**
  String get food13Full;

  /// No description provided for @food14Desc.
  ///
  /// In en, this message translates to:
  /// **'Modern café experience.'**
  String get food14Desc;

  /// No description provided for @food14Full.
  ///
  /// In en, this message translates to:
  /// **'DYA ZARA CAFE Rompin offers a modern café environment with Western and local dishes.'**
  String get food14Full;

  /// No description provided for @food15Desc.
  ///
  /// In en, this message translates to:
  /// **'Family dining spot.'**
  String get food15Desc;

  /// No description provided for @food15Full.
  ///
  /// In en, this message translates to:
  /// **'Meisha Corner provides comfortable family dining with affordable meals.'**
  String get food15Full;

  /// No description provided for @food16Desc.
  ///
  /// In en, this message translates to:
  /// **'Trendy street kitchen.'**
  String get food16Desc;

  /// No description provided for @food16Full.
  ///
  /// In en, this message translates to:
  /// **'MS Street Kitchen offers trendy street food loved by young visitors.'**
  String get food16Full;

  /// No description provided for @food17Desc.
  ///
  /// In en, this message translates to:
  /// **'Simple village warung.'**
  String get food17Desc;

  /// No description provided for @food17Full.
  ///
  /// In en, this message translates to:
  /// **'Warung Mokla serves simple yet satisfying traditional meals.'**
  String get food17Full;

  /// No description provided for @food18Desc.
  ///
  /// In en, this message translates to:
  /// **'Seafood specialist.'**
  String get food18Desc;

  /// No description provided for @food18Full.
  ///
  /// In en, this message translates to:
  /// **'One\'s Seafood is popular for its wide range of fresh seafood dishes.'**
  String get food18Full;

  /// No description provided for @food19Desc.
  ///
  /// In en, this message translates to:
  /// **'Food court with variety.'**
  String get food19Desc;

  /// No description provided for @food19Full.
  ///
  /// In en, this message translates to:
  /// **'Medan Selera Rompin offers multiple stalls serving diverse local cuisine.'**
  String get food19Full;

  /// No description provided for @food20Desc.
  ///
  /// In en, this message translates to:
  /// **'Sweet dessert treats.'**
  String get food20Desc;

  /// No description provided for @food20Full.
  ///
  /// In en, this message translates to:
  /// **'MR CHURROS is known for its delicious churros and sweet snacks.'**
  String get food20Full;

  /// No description provided for @jerantutExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Jerantut Exploration'**
  String get jerantutExplorationTitle;

  /// No description provided for @matKilauDesc.
  ///
  /// In en, this message translates to:
  /// **'Historical gallery dedicated to Mat Kilau.'**
  String get matKilauDesc;

  /// No description provided for @matKilauFull.
  ///
  /// In en, this message translates to:
  /// **'Kompleks Galeri Mat Kilau Pulau Tawar showcases the history of Mat Kilau, a Malay warrior who fought against British colonial forces in Pahang.'**
  String get matKilauFull;

  /// No description provided for @lamanMatKilauDesc.
  ///
  /// In en, this message translates to:
  /// **'Public square honoring Mat Kilau.'**
  String get lamanMatKilauDesc;

  /// No description provided for @lamanMatKilauFull.
  ///
  /// In en, this message translates to:
  /// **'Laman Mat Kilau is a cultural landmark and gathering space that celebrates the bravery and legacy of Mat Kilau.'**
  String get lamanMatKilauFull;

  /// No description provided for @kualaTembelingDesc.
  ///
  /// In en, this message translates to:
  /// **'Old railway stop site.'**
  String get kualaTembelingDesc;

  /// No description provided for @kualaTembelingFull.
  ///
  /// In en, this message translates to:
  /// **'The former Kuala Tembeling railway stop reflects early transportation history in Jerantut.'**
  String get kualaTembelingFull;

  /// No description provided for @lataMeraungDesc.
  ///
  /// In en, this message translates to:
  /// **'Beautiful natural waterfall.'**
  String get lataMeraungDesc;

  /// No description provided for @lataMeraungFull.
  ///
  /// In en, this message translates to:
  /// **'Lata Meraung is a serene waterfall surrounded by lush rainforest, perfect for picnics and relaxation.'**
  String get lataMeraungFull;

  /// No description provided for @icityDesc.
  ///
  /// In en, this message translates to:
  /// **'Family recreational park.'**
  String get icityDesc;

  /// No description provided for @icityFull.
  ///
  /// In en, this message translates to:
  /// **'Taman I-City Jerantut offers fun attractions and colorful light displays for families.'**
  String get icityFull;

  /// No description provided for @gelanggiDesc.
  ///
  /// In en, this message translates to:
  /// **'Famous limestone cave.'**
  String get gelanggiDesc;

  /// No description provided for @gelanggiFull.
  ///
  /// In en, this message translates to:
  /// **'Gua Kota Gelanggi is a historic limestone cave with fascinating rock formations and legends.'**
  String get gelanggiFull;

  /// No description provided for @dpumaDesc.
  ///
  /// In en, this message translates to:
  /// **'Unique themed house attraction.'**
  String get dpumaDesc;

  /// No description provided for @dpumaFull.
  ///
  /// In en, this message translates to:
  /// **'D’PUMA HOUSE is a creative tourism spot popular for photography and social visits.'**
  String get dpumaFull;

  /// No description provided for @rakitDesc.
  ///
  /// In en, this message translates to:
  /// **'Floating house experience.'**
  String get rakitDesc;

  /// No description provided for @rakitFull.
  ///
  /// In en, this message translates to:
  /// **'Rumah Rakit D\'jongkei Kelola offers a peaceful floating accommodation experience by the river.'**
  String get rakitFull;

  /// No description provided for @bukitMerahDesc.
  ///
  /// In en, this message translates to:
  /// **'Red-colored forest hill.'**
  String get bukitMerahDesc;

  /// No description provided for @bukitMerahFull.
  ///
  /// In en, this message translates to:
  /// **'Bukit Merah is known for its unique red soil landscape and scenic hiking trails.'**
  String get bukitMerahFull;

  /// No description provided for @viaFerrataDesc.
  ///
  /// In en, this message translates to:
  /// **'Adventure climbing activity.'**
  String get viaFerrataDesc;

  /// No description provided for @viaFerrataFull.
  ///
  /// In en, this message translates to:
  /// **'Via Ferrata Paya Gunung offers a thrilling climbing route with safety cables and panoramic views.'**
  String get viaFerrataFull;

  /// No description provided for @tapahExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Tapah, Perak Exploration'**
  String get tapahExplorationTitle;

  /// No description provided for @tabBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business Places'**
  String get tabBusiness;

  /// No description provided for @memoryLaneDesc.
  ///
  /// In en, this message translates to:
  /// **'Famous Sunday flea market in Ipoh.'**
  String get memoryLaneDesc;

  /// No description provided for @memoryLaneFull.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane is a popular flea market operating every Sunday morning offering antiques, collectibles and vintage goods.'**
  String get memoryLaneFull;

  /// No description provided for @concubineLaneDesc.
  ///
  /// In en, this message translates to:
  /// **'Historic lane with cafes and souvenirs.'**
  String get concubineLaneDesc;

  /// No description provided for @concubineLaneFull.
  ///
  /// In en, this message translates to:
  /// **'Concubine Lane is a vibrant heritage street filled with cafes, snacks and souvenir shops.'**
  String get concubineLaneFull;

  /// No description provided for @lorongSeniDesc.
  ///
  /// In en, this message translates to:
  /// **'Art street with murals.'**
  String get lorongSeniDesc;

  /// No description provided for @lorongSeniFull.
  ///
  /// In en, this message translates to:
  /// **'Lorong Seni features beautiful murals and art installations perfect for photography.'**
  String get lorongSeniFull;

  /// No description provided for @gerbangMalamDesc.
  ///
  /// In en, this message translates to:
  /// **'Night market in Ipoh town.'**
  String get gerbangMalamDesc;

  /// No description provided for @gerbangMalamFull.
  ///
  /// In en, this message translates to:
  /// **'Gerbang Malam is a lively night market selling clothes, food and accessories.'**
  String get gerbangMalamFull;

  /// No description provided for @pettingZooDesc.
  ///
  /// In en, this message translates to:
  /// **'Family friendly animal park.'**
  String get pettingZooDesc;

  /// No description provided for @pettingZooFull.
  ///
  /// In en, this message translates to:
  /// **'Petting Zoo at Gunung Lang offers interactive experiences with animals for children and families.'**
  String get pettingZooFull;

  /// No description provided for @lightSoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Night light show attraction.'**
  String get lightSoundDesc;

  /// No description provided for @lightSoundFull.
  ///
  /// In en, this message translates to:
  /// **'Light & Sound at Ipoh Padang is a colorful evening attraction with music and lighting effects.'**
  String get lightSoundFull;

  /// No description provided for @ipohPadangDesc.
  ///
  /// In en, this message translates to:
  /// **'Historic field in Ipoh.'**
  String get ipohPadangDesc;

  /// No description provided for @ipohPadangFull.
  ///
  /// In en, this message translates to:
  /// **'Ipoh Padang is a historical open field surrounded by colonial buildings.'**
  String get ipohPadangFull;

  /// No description provided for @sultanAzizDesc.
  ///
  /// In en, this message translates to:
  /// **'Popular recreational park.'**
  String get sultanAzizDesc;

  /// No description provided for @sultanAzizFull.
  ///
  /// In en, this message translates to:
  /// **'Taman Rekreasi Sultan Abdul Aziz is ideal for jogging and outdoor activities.'**
  String get sultanAzizFull;

  /// No description provided for @gunungLangDesc.
  ///
  /// In en, this message translates to:
  /// **'A scenic recreational park with a lake, limestone hills and landscaped gardens.'**
  String get gunungLangDesc;

  /// No description provided for @gunungLangFull.
  ///
  /// In en, this message translates to:
  /// **'Gunung Lang Recreational Park is known for its lake, limestone scenery, gardens and relaxing environment. Visitors can enjoy views, photography and family recreation in a natural setting.'**
  String get gunungLangFull;

  /// No description provided for @tamanJepunDesc.
  ///
  /// In en, this message translates to:
  /// **'Japanese garden park.'**
  String get tamanJepunDesc;

  /// No description provided for @tamanJepunFull.
  ///
  /// In en, this message translates to:
  /// **'Taman Jepun is a peaceful garden inspired by Japanese landscaping.'**
  String get tamanJepunFull;

  /// No description provided for @drSeenivasagamDesc.
  ///
  /// In en, this message translates to:
  /// **'City recreational park.'**
  String get drSeenivasagamDesc;

  /// No description provided for @drSeenivasagamFull.
  ///
  /// In en, this message translates to:
  /// **'A popular urban park for leisure and family activities.'**
  String get drSeenivasagamFull;

  /// No description provided for @guaTambunDesc.
  ///
  /// In en, this message translates to:
  /// **'Ancient cave paintings site.'**
  String get guaTambunDesc;

  /// No description provided for @guaTambunFull.
  ///
  /// In en, this message translates to:
  /// **'Gua Tambun is known for prehistoric cave paintings.'**
  String get guaTambunFull;

  /// No description provided for @qinXingLingDesc.
  ///
  /// In en, this message translates to:
  /// **'Large cave temple.'**
  String get qinXingLingDesc;

  /// No description provided for @qinXingLingFull.
  ///
  /// In en, this message translates to:
  /// **'Qin Xing Ling is a famous limestone cave temple in Ipoh.'**
  String get qinXingLingFull;

  /// No description provided for @guaMasooratDesc.
  ///
  /// In en, this message translates to:
  /// **'Natural limestone cave.'**
  String get guaMasooratDesc;

  /// No description provided for @guaMasooratFull.
  ///
  /// In en, this message translates to:
  /// **'Gua Masoorat is a scenic limestone cave attraction.'**
  String get guaMasooratFull;

  /// No description provided for @tasekCerminDesc.
  ///
  /// In en, this message translates to:
  /// **'Hidden mirror lake.'**
  String get tasekCerminDesc;

  /// No description provided for @tasekCerminFull.
  ///
  /// In en, this message translates to:
  /// **'Tasek Cermin is a hidden lake surrounded by limestone hills.'**
  String get tasekCerminFull;

  /// No description provided for @medanSagorDesc.
  ///
  /// In en, this message translates to:
  /// **'Local food court.'**
  String get medanSagorDesc;

  /// No description provided for @medanSagorFull.
  ///
  /// In en, this message translates to:
  /// **'Medan Selera Dato Sagor offers various local Malaysian dishes.'**
  String get medanSagorFull;

  /// No description provided for @rojakDesc.
  ///
  /// In en, this message translates to:
  /// **'Famous rojak and cendol stall.'**
  String get rojakDesc;

  /// No description provided for @rojakFull.
  ///
  /// In en, this message translates to:
  /// **'Popular spot for refreshing cendol and delicious rojak.'**
  String get rojakFull;

  /// No description provided for @planBDesc.
  ///
  /// In en, this message translates to:
  /// **'Modern cafe in Ipoh.'**
  String get planBDesc;

  /// No description provided for @planBFull.
  ///
  /// In en, this message translates to:
  /// **'Plan B serves Western and fusion cuisine in a stylish setting.'**
  String get planBFull;

  /// No description provided for @stgDesc.
  ///
  /// In en, this message translates to:
  /// **'Coffee specialist cafe.'**
  String get stgDesc;

  /// No description provided for @stgFull.
  ///
  /// In en, this message translates to:
  /// **'STG Ipoh Old Town is known for quality coffee and desserts.'**
  String get stgFull;

  /// No description provided for @durbarDesc.
  ///
  /// In en, this message translates to:
  /// **'Historic Indian restaurant.'**
  String get durbarDesc;

  /// No description provided for @durbarFull.
  ///
  /// In en, this message translates to:
  /// **'Durbar at FMS is one of the oldest Indian restaurants in Ipoh.'**
  String get durbarFull;

  /// No description provided for @mikerDesc.
  ///
  /// In en, this message translates to:
  /// **'Popular pizza restaurant.'**
  String get mikerDesc;

  /// No description provided for @mikerFull.
  ///
  /// In en, this message translates to:
  /// **'Miker Pizza serves local-flavored and classic pizzas.'**
  String get mikerFull;

  /// No description provided for @thumbsDesc.
  ///
  /// In en, this message translates to:
  /// **'Cozy cafe in Ipoh.'**
  String get thumbsDesc;

  /// No description provided for @thumbsFull.
  ///
  /// In en, this message translates to:
  /// **'Thumb\'s Cafe offers pastries and specialty drinks.'**
  String get thumbsFull;

  /// No description provided for @tandoorDesc.
  ///
  /// In en, this message translates to:
  /// **'Authentic North Indian cuisine.'**
  String get tandoorDesc;

  /// No description provided for @tandoorFull.
  ///
  /// In en, this message translates to:
  /// **'Tandoor Grill serves authentic North Indian dishes.'**
  String get tandoorFull;

  /// No description provided for @centralKitchenDesc.
  ///
  /// In en, this message translates to:
  /// **'Local Malaysian cuisine hub.'**
  String get centralKitchenDesc;

  /// No description provided for @centralKitchenFull.
  ///
  /// In en, this message translates to:
  /// **'Ipoh Central Kitchen offers traditional and modern Malaysian dishes.'**
  String get centralKitchenFull;

  /// No description provided for @greentownDesc.
  ///
  /// In en, this message translates to:
  /// **'Famous dim sum restaurant.'**
  String get greentownDesc;

  /// No description provided for @greentownFull.
  ///
  /// In en, this message translates to:
  /// **'Greentown Dimsum Cafe is popular for its variety of dim sum.'**
  String get greentownFull;

  /// No description provided for @cameronExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Cameron Highlands'**
  String get cameronExplorationTitle;

  /// No description provided for @keaFarmMarketDesc.
  ///
  /// In en, this message translates to:
  /// **'Morning market selling vegetables and local produce.'**
  String get keaFarmMarketDesc;

  /// No description provided for @keaFarmMarketFull.
  ///
  /// In en, this message translates to:
  /// **'Kea Farm Morning Market is a popular market selling fresh vegetables, fruits, and souvenirs from Cameron Highlands.'**
  String get keaFarmMarketFull;

  /// No description provided for @farmersArcadeDesc.
  ///
  /// In en, this message translates to:
  /// **'Shopping arcade for local products.'**
  String get farmersArcadeDesc;

  /// No description provided for @farmersArcadeFull.
  ///
  /// In en, this message translates to:
  /// **'Farmers Arcade offers a variety of fresh vegetables, fruits, flowers, and agricultural products from local farmers.'**
  String get farmersArcadeFull;

  /// No description provided for @bazarKeaFarmDesc.
  ///
  /// In en, this message translates to:
  /// **'Local bazaar with fruits and souvenirs.'**
  String get bazarKeaFarmDesc;

  /// No description provided for @bazarKeaFarmFull.
  ///
  /// In en, this message translates to:
  /// **'Kea Farm Bazaar is a busy tourist market offering strawberries, vegetables, snacks, and souvenirs.'**
  String get bazarKeaFarmFull;

  /// No description provided for @agroMarketDesc.
  ///
  /// In en, this message translates to:
  /// **'Agricultural market selling local farm products.'**
  String get agroMarketDesc;

  /// No description provided for @agroMarketFull.
  ///
  /// In en, this message translates to:
  /// **'Agro Market provides fresh produce from Cameron Highlands farms including vegetables and flowers.'**
  String get agroMarketFull;

  /// No description provided for @sCornerDesc.
  ///
  /// In en, this message translates to:
  /// **'Central market area for shopping.'**
  String get sCornerDesc;

  /// No description provided for @sCornerFull.
  ///
  /// In en, this message translates to:
  /// **'S\'Corner Central Market offers a variety of local products and souvenirs for visitors.'**
  String get sCornerFull;

  /// No description provided for @pasarRayaDesc.
  ///
  /// In en, this message translates to:
  /// **'Supermarket selling daily necessities.'**
  String get pasarRayaDesc;

  /// No description provided for @pasarRayaFull.
  ///
  /// In en, this message translates to:
  /// **'Pasar Raya Cameron Highland provides groceries, food items, and daily essentials.'**
  String get pasarRayaFull;

  /// No description provided for @keaVegetableDesc.
  ///
  /// In en, this message translates to:
  /// **'Vegetable farm selling fresh produce.'**
  String get keaVegetableDesc;

  /// No description provided for @keaVegetableFull.
  ///
  /// In en, this message translates to:
  /// **'Kea Farm Vegetable Farm sells fresh vegetables grown in the cool climate of Cameron Highlands.'**
  String get keaVegetableFull;

  /// No description provided for @kokLamDesc.
  ///
  /// In en, this message translates to:
  /// **'Vegetable farm and agriculture business.'**
  String get kokLamDesc;

  /// No description provided for @kokLamFull.
  ///
  /// In en, this message translates to:
  /// **'Kok Lam Farm is known for growing high quality vegetables in Cameron Highlands.'**
  String get kokLamFull;

  /// No description provided for @cameronSquareDesc.
  ///
  /// In en, this message translates to:
  /// **'Shopping complex in Cameron Highlands.'**
  String get cameronSquareDesc;

  /// No description provided for @cameronSquareFull.
  ///
  /// In en, this message translates to:
  /// **'Cameron Square is a shopping mall offering restaurants, cafes, and retail stores.'**
  String get cameronSquareFull;

  /// No description provided for @arkedPeladangDesc.
  ///
  /// In en, this message translates to:
  /// **'Farmers market selling agricultural goods.'**
  String get arkedPeladangDesc;

  /// No description provided for @arkedPeladangFull.
  ///
  /// In en, this message translates to:
  /// **'Arked Peladang Cameron Highlands sells fresh farm produce and local agricultural products.'**
  String get arkedPeladangFull;

  /// No description provided for @brinchangNightDesc.
  ///
  /// In en, this message translates to:
  /// **'Night market with food and souvenirs.'**
  String get brinchangNightDesc;

  /// No description provided for @brinchangNightFull.
  ///
  /// In en, this message translates to:
  /// **'Brinchang Night Market is famous for street food, strawberries, vegetables, and souvenirs.'**
  String get brinchangNightFull;

  /// No description provided for @avantChocolateDesc.
  ///
  /// In en, this message translates to:
  /// **'Chocolate shop and factory.'**
  String get avantChocolateDesc;

  /// No description provided for @avantChocolateFull.
  ///
  /// In en, this message translates to:
  /// **'Avant Chocolate Cameron Highlands produces and sells delicious homemade chocolates.'**
  String get avantChocolateFull;

  /// No description provided for @cameronCentrumDesc.
  ///
  /// In en, this message translates to:
  /// **'Modern lifestyle attraction in Cameron Highlands.'**
  String get cameronCentrumDesc;

  /// No description provided for @cameronCentrumFull.
  ///
  /// In en, this message translates to:
  /// **'Cameron Centrum is a new tourism hub with restaurants, cafes, and attractions.'**
  String get cameronCentrumFull;

  /// No description provided for @greenViewDesc.
  ///
  /// In en, this message translates to:
  /// **'Garden and strawberry attraction.'**
  String get greenViewDesc;

  /// No description provided for @greenViewFull.
  ///
  /// In en, this message translates to:
  /// **'Green View Garden features strawberry farms, gardens, and family attractions.'**
  String get greenViewFull;

  /// No description provided for @lavenderGardenDesc.
  ///
  /// In en, this message translates to:
  /// **'Beautiful lavender themed garden.'**
  String get lavenderGardenDesc;

  /// No description provided for @lavenderGardenFull.
  ///
  /// In en, this message translates to:
  /// **'Cameron Lavender Garden is famous for colorful flowers, lavender fields, and souvenirs.'**
  String get lavenderGardenFull;

  /// No description provided for @bohTeaDesc.
  ///
  /// In en, this message translates to:
  /// **'Famous tea plantation and cafe.'**
  String get bohTeaDesc;

  /// No description provided for @bohTeaFull.
  ///
  /// In en, this message translates to:
  /// **'BOH Tea Centre at Sungei Palas offers scenic views of tea plantations and a tea tasting experience.'**
  String get bohTeaFull;

  /// No description provided for @freshCropDesc.
  ///
  /// In en, this message translates to:
  /// **'Local bazaar selling fresh crops.'**
  String get freshCropDesc;

  /// No description provided for @freshCropFull.
  ///
  /// In en, this message translates to:
  /// **'Cameron Fresh Crop Bazaar sells vegetables, fruits, and local products.'**
  String get freshCropFull;

  /// No description provided for @sheepSanctuaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Animal farm attraction.'**
  String get sheepSanctuaryDesc;

  /// No description provided for @sheepSanctuaryFull.
  ///
  /// In en, this message translates to:
  /// **'The Sheep Sanctuary allows visitors to interact with sheep and feed them.'**
  String get sheepSanctuaryFull;

  /// No description provided for @ppkStrawberryDesc.
  ///
  /// In en, this message translates to:
  /// **'Strawberry farm attraction.'**
  String get ppkStrawberryDesc;

  /// No description provided for @ppkStrawberryFull.
  ///
  /// In en, this message translates to:
  /// **'PPK Strawberry Farm allows visitors to pick fresh strawberries.'**
  String get ppkStrawberryFull;

  /// No description provided for @bigRedDesc.
  ///
  /// In en, this message translates to:
  /// **'Popular strawberry farm attraction.'**
  String get bigRedDesc;

  /// No description provided for @bigRedFull.
  ///
  /// In en, this message translates to:
  /// **'Big Red Strawberry Farm offers strawberry picking and a cafe.'**
  String get bigRedFull;

  /// No description provided for @floraParkDesc.
  ///
  /// In en, this message translates to:
  /// **'Beautiful flower park attraction.'**
  String get floraParkDesc;

  /// No description provided for @floraParkFull.
  ///
  /// In en, this message translates to:
  /// **'Cameron Highlands Flora Park showcases many colorful flowers and gardens.'**
  String get floraParkFull;

  /// No description provided for @rainbowGardenDesc.
  ///
  /// In en, this message translates to:
  /// **'Garden attraction with animals.'**
  String get rainbowGardenDesc;

  /// No description provided for @rainbowGardenFull.
  ///
  /// In en, this message translates to:
  /// **'Rainbow Garden offers plants, flowers, and animal feeding activities.'**
  String get rainbowGardenFull;

  /// No description provided for @cactusPointDesc.
  ///
  /// In en, this message translates to:
  /// **'Large cactus garden attraction.'**
  String get cactusPointDesc;

  /// No description provided for @cactusPointFull.
  ///
  /// In en, this message translates to:
  /// **'Cactus Point features thousands of cactus species and plants.'**
  String get cactusPointFull;

  /// No description provided for @apiaryFarmDesc.
  ///
  /// In en, this message translates to:
  /// **'Honey farm attraction.'**
  String get apiaryFarmDesc;

  /// No description provided for @apiaryFarmFull.
  ///
  /// In en, this message translates to:
  /// **'Highlands Apiary Farm is known for honey production and bee farming.'**
  String get apiaryFarmFull;

  /// No description provided for @orGardenDesc.
  ///
  /// In en, this message translates to:
  /// **'Beautiful flower garden attraction.'**
  String get orGardenDesc;

  /// No description provided for @orGardenFull.
  ///
  /// In en, this message translates to:
  /// **'O&R Garden displays various flowers and ornamental plants.'**
  String get orGardenFull;

  /// No description provided for @pertabalanDesc.
  ///
  /// In en, this message translates to:
  /// **'Public park in Tanah Rata.'**
  String get pertabalanDesc;

  /// No description provided for @pertabalanFull.
  ///
  /// In en, this message translates to:
  /// **'Taman Pertabalan Tanah Rata is a relaxing park for visitors.'**
  String get pertabalanFull;

  /// No description provided for @zoomaniDesc.
  ///
  /// In en, this message translates to:
  /// **'Butterfly and insect farm attraction.'**
  String get zoomaniDesc;

  /// No description provided for @zoomaniFull.
  ///
  /// In en, this message translates to:
  /// **'ZooMania Butterfly Farm houses butterflies and insects.'**
  String get zoomaniFull;

  /// No description provided for @mardiDesc.
  ///
  /// In en, this message translates to:
  /// **'Agricultural research park.'**
  String get mardiDesc;

  /// No description provided for @mardiFull.
  ///
  /// In en, this message translates to:
  /// **'MARDI Agrotechnology Park showcases agricultural technology and gardens.'**
  String get mardiFull;

  /// No description provided for @timeTunnelDesc.
  ///
  /// In en, this message translates to:
  /// **'Historical museum of Cameron Highlands.'**
  String get timeTunnelDesc;

  /// No description provided for @timeTunnelFull.
  ///
  /// In en, this message translates to:
  /// **'Time Tunnel Museum displays historical artifacts and memories of Cameron Highlands.'**
  String get timeTunnelFull;

  /// No description provided for @lataIskandarDesc.
  ///
  /// In en, this message translates to:
  /// **'Waterfall between Tapah and Cameron Highlands.'**
  String get lataIskandarDesc;

  /// No description provided for @lataIskandarFull.
  ///
  /// In en, this message translates to:
  /// **'Lata Iskandar is a popular roadside waterfall for tourists.'**
  String get lataIskandarFull;

  /// No description provided for @robinsonDesc.
  ///
  /// In en, this message translates to:
  /// **'Hidden waterfall hiking attraction.'**
  String get robinsonDesc;

  /// No description provided for @robinsonFull.
  ///
  /// In en, this message translates to:
  /// **'Robinson Falls is a beautiful waterfall reached by jungle trekking.'**
  String get robinsonFull;

  /// No description provided for @mossyForestDesc.
  ///
  /// In en, this message translates to:
  /// **'Unique high altitude forest.'**
  String get mossyForestDesc;

  /// No description provided for @mossyForestFull.
  ///
  /// In en, this message translates to:
  /// **'Mossy Forest is a magical cloud forest with moss-covered trees.'**
  String get mossyForestFull;

  /// No description provided for @eeFengDesc.
  ///
  /// In en, this message translates to:
  /// **'Bee farm attraction.'**
  String get eeFengDesc;

  /// No description provided for @eeFengFull.
  ///
  /// In en, this message translates to:
  /// **'Ee Feng Gu Bee Farm produces honey and sells bee products.'**
  String get eeFengFull;

  /// No description provided for @gunungIrauDesc.
  ///
  /// In en, this message translates to:
  /// **'Highest hiking mountain in Cameron Highlands.'**
  String get gunungIrauDesc;

  /// No description provided for @gunungIrauFull.
  ///
  /// In en, this message translates to:
  /// **'Gunung Irau is famous for its Mossy Forest hiking trail.'**
  String get gunungIrauFull;

  /// No description provided for @cameronAdventureDesc.
  ///
  /// In en, this message translates to:
  /// **'Outdoor adventure activity.'**
  String get cameronAdventureDesc;

  /// No description provided for @cameronAdventureFull.
  ///
  /// In en, this message translates to:
  /// **'Cameron Adventurous offers ATV rides and outdoor experiences.'**
  String get cameronAdventureFull;

  /// No description provided for @grapeFarmDesc.
  ///
  /// In en, this message translates to:
  /// **'Grape farm attraction.'**
  String get grapeFarmDesc;

  /// No description provided for @grapeFarmFull.
  ///
  /// In en, this message translates to:
  /// **'KC Kwang & Sons Grape Farm grows grapes and other fruits.'**
  String get grapeFarmFull;

  /// No description provided for @camelliaDesc.
  ///
  /// In en, this message translates to:
  /// **'Flower garden attraction.'**
  String get camelliaDesc;

  /// No description provided for @camelliaFull.
  ///
  /// In en, this message translates to:
  /// **'Tan\'s Camellia Garden features beautiful camellia flowers.'**
  String get camelliaFull;

  /// No description provided for @rajuHillDesc.
  ///
  /// In en, this message translates to:
  /// **'Strawberry farm and cafe.'**
  String get rajuHillDesc;

  /// No description provided for @rajuHillFull.
  ///
  /// In en, this message translates to:
  /// **'Raju Hill Strawberry Farm allows visitors to pick strawberries.'**
  String get rajuHillFull;

  /// No description provided for @mahMeriDesc.
  ///
  /// In en, this message translates to:
  /// **'Art gallery attraction.'**
  String get mahMeriDesc;

  /// No description provided for @mahMeriFull.
  ///
  /// In en, this message translates to:
  /// **'Mah Meri Art Gallery displays traditional Malaysian art.'**
  String get mahMeriFull;

  /// No description provided for @khmDesc.
  ///
  /// In en, this message translates to:
  /// **'Cafe serving strawberry desserts.'**
  String get khmDesc;

  /// No description provided for @khmFull.
  ///
  /// In en, this message translates to:
  /// **'KHM Strawberries & Jam offers desserts and strawberry products.'**
  String get khmFull;

  /// No description provided for @yzAgroDesc.
  ///
  /// In en, this message translates to:
  /// **'Strawberry farm cafe.'**
  String get yzAgroDesc;

  /// No description provided for @yzAgroFull.
  ///
  /// In en, this message translates to:
  /// **'YZ Agro Farm provides strawberry picking and cafe food.'**
  String get yzAgroFull;

  /// No description provided for @teaHouseDesc.
  ///
  /// In en, this message translates to:
  /// **'Tea house overlooking tea plantations.'**
  String get teaHouseDesc;

  /// No description provided for @teaHouseFull.
  ///
  /// In en, this message translates to:
  /// **'Cameron Valley Tea House offers tea and scenic plantation views.'**
  String get teaHouseFull;

  /// No description provided for @teaKualaTerlaDesc.
  ///
  /// In en, this message translates to:
  /// **'Tea cafe in Kuala Terla.'**
  String get teaKualaTerlaDesc;

  /// No description provided for @teaKualaTerlaFull.
  ///
  /// In en, this message translates to:
  /// **'Cameron Valley Tea House Kuala Terla serves tea with beautiful views.'**
  String get teaKualaTerlaFull;

  /// No description provided for @seedsCafeDesc.
  ///
  /// In en, this message translates to:
  /// **'Modern cafe in Cameron Highlands.'**
  String get seedsCafeDesc;

  /// No description provided for @seedsCafeFull.
  ///
  /// In en, this message translates to:
  /// **'200 Seeds Café offers coffee, desserts, and relaxing atmosphere.'**
  String get seedsCafeFull;

  /// No description provided for @dragText.
  ///
  /// In en, this message translates to:
  /// **'DRAG TO EXPLORE'**
  String get dragText;

  /// No description provided for @searchMap.
  ///
  /// In en, this message translates to:
  /// **'Tap To Search Location'**
  String get searchMap;

  /// No description provided for @errorMapSearch.
  ///
  /// In en, this message translates to:
  /// **'No suggestion place found.'**
  String get errorMapSearch;

  /// No description provided for @temerlohExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Temerloh, Pahang Exploration'**
  String get temerlohExplorationTitle;

  /// No description provided for @temBusiness1Desc.
  ///
  /// In en, this message translates to:
  /// **'Weekly market with local products.'**
  String get temBusiness1Desc;

  /// No description provided for @temBusiness1Full.
  ///
  /// In en, this message translates to:
  /// **'Pasar Sehari Temerloh is a popular weekly market selling fresh produce, clothing, household goods and local snacks.'**
  String get temBusiness1Full;

  /// No description provided for @temBusiness2Desc.
  ///
  /// In en, this message translates to:
  /// **'Main public square of Temerloh.'**
  String get temBusiness2Desc;

  /// No description provided for @temBusiness2Full.
  ///
  /// In en, this message translates to:
  /// **'Dataran Patin is a landmark square named after Temerloh’s famous patin fish. Great for relaxing and events.'**
  String get temBusiness2Full;

  /// No description provided for @temBusiness3Desc.
  ///
  /// In en, this message translates to:
  /// **'Traditional wet and dry market.'**
  String get temBusiness3Desc;

  /// No description provided for @temBusiness3Full.
  ///
  /// In en, this message translates to:
  /// **'Pasar Besar Temerloh offers seafood, vegetables, meat and many daily essentials for locals and visitors.'**
  String get temBusiness3Full;

  /// No description provided for @temBusiness4Desc.
  ///
  /// In en, this message translates to:
  /// **'Night flea market.'**
  String get temBusiness4Desc;

  /// No description provided for @temBusiness4Full.
  ///
  /// In en, this message translates to:
  /// **'Pasar Karat Temerloh is known for second-hand goods, vintage items and bargain shopping at night.'**
  String get temBusiness4Full;

  /// No description provided for @temBusiness5Desc.
  ///
  /// In en, this message translates to:
  /// **'Local art and handmade items.'**
  String get temBusiness5Desc;

  /// No description provided for @temBusiness5Full.
  ///
  /// In en, this message translates to:
  /// **'Pasar Seni Temerloh features crafts, paintings, handmade gifts and cultural products.'**
  String get temBusiness5Full;

  /// No description provided for @temBusiness6Desc.
  ///
  /// In en, this message translates to:
  /// **'Heritage themed market.'**
  String get temBusiness6Desc;

  /// No description provided for @temBusiness6Full.
  ///
  /// In en, this message translates to:
  /// **'Pasar Warisan Temerloh promotes traditional food, classic goods and local heritage culture.'**
  String get temBusiness6Full;

  /// No description provided for @temBusiness7Desc.
  ///
  /// In en, this message translates to:
  /// **'Popular evening market.'**
  String get temBusiness7Desc;

  /// No description provided for @temBusiness7Full.
  ///
  /// In en, this message translates to:
  /// **'Temerloh Night Market is filled with food stalls, drinks, clothing and affordable street shopping.'**
  String get temBusiness7Full;

  /// No description provided for @temBusiness8Desc.
  ///
  /// In en, this message translates to:
  /// **'Local community market.'**
  String get temBusiness8Desc;

  /// No description provided for @temBusiness8Full.
  ///
  /// In en, this message translates to:
  /// **'Pasar Tiga Temerloh serves nearby residents with fresh food, groceries and daily necessities.'**
  String get temBusiness8Full;

  /// No description provided for @temInteresting1Desc.
  ///
  /// In en, this message translates to:
  /// **'Center point of Peninsular Malaysia.'**
  String get temInteresting1Desc;

  /// No description provided for @temInteresting1Full.
  ///
  /// In en, this message translates to:
  /// **'Titik Tengah Semenanjung is the geographical midpoint of Peninsular Malaysia and a famous photo spot.'**
  String get temInteresting1Full;

  /// No description provided for @temInteresting2Desc.
  ///
  /// In en, this message translates to:
  /// **'Lake park for recreation.'**
  String get temInteresting2Desc;

  /// No description provided for @temInteresting2Full.
  ///
  /// In en, this message translates to:
  /// **'Tasik Chatin Recreation Park offers jogging paths, greenery, lakeside scenery and family activities.'**
  String get temInteresting2Full;

  /// No description provided for @temInteresting3Desc.
  ///
  /// In en, this message translates to:
  /// **'National elephant sanctuary.'**
  String get temInteresting3Desc;

  /// No description provided for @temInteresting3Full.
  ///
  /// In en, this message translates to:
  /// **'Pusat Konservasi Gajah Kebangsaan protects elephants and educates visitors about wildlife conservation.'**
  String get temInteresting3Full;

  /// No description provided for @temInteresting4Desc.
  ///
  /// In en, this message translates to:
  /// **'Family animal attraction.'**
  String get temInteresting4Desc;

  /// No description provided for @temInteresting4Full.
  ///
  /// In en, this message translates to:
  /// **'Deerland Park allows visitors to see deer and other animals in a fun family environment.'**
  String get temInteresting4Full;

  /// No description provided for @temInteresting5Desc.
  ///
  /// In en, this message translates to:
  /// **'Water theme park.'**
  String get temInteresting5Desc;

  /// No description provided for @temInteresting5Full.
  ///
  /// In en, this message translates to:
  /// **'Kubang Gajah Water Theme Park is suitable for children and families with pools and slides.'**
  String get temInteresting5Full;

  /// No description provided for @temInteresting6Desc.
  ///
  /// In en, this message translates to:
  /// **'Beautiful limestone hill.'**
  String get temInteresting6Desc;

  /// No description provided for @temInteresting6Full.
  ///
  /// In en, this message translates to:
  /// **'Gunung Senyum is famous for caves, climbing and scenic natural landscapes.'**
  String get temInteresting6Full;

  /// No description provided for @temInteresting7Desc.
  ///
  /// In en, this message translates to:
  /// **'Seladang conservation center.'**
  String get temInteresting7Desc;

  /// No description provided for @temInteresting7Full.
  ///
  /// In en, this message translates to:
  /// **'This center focuses on conserving seladang (gaur), one of Malaysia’s protected wild animals.'**
  String get temInteresting7Full;

  /// No description provided for @temInteresting8Desc.
  ///
  /// In en, this message translates to:
  /// **'Traditional village stay.'**
  String get temInteresting8Desc;

  /// No description provided for @temInteresting8Full.
  ///
  /// In en, this message translates to:
  /// **'Kampungstay Desa Murni offers homestay experiences with village lifestyle and cultural activities.'**
  String get temInteresting8Full;

  /// No description provided for @temInteresting9Desc.
  ///
  /// In en, this message translates to:
  /// **'Peaceful recreation park.'**
  String get temInteresting9Desc;

  /// No description provided for @temInteresting9Full.
  ///
  /// In en, this message translates to:
  /// **'Wadi Al-Amin Recreation Park is a peaceful place for family outings and relaxation.'**
  String get temInteresting9Full;

  /// No description provided for @temInteresting10Desc.
  ///
  /// In en, this message translates to:
  /// **'Refreshing waterfall destination.'**
  String get temInteresting10Desc;

  /// No description provided for @temInteresting10Full.
  ///
  /// In en, this message translates to:
  /// **'Lata Bujang Waterfall is a natural attraction popular for picnics and enjoying cool fresh water.'**
  String get temInteresting10Full;

  /// No description provided for @temInteresting11Desc.
  ///
  /// In en, this message translates to:
  /// **'Indigenous village experience.'**
  String get temInteresting11Desc;

  /// No description provided for @temInteresting11Full.
  ///
  /// In en, this message translates to:
  /// **'Visitors can learn about the Che’ Wong indigenous community, traditions and lifestyle.'**
  String get temInteresting11Full;

  /// No description provided for @temInteresting12Desc.
  ///
  /// In en, this message translates to:
  /// **'Protected wildlife forest reserve.'**
  String get temInteresting12Desc;

  /// No description provided for @temInteresting12Full.
  ///
  /// In en, this message translates to:
  /// **'Krau Wildlife Reserve is rich in biodiversity and ideal for eco-tourism and nature lovers.'**
  String get temInteresting12Full;

  /// No description provided for @temInteresting13Desc.
  ///
  /// In en, this message translates to:
  /// **'Riverfront public attraction.'**
  String get temInteresting13Desc;

  /// No description provided for @temInteresting13Full.
  ///
  /// In en, this message translates to:
  /// **'Esplanade Temerloh is a relaxing riverside area for walking, gatherings and enjoying the town atmosphere.'**
  String get temInteresting13Full;

  /// No description provided for @temFood1Desc.
  ///
  /// In en, this message translates to:
  /// **'Popular local stall.'**
  String get temFood1Desc;

  /// No description provided for @temFood1Full.
  ///
  /// In en, this message translates to:
  /// **'Warung Acu is known for tasty local dishes and friendly service.'**
  String get temFood1Full;

  /// No description provided for @temFood2Desc.
  ///
  /// In en, this message translates to:
  /// **'Roadside favourite eatery.'**
  String get temFood2Desc;

  /// No description provided for @temFood2Full.
  ///
  /// In en, this message translates to:
  /// **'Go\' Bang Maju Tol is a well-known stop for travelers seeking hearty meals.'**
  String get temFood2Full;

  /// No description provided for @temFood3Desc.
  ///
  /// In en, this message translates to:
  /// **'Famous patin riverside restaurant.'**
  String get temFood3Desc;

  /// No description provided for @temFood3Full.
  ///
  /// In en, this message translates to:
  /// **'Angah Maju Selera Patin Tebing Sungai is famous for patin tempoyak and river views.'**
  String get temFood3Full;

  /// No description provided for @temFood4Desc.
  ///
  /// In en, this message translates to:
  /// **'Affordable local food stall.'**
  String get temFood4Desc;

  /// No description provided for @temFood4Full.
  ///
  /// In en, this message translates to:
  /// **'Gerai Adik Hanizan serves delicious home-style dishes at reasonable prices.'**
  String get temFood4Full;

  /// No description provided for @temFood5Desc.
  ///
  /// In en, this message translates to:
  /// **'Modern café dining.'**
  String get temFood5Desc;

  /// No description provided for @temFood5Full.
  ///
  /// In en, this message translates to:
  /// **'KOI & AOK Cafe offers burgers, steak, coffee and desserts in a cozy atmosphere.'**
  String get temFood5Full;

  /// No description provided for @temFood6Desc.
  ///
  /// In en, this message translates to:
  /// **'Traditional restaurant.'**
  String get temFood6Desc;

  /// No description provided for @temFood6Full.
  ///
  /// In en, this message translates to:
  /// **'Restoran Tok Gajah Temerloh serves authentic Pahang cuisine and local favourites.'**
  String get temFood6Full;

  /// No description provided for @temFood7Desc.
  ///
  /// In en, this message translates to:
  /// **'Relaxing café spot.'**
  String get temFood7Desc;

  /// No description provided for @temFood7Full.
  ///
  /// In en, this message translates to:
  /// **'Mukmin Cafe is a nice place for drinks, snacks and casual meals.'**
  String get temFood7Full;

  /// No description provided for @temFood8Desc.
  ///
  /// In en, this message translates to:
  /// **'Unique coffee place.'**
  String get temFood8Desc;

  /// No description provided for @temFood8Full.
  ///
  /// In en, this message translates to:
  /// **'Kopi Bawah Tangga is known for coffee and charming ambiance.'**
  String get temFood8Full;

  /// No description provided for @temFood9Desc.
  ///
  /// In en, this message translates to:
  /// **'Popular patin destination.'**
  String get temFood9Desc;

  /// No description provided for @temFood9Full.
  ///
  /// In en, this message translates to:
  /// **'Selera Patin Bangau Temerloh is another famous place to enjoy Temerloh patin dishes.'**
  String get temFood9Full;

  /// No description provided for @sewaanPbtTitle.
  ///
  /// In en, this message translates to:
  /// **'PBT Rental'**
  String get sewaanPbtTitle;

  /// No description provided for @sewaanInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Rental Information'**
  String get sewaanInfoTitle;

  /// No description provided for @sewaanSelectPayment.
  ///
  /// In en, this message translates to:
  /// **'Please select rental arrears for payment'**
  String get sewaanSelectPayment;

  /// No description provided for @sewaanDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rental Details'**
  String get sewaanDetailsTitle;

  /// No description provided for @sewaanNoData.
  ///
  /// In en, this message translates to:
  /// **'No rental data found'**
  String get sewaanNoData;

  /// No description provided for @sewaanSelectAlert.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one rental.'**
  String get sewaanSelectAlert;

  /// No description provided for @sewaanNoArrearsAlert.
  ///
  /// In en, this message translates to:
  /// **'No rental arrears to pay.'**
  String get sewaanNoArrearsAlert;

  /// No description provided for @sewaanNoRecord.
  ///
  /// In en, this message translates to:
  /// **'No rental record found'**
  String get sewaanNoRecord;

  /// No description provided for @taksiranTitle.
  ///
  /// In en, this message translates to:
  /// **'Assessment Tax'**
  String get taksiranTitle;

  /// No description provided for @taksiranSelectPayment.
  ///
  /// In en, this message translates to:
  /// **'Please select assessment tax for payment'**
  String get taksiranSelectPayment;

  /// No description provided for @taksiranDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assessment Tax Details'**
  String get taksiranDetailsTitle;

  /// No description provided for @taksiranNoData.
  ///
  /// In en, this message translates to:
  /// **'No assessment tax data found'**
  String get taksiranNoData;

  /// No description provided for @taksiranSelectAlert.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one assessment tax.'**
  String get taksiranSelectAlert;

  /// No description provided for @taksiranNoAmountAlert.
  ///
  /// In en, this message translates to:
  /// **'No assessment tax amount to pay.'**
  String get taksiranNoAmountAlert;

  /// No description provided for @taksiranNoRecord.
  ///
  /// In en, this message translates to:
  /// **'No assessment tax record found'**
  String get taksiranNoRecord;

  /// No description provided for @notice.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get notice;

  /// No description provided for @oldAccountNo.
  ///
  /// In en, this message translates to:
  /// **'Old Account No'**
  String get oldAccountNo;

  /// No description provided for @invoiceNo.
  ///
  /// In en, this message translates to:
  /// **'Invoice No'**
  String get invoiceNo;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @icNo.
  ///
  /// In en, this message translates to:
  /// **'IC No'**
  String get icNo;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @rentalMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Rental'**
  String get rentalMonthly;

  /// No description provided for @rentalPlace.
  ///
  /// In en, this message translates to:
  /// **'Rental Place'**
  String get rentalPlace;

  /// No description provided for @rentalCity.
  ///
  /// In en, this message translates to:
  /// **'Rental City'**
  String get rentalCity;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @postcode.
  ///
  /// In en, this message translates to:
  /// **'Postcode'**
  String get postcode;

  /// No description provided for @town.
  ///
  /// In en, this message translates to:
  /// **'Town'**
  String get town;

  /// No description provided for @rentalArrears.
  ///
  /// In en, this message translates to:
  /// **'Rental Arrears'**
  String get rentalArrears;

  /// No description provided for @waterArrears.
  ///
  /// In en, this message translates to:
  /// **'Water Charge Arrears'**
  String get waterArrears;

  /// No description provided for @electricArrears.
  ///
  /// In en, this message translates to:
  /// **'Electric Charge Arrears'**
  String get electricArrears;

  /// No description provided for @managementArrears.
  ///
  /// In en, this message translates to:
  /// **'Management Charge Arrears'**
  String get managementArrears;

  /// No description provided for @annualTotal.
  ///
  /// In en, this message translates to:
  /// **'Annual Total'**
  String get annualTotal;

  /// No description provided for @propertyPostcode.
  ///
  /// In en, this message translates to:
  /// **'Property Postcode'**
  String get propertyPostcode;

  /// No description provided for @propertyCity.
  ///
  /// In en, this message translates to:
  /// **'Property City'**
  String get propertyCity;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @mukim.
  ///
  /// In en, this message translates to:
  /// **'Mukim'**
  String get mukim;

  /// No description provided for @lotNo.
  ///
  /// In en, this message translates to:
  /// **'Lot No'**
  String get lotNo;

  /// No description provided for @titleNo.
  ///
  /// In en, this message translates to:
  /// **'Title No'**
  String get titleNo;

  /// No description provided for @ownerAddress.
  ///
  /// In en, this message translates to:
  /// **'Owner Address'**
  String get ownerAddress;

  /// No description provided for @telephone.
  ///
  /// In en, this message translates to:
  /// **'Telephone'**
  String get telephone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @annualValue.
  ///
  /// In en, this message translates to:
  /// **'Annual Value'**
  String get annualValue;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @annualTax.
  ///
  /// In en, this message translates to:
  /// **'Annual Tax'**
  String get annualTax;

  /// No description provided for @halfYearTax.
  ///
  /// In en, this message translates to:
  /// **'Half-Year Tax'**
  String get halfYearTax;

  /// No description provided for @currentTax.
  ///
  /// In en, this message translates to:
  /// **'Current Tax'**
  String get currentTax;

  /// No description provided for @taxArrears.
  ///
  /// In en, this message translates to:
  /// **'Tax Arrears'**
  String get taxArrears;

  /// No description provided for @noticeE.
  ///
  /// In en, this message translates to:
  /// **'Notice E'**
  String get noticeE;

  /// No description provided for @waranLod.
  ///
  /// In en, this message translates to:
  /// **'Warrant LOD'**
  String get waranLod;

  /// No description provided for @halfYearTotal.
  ///
  /// In en, this message translates to:
  /// **'Half-Year Total'**
  String get halfYearTotal;

  /// No description provided for @semakanSewaanTitle.
  ///
  /// In en, this message translates to:
  /// **'RENT INQUIRY'**
  String get semakanSewaanTitle;

  /// No description provided for @semakanSewaanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rental Payment Transaction List'**
  String get semakanSewaanSubtitle;

  /// No description provided for @transactionInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Information'**
  String get transactionInfoTitle;

  /// No description provided for @tenantName.
  ///
  /// In en, this message translates to:
  /// **'Tenant Name'**
  String get tenantName;

  /// No description provided for @premiseAddress.
  ///
  /// In en, this message translates to:
  /// **'Premise Address'**
  String get premiseAddress;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get transactionId;

  /// No description provided for @subangExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Subang Jaya'**
  String get subangExplorationTitle;

  /// No description provided for @subangBlueMosqueTitle.
  ///
  /// In en, this message translates to:
  /// **'Blue Mosque Shah Alam'**
  String get subangBlueMosqueTitle;

  /// No description provided for @subangBlueMosqueDesc.
  ///
  /// In en, this message translates to:
  /// **'One of Selangor\'s most iconic landmarks.'**
  String get subangBlueMosqueDesc;

  /// No description provided for @subangBlueMosqueFull.
  ///
  /// In en, this message translates to:
  /// **'The Sultan Salahuddin Abdul Aziz Mosque, also known as the Blue Mosque, is one of the most famous landmarks near Subang Jaya. It is known for its large blue dome, beautiful Islamic architecture, and peaceful surroundings.'**
  String get subangBlueMosqueFull;

  /// No description provided for @subangIstanaAlamTitle.
  ///
  /// In en, this message translates to:
  /// **'Istana Alam Shah'**
  String get subangIstanaAlamTitle;

  /// No description provided for @subangIstanaAlamDesc.
  ///
  /// In en, this message translates to:
  /// **'Royal palace of the Sultan of Selangor.'**
  String get subangIstanaAlamDesc;

  /// No description provided for @subangIstanaAlamFull.
  ///
  /// In en, this message translates to:
  /// **'Istana Alam Shah is an important royal landmark in Selangor. It represents the heritage and royal history of the state and is located within travelling distance from Subang Jaya.'**
  String get subangIstanaAlamFull;

  /// No description provided for @subangLakeGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'Shah Alam Lake Gardens'**
  String get subangLakeGardenTitle;

  /// No description provided for @subangLakeGardenDesc.
  ///
  /// In en, this message translates to:
  /// **'Historic public park and lake area.'**
  String get subangLakeGardenDesc;

  /// No description provided for @subangLakeGardenFull.
  ///
  /// In en, this message translates to:
  /// **'Shah Alam Lake Gardens is one of the well-known recreational and public spaces in Selangor. It is suitable for relaxing walks, family activities and sightseeing.'**
  String get subangLakeGardenFull;

  /// No description provided for @subangSunwayLagoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Sunway Lagoon'**
  String get subangSunwayLagoonTitle;

  /// No description provided for @subangSunwayLagoonDesc.
  ///
  /// In en, this message translates to:
  /// **'Famous theme park in Bandar Sunway.'**
  String get subangSunwayLagoonDesc;

  /// No description provided for @subangSunwayLagoonFull.
  ///
  /// In en, this message translates to:
  /// **'Sunway Lagoon is one of Malaysia\'s most popular theme parks. It offers water attractions, wildlife areas, thrilling rides and entertainment activities suitable for families and tourists.'**
  String get subangSunwayLagoonFull;

  /// No description provided for @subangSunwayPyramidTitle.
  ///
  /// In en, this message translates to:
  /// **'Sunway Pyramid'**
  String get subangSunwayPyramidTitle;

  /// No description provided for @subangSunwayPyramidDesc.
  ///
  /// In en, this message translates to:
  /// **'Iconic shopping mall with pyramid design.'**
  String get subangSunwayPyramidDesc;

  /// No description provided for @subangSunwayPyramidFull.
  ///
  /// In en, this message translates to:
  /// **'Sunway Pyramid is a famous shopping and lifestyle mall in Bandar Sunway. It is known for its Egyptian-inspired architecture, shopping outlets, restaurants, cinema and ice-skating rink.'**
  String get subangSunwayPyramidFull;

  /// No description provided for @subangRiaParkTitle.
  ///
  /// In en, this message translates to:
  /// **'Subang Ria Recreational Park'**
  String get subangRiaParkTitle;

  /// No description provided for @subangRiaParkDesc.
  ///
  /// In en, this message translates to:
  /// **'Popular park for leisure and exercise.'**
  String get subangRiaParkDesc;

  /// No description provided for @subangRiaParkFull.
  ///
  /// In en, this message translates to:
  /// **'Subang Ria Recreational Park is a green space in Subang Jaya with lake views and walking areas. It is suitable for jogging, relaxing and spending time with family.'**
  String get subangRiaParkFull;

  /// No description provided for @subangEmpireTitle.
  ///
  /// In en, this message translates to:
  /// **'Empire Shopping Gallery'**
  String get subangEmpireTitle;

  /// No description provided for @subangEmpireDesc.
  ///
  /// In en, this message translates to:
  /// **'Modern shopping and dining destination.'**
  String get subangEmpireDesc;

  /// No description provided for @subangEmpireFull.
  ///
  /// In en, this message translates to:
  /// **'Empire Shopping Gallery is a popular lifestyle mall in Subang Jaya. Visitors can enjoy shopping, cafes, restaurants and indoor activities.'**
  String get subangEmpireFull;

  /// No description provided for @subangSS15Title.
  ///
  /// In en, this message translates to:
  /// **'SS15 Subang Jaya'**
  String get subangSS15Title;

  /// No description provided for @subangSS15Desc.
  ///
  /// In en, this message translates to:
  /// **'Famous food, cafe and student area.'**
  String get subangSS15Desc;

  /// No description provided for @subangSS15Full.
  ///
  /// In en, this message translates to:
  /// **'SS15 is one of the liveliest areas in Subang Jaya. It is well known for cafes, bubble tea shops, local food, restaurants and a youthful atmosphere.'**
  String get subangSS15Full;

  /// No description provided for @subangDaMenTitle.
  ///
  /// In en, this message translates to:
  /// **'Da Men Mall'**
  String get subangDaMenTitle;

  /// No description provided for @subangDaMenDesc.
  ///
  /// In en, this message translates to:
  /// **'Shopping mall located in USJ.'**
  String get subangDaMenDesc;

  /// No description provided for @subangDaMenFull.
  ///
  /// In en, this message translates to:
  /// **'Da Men Mall is a convenient shopping destination in USJ, Subang Jaya. It offers retail stores, food outlets and family-friendly facilities.'**
  String get subangDaMenFull;

  /// No description provided for @subangSummitTitle.
  ///
  /// In en, this message translates to:
  /// **'The Summit USJ'**
  String get subangSummitTitle;

  /// No description provided for @subangSummitDesc.
  ///
  /// In en, this message translates to:
  /// **'Long-established mall in USJ.'**
  String get subangSummitDesc;

  /// No description provided for @subangSummitFull.
  ///
  /// In en, this message translates to:
  /// **'The Summit USJ is a familiar shopping centre for many Subang Jaya residents. It provides retail shops, food outlets and services for the local community.'**
  String get subangSummitFull;

  /// No description provided for @subangJibbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Jibby & Co'**
  String get subangJibbyTitle;

  /// No description provided for @subangJibbyDesc.
  ///
  /// In en, this message translates to:
  /// **'Popular cafe and restaurant.'**
  String get subangJibbyDesc;

  /// No description provided for @subangJibbyFull.
  ///
  /// In en, this message translates to:
  /// **'Jibby & Co is a popular dining place in Subang Jaya, offering Western, local and fusion dishes in a modern cafe setting.'**
  String get subangJibbyFull;

  /// No description provided for @subangVillageParkTitle.
  ///
  /// In en, this message translates to:
  /// **'Village Park Restaurant'**
  String get subangVillageParkTitle;

  /// No description provided for @subangVillageParkDesc.
  ///
  /// In en, this message translates to:
  /// **'Famous nasi lemak restaurant.'**
  String get subangVillageParkDesc;

  /// No description provided for @subangVillageParkFull.
  ///
  /// In en, this message translates to:
  /// **'Village Park Restaurant is widely known for nasi lemak and Malaysian comfort food. It is a popular food destination for locals and visitors.'**
  String get subangVillageParkFull;

  /// No description provided for @subangRakuzenTitle.
  ///
  /// In en, this message translates to:
  /// **'Rakuzen Sunway Pyramid'**
  String get subangRakuzenTitle;

  /// No description provided for @subangRakuzenDesc.
  ///
  /// In en, this message translates to:
  /// **'Japanese restaurant in Sunway Pyramid.'**
  String get subangRakuzenDesc;

  /// No description provided for @subangRakuzenFull.
  ///
  /// In en, this message translates to:
  /// **'Rakuzen serves Japanese dishes such as sushi, sashimi, rice sets and noodles. It is suitable for visitors looking for Japanese cuisine around Subang Jaya.'**
  String get subangRakuzenFull;

  /// No description provided for @subangFoodStreetTitle.
  ///
  /// In en, this message translates to:
  /// **'SS15 Food Street'**
  String get subangFoodStreetTitle;

  /// No description provided for @subangFoodStreetDesc.
  ///
  /// In en, this message translates to:
  /// **'Popular food area in Subang Jaya.'**
  String get subangFoodStreetDesc;

  /// No description provided for @subangFoodStreetFull.
  ///
  /// In en, this message translates to:
  /// **'SS15 Food Street is known for local food, dessert shops, cafes and casual restaurants. It is one of the best places to explore food in Subang Jaya.'**
  String get subangFoodStreetFull;

  /// No description provided for @prayerTimeDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times Disclaimer'**
  String get prayerTimeDisclaimerTitle;

  /// No description provided for @prayerTimeDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The prayer times displayed are provided for reference and are sourced from the official JAKIM e-Solat service.'**
  String get prayerTimeDisclaimer;

  /// No description provided for @prayerTimeQrInstruction.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code to view the latest prayer times on the official e-Solat website.'**
  String get prayerTimeQrInstruction;

  /// No description provided for @parkingInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'PARKING INFORMATION'**
  String get parkingInfoTitle;

  /// No description provided for @parkingRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Parking Rate'**
  String get parkingRateLabel;

  /// No description provided for @parkingRatePerHour.
  ///
  /// In en, this message translates to:
  /// **'RM {rate} / Hour'**
  String parkingRatePerHour(Object rate);

  /// No description provided for @parkingContactTitle.
  ///
  /// In en, this message translates to:
  /// **'If you experience any issues, please contact:'**
  String get parkingContactTitle;

  /// No description provided for @parkingCouncilHotline.
  ///
  /// In en, this message translates to:
  /// **'Municipal Council Hotline'**
  String get parkingCouncilHotline;

  /// No description provided for @parkingCityCarParkHotline.
  ///
  /// In en, this message translates to:
  /// **'CityCarPark Hotline'**
  String get parkingCityCarParkHotline;

  /// No description provided for @parkingInfoOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get parkingInfoOk;

  /// No description provided for @pinConnectingTitle.
  ///
  /// In en, this message translates to:
  /// **'PREPARING CARD PAYMENT'**
  String get pinConnectingTitle;

  /// No description provided for @pinConnectingMessage.
  ///
  /// In en, this message translates to:
  /// **'Please follow the instructions shown on the card reader.'**
  String get pinConnectingMessage;

  /// No description provided for @pinEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'ENTER YOUR PIN'**
  String get pinEntryTitle;

  /// No description provided for @pinEntryMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN securely using the keypad on the card reader.'**
  String get pinEntryMessage;

  /// No description provided for @pinProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'PROCESSING PAYMENT'**
  String get pinProcessingTitle;

  /// No description provided for @pinProcessingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your PIN has been received. Please wait while the payment is being processed.'**
  String get pinProcessingMessage;

  /// No description provided for @pinSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT SUCCESSFUL'**
  String get pinSuccessTitle;

  /// No description provided for @pinSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your card payment has been approved.'**
  String get pinSuccessMessage;

  /// No description provided for @pinTestSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'The card-reader process has completed. The result is being treated as successful for testing.'**
  String get pinTestSuccessMessage;

  /// No description provided for @pinFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT UNSUCCESSFUL'**
  String get pinFailedTitle;

  /// No description provided for @pinCancellingTitle.
  ///
  /// In en, this message translates to:
  /// **'CANCELLING PAYMENT'**
  String get pinCancellingTitle;

  /// No description provided for @pinCancellingMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait while the card reader completes the cancellation process.'**
  String get pinCancellingMessage;

  /// No description provided for @pinPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT AMOUNT'**
  String get pinPaymentAmount;

  /// No description provided for @pinKeypadInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN on the card reader keypad, then press the green confirmation button.'**
  String get pinKeypadInstruction;

  /// No description provided for @pinDoNotRemoveCard.
  ///
  /// In en, this message translates to:
  /// **'Do not remove your card until the card reader instructs you to do so.'**
  String get pinDoNotRemoveCard;

  /// No description provided for @pinTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get pinTimeRemaining;

  /// No description provided for @pinSeconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get pinSeconds;

  /// No description provided for @pinSuccessNextStep.
  ///
  /// In en, this message translates to:
  /// **'Please wait. Your receipt is being prepared.'**
  String get pinSuccessNextStep;

  /// No description provided for @pinFailureNextStep.
  ///
  /// In en, this message translates to:
  /// **'You will be returned to the payment page shortly.'**
  String get pinFailureNextStep;

  /// No description provided for @pinReferenceCode.
  ///
  /// In en, this message translates to:
  /// **'Reference code'**
  String get pinReferenceCode;

  /// No description provided for @pinTestingModeNotice.
  ///
  /// In en, this message translates to:
  /// **'TESTING MODE: The real card-reader process is running, but every final result will continue as successful.'**
  String get pinTestingModeNotice;

  /// No description provided for @pinFailureDeclined.
  ///
  /// In en, this message translates to:
  /// **'The payment was not approved. Please use another card or payment method.'**
  String get pinFailureDeclined;

  /// No description provided for @pinFailureInsufficientFunds.
  ///
  /// In en, this message translates to:
  /// **'The payment could not be completed. Please check your available balance or use another payment method.'**
  String get pinFailureInsufficientFunds;

  /// No description provided for @pinFailureExpiredCard.
  ///
  /// In en, this message translates to:
  /// **'This card has expired. Please use another card.'**
  String get pinFailureExpiredCard;

  /// No description provided for @pinFailureIncorrectPin.
  ///
  /// In en, this message translates to:
  /// **'The PIN entered was incorrect. Please try the payment again carefully.'**
  String get pinFailureIncorrectPin;

  /// No description provided for @pinFailureInvalidCard.
  ///
  /// In en, this message translates to:
  /// **'This card could not be used. Please use another supported card.'**
  String get pinFailureInvalidCard;

  /// No description provided for @pinFailureNotPermitted.
  ///
  /// In en, this message translates to:
  /// **'This transaction is not permitted for the selected card. Please use another payment method.'**
  String get pinFailureNotPermitted;

  /// No description provided for @pinFailureConnection.
  ///
  /// In en, this message translates to:
  /// **'The payment service is temporarily unavailable. Please try again.'**
  String get pinFailureConnection;

  /// No description provided for @pinFailureCancelled.
  ///
  /// In en, this message translates to:
  /// **'The payment was cancelled. No payment has been completed.'**
  String get pinFailureCancelled;

  /// No description provided for @pinFailureTimeout.
  ///
  /// In en, this message translates to:
  /// **'The payment session took too long and could not be completed. Please try again.'**
  String get pinFailureTimeout;

  /// No description provided for @pinFailureGeneral.
  ///
  /// In en, this message translates to:
  /// **'The payment could not be completed. Please try again or use another payment method.'**
  String get pinFailureGeneral;

  /// No description provided for @cardPaymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT SUCCESSFUL'**
  String get cardPaymentSuccessTitle;

  /// No description provided for @cardPaymentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your card payment has been approved successfully.'**
  String get cardPaymentSuccessMessage;

  /// No description provided for @cardPreparingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Preparing your receipt...'**
  String get cardPreparingReceipt;

  /// No description provided for @cardPleaseWaitNotice.
  ///
  /// In en, this message translates to:
  /// **'Please wait and do not touch the screen.'**
  String get cardPleaseWaitNotice;

  /// No description provided for @pinTitle.
  ///
  /// In en, this message translates to:
  /// **'ENTER PIN'**
  String get pinTitle;

  /// No description provided for @pinInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please enter your PIN on the card reader'**
  String get pinInstruction;

  /// No description provided for @ipohExplorationTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Ipoh'**
  String get ipohExplorationTitle;

  /// No description provided for @ipohTabHistorical.
  ///
  /// In en, this message translates to:
  /// **'Historical Places'**
  String get ipohTabHistorical;

  /// No description provided for @ipohTabInteresting.
  ///
  /// In en, this message translates to:
  /// **'Interesting Places'**
  String get ipohTabInteresting;

  /// No description provided for @ipohTabEating.
  ///
  /// In en, this message translates to:
  /// **'Food Places'**
  String get ipohTabEating;

  /// No description provided for @ipohGoogleMap.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get ipohGoogleMap;

  /// No description provided for @ipohClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get ipohClose;

  /// No description provided for @birchMemorialClockTowerTitle.
  ///
  /// In en, this message translates to:
  /// **'Birch Memorial Clock Tower'**
  String get birchMemorialClockTowerTitle;

  /// No description provided for @birchMemorialClockTowerDesc.
  ///
  /// In en, this message translates to:
  /// **'A well-known colonial-era clock tower in the heart of Ipoh.'**
  String get birchMemorialClockTowerDesc;

  /// No description provided for @birchMemorialClockTowerFull.
  ///
  /// In en, this message translates to:
  /// **'The Birch Memorial Clock Tower is one of Ipoh\'s most recognizable historical landmarks. Built during the British colonial period, it features decorative panels and a clock tower design that reflects the architecture of its time.'**
  String get birchMemorialClockTowerFull;

  /// No description provided for @masjidMuhammadiahIpohTitle.
  ///
  /// In en, this message translates to:
  /// **'Masjid Muhammadiah Ipoh'**
  String get masjidMuhammadiahIpohTitle;

  /// No description provided for @masjidMuhammadiahIpohDesc.
  ///
  /// In en, this message translates to:
  /// **'A unique Chinese-style mosque that reflects Ipoh\'s multicultural identity.'**
  String get masjidMuhammadiahIpohDesc;

  /// No description provided for @masjidMuhammadiahIpohFull.
  ///
  /// In en, this message translates to:
  /// **'Masjid Muhammadiah Ipoh is known for its distinctive Chinese-inspired architecture. Its red walls, decorative roof details and peaceful prayer environment make it an important religious and cultural landmark in Ipoh.'**
  String get masjidMuhammadiahIpohFull;

  /// No description provided for @muziumDarulRidzuanTitle.
  ///
  /// In en, this message translates to:
  /// **'Darul Ridzuan Museum'**
  String get muziumDarulRidzuanTitle;

  /// No description provided for @muziumDarulRidzuanDesc.
  ///
  /// In en, this message translates to:
  /// **'A museum presenting the history and development of Perak.'**
  String get muziumDarulRidzuanDesc;

  /// No description provided for @muziumDarulRidzuanFull.
  ///
  /// In en, this message translates to:
  /// **'Darul Ridzuan Museum is housed in a historic building and displays information about Perak\'s administration, mining history, culture and local development. It is suitable for visitors who want to understand the state\'s heritage.'**
  String get muziumDarulRidzuanFull;

  /// No description provided for @muziumGeologiIpohTitle.
  ///
  /// In en, this message translates to:
  /// **'Geological Museum Ipoh'**
  String get muziumGeologiIpohTitle;

  /// No description provided for @muziumGeologiIpohDesc.
  ///
  /// In en, this message translates to:
  /// **'A museum featuring rocks, minerals, fossils and Malaysia\'s geological heritage.'**
  String get muziumGeologiIpohDesc;

  /// No description provided for @muziumGeologiIpohFull.
  ///
  /// In en, this message translates to:
  /// **'The Geological Museum Ipoh provides educational displays about rocks, minerals, fossils, mining and geological processes. It is a useful destination for families, students and visitors interested in earth science.'**
  String get muziumGeologiIpohFull;

  /// No description provided for @lostWorldTambunTitle.
  ///
  /// In en, this message translates to:
  /// **'Lost World of Tambun'**
  String get lostWorldTambunTitle;

  /// No description provided for @lostWorldTambunDesc.
  ///
  /// In en, this message translates to:
  /// **'A family theme park with water attractions, hot springs and adventure activities.'**
  String get lostWorldTambunDesc;

  /// No description provided for @lostWorldTambunFull.
  ///
  /// In en, this message translates to:
  /// **'Lost World of Tambun is a popular family destination featuring a water park, amusement rides, natural hot springs, animal attractions and adventure activities surrounded by limestone hills.'**
  String get lostWorldTambunFull;

  /// No description provided for @bookXcessIpohTitle.
  ///
  /// In en, this message translates to:
  /// **'BookXcess Ipoh'**
  String get bookXcessIpohTitle;

  /// No description provided for @bookXcessIpohDesc.
  ///
  /// In en, this message translates to:
  /// **'A stylish bookstore located inside a historic building in Ipoh Old Town.'**
  String get bookXcessIpohDesc;

  /// No description provided for @bookXcessIpohFull.
  ///
  /// In en, this message translates to:
  /// **'BookXcess Ipoh combines books, heritage architecture and creative interior design. Visitors can browse a wide range of books while enjoying the unique atmosphere of a restored historic building.'**
  String get bookXcessIpohFull;

  /// No description provided for @kongHengSquareTitle.
  ///
  /// In en, this message translates to:
  /// **'Kong Heng Square'**
  String get kongHengSquareTitle;

  /// No description provided for @kongHengSquareDesc.
  ///
  /// In en, this message translates to:
  /// **'A vibrant heritage area with cafes, shops and creative spaces.'**
  String get kongHengSquareDesc;

  /// No description provided for @kongHengSquareFull.
  ///
  /// In en, this message translates to:
  /// **'Kong Heng Square is a popular gathering place in Ipoh Old Town. It features restored heritage buildings, cafes, small shops, art spaces and a lively environment suitable for photography and casual exploration.'**
  String get kongHengSquareFull;

  /// No description provided for @banjaranHotspringsTitle.
  ///
  /// In en, this message translates to:
  /// **'The Banjaran Hotsprings Retreat'**
  String get banjaranHotspringsTitle;

  /// No description provided for @banjaranHotspringsDesc.
  ///
  /// In en, this message translates to:
  /// **'A luxury wellness retreat surrounded by limestone hills and natural hot springs.'**
  String get banjaranHotspringsDesc;

  /// No description provided for @banjaranHotspringsFull.
  ///
  /// In en, this message translates to:
  /// **'The Banjaran Hotsprings Retreat offers a peaceful wellness experience with geothermal hot springs, caves, spa facilities and lush tropical scenery. It is known for privacy, relaxation and natural beauty.'**
  String get banjaranHotspringsFull;

  /// No description provided for @gopengRaftingTitle.
  ///
  /// In en, this message translates to:
  /// **'Gopeng Rainforest White Water Rafting'**
  String get gopengRaftingTitle;

  /// No description provided for @gopengRaftingDesc.
  ///
  /// In en, this message translates to:
  /// **'An exciting white-water rafting experience surrounded by rainforest scenery.'**
  String get gopengRaftingDesc;

  /// No description provided for @gopengRaftingFull.
  ///
  /// In en, this message translates to:
  /// **'Gopeng Rainforest White Water Rafting offers guided river adventures suitable for visitors seeking outdoor excitement. The activity combines rapids, teamwork and beautiful rainforest surroundings.'**
  String get gopengRaftingFull;

  /// No description provided for @timeTunnelIpohTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Tunnel Ipoh'**
  String get timeTunnelIpohTitle;

  /// No description provided for @timeTunnelIpohDesc.
  ///
  /// In en, this message translates to:
  /// **'A nostalgic museum displaying memories and everyday items from earlier decades.'**
  String get timeTunnelIpohDesc;

  /// No description provided for @timeTunnelIpohFull.
  ///
  /// In en, this message translates to:
  /// **'Time Tunnel Ipoh presents vintage household items, photographs, advertisements and recreated scenes from Malaysia\'s past. It offers visitors a nostalgic and educational journey through earlier decades.'**
  String get timeTunnelIpohFull;

  /// No description provided for @upsideDownWorldIpohTitle.
  ///
  /// In en, this message translates to:
  /// **'Upside Down World Ipoh'**
  String get upsideDownWorldIpohTitle;

  /// No description provided for @upsideDownWorldIpohDesc.
  ///
  /// In en, this message translates to:
  /// **'A fun indoor attraction featuring upside-down rooms and creative photo opportunities.'**
  String get upsideDownWorldIpohDesc;

  /// No description provided for @upsideDownWorldIpohFull.
  ///
  /// In en, this message translates to:
  /// **'Upside Down World Ipoh features specially designed rooms where furniture and decorations appear upside down. It is a family-friendly attraction created for imaginative and entertaining photography.'**
  String get upsideDownWorldIpohFull;

  /// No description provided for @catchAToyRainbowBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Catch A Toy x Rainbow Box'**
  String get catchAToyRainbowBoxTitle;

  /// No description provided for @catchAToyRainbowBoxDesc.
  ///
  /// In en, this message translates to:
  /// **'A colourful entertainment venue with arcade games and toy-catching machines.'**
  String get catchAToyRainbowBoxDesc;

  /// No description provided for @catchAToyRainbowBoxFull.
  ///
  /// In en, this message translates to:
  /// **'Catch A Toy x Rainbow Box is an indoor entertainment destination featuring claw machines, arcade-style games and colourful displays. It is suitable for children, families and visitors who enjoy casual gaming.'**
  String get catchAToyRainbowBoxFull;

  /// No description provided for @kekLokTongTitle.
  ///
  /// In en, this message translates to:
  /// **'Kek Look Tong Cave Temple & Zen Garden'**
  String get kekLokTongTitle;

  /// No description provided for @kekLokTongDesc.
  ///
  /// In en, this message translates to:
  /// **'A peaceful cave temple surrounded by limestone formations and a Zen garden.'**
  String get kekLokTongDesc;

  /// No description provided for @kekLokTongFull.
  ///
  /// In en, this message translates to:
  /// **'Kek Look Tong Cave Temple is located inside a limestone cave and opens into a scenic garden area. Visitors can enjoy religious architecture, natural rock formations, landscaped grounds and a calm atmosphere.'**
  String get kekLokTongFull;

  /// No description provided for @artOfOldTownTitle.
  ///
  /// In en, this message translates to:
  /// **'Art of Old Town'**
  String get artOfOldTownTitle;

  /// No description provided for @artOfOldTownDesc.
  ///
  /// In en, this message translates to:
  /// **'A collection of wall murals that tells stories about Ipoh\'s heritage and daily life.'**
  String get artOfOldTownDesc;

  /// No description provided for @artOfOldTownFull.
  ///
  /// In en, this message translates to:
  /// **'Art of Old Town features murals painted across heritage buildings in Ipoh Old Town. The artworks highlight local culture, traditional activities and memorable scenes, making the area popular for walking and photography.'**
  String get artOfOldTownFull;

  /// No description provided for @gunungLangTitle.
  ///
  /// In en, this message translates to:
  /// **'Gunung Lang Recreational Park'**
  String get gunungLangTitle;

  /// No description provided for @funtasyHouseTitle.
  ///
  /// In en, this message translates to:
  /// **'Funtasy House Trick Art'**
  String get funtasyHouseTitle;

  /// No description provided for @funtasyHouseDesc.
  ///
  /// In en, this message translates to:
  /// **'An interactive trick-art gallery with creative optical illusion displays.'**
  String get funtasyHouseDesc;

  /// No description provided for @funtasyHouseFull.
  ///
  /// In en, this message translates to:
  /// **'Funtasy House Trick Art offers interactive paintings and optical illusion scenes where visitors can become part of the artwork. It is designed for entertaining photos and family activities.'**
  String get funtasyHouseFull;

  /// No description provided for @dataranMedanStesenTitle.
  ///
  /// In en, this message translates to:
  /// **'Ipoh Station Square'**
  String get dataranMedanStesenTitle;

  /// No description provided for @dataranMedanStesenDesc.
  ///
  /// In en, this message translates to:
  /// **'A prominent public square located in front of the historic Ipoh Railway Station.'**
  String get dataranMedanStesenDesc;

  /// No description provided for @dataranMedanStesenFull.
  ///
  /// In en, this message translates to:
  /// **'Ipoh Station Square is an open public space near the iconic Ipoh Railway Station. The area is suitable for sightseeing, photography and appreciating the city\'s colonial architecture.'**
  String get dataranMedanStesenFull;

  /// No description provided for @bluebluePlaylandTitle.
  ///
  /// In en, this message translates to:
  /// **'Blueblue Playland'**
  String get bluebluePlaylandTitle;

  /// No description provided for @bluebluePlaylandDesc.
  ///
  /// In en, this message translates to:
  /// **'A family-friendly indoor playground designed for children\'s active play.'**
  String get bluebluePlaylandDesc;

  /// No description provided for @bluebluePlaylandFull.
  ///
  /// In en, this message translates to:
  /// **'Blueblue Playland provides indoor play equipment and activity spaces for children. It offers families a comfortable place for recreation, movement and supervised play.'**
  String get bluebluePlaylandFull;

  /// No description provided for @lubukTimahTitle.
  ///
  /// In en, this message translates to:
  /// **'Lubuk Timah Hot Spring'**
  String get lubukTimahTitle;

  /// No description provided for @lubukTimahDesc.
  ///
  /// In en, this message translates to:
  /// **'A natural hot spring and recreational area surrounded by greenery.'**
  String get lubukTimahDesc;

  /// No description provided for @lubukTimahFull.
  ///
  /// In en, this message translates to:
  /// **'Lubuk Timah Hot Spring is a nature-based destination offering warm spring water, forest scenery and a relaxed outdoor atmosphere. It is suitable for visitors looking for a simple recreational escape.'**
  String get lubukTimahFull;

  /// No description provided for @xParkSunwayTitle.
  ///
  /// In en, this message translates to:
  /// **'X Park Sunway City Ipoh'**
  String get xParkSunwayTitle;

  /// No description provided for @xParkSunwayDesc.
  ///
  /// In en, this message translates to:
  /// **'An outdoor activity park offering adventure and recreational experiences.'**
  String get xParkSunwayDesc;

  /// No description provided for @xParkSunwayFull.
  ///
  /// In en, this message translates to:
  /// **'X Park Sunway City Ipoh offers a range of outdoor and adventure-based activities. It is suitable for groups, families and visitors looking for active recreation in the Sunway City Ipoh area.'**
  String get xParkSunwayFull;

  /// No description provided for @tasikCerminTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasik Cermin 1'**
  String get tasikCerminTitle;

  /// No description provided for @tasikCerminDesc.
  ///
  /// In en, this message translates to:
  /// **'A hidden lake with calm water surrounded by dramatic limestone cliffs.'**
  String get tasikCerminDesc;

  /// No description provided for @tasikCerminFull.
  ///
  /// In en, this message translates to:
  /// **'Tasik Cermin, also known as Mirror Lake, is famous for its reflective water and limestone surroundings. The peaceful scenery makes it a popular destination for sightseeing and photography.'**
  String get tasikCerminFull;

  /// No description provided for @dataranMbiFoodCourtTitle.
  ///
  /// In en, this message translates to:
  /// **'Dataran MBI Food Court'**
  String get dataranMbiFoodCourtTitle;

  /// No description provided for @dataranMbiFoodCourtDesc.
  ///
  /// In en, this message translates to:
  /// **'A convenient food court offering a variety of local meals and drinks.'**
  String get dataranMbiFoodCourtDesc;

  /// No description provided for @dataranMbiFoodCourtFull.
  ///
  /// In en, this message translates to:
  /// **'Dataran MBI Food Court brings together different local food choices in one convenient location. It is suitable for visitors who want to sample casual Malaysian meals and refreshments.'**
  String get dataranMbiFoodCourtFull;

  /// No description provided for @meeRebusRamliTitle.
  ///
  /// In en, this message translates to:
  /// **'Restoran Mee Rebus Ramli - Taman Tasek Jaya'**
  String get meeRebusRamliTitle;

  /// No description provided for @meeRebusRamliDesc.
  ///
  /// In en, this message translates to:
  /// **'A local restaurant known for mee rebus and familiar Malaysian flavours.'**
  String get meeRebusRamliDesc;

  /// No description provided for @meeRebusRamliFull.
  ///
  /// In en, this message translates to:
  /// **'Restoran Mee Rebus Ramli at Taman Tasek Jaya is a local dining destination offering mee rebus and other Malaysian dishes. It is suitable for visitors looking for a casual local meal.'**
  String get meeRebusRamliFull;

  /// No description provided for @redBrickKitchenTitle.
  ///
  /// In en, this message translates to:
  /// **'Red Brick Kitchen'**
  String get redBrickKitchenTitle;

  /// No description provided for @redBrickKitchenDesc.
  ///
  /// In en, this message translates to:
  /// **'A comfortable dining spot with a modern and welcoming atmosphere.'**
  String get redBrickKitchenDesc;

  /// No description provided for @redBrickKitchenFull.
  ///
  /// In en, this message translates to:
  /// **'Red Brick Kitchen offers a casual dining environment with a modern interior and a selection of meals. It is suitable for families, friends and visitors looking for a relaxed place to eat in Ipoh.'**
  String get redBrickKitchenFull;

  /// No description provided for @networkInterruptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Interruption'**
  String get networkInterruptionTitle;

  /// No description provided for @networkLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get networkLastUpdated;

  /// No description provided for @networkInterruptionMessage.
  ///
  /// In en, this message translates to:
  /// **'{biller} is currently experiencing an interruption. Your transaction may be slow or may not go through. You may still continue with your payment.'**
  String networkInterruptionMessage(Object biller);

  /// No description provided for @electricAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your electricity account number.'**
  String get electricAccountRequired;

  /// No description provided for @electricAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get electricAccountNumber;

  /// No description provided for @electricAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'No electricity account record was found.'**
  String get electricAccountNotFound;

  /// No description provided for @electricAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'ENTER YOUR ELECTRICITY ACCOUNT NUMBER'**
  String get electricAccountTitle;

  /// No description provided for @electricAccountHint.
  ///
  /// In en, this message translates to:
  /// **'ENTER YOUR ELECTRICITY ACCOUNT NUMBER'**
  String get electricAccountHint;

  /// No description provided for @electricProductCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Product code is required.'**
  String get electricProductCodeRequired;

  /// No description provided for @electricAccountNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Account number is required.'**
  String get electricAccountNumberRequired;

  /// No description provided for @electricApiKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'The IIMMPACT API key is missing.'**
  String get electricApiKeyMissing;

  /// No description provided for @electricHmacSecretMissing.
  ///
  /// In en, this message translates to:
  /// **'The IIMMPACT HMAC secret is missing.'**
  String get electricHmacSecretMissing;

  /// No description provided for @electricInquiryHttpFailed.
  ///
  /// In en, this message translates to:
  /// **'Bill inquiry failed. HTTP {statusCode}.'**
  String electricInquiryHttpFailed(int statusCode);

  /// No description provided for @electricNoBillRecordFound.
  ///
  /// In en, this message translates to:
  /// **'No bill record was found.'**
  String get electricNoBillRecordFound;

  /// No description provided for @electricNoBillRecordForAccount.
  ///
  /// In en, this message translates to:
  /// **'No bill record was found for this account.'**
  String get electricNoBillRecordForAccount;

  /// No description provided for @electricInquiryTimeout.
  ///
  /// In en, this message translates to:
  /// **'The inquiry took too long. Please try again.'**
  String get electricInquiryTimeout;

  /// No description provided for @electricUnableToConnect.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the bill inquiry service.'**
  String get electricUnableToConnect;

  /// No description provided for @electricInvalidServerResponse.
  ///
  /// In en, this message translates to:
  /// **'The server returned an invalid response: {error}'**
  String electricInvalidServerResponse(String error);

  /// No description provided for @electricInquiryFailed.
  ///
  /// In en, this message translates to:
  /// **'Electric bill inquiry failed: {error}'**
  String electricInquiryFailed(String error);

  /// No description provided for @electricInvalidHmacBase64.
  ///
  /// In en, this message translates to:
  /// **'The IIMMPACT HMAC secret is not valid Base64.'**
  String get electricInvalidHmacBase64;

  /// No description provided for @electricEmptyApiResponse.
  ///
  /// In en, this message translates to:
  /// **'The API response was empty.'**
  String get electricEmptyApiResponse;

  /// No description provided for @electricInvalidJsonObject.
  ///
  /// In en, this message translates to:
  /// **'The API response is not a JSON object.'**
  String get electricInvalidJsonObject;

  /// No description provided for @electricInvalidAccount.
  ///
  /// In en, this message translates to:
  /// **'Invalid account number.'**
  String get electricInvalidAccount;

  /// No description provided for @electricInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get electricInformation;

  /// No description provided for @electricOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get electricOk;

  /// No description provided for @electricMaximumPayment.
  ///
  /// In en, this message translates to:
  /// **'The maximum payment amount is {amount}.'**
  String electricMaximumPayment(String amount);

  /// No description provided for @electricMinimumPayment.
  ///
  /// In en, this message translates to:
  /// **'The minimum payment amount is {amount}.'**
  String electricMinimumPayment(String amount);

  /// No description provided for @electricNoOutstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'This account does not have a positive outstanding amount.'**
  String get electricNoOutstandingBalance;

  /// No description provided for @electricEnterPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Payment Amount'**
  String get electricEnterPaymentAmount;

  /// No description provided for @electricUseKeypad.
  ///
  /// In en, this message translates to:
  /// **'Use the keypad below'**
  String get electricUseKeypad;

  /// No description provided for @electricKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Amount Keyboard'**
  String get electricKeyboard;

  /// No description provided for @electricClear.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get electricClear;

  /// No description provided for @electricDone.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get electricDone;

  /// No description provided for @electricCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get electricCancel;

  /// No description provided for @electricMinimumMaximum.
  ///
  /// In en, this message translates to:
  /// **'Minimum RM 1.00 • Maximum RM 10,000.00'**
  String get electricMinimumMaximum;

  /// No description provided for @electricBillPayment.
  ///
  /// In en, this message translates to:
  /// **'Electricity Bill Payment'**
  String get electricBillPayment;

  /// No description provided for @electricBillInformation.
  ///
  /// In en, this message translates to:
  /// **'Bill Information'**
  String get electricBillInformation;

  /// Actual outstanding balance returned by the utility provider. May be negative if the customer has a credit balance.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Amount'**
  String get electricOutstandingAmount;

  /// No description provided for @electricCreditBalance.
  ///
  /// In en, this message translates to:
  /// **'Credit Balance'**
  String get electricCreditBalance;

  /// No description provided for @electricDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get electricDueDate;

  /// No description provided for @electricCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get electricCustomerName;

  /// No description provided for @electricServiceAddress.
  ///
  /// In en, this message translates to:
  /// **'Service Address'**
  String get electricServiceAddress;

  /// No description provided for @electricCreditNotice.
  ///
  /// In en, this message translates to:
  /// **'This account currently has a credit balance.'**
  String get electricCreditNotice;

  /// No description provided for @electricSelectPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Amount'**
  String get electricSelectPaymentAmount;

  /// No description provided for @electricAmountInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap the amount box to type your payment amount, or use the − and + buttons.'**
  String get electricAmountInstruction;

  /// No description provided for @electricIncreaseDecreaseInstruction.
  ///
  /// In en, this message translates to:
  /// **'Press − to decrease or + to increase the amount by RM 1.00.'**
  String get electricIncreaseDecreaseInstruction;

  /// No description provided for @electricAmountLimit.
  ///
  /// In en, this message translates to:
  /// **'Minimum: RM 1.00 | Maximum: RM 10,000.00'**
  String get electricAmountLimit;

  /// No description provided for @electricFull.
  ///
  /// In en, this message translates to:
  /// **'FULL'**
  String get electricFull;

  /// No description provided for @electricOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get electricOrderSummary;

  /// No description provided for @electricServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get electricServiceFee;

  /// No description provided for @electricTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get electricTotalAmount;

  /// No description provided for @electricContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get electricContinue;

  /// No description provided for @electricPaymentUpdateTime.
  ///
  /// In en, this message translates to:
  /// **'Bill Update Time'**
  String get electricPaymentUpdateTime;

  /// No description provided for @electricUpdateInstant.
  ///
  /// In en, this message translates to:
  /// **'INSTANT'**
  String get electricUpdateInstant;

  /// No description provided for @electricUpdateWithinThreeDays.
  ///
  /// In en, this message translates to:
  /// **'Within 3 days'**
  String get electricUpdateWithinThreeDays;

  /// No description provided for @waterUpdateInstant.
  ///
  /// In en, this message translates to:
  /// **'INSTANT'**
  String get waterUpdateInstant;

  /// No description provided for @waterUpdateTwentyFourHours.
  ///
  /// In en, this message translates to:
  /// **'Within 24 hours'**
  String get waterUpdateTwentyFourHours;

  /// No description provided for @waterBillProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'BILL ELECTRIC OPTIONS'**
  String get waterBillProviderTitle;

  /// No description provided for @waterBillProviderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please select your water service provider'**
  String get waterBillProviderSubtitle;

  /// No description provided for @waterAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Water Account Number'**
  String get waterAccountTitle;

  /// No description provided for @waterAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your water account number'**
  String get waterAccountHint;

  /// No description provided for @networkLabel.
  ///
  /// In en, this message translates to:
  /// **'NETWORK'**
  String get networkLabel;

  /// No description provided for @networkStatusChecking.
  ///
  /// In en, this message translates to:
  /// **'CHECKING'**
  String get networkStatusChecking;

  /// No description provided for @networkStatusGood.
  ///
  /// In en, this message translates to:
  /// **'GOOD'**
  String get networkStatusGood;

  /// No description provided for @networkStatusSlow.
  ///
  /// In en, this message translates to:
  /// **'SLOW'**
  String get networkStatusSlow;

  /// No description provided for @networkStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get networkStatusUnknown;

  /// No description provided for @waterBillPayment.
  ///
  /// In en, this message translates to:
  /// **'Water Bill Payment'**
  String get waterBillPayment;

  /// No description provided for @waterBillInformation.
  ///
  /// In en, this message translates to:
  /// **'Water Bill Information'**
  String get waterBillInformation;

  /// Actual outstanding water account balance returned by the bill provider
  ///
  /// In en, this message translates to:
  /// **'Outstanding Amount'**
  String get waterOutstandingAmount;

  /// No description provided for @waterCreditBalance.
  ///
  /// In en, this message translates to:
  /// **'Credit Balance'**
  String get waterCreditBalance;

  /// No description provided for @waterDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get waterDueDate;

  /// No description provided for @waterCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get waterCustomerName;

  /// No description provided for @waterServiceAddress.
  ///
  /// In en, this message translates to:
  /// **'Service Address'**
  String get waterServiceAddress;

  /// No description provided for @waterCreditNotice.
  ///
  /// In en, this message translates to:
  /// **'This account currently has a credit balance.'**
  String get waterCreditNotice;

  /// No description provided for @waterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get waterAccountNumber;

  /// No description provided for @waterSelectPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Amount'**
  String get waterSelectPaymentAmount;

  /// No description provided for @waterOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get waterOrderSummary;

  /// Customer-facing service fee added to a water bill
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get waterServiceFee;

  /// No description provided for @waterTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get waterTotalAmount;

  /// No description provided for @waterPaymentUpdateTime.
  ///
  /// In en, this message translates to:
  /// **'Bill Update Time'**
  String get waterPaymentUpdateTime;

  /// No description provided for @waterUpdateWithinThreeDays.
  ///
  /// In en, this message translates to:
  /// **'Within 3 working days'**
  String get waterUpdateWithinThreeDays;

  /// No description provided for @waterContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get waterContinue;

  /// No description provided for @waterInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get waterInformation;

  /// No description provided for @waterOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get waterOk;

  /// No description provided for @waterEnterPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Payment Amount'**
  String get waterEnterPaymentAmount;

  /// No description provided for @waterCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get waterCancel;

  /// No description provided for @waterDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get waterDone;

  /// No description provided for @waterNoOutstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'There is no outstanding balance for this account.'**
  String get waterNoOutstandingBalance;

  /// No description provided for @waterMinimumPayment.
  ///
  /// In en, this message translates to:
  /// **'Minimum payment amount is {amount}.'**
  String waterMinimumPayment(String amount);

  /// No description provided for @waterMaximumPayment.
  ///
  /// In en, this message translates to:
  /// **'Maximum payment amount is {amount}.'**
  String waterMaximumPayment(String amount);

  /// No description provided for @waterProductCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Water provider product code is required.'**
  String get waterProductCodeRequired;

  /// No description provided for @waterAccountNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Water account number is required.'**
  String get waterAccountNumberRequired;

  /// No description provided for @waterAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the water account number.'**
  String get waterAccountRequired;

  /// No description provided for @waterAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Water bill account was not found.'**
  String get waterAccountNotFound;

  /// No description provided for @waterApiKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'The API key is missing.'**
  String get waterApiKeyMissing;

  /// No description provided for @waterHmacSecretMissing.
  ///
  /// In en, this message translates to:
  /// **'The HMAC secret is missing.'**
  String get waterHmacSecretMissing;

  /// No description provided for @waterInvalidHmacBase64.
  ///
  /// In en, this message translates to:
  /// **'The HMAC secret is not valid Base64.'**
  String get waterInvalidHmacBase64;

  /// No description provided for @waterInquiryTimeout.
  ///
  /// In en, this message translates to:
  /// **'The water bill inquiry timed out. Please try again.'**
  String get waterInquiryTimeout;

  /// No description provided for @waterUnableToConnect.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the water bill service.'**
  String get waterUnableToConnect;

  /// No description provided for @waterInvalidServerResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid server response: {error}'**
  String waterInvalidServerResponse(String error);

  /// No description provided for @waterInquiryFailed.
  ///
  /// In en, this message translates to:
  /// **'Water bill inquiry failed: {error}'**
  String waterInquiryFailed(String error);

  /// No description provided for @waterInquiryHttpFailed.
  ///
  /// In en, this message translates to:
  /// **'Water bill inquiry failed with status code {statusCode}.'**
  String waterInquiryHttpFailed(int statusCode);

  /// No description provided for @waterEmptyApiResponse.
  ///
  /// In en, this message translates to:
  /// **'The API returned an empty response.'**
  String get waterEmptyApiResponse;

  /// No description provided for @waterInvalidJsonObject.
  ///
  /// In en, this message translates to:
  /// **'The API response is not a valid JSON object.'**
  String get waterInvalidJsonObject;

  /// No description provided for @waterNoBillRecordFound.
  ///
  /// In en, this message translates to:
  /// **'No water bill record was found.'**
  String get waterNoBillRecordFound;

  /// No description provided for @waterInvalidAccount.
  ///
  /// In en, this message translates to:
  /// **'Invalid water account number.'**
  String get waterInvalidAccount;

  /// No description provided for @waterProviderTimeout.
  ///
  /// In en, this message translates to:
  /// **'The water provider is taking too long to respond. Please try again later.'**
  String get waterProviderTimeout;

  /// Label for the amount the customer needs to pay
  ///
  /// In en, this message translates to:
  /// **'Amount to Pay'**
  String get electricAmountToPay;

  /// Amount currently payable for the water bill
  ///
  /// In en, this message translates to:
  /// **'Amount to Pay'**
  String get waterAmountToPay;

  /// Title shown above the bill information review step
  ///
  /// In en, this message translates to:
  /// **'Check Your Details'**
  String get electricReviewDetailsTitle;

  /// Instruction shown on the bill information review step
  ///
  /// In en, this message translates to:
  /// **'Please confirm the bill information and account number before continuing.'**
  String get electricReviewDetailsSubtitle;

  /// Title shown above the water bill information review step
  ///
  /// In en, this message translates to:
  /// **'Check Your Details'**
  String get waterReviewDetailsTitle;

  /// Instruction shown on the water bill information review step
  ///
  /// In en, this message translates to:
  /// **'Please confirm the bill information and account number before continuing.'**
  String get waterReviewDetailsSubtitle;

  /// No description provided for @billbroadbandButton.
  ///
  /// In en, this message translates to:
  /// **'BROADBAND BILL'**
  String get billbroadbandButton;

  /// No description provided for @broadbandSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'SELECT BROADBAND BILL'**
  String get broadbandSelectionTitle;

  /// No description provided for @broadbandAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Broadband Account Number'**
  String get broadbandAccountTitle;

  /// No description provided for @broadbandAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your account number'**
  String get broadbandAccountHint;

  /// No description provided for @tmBroadbandButton.
  ///
  /// In en, this message translates to:
  /// **'TM BILL'**
  String get tmBroadbandButton;

  /// No description provided for @unbBroadbandButton.
  ///
  /// In en, this message translates to:
  /// **'UNIFI BILL'**
  String get unbBroadbandButton;

  /// No description provided for @electricProviderDiscount.
  ///
  /// In en, this message translates to:
  /// **'Provider Discount'**
  String get electricProviderDiscount;

  /// No description provided for @electricServiceAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get electricServiceAdjustment;

  /// Customer-facing adjustment deducted from a water bill
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get waterServiceAdjustment;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ms': return AppLocalizationsMs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
