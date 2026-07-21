class CatalogPricing {
  final CatalogDiscount? providerDiscount;
  final CatalogPriceAdjustment? priceAdjustment;

  const CatalogPricing({
    this.providerDiscount,
    this.priceAdjustment,
  });

  const CatalogPricing.empty()
      : providerDiscount = null,
        priceAdjustment = null;

  factory CatalogPricing.fromCatalogResponse({
    required Map<String, dynamic> catalogJson,
    required String productCode,
  }) {
    final dynamic productsValue =
        catalogJson['products'];

    if (productsValue is! Map) {
      return const CatalogPricing.empty();
    }

    final String normalizedProductCode =
        productCode.trim().toUpperCase();

    final dynamic productValue =
        productsValue[normalizedProductCode];

    if (productValue is! Map) {
      return const CatalogPricing.empty();
    }

    final dynamic pricingValue =
        productValue['pricing'];

    if (pricingValue is! Map) {
      return const CatalogPricing.empty();
    }

    return CatalogPricing(
      providerDiscount:
          CatalogDiscount.fromJson(
        pricingValue['discount'],
      ),
      priceAdjustment:
          CatalogPriceAdjustment.fromJson(
        pricingValue['price_adjustment'],
      ),
    );
  }

  bool get hasProviderDiscount {
    return providerDiscount != null &&
        providerDiscount!.isValid &&
        providerDiscount!.numericValue != 0;
  }

  bool get hasPriceAdjustment {
    return priceAdjustment != null &&
        priceAdjustment!.isValid &&
        priceAdjustment!.hasEffect;
  }
}

class CatalogDiscount {
  final String type;
  final dynamic rawValue;

  const CatalogDiscount({
    required this.type,
    required this.rawValue,
  });

  /// This must be a static nullable method.
  /// A factory constructor cannot return CatalogDiscount?.
  static CatalogDiscount? fromJson(
    dynamic json,
  ) {
    if (json is! Map) {
      return null;
    }

    final String type =
        '${json['type'] ?? ''}'
            .trim()
            .toLowerCase();

    final dynamic value = json['value'];

    if (type.isEmpty || value == null) {
      return null;
    }

    final CatalogDiscount discount =
        CatalogDiscount(
      type: type,
      rawValue: value,
    );

    if (!discount.isValid) {
      return null;
    }

    return discount;
  }

  double get numericValue {
    return _parseNumber(rawValue);
  }

  bool get isPercentage {
    return type == 'percentage';
  }

  bool get isFixed {
    return type == 'fixed' ||
        type == 'fixed_amount' ||
        type == 'amount';
  }

  bool get isValid {
    return isPercentage || isFixed;
  }

  bool get hasDiscount {
    return isValid && numericValue != 0;
  }

  double calculateDiscount(
    double amount,
  ) {
    final double safeAmount =
        _nonNegative(amount);

    if (safeAmount <= 0 || !isValid) {
      return 0;
    }

    double discountAmount = 0;

    if (isPercentage) {
      final double percentage =
          numericValue.abs();

      discountAmount =
          safeAmount * (percentage / 100);
    } else if (isFixed) {
      discountAmount =
          numericValue.abs();
    }

    // A discount cannot be larger than
    // the bill amount.
    return discountAmount
        .clamp(0.0, safeAmount)
        .toDouble();
  }

  String get displayValue {
    if (isPercentage) {
      return '${_trimZeros(
        numericValue.abs(),
      )}%';
    }

    if (isFixed) {
      return 'RM ${numericValue.abs().toStringAsFixed(2)}';
    }

    return '-';
  }

  String get displayLabel {
    if (isPercentage) {
      return 'Provider Discount '
          '(${displayValue})';
    }

    if (isFixed) {
      return 'Provider Discount';
    }

    return 'Provider Discount';
  }
}

class CatalogPriceAdjustment {
  final String type;
  final dynamic rawValue;

  const CatalogPriceAdjustment({
    required this.type,
    required this.rawValue,
  });

