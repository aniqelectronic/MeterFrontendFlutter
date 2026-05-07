import 'package:http/http.dart' as http;
import 'dart:async';

class InternetChecker {
  /// Returns true if internet is available
  static Future<bool> isInternetAvailable({Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(timeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
