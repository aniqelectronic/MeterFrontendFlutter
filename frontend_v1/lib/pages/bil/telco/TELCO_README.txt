# Telco Module

This folder contains the complete Telco service flow for the kiosk.

The Telco module currently supports two main services:

1. Telco Bill Payment / Postpaid
2. Mobile PIN / Prepaid PIN Purchase


============================================================
FOLDER STRUCTURE
============================================================

telco/
|
|-- README.txt
|-- ptelco3.dart
|-- ptelco4.dart
|
|-- services/
|   `-- ptelcoprovider3.dart
|
|-- postpaid/
|   |-- ptelcobill3.dart
|   `-- p5_telco_bill_result.dart
|
`-- mobilepin/
    |-- pmobilepin3.dart
    |-- pmobilepin4.dart
    `-- [Mobile PIN recipient number page]


NOTE:

Update the Mobile PIN recipient-number filename above if the
actual Dart filename is different.


============================================================
OVERALL TELCO FLOW
============================================================

TELCO
|
|-- TELCO BILL PAYMENT / POSTPAID
|   |
|   |-- Select Postpaid Provider
|   |-- Check Provider Network Status
|   |-- Enter Account / Mobile Number
|   |-- IIMMPACT Bill Inquiry
|   |-- Review Bill Information
|   |-- Select Payment Amount
|   |-- Apply Catalog Pricing
|   |-- DuitNow QR Payment
|   |-- Send Payment to IIMMPACT
|   |-- Wait for Final IIMMPACT Status
|   `-- Receipt
|
`-- MOBILE PIN
    |
    |-- Select Mobile PIN Provider
    |-- Check Provider Network Status
    |-- Load Product from IIMMPACT Catalog
    |-- Select PIN Denomination
    |-- Calculate Price Adjustment
    |-- Enter Recipient Mobile Number
    |-- DuitNow QR Payment
    |-- Send PIN Purchase to IIMMPACT
    |-- Wait for Final IIMMPACT Status
    |-- Retrieve PIN Information
    `-- Mobile PIN Receipt


============================================================
FILE: ptelco3.dart
============================================================

PURPOSE

Main Telco menu page.

This is the first page shown after the user selects the
Telco service from the kiosk.

It provides two options:

- Telco Bill Payment
- Mobile PIN


NAVIGATION

PTELCO3PAGE
|
|-- Bill Payment
|   `-- PTELCOBILL3PAGE
|
`-- Mobile PIN
    `-- PMOBILEPIN3PAGE


IMPORTANT

This page does not call IIMMPACT APIs directly.

It is only responsible for allowing the user to choose which
Telco service they want.


============================================================
FILE: services/ptelcoprovider3.dart
============================================================

PURPOSE

Shared Telco provider-selection page.

This page is reused by:

- Telco Postpaid Bill Payment
- Mobile PIN

It displays the available Telco providers as cards.


EXAMPLES

Celcom
Digi
U Mobile
RedOne
XOX
YES
Maxis
TuneTalk
Unifi Mobile
etc.


RESPONSIBILITIES

This page:

- Displays provider cards.
- Loads provider logos.
- Checks provider network/service status.
- Uses IimmpactNetworkStatusService.
- Shows network interruption warnings.
- Rechecks network status when a provider is selected.
- Decides which next page to open.


NAVIGATION LOGIC

Telco Bill Payment:

Provider
   |
   v
PTELCO4PAGE


Mobile PIN:

Provider
   |
   v
PMOBILEPIN4PAGE


IMPORTANT

Do not put:

- Bill inquiry logic
- Mobile PIN purchase logic
- DuitNow payment logic
- IIMMPACT transaction logic

directly inside this page.

This page should remain a shared provider-selection layer.


============================================================
POSTPAID BILL PAYMENT
============================================================


============================================================
FILE: postpaid/ptelcobill3.dart
============================================================

PURPOSE

Defines the available Telco Postpaid providers.


EXAMPLES

CB   = Celcom Postpaid
DB   = Digi Postpaid
RB   = RedOne Postpaid
UB   = U Mobile Postpaid
XB   = XOX Postpaid
YESB = Yes Postpaid


Each provider contains:

- IIMMPACT product code
- Display name
- Provider image URL
- UI accent colors


EXAMPLE

TelcoProviderItem(
  productCode: 'CB',
  name: 'Celcom Postpaid',
  imageUrl: 'https://dashboard.iimmpact.com/img/CB.png',
)