  /// This must also be a static nullable method.
  static CatalogPriceAdjustment? fromJson(
    dynamic json,
  ) {
    if (json is! Map) {
      return null;
    }

    final String type =
        '${json['type'] ?? ''}'
            .trim()
            .toLowerCase();

    final dynamic value = json['value'];

    if (type.isEmpty || value == null) {
      return null;
    }

    final CatalogPriceAdjustment adjustment =
        CatalogPriceAdjustment(
      type: type,
      rawValue: value,
    );

    if (!adjustment.isValid) {
      return null;
    }

    return adjustment;
  }

  double get numericValue {
    return _parseNumber(rawValue);
  }

  bool get isPercentage {
    return type == 'percentage';
  }

  bool get isFixed {
    return type == 'fixed' ||
        type == 'fixed_amount' ||
        type == 'amount';
  }

  bool get isValid {
    return isPercentage || isFixed;
  }

  bool get rawValueContainsPercent {
    return rawValue is String &&
        rawValue
            .toString()
            .trim()
            .contains('%');
  }

  /// IIMMPACT example:
  ///
  /// "type": "percentage",
  /// "value": 0.9000
  ///
  /// This is treated as a multiplier:
  /// 0.9000 = customer pays 90%
  /// = effective 10% discount.
  bool get isMultiplier {
    final double value = numericValue;

    return isPercentage &&
        !rawValueContainsPercent &&
        value >= 0 &&
        value <= 2;
  }

  bool get hasEffect {
    if (!isValid) {
      return false;
    }

    if (isFixed) {
      return numericValue != 0;
    }

    if (isMultiplier) {
      return numericValue != 1;
    }

    return numericValue != 0;
  }

  double get effectivePercentage {
    if (!isPercentage) {
      return 0;
    }

    if (isMultiplier) {
      return (numericValue - 1) * 100;
    }

    return numericValue;
  }

  PriceAdjustmentResult apply(
    double amount,
  ) {
    final double safeAmount =
        _nonNegative(amount);

    if (safeAmount <= 0 ||
        !isValid ||
        !hasEffect) {
      return PriceAdjustmentResult.none(
        safeAmount,
      );
    }

    if (isFixed) {
      final double requestedAdjustment =
          numericValue;

      final double amountAfter =
          _nonNegative(
        safeAmount + requestedAdjustment,
      );

      final double actualAdjustment =
          amountAfter - safeAmount;

      return PriceAdjustmentResult(
        amountBefore: safeAmount,
        adjustmentAmount:
            actualAdjustment,
        amountAfter: amountAfter,
        displayRate: null,
        isMultiplier: false,
      );
    }

    if (isPercentage) {
      if (isMultiplier) {
        final double amountAfter =
            _nonNegative(
          safeAmount * numericValue,
        );

        return PriceAdjustmentResult(
          amountBefore: safeAmount,
          adjustmentAmount:
              amountAfter - safeAmount,
          amountAfter: amountAfter,
          displayRate:
              effectivePercentage,
          isMultiplier: true,
        );
      }

      // Examples:
      // "2%"  = add 2%
      // "-2%" = discount 2%
      final double amountAfter =
          _nonNegative(
        safeAmount *
            (1 + numericValue / 100),
      );

      return PriceAdjustmentResult(
        amountBefore: safeAmount,
        adjustmentAmount:
            amountAfter - safeAmount,
        amountAfter: amountAfter,
        displayRate: numericValue,
        isMultiplier: false,
      );
    }

    return PriceAdjustmentResult.none(
      safeAmount,
    );
  }

  String get displayValue {
    if (isFixed) {
      final String sign =
          numericValue >= 0 ? '+' : '-';

      return '$sign RM '
          '${numericValue.abs().toStringAsFixed(2)}';
    }

    if (isPercentage) {
      final double percentage =
          effectivePercentage;

      final String sign =
          percentage >= 0 ? '+' : '-';

      return '$sign'
          '${_trimZeros(percentage.abs())}%';
    }

    return '-';
  }

  String get displayLabel {
    if (isPercentage) {
      final double percentage =
          effectivePercentage;

      if (percentage < 0) {
        return 'Service Discount '
            '(${_trimZeros(percentage.abs())}%)';
      }

      if (percentage > 0) {
        return 'Service Fee '
            '(${_trimZeros(percentage)}%)';
      }
    }

    if (isFixed) {
      if (numericValue < 0) {
        return 'Service Discount';
      }

      if (numericValue > 0) {
        return 'Service Fee';
      }
    }

    return 'Service Adjustment';
  }
}

