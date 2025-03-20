import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';
import '../utils/storage_service.dart'; // Add this import

class ApiService {
  static final String _baseUrl = dotenv.get('BASE_API_URL');

  // Helper method to get headers with authentication
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> post(String endpoint, dynamic body) async {
    final headers = await _getHeaders();
    final response = await http
        .post(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http
        .get(Uri.parse('$_baseUrl/$endpoint'), headers: headers)
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, dynamic body) async {
    final headers = await _getHeaders();
    final response = await http
        .put(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http
        .delete(Uri.parse('$_baseUrl/$endpoint'), headers: headers)
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static Future<dynamic> patch(String endpoint, dynamic body) async {
    final headers = await _getHeaders();
    final response = await http
        .patch(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
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