IMPORTANT

The IIMMPACT productCode is important because it is later
used for:

- Network status
- Bill inquiry
- Catalog pricing
- IIMMPACT payment


Do not change a product code unless the corresponding
IIMMPACT product code has changed.


============================================================
FILE: ptelco4.dart
============================================================

PURPOSE

Telco Postpaid account/mobile-number input page.

The user enters the Telco account number or mobile number
using a numeric keypad.


RESPONSIBILITIES

This page:

- Accepts numeric input only.
- Validates the entered number.
- Receives the selected provider/product code.
- Calls the Telco bill inquiry service.
- Handles invalid account responses.
- Handles API/service errors.
- Navigates to the Telco bill result/payment page when the
  account is valid.


BILL INQUIRY

The request uses the selected product code and entered
account number.


Example:

GET /v2/bill-presentment
?product=CB
&account=0123878585


Example valid response:

Account no is valid


Example invalid response:

Invalid account no


IMPORTANT

This page is for Telco Bill Payment only.

Do NOT send Mobile PIN users through this page.

The Mobile PIN recipient number is collected later in the
Mobile PIN flow and is NOT validated using bill-presentment.


============================================================
FILE: postpaid/p5_telco_bill_result.dart
============================================================

PURPOSE

Telco Postpaid bill review and payment-amount page.

This page is shown after a successful bill inquiry.


RESPONSIBILITIES

This page displays information such as:

- Telco provider
- Provider logo
- Account/mobile number
- Customer name when available
- Outstanding amount
- Due date when available

The user can then select how much they want to pay.


PAYMENT AMOUNT

The page may support:

- Minimum payment amount
- Custom numeric keypad
- Quick amount buttons
- Full outstanding amount
- Increase/decrease amount controls


CATALOG PRICING

This page uses pricing retrieved from:

GET /v2/catalog


The selected Telco product code is used to obtain its
catalog pricing.

Catalog pricing may contain:

discount
price_adjustment


The final customer payment amount is calculated using the
app's pricing logic.


IMPORTANT AMOUNTS

Keep these values separate:


billAmount

= Amount that belongs to the Telco bill/provider.


totalAmount

= Amount actually charged to the kiosk customer after
  applicable customer-facing pricing adjustment.


Do not automatically send totalAmount as the provider bill
amount if the additional amount belongs to the kiosk's
customer-facing adjustment.


PAYMENT FLOW

Bill Inquiry
    |
    v
P5 Telco Bill Result
    |
    v
Select Amount
    |
    v
Calculate Catalog Pricing
    |
    v
BilQrPaymentPage
    |
    v
DuitNow QR Payment
    |
    v
IIMMPACT Payment
    |
    v
Final Status
    |
    v
Receipt


============================================================
MOBILE PIN
============================================================


============================================================
FILE: mobilepin/pmobilepin3.dart
============================================================

PURPOSE

Defines the available Mobile PIN providers.


EXAMPLES

CP   = Celcom PIN
DIP  = Digi Internet PIN
DP   = Digi PIN
MCP  = HelloSim PIN
MP   = Maxis PIN
RP   = RedOne PIN
S    = SpeakOut PIN
TP   = TuneTalk PIN
UNP  = Unifi Mobile PIN
UP   = U Mobile PIN
XP   = XOX PIN
YESP = Yes PIN


Each provider contains:

- IIMMPACT product code
- Provider name
- Provider image URL
- UI colors


IMPORTANT

Mobile PIN does NOT use the Telco Postpaid bill account
keypad flow.

After selecting a provider, the user goes directly to:

PMOBILEPIN4PAGE


============================================================
FILE: mobilepin/pmobilepin4.dart
============================================================

PURPOSE

Mobile PIN denomination-selection and order-summary page.

This page retrieves the latest Mobile PIN product information
from:

GET /v2/catalog


CATALOG DATA USED

The page may read values such as:

code
name
image_url
note
is_active
processing_time
denomination
denomination_currency
pricing


============================================================
MOBILE PIN DENOMINATION
============================================================

PIN values must be taken from the IIMMPACT catalog.

Do NOT hard-code denomination buttons.


Example:

Celcom PIN

denomination:

5,10,30,50,100


The UI can automatically create:

RM5
RM10
RM30
RM50
RM100


Different providers may have different denominations.


