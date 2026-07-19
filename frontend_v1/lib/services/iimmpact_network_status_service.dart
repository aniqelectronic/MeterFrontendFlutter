import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:frontend_v1/pages/data.dart';
import 'package:http/http.dart' as http;

// import 'package:frontend_v1/pages/config.dart';

class IimmpactNetworkStatus {
  final String productCode;
  final String productName;
  final String networkStatus;
  final String? lastUpdated;

  const IimmpactNetworkStatus({
    required this.productCode,
    required this.productName,
    required this.networkStatus,
    this.lastUpdated,
  });

  bool get isHealthy =>
      networkStatus.trim().toLowerCase() == 'healthy';

  bool get isInterruption =>
      networkStatus.trim().toLowerCase() == 'interruption';

  factory IimmpactNetworkStatus.fromJson(
    Map<String, dynamic> json,
  ) {
    final data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final metadata =
        json['metadata'] as Map<String, dynamic>? ??
            <String, dynamic>{};

    return IimmpactNetworkStatus(
      productCode: data['product_code']?.toString() ?? '',
      productName: data['product_name']?.toString() ?? '',
      networkStatus:
          data['network_status']?.toString() ?? 'Unknown',
      lastUpdated: metadata['last_updated']?.toString(),
    );
  }
}

class IimmpactNetworkStatusService {
  static const String _baseUrl =
      Data.iimmpactBaseUrl;

  static Future<IimmpactNetworkStatus> getStatus({
    required String productCode,
  }) async {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final nonce = _generateNonce(timestamp);

    const method = 'GET';
    const body = '';

    final query = 'product=$productCode';

    final bodyHash = base64Encode(
      sha256.convert(utf8.encode(body)).bytes,
    );

    final canonical =
        'v1:$timestamp:$nonce:$method:$query:$bodyHash';

    final secretBytes = base64Decode(
      Data.iimmpactHmacSecret,
    );

    final signatureBytes = Hmac(
      sha256,
      secretBytes,
    ).convert(
      utf8.encode(canonical),
    );

    final signature = base64Encode(signatureBytes.bytes);

    final uri = Uri.parse(
      '$_baseUrl/v2/networkstatus',
    ).replace(
      queryParameters: {
        'product': productCode,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'X-Api-Key': Data.iimmpactApiKey,
        'X-Timestamp': timestamp,
        'X-Nonce': nonce,
        'X-Signature': 'v1=$signature',
      },
    ).timeout(
      const Duration(seconds: 15),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      String message = 'Unable to check network status.';

      if (decoded is Map<String, dynamic>) {
        message = decoded['message']?.toString() ?? message;
      }

      throw Exception(message);
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid network status response.');
    }

    return IimmpactNetworkStatus.fromJson(decoded);
  }

  static String _generateNonce(String timestamp) {
    final random = Random.secure();

    final randomPart = List.generate(
      16,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();

    return 'req-$timestamp-$randomPart';
  }
}