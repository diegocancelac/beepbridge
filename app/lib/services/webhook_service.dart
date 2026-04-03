import 'dart:convert';
import 'package:http/http.dart' as http;

class WebhookService {
  static Future<(bool success, String message)> sendScan(
    String serverUrl,
    String barcode,
  ) async {
    final url = serverUrl.endsWith('/')
        ? '${serverUrl}scan'
        : '$serverUrl/scan';
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'barcode': barcode}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return (true, 'Scan sent');
      }
      return (false, 'Server returned ${response.statusCode}');
    } on Exception catch (e) {
      return (false, _friendlyError(e));
    }
  }

  static Future<(bool success, String message)> testConnection(
    String serverUrl,
  ) async {
    final url = serverUrl.endsWith('/')
        ? '${serverUrl}health'
        : '$serverUrl/health';
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return (true, 'Connection successful');
      }
      return (false, 'Server returned ${response.statusCode}');
    } on Exception catch (e) {
      return (false, _friendlyError(e));
    }
  }

  static String _friendlyError(Exception e) {
    final msg = e.toString();
    if (msg.contains('SocketException')) return 'Cannot reach server';
    if (msg.contains('TimeoutException')) return 'Connection timed out';
    if (msg.contains('FormatException')) return 'Invalid server URL';
    return 'Network error';
  }
}