class PriceAdjustmentResult {
  final double amountBefore;
  final double adjustmentAmount;
  final double amountAfter;

  /// Effective percentage.
  ///
  /// Examples:
  /// -10 means 10% discount.
  /// 5 means 5% surcharge.
  final double? displayRate;

  final bool isMultiplier;

  const PriceAdjustmentResult({
    required this.amountBefore,
    required this.adjustmentAmount,
    required this.amountAfter,
    required this.displayRate,
    required this.isMultiplier,
  });

  factory PriceAdjustmentResult.none(
    double amount,
  ) {
    final double safeAmount =
        _nonNegative(amount);

    return PriceAdjustmentResult(
      amountBefore: safeAmount,
      adjustmentAmount: 0,
      amountAfter: safeAmount,
      displayRate: null,
      isMultiplier: false,
    );
  }

  bool get hasAdjustment {
    return adjustmentAmount.abs() > 0.000001;
  }

  bool get isDiscount {
    return adjustmentAmount < 0;
  }

  bool get isSurcharge {
    return adjustmentAmount > 0;
  }
}

class BillPricingResult {
  final double billAmount;

  final double providerDiscountAmount;

  final double amountAfterProviderDiscount;

  /// Negative means discount.
  /// Positive means fee/surcharge.
  final double platformAdjustmentAmount;

  final double totalAmount;

  const BillPricingResult({
    required this.billAmount,
    required this.providerDiscountAmount,
    required this.amountAfterProviderDiscount,
    required this.platformAdjustmentAmount,
    required this.totalAmount,
  });

  factory BillPricingResult.calculate({
    required double billAmount,
    required CatalogPricing pricing,
  }) {
    final double safeBillAmount =
        _nonNegative(billAmount);

    // This is the merchant/provider margin.
    // It must NOT reduce the customer's bill.
    final double providerMargin =
        pricing.providerDiscount
                ?.calculateDiscount(
                  safeBillAmount,
                ) ??
            0;

    // Customer service fee/adjustment is applied
    // directly to the original bill amount.
    final PriceAdjustmentResult adjustmentResult =
        pricing.priceAdjustment?.apply(
              safeBillAmount,
            ) ??
            PriceAdjustmentResult.none(
              safeBillAmount,
            );

    return BillPricingResult(
      billAmount: safeBillAmount,

      // Keep this internally as the merchant margin.
      // Do not show it as a customer discount.
      providerDiscountAmount: providerMargin,

      // Customer bill remains unchanged by merchant margin.
      amountAfterProviderDiscount: safeBillAmount,

      platformAdjustmentAmount:
          adjustmentResult.adjustmentAmount,

      totalAmount:
          adjustmentResult.amountAfter,
    );
  }

  bool get hasProviderDiscount {
    return providerDiscountAmount.abs() >
        0.000001;
  }

  bool get hasPlatformAdjustment {
    return platformAdjustmentAmount.abs() >
        0.000001;
  }

  bool get platformAdjustmentIsDiscount {
    return platformAdjustmentAmount < 0;
  }

  bool get platformAdjustmentIsFee {
    return platformAdjustmentAmount > 0;
  }
}

double _parseNumber(
  dynamic value,
) {
  if (value == null) {
    return 0;
  }

  if (value is num) {
    return value.toDouble();
  }

  final String original =
      value.toString().trim().toLowerCase();

  final bool isCentValue =
      original.contains('cent') ||
      original.contains('sen');

  final String cleaned = original
      .replaceAll('%', '')
      .replaceAll(
        RegExp(
          'rm',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll('cent', '')
      .replaceAll('sen', '')
      .replaceAll(',', '')
      .replaceAll(' ', '')
      .replaceAll(
        RegExp(r'[^0-9.\-]'),
        '',
      );

  final double parsed =
      double.tryParse(cleaned) ?? 0;

  if (isCentValue) {
    return parsed / 100;
  }

  return parsed;
}

double _nonNegative(
  num value,
) {
  return value
      .clamp(0.0, double.infinity)
      .toDouble();
}

String _trimZeros(
  double value,
) {
  final String fixed =
      value.toStringAsFixed(4);

  return fixed.replaceFirst(
    RegExp(r'\.?0+$'),
    '',
  );
}