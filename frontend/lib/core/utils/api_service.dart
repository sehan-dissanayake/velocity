import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final String _baseUrl = dotenv.get('BASE_API_URL');

  static Future<dynamic> post(String endpoint, dynamic body) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      case 400:
        throw Exception('Bad Request: ${response.body}');
      case 401:
        throw Exception('Unauthorized: ${response.body}');
      case 500:
        throw Exception('Server Error: ${response.body}');
      default:
        throw Exception('Request failed: ${response.statusCode}');
    }
  }
}
