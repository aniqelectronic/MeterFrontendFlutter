import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class HmacApiClient {
  final String apiKey;
  final String hmacSecret;

  HmacApiClient({
    required this.apiKey,
    required this.hmacSecret,
  });

  String _bodyHash(String body) {
    final digest = sha256.convert(
      utf8.encode(body),
    );

    return base64Encode(digest.bytes);
  }

  String _canonicalQuery(Uri uri) {
    final entries = <MapEntry<String, String>>[];

    uri.queryParametersAll.forEach((key, values) {
      for (final value in values) {
        entries.add(MapEntry(key, value));
      }
    });

    entries.sort((a, b) {
      final keyCompare = a.key.compareTo(b.key);

      if (keyCompare != 0) {
        return keyCompare;
      }

      return a.value.compareTo(b.value);
    });

    return entries
        .map((e) =>
            "${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}")
        .join("&");
  }

  Map<String, String> createHeaders({
    required String method,
    required Uri uri,
    String body = "",
  }) {
    final canonicalString = [
      method.toUpperCase(),
      uri.path,
      _canonicalQuery(uri),
      _bodyHash(body),
    ].join("\n");

    final signature = Hmac(
      sha256,
      utf8.encode(hmacSecret),
    ).convert(
      utf8.encode(canonicalString),
    );

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-API-Key": apiKey,
      "X-Signature": "v1=${signature.toString()}",
    };
  }

  Future<http.Response> get(
    Uri uri,
  ) {
    return http.get(
      uri,
      headers: createHeaders(
        method: "GET",
        uri: uri,
      ),
    );
  }

  Future<http.Response> post(
    Uri uri,
    Object? body,
  ) {
    final jsonBody = jsonEncode(body);

    return http.post(
      uri,
      body: jsonBody,
      headers: createHeaders(
        method: "POST",
        uri: uri,
        body: jsonBody,
      ),
    );
  }

  Future<http.Response> put(
    Uri uri,
    Object? body,
  ) {
    final jsonBody = jsonEncode(body);

    return http.put(
      uri,
      body: jsonBody,
      headers: createHeaders(
        method: "PUT",
        uri: uri,
        body: jsonBody,
      ),
    );
  }
}