import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'pip_iimmpact_catalog_snapshot.dart';

/// Catalog metadata is separate from the kiosk/branch where the sale occurs.
class PipIimmpactProduct {
  const PipIimmpactProduct({
    required this.productCode,
    required this.productName,
    required this.groupId,
    required this.groupName,
    required this.categoryId,
    required this.categoryName,
  });

  final String productCode;
  final String productName;
  final String groupId;
  final String groupName;
  final String categoryId;
  final String categoryName;

  Map<String, dynamic> toJson({
    required double providerAmount,
    required double gatewayAmount,
    required String pegepayOrderNo,
    required bool qrTesting,
  }) {
    return <String, dynamic>{
      'catalog_group_id': groupId,
      'catalog_group_name': groupName,
      'catalog_category_id': categoryId,
      'catalog_category_name': categoryName,
      'product_code': productCode,
      'product_name': productName.length > 120
          ? productName.substring(0, 120)
          : productName,
      'provider_amount': providerAmount.toStringAsFixed(2),
      'gateway_amount': gatewayAmount.toStringAsFixed(2),
      'pegepay_order_no': pegepayOrderNo,
      'qr_testing': qrTesting,
    };
  }
}

/// Reads the authoritative IIMMPACT catalog, with the 2026-11-18 supplied
/// catalog as a fallback if the catalog endpoint is temporarily unavailable.
/// No catalog request is required before opening the PegePay QR window.
class PipIimmpactCatalogLookup {
  PipIimmpactCatalogLookup._();

  static Future<Map<String, PipIimmpactProduct>>? _cache;
  static const Duration _timeout = Duration(seconds: 6);
  static const Uuid _uuid = Uuid();

  static Future<PipIimmpactProduct> resolve({
    required String productCode,
    required String fallbackName,
  }) async {
    final code = productCode.trim().toUpperCase();
    final snapshot = _fallback(code, fallbackName);
    try {
      final products = await (_cache ??= _load());
      return products[code] ?? snapshot;
    } catch (error) {
      debugPrint('[PIP BIL] Catalog lookup unavailable: $error');
      return snapshot;
    }
  }

  static PipIimmpactProduct _fallback(String code, String fallbackName) {
    final record = PipIimmpactCatalogSnapshot.products[code];
    return PipIimmpactProduct(
      productCode: code,
      productName: record?[0] ?? fallbackName.trim(),
      groupId: record?[1] ?? 'UNKNOWN',
      groupName: record?[2] ?? 'Unknown',
      categoryId: record?[3] ?? 'UNKNOWN',
      categoryName: record?[4] ?? 'Unknown',
    );
  }

  static Future<Map<String, PipIimmpactProduct>> _load() async {
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final nonce = 'pip-catalog-$timestamp-${_uuid.v4()}';
    final bodyHash = base64Encode(sha256.convert(utf8.encode('')).bytes);
    final canonical = 'v1:$timestamp:$nonce:GET::$bodyHash';
    final secret = Data.iimmpactHmacSecret.trim();
    List<int> secretBytes;
    try {
      secretBytes = base64Decode(base64.normalize(secret));
    } catch (_) {
      secretBytes = utf8.encode(secret);
    }
    final signature = base64Encode(
      Hmac(sha256, secretBytes).convert(utf8.encode(canonical)).bytes,
    );

    final uri = Uri.parse('${Data.iimmpactBaseUrl}/v2/catalog');
    final response = await http.get(uri, headers: <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-API-Key': Data.iimmpactApiKey,
      'X-Timestamp': timestamp.toString(),
      'X-Nonce': nonce,
      'X-Signature': 'v1=$signature',
    }).timeout(_timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('IIMMPACT catalog HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) throw const FormatException('Catalog must be an object');
    final products = decoded['products'];
    final tree = decoded['tree'];
    if (products is! Map || tree is! Map) {
      throw const FormatException('Catalog products/tree missing');
    }
    final groups = tree['groups'];
    if (groups is! List) throw const FormatException('Catalog groups missing');
    final result = <String, PipIimmpactProduct>{};
    for (final rawGroup in groups) {
      if (rawGroup is! Map) continue;
      final categories = rawGroup['categories'];
      if (categories is! List) continue;
      for (final rawCategory in categories) {
        if (rawCategory is! Map) continue;
        final codes = rawCategory['product_codes'];
        if (codes is! List) continue;
        for (final rawCode in codes) {
          final code = rawCode.toString().trim().toUpperCase();
          final product = products[code];
          if (product is! Map) continue;
          result[code] = PipIimmpactProduct(
            productCode: code,
            productName: (product['name'] ?? code).toString(),
            groupId: (rawGroup['id'] ?? '').toString(),
            groupName: (rawGroup['name'] ?? '').toString(),
            categoryId: (rawCategory['id'] ?? '').toString(),
            categoryName: (rawCategory['name'] ?? '').toString(),
          );
        }
      }
    }
    if (result.isEmpty) throw const FormatException('Empty catalog index');
    debugPrint('[PIP BIL] Catalog loaded: ${result.length} products');
    return result;
  }
}