============================================================
CURRENT MOBILE PIN QUANTITY RULE
============================================================

The kiosk currently allows only ONE Mobile PIN per
transaction.

Quantity selection is intentionally disabled/removed from
the customer flow for now.


CURRENT QUANTITY:

1 PIN per transaction


This simplifies:

- Payment handling
- IIMMPACT transaction handling
- PIN delivery
- Receipt presentation
- Transaction recovery
- Customer support


IMPORTANT

Do not remove the underlying architecture only because the
current UI supports one PIN.

Multiple PIN purchasing may be added again in the future.


============================================================
MOBILE PIN PRICING
============================================================

Mobile PIN pricing may contain:

pricing.discount

and:

pricing.price_adjustment


------------------------------------------------------------
PROVIDER DISCOUNT
------------------------------------------------------------

pricing.discount

is treated as internal provider/IIMMPACT pricing.

It is NOT used to reduce the customer-facing PIN
denomination.


Example:

Provider discount:
2%

PIN value:
RM10


The kiosk must NOT display:

RM9.80


The PIN denomination remains:

RM10.00


before customer-facing adjustment.


------------------------------------------------------------
PRICE ADJUSTMENT
------------------------------------------------------------

pricing.price_adjustment

is the customer-facing adjustment.

It may be:

- fixed
- percentage


If price_adjustment is:

- null
- unavailable
- zero

then no customer-facing adjustment should be added and the
adjustment row should not be displayed.


------------------------------------------------------------
FIXED ADJUSTMENT EXAMPLE
------------------------------------------------------------

PIN value:

RM10.00


Fixed adjustment:

+RM0.50


Customer total:

RM10.50


------------------------------------------------------------
PERCENTAGE ADJUSTMENT EXAMPLE
------------------------------------------------------------

PIN value:

RM10.00


Percentage multiplier:

1.0100


This means:

101%

or:

+1%


Calculation:

RM10.00 x 1.01

= RM10.10


Customer total:

RM10.10


============================================================
FUTURE: MULTIPLE PIN PURCHASES
============================================================

Multiple PIN purchasing is currently disabled.

If multiple PIN purchasing is restored in the future,
price_adjustment must be calculated separately for EVERY
PIN purchased.


Example:

PIN value:
RM10.00

Fixed adjustment:
RM0.50

Quantity:
3


Per PIN:

RM10.00 + RM0.50

= RM10.50


Total:

RM10.50 x 3

= RM31.50


DO NOT calculate:

RM30.00 + RM0.50

= RM30.50


That would incorrectly apply the adjustment only once.


============================================================
MOBILE PIN RECIPIENT NUMBER PAGE
============================================================

PURPOSE

Collects the recipient mobile number after the user selects
a PIN denomination and before payment.


IMPORTANT DIFFERENCE

The Mobile PIN recipient number is NOT used for:

GET /v2/bill-presentment


Mobile PIN is a purchase transaction, not a postpaid bill
inquiry.


The recipient number is eventually passed to IIMMPACT as
the:

account

field for the Mobile PIN transaction.


FLOW

Select PIN Provider
    |
    v
Select PIN Denomination
    |
    v
Calculate Customer Total
    |
    v
Enter Recipient Mobile Number
    |
    v
Validate Number
    |
    v
Continue to Payment


RESPONSIBILITIES

This page:

- Displays the selected Mobile PIN product.
- Displays the provider logo.
- Displays the selected PIN denomination.
- Displays the final customer payment amount.
- Provides a kiosk-friendly numeric keypad.
- Accepts the recipient mobile number.
- Validates the entered mobile number.
- Allows clear/backspace input.
- Passes the required Mobile PIN information to the
  payment page.


IIMMPACT ACCOUNT VALUE

For Mobile PIN:

account = recipient mobile number


Example:

product = CP
account = 0123456789
amount = 10.00


============================================================
SHARED PAYMENT FLOW
============================================================

Telco Postpaid and Mobile PIN use the shared bill QR
payment flow.

Payment page:

BilQrPaymentPage


The payment process contains TWO important transaction
stages:

1. Customer payment through DuitNow QR / PegePay
2. Provider transaction through IIMMPACT


These must not be treated as the same transaction.


============================================================
STAGE 1: DUITNOW QR PAYMENT
============================================================

The customer first pays the kiosk through DuitNow QR.

The payment flow may return information such as:

- Order number
- Bank transaction reference
- Payment status


A successful DuitNow QR payment means:

THE CUSTOMER HAS PAID THE KIOSK.


It does NOT automatically mean:

THE PROVIDER TRANSACTION HAS SUCCEEDED.


After DuitNow payment succeeds, the application must
continue with the corresponding IIMMPACT transaction.


============================================================
STAGE 2: IIMMPACT MAKE PAYMENT
============================================================

ENDPOINT

POST /v2/topup


PURPOSE

This is the unified IIMMPACT transaction endpoint used for
supported products.

The same endpoint is used for product types such as:

- Utility bills
- Telco Postpaid
- Mobile PIN
- Mobile reload
- Vouchers
- Other supported IIMMPACT products


============================================================
IIMMPACT PAYMENT REQUEST
============================================================

Important request fields:

refid
product
account
amount
remarks
extras


Example structure:

{
  "refid": "...",
  "product": "...",
  "account": "...",
  "amount": 10.00,
  "remarks": "...",
  "extras": {}
}


============================================================
TELCO POSTPAID IIMMPACT REQUEST
============================================================

Example:

product = CB

account =
customer's Telco account/mobile number

amount =
provider bill amount


The customer-facing payment total may contain additional
pricing adjustment.

Keep provider amount and customer total separate.


============================================================
MOBILE PIN IIMMPACT REQUEST
============================================================

Example:

product = CP

account =
recipient mobile number

amount =
selected PIN denomination


Example:

product = CP
account = 0123456789
amount = 10.00


IMPORTANT

For Mobile PIN:

The amount sent to IIMMPACT represents the selected PIN
denomination/provider transaction amount.

The kiosk customer-facing amount may contain an additional
price_adjustment.


Example:

PIN denomination:
RM10.00

Customer adjustment:
RM0.50

Customer pays:
RM10.50


IIMMPACT PIN transaction amount:

RM10.00


Keep these values separate.


============================================================
IIMMPACT AUTHENTICATION
============================================================

IIMMPACT requests require authenticated headers.

The integration uses values such as:

X-Api-Key
X-Timestamp
X-Nonce
X-Signature


X-Signature uses HMAC-SHA256 according to the IIMMPACT
authentication requirements.


IMPORTANT

Do not log or expose:

- API secret
- HMAC secret

to the customer UI.


If IIMMPACT returns:

HTTP 401
invalid_signature


check the HMAC canonical string/signature implementation,
timestamp, nonce, request body hash, API key, and secret.


============================================================
REFID / IDEMPOTENCY
============================================================

Every IIMMPACT transaction uses a refid.

The refid is used as the unique transaction reference for
the provider transaction.


Current kiosk refid format follows the terminal identifier
and transaction timestamp.


Example:

TIP-TEST03-260815113444891


IMPORTANT

IIMMPACT transactions are idempotent using refid.


For the SAME transaction:

ALWAYS reuse the SAME refid.


This applies when:

- Initial transaction returns Accepted
- Initial transaction returns Processing
- Checking transaction status
- Recovering the status of an existing transaction


Do NOT generate a new refid just because the existing
transaction is still processing.


Generating another refid may create another transaction.


============================================================
IIMMPACT STATUS VALUES
============================================================

Possible transaction status values include:


Accepted

Transaction has been created but is not final.


Processing

Transaction is still being processed.


Succesful

Transaction completed successfully.

IMPORTANT:

IIMMPACT intentionally spells the success status:

Succesful

with a single "s" after "Succe".

The application must support this exact API value.


Failed

Transaction failed.


Refund

Transaction was voided/refunded.


============================================================
IIMMPACT HTTP 400 VS HTTP 200 FAILED
============================================================

This distinction is important.


HTTP 400 + Failed

means:

- Pre-transaction validation failed.
- No provider transaction was created.
- refid is NOT consumed.
- Input may be corrected.
- Same refid can be retried after correcting the problem.


Examples may include:

Invalid_Denomination
Insufficient_Balance
Invalid account
Invalid product


HTTP 200 + Failed

means:

- Provider transaction was created.
- Provider transaction failed.
- Failure is final.
- Do NOT treat it as a simple validation retry.


============================================================
IIMMPACT POLLING
============================================================

When IIMMPACT returns:

Accepted

or:

Processing


the application should check the transaction again using
the SAME:

refid
product
account
amount
remarks
extras


Recommended behavior:

Wait a short period and re-query the same transaction.


