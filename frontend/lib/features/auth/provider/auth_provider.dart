import 'package:frontend/core/utils/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/utils/storage_service.dart';
import 'package:frontend/core/utils/auth_state.dart';

class AuthProvider with ChangeNotifier {
  AuthState _state = AuthState.loading;
  String _errorMessage = '';

  AuthState get state => _state;
  String get errorMessage => _errorMessage;

  Future<void> initialize() async {
    try {
      print('Initializing AuthProvider...');
      _state = AuthState.loading;
      notifyListeners();

      final isLoggedIn = StorageService.isLoggedIn;
      print('StorageService.isLoggedIn: $isLoggedIn');

      _state = isLoggedIn ? AuthState.authenticated : AuthState.unauthenticated;
      print('Initialization complete. State: $_state');
    } catch (e) {
      print('Initialization error: $e');
      _state = AuthState.error;
      _errorMessage = 'Initialization failed';
    } finally {
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.post('auth/login', {
        'email': email,
        'password': password,
      });

      await StorageService.setToken(response['token']);
      await StorageService.setLoggedIn(true);
      _state = AuthState.authenticated;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await StorageService.deleteToken();
    await StorageService.setLoggedIn(false);
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.post('auth/signup', {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
      });

      // Assuming the signup endpoint returns a token like login does
      await StorageService.setToken(response['token']);
      await StorageService.setLoggedIn(true);
      _state = AuthState.authenticated;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }
}
