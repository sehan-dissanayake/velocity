import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';
import '../models/railway_station.dart';

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

  static Future<dynamic> get(String endpoint) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, dynamic body) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final response = await http
        .delete(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static Future<dynamic> patch(String endpoint, dynamic body) async {
    final response = await http
        .patch(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200 || 201:
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

  static Future<List<RailwayStation>> fetchRailwayStations() async {
    try {
      final response = await get('railway-stations');
      print('Raw API response: $response'); // Debug log
      // Since the response is a list, parse it directly
      final List<dynamic> data = response; // No need for response['data']
      print('Station data: $data'); // Debug log
      return data.map((json) => RailwayStation.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching railway stations: $e');
    }
  }
}
