import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/utils/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('auth/login', {
        'email': email,
        'password': password,
      });

      // Handle successful login
      print('Login successful: $response');
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('Login error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