IMPORTANT

Do NOT:

- Generate a new refid.
- Ask the customer to pay DuitNow again.
- Create another provider transaction.

while checking the status of an existing transaction.


============================================================
MOBILE PIN IIMMPACT RESULT
============================================================

A successful Mobile PIN transaction may return values such
as:

status
statusCode
product
productName
account
amount
refid
timestamp
sn
pin
expiry
note
voucherlink


============================================================
IMPORTANT MOBILE PIN RESULT VALUES
============================================================

pin

= PIN/voucher code issued by the provider.


sn

= Provider/operator serial number.


expiry

= PIN/voucher expiry date when supplied.


note

= Provider instructions for using/redeeming the PIN.


voucherlink

= Voucher/redeem link when supplied by the product.


============================================================
MOBILE PIN SUCCESS RULE
============================================================

Do NOT navigate to a successful Mobile PIN receipt only
because the DuitNow QR payment succeeded.


The correct sequence is:

DuitNow Payment Successful
        |
        v
Send Mobile PIN Transaction to IIMMPACT
        |
        v
Accepted / Processing?
        |
       YES
        |
        v
Poll Same IIMMPACT Transaction
        |
        v
Succesful
        |
        v
Retrieve PIN Information
        |
        v
Mobile PIN Receipt


The PIN receipt should only be treated as successful when
the provider transaction reaches the appropriate successful
final status.


============================================================
MOBILE PIN DATA PRESERVATION
============================================================

After a successful Mobile PIN transaction, preserve the
important IIMMPACT response values before navigating away
from the payment flow.


Important values include:

- Product code
- Product name
- Recipient mobile number
- PIN denomination
- IIMMPACT refid
- IIMMPACT timestamp
- Serial number
- PIN code
- Expiry
- Note
- Voucher link when available


These values may be required by the receipt.


============================================================
SHARED BILL RECEIPT
============================================================

The existing bill receipt page is reused for multiple
transaction types.

Current receipt modes include:

1. Standard bill receipt
2. Telco Postpaid receipt
3. Mobile PIN receipt


The old receipt behavior should remain available for
existing bill types.

Telco-specific functionality is added without breaking the
existing receipt flow.


============================================================
STANDARD BILL RECEIPT
============================================================

Used by existing supported bill-payment services.

Customer-facing information may include:

- Provider
- Account
- Payment amount
- Payment method
- Payment date/time
- Bank transaction reference
- Other relevant bill information


============================================================
TELCO POSTPAID RECEIPT
============================================================

Telco Postpaid reuses the shared receipt page with
Telco-specific information.

Customer-facing information may include:

- Telco provider
- Product code
- Account/mobile number
- Payment method
- Payment date/time
- Bank transaction reference
- Total amount paid


============================================================
MOBILE PIN RECEIPT
============================================================

Mobile PIN also reuses the shared receipt page.

The receipt uses the successful IIMMPACT transaction result.


Customer-facing information may include:

- Product code
- PIN value
- Payment method
- Payment date/time
- Bank transaction reference
- Serial number
- PIN code
- Expiry date
- Provider instructions
- Total amount paid


============================================================
CURRENT RECEIPT DISPLAY RULES
============================================================

ORDER NUMBER / NOMBOR PESANAN

Order Number is currently hidden from ALL customer-facing
receipt types.

This includes:

- Standard bill receipt
- Telco Postpaid receipt
- Mobile PIN receipt


IMPORTANT

The orderNo value should still be kept internally.

Do NOT remove:

orderNo

from the receipt data model simply because it is hidden
from the UI.

It may still be useful for:

- Backend records
- Payment reconciliation
- PegePay transaction tracking
- Debugging
- Support
- Receipt generation


------------------------------------------------------------
MOBILE PIN TRANSACTION REFERENCE
------------------------------------------------------------

The IIMMPACT transaction reference is currently hidden from
the customer-facing Mobile PIN receipt.

The value should still be retained internally.


------------------------------------------------------------
MOBILE PIN "PIN 1" LABEL
------------------------------------------------------------

The:

PIN 1

label is currently hidden.

Because only ONE PIN can currently be purchased per
transaction, displaying "PIN 1" is unnecessary.


------------------------------------------------------------
MOBILE PIN QUANTITY
------------------------------------------------------------

Quantity is currently not displayed on the Mobile PIN
receipt because purchases are limited to:

1 PIN per transaction.


