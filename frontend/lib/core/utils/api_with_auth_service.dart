import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';
import './storage_service.dart';

class ApiWithAuthService {
  static final String _baseUrl = dotenv.get('BASE_API_URL');

  // Get headers with authentication token if available
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};

    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Authenticated API calls
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

  // Non-authenticated API calls
  static Future<dynamic> postNoAuth(String endpoint, dynamic body) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static Future<dynamic> getNoAuth(String endpoint) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static Future<dynamic> putNoAuth(String endpoint, dynamic body) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static Future<dynamic> deleteNoAuth(String endpoint) async {
    final response = await http
        .delete(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static Future<dynamic> patchNoAuth(String endpoint, dynamic body) async {
    final response = await http
        .patch(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  // Auth-specific methods
  static Future<bool> login(String email, String password) async {
    try {
      final response = await postNoAuth('auth/login', {
        'email': email,
        'password': password,
      });

      if (response != null && response['token'] != null) {
        await StorageService.setToken(response['token']);
        if (response['user'] != null && response['user']['id'] != null) {
          await StorageService.setUserId(response['user']['id']);
        }
        await StorageService.setLoggedIn(true);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    await StorageService.deleteToken();
    await StorageService.setLoggedIn(false);
  }

  static Future<bool> register(Map<String, dynamic> userData) async {
    try {
      final response = await postNoAuth('auth/register', userData);
      return response != null && response['success'] == true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  static Future<bool> refreshToken() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await postNoAuth('auth/refresh', {'token': token});

      if (response != null && response['token'] != null) {
        await StorageService.setToken(response['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  static dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw Exception('Bad Request: ${response.body}');
      case 401:
        // Clear invalid token and logged in status
        StorageService.deleteToken();
        StorageService.setLoggedIn(false);
        throw Exception('Unauthorized: ${response.body}');
      case 403:
        throw Exception('Forbidden: ${response.body}');
      case 404:
        throw Exception('Not Found: ${response.body}');
      case 500:
        throw Exception('Server Error: ${response.body}');
      default:
        throw Exception('Request failed: ${response.statusCode}');
    }
  }
}
