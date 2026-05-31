import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/remix_result.dart';

class RemixException implements Exception {
  final String message;
  const RemixException(this.message);
}

class RemixService {
  static Future<RemixResult> remix({
    required String recipe,
    required String constraint,
  }) async {
    final uri = Uri.parse('/api/remix');
    final http.Response response;

    try {
      response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'recipe': recipe, 'constraint': constraint}),
          )
          .timeout(const Duration(seconds: 45));
    } catch (_) {
      throw const RemixException(
          'Could not reach the server. Check your connection and try again.');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw RemixException(
          body['error'] as String? ?? 'Something went wrong. Please try again.');
    }

    try {
      return RemixResult.fromJson(body);
    } catch (_) {
      throw const RemixException(
          'Received an unexpected response. Please try again.');
    }
  }
}