------------------------------------------------------------
AUTO HOME
------------------------------------------------------------

Automatic return-to-home countdown is currently disabled /
commented.


The HOME button remains available.

The customer can manually press HOME after viewing the
receipt.


============================================================
IMPORTANT RECEIPT RULE
============================================================

Hiding a value from the receipt UI does NOT mean that the
value should be removed from the transaction model.


For example:

orderNo
refId


may remain internally even when they are not displayed.


UI visibility and transaction data storage are separate
concerns.


============================================================
IIMMPACT SERVICES USED
============================================================


------------------------------------------------------------
NETWORK STATUS
------------------------------------------------------------

Service:

IimmpactNetworkStatusService


Purpose:

Check whether a selected Telco product/provider is healthy
or currently experiencing interruption.


Used by:

Shared Telco provider-selection page.


------------------------------------------------------------
CATALOG
------------------------------------------------------------

Service:

IimmpactCatalogService


Endpoint:

GET /v2/catalog


Used for:

- Telco pricing
- Mobile PIN denominations
- Mobile PIN product information
- Product image
- Product note
- Active status
- Price adjustment


------------------------------------------------------------
BILL PRESENTMENT
------------------------------------------------------------

Endpoint:

GET /v2/bill-presentment


Used for:

Telco Postpaid Bill Payment


Example:

GET /v2/bill-presentment
?product=CB
&account=0123878585


Purpose:

- Validate the Telco account/mobile number.
- Retrieve available bill information.


IMPORTANT

Do NOT use bill-presentment for Mobile PIN recipient-number
input.


------------------------------------------------------------
MAKE PAYMENT / TOPUP
------------------------------------------------------------

Endpoint:

POST /v2/topup


Used for:

- Telco Postpaid provider transaction
- Mobile PIN purchase
- Other supported IIMMPACT transactions


Purpose:

Create and check the final status of IIMMPACT transactions.


============================================================
LOCALIZATION
============================================================

All customer-visible Telco UI text should use:

AppLocalizations.of(context)!


Supported kiosk languages:

- English
- Bahasa Melayu
- Malaysian Mandarin
- Tamil


Do not hard-code customer-facing English text inside Telco
pages if an ARB translation can be used instead.


Provider names and API-returned values do not normally need
translation.


Examples:

Celcom Postpaid
Celcom Pin
Digi Pin
0123878585
RM 10.00


============================================================
CONFIGURATION
============================================================

IIMMPACT configuration is currently stored separately from
the Telco UI pages.

Configuration includes values such as:

- IIMMPACT API key
- IIMMPACT HMAC secret
- IIMMPACT base URL
- Terminal ID


Do not duplicate API credentials inside individual Telco
pages.


The Telco UI should call the appropriate service layer
instead.


============================================================
SECURITY RULES
============================================================

1. Do not display IIMMPACT API credentials in the UI.

2. Do not display HMAC secrets in the UI.

3. Avoid printing secrets in production logs.

4. Keep payment/provider API logic inside service classes
   instead of UI widgets when possible.

5. Reuse the same IIMMPACT refid when checking the same
   transaction.

6. Do not create another customer payment simply because
   IIMMPACT is still Processing.

7. Preserve transaction references internally for
   reconciliation and troubleshooting.


============================================================
IMPORTANT DEVELOPMENT RULES
============================================================

When modifying this module:

1. Keep Postpaid Bill Payment and Mobile PIN flows separate.

2. Do not send Mobile PIN users through the Postpaid
   account-number keypad.

3. Use the IIMMPACT product code as the main provider
   product identifier.

4. Load Mobile PIN denominations from /v2/catalog.

5. Do not hard-code Mobile PIN denominations.

6. Keep provider discount internal.

7. Apply price_adjustment only when available.

8. Keep provider transaction amount and customer total
   separate.

9. Mobile PIN currently supports only ONE PIN per
   transaction.

10. Collect the Mobile PIN recipient mobile number after
    denomination selection.

11. Use the recipient mobile number as the Mobile PIN
    IIMMPACT account value.

12. Do not call bill-presentment for Mobile PIN.

13. Use ARB localization for all customer-facing text.

14. Keep provider/network-status checking in the shared
    provider-selection page.

15. Do not place payment API logic directly inside the
    provider-selection page.

16. After DuitNow success, complete the required IIMMPACT
    transaction.

17. Do not consider Mobile PIN complete until IIMMPACT
    returns the appropriate final successful status.

18. Preserve returned PIN, serial number, expiry and note
    for the receipt.

19. Reuse the same refid when polling an existing IIMMPACT
    transaction.

20. Do not expose internal API/HMAC secrets.

21. Keep orderNo internally even though Nombor Pesanan is
    hidden from the receipt UI.

22. Do not break the existing standard bill receipt while
    adding Telco-specific receipt behavior.


============================================================
CURRENT DEVELOPMENT STATUS
============================================================


TELCO POSTPAID

Provider Selection        : DONE
Network Status Check      : DONE
Account Number Input      : DONE
Bill Inquiry              : DONE
Bill Review               : DONE
Catalog Pricing           : DONE
Payment Amount Selection  : DONE
DuitNow QR Payment        : DONE
IIMMPACT Payment          : DONE
IIMMPACT Status Handling  : DONE
Shared Receipt            : DONE


MOBILE PIN

Provider Selection        : DONE
Network Status Check      : DONE
Catalog Loading           : DONE
Dynamic Denominations     : DONE
Single PIN Purchase       : DONE
Price Adjustment          : DONE
Order Summary             : DONE
Recipient Mobile Number   : DONE
Numeric Keypad            : DONE
DuitNow QR Payment        : DONE
IIMMPACT PIN Purchase     : DONE
IIMMPACT Status Handling  : DONE
PIN Result Handling       : DONE
Mobile PIN Receipt        : DONE


============================================================
CURRENT MOBILE PIN LIMITATION
============================================================

Only ONE Mobile PIN can currently be purchased per
transaction.

Multiple PIN quantity support may be restored in a future
version.


If multiple PIN support is restored:

- Apply price adjustment to every PIN.
- Preserve every returned PIN result.
- Display every PIN clearly on the receipt.
- Ensure each PIN result can be reconciled to the
  transaction.


============================================================
QUICK REFERENCE
============================================================

ptelco3.dart

-> Main Telco service menu.


services/ptelcoprovider3.dart

-> Shared provider selection and network-status checking.


postpaid/ptelcobill3.dart

-> Telco Postpaid provider definitions.


ptelco4.dart

-> Telco Postpaid account/mobile-number input and bill
   inquiry.


postpaid/p5_telco_bill_result.dart

-> Telco Postpaid bill review, payment amount selection and
   catalog pricing.


mobilepin/pmobilepin3.dart

-> Mobile PIN provider definitions.


mobilepin/pmobilepin4.dart

-> Mobile PIN denomination selection, catalog loading,
   pricing and order summary.


Mobile PIN Recipient Number Page

-> Collects and validates the recipient mobile number before
   payment.


BilQrPaymentPage

-> Shared DuitNow QR payment flow and IIMMPACT transaction
   execution.


Shared Bill Receipt Page

-> Displays standard bill, Telco Postpaid and Mobile PIN
   receipt information.


============================================================
TRANSACTION FLOW QUICK REFERENCE
============================================================


TELCO POSTPAID

Provider
   |
   v
Postpaid Account Input
   |
   v
Bill Presentment
   |
   v
Bill Review
   |
   v
Amount Selection
   |
   v
Catalog Pricing
   |
   v
DuitNow QR
   |
   v
Customer Payment Successful
   |
   v
POST /v2/topup
   |
   v
IIMMPACT Final Status
   |
   v
Receipt


MOBILE PIN

Provider
   |
   v
Catalog
   |
   v
PIN Denomination
   |
   v
Price Adjustment
   |
   v
Recipient Mobile Number
   |
   v
DuitNow QR
   |
   v
Customer Payment Successful
   |
   v
POST /v2/topup
   |
   v
Accepted / Processing
   |
   v
Poll Same refid
   |
   v
Succesful
   |
   v
PIN + Serial + Expiry + Note
   |
   v
Mobile PIN Receipt


============================================================
DEVELOPER NOTE
============================================================

For the complete Telco flow, always check this README before
changing:

- Navigation
- Provider codes
- Catalog handling
- Pricing
- Mobile PIN denomination logic
- Recipient mobile-number logic
- DuitNow payment
- IIMMPACT payment
- Transaction polling
- Receipt behavior


Recommended comment at the top of Telco Dart files:

// See lib/pages/bil/telco/README.txt for the complete
// Telco module flow.


============================================================
END OF TELCO README
============================================================