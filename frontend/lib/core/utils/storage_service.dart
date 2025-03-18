import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final _secureStorage = FlutterSecureStorage();
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Secure storage
  static Future<String?> getToken() => _secureStorage.read(key: 'jwt_token');
  static Future<void> setToken(String token) =>
      _secureStorage.write(key: 'jwt_token', value: token);
  static Future<void> deleteToken() => _secureStorage.delete(key: 'jwt_token');

  // General preferences
  static bool get isLoggedIn => _prefs?.getBool('is_logged_in') ?? false;
  static Future<void> setLoggedIn(bool value) =>
      _prefs?.setBool('is_logged_in', value) ?? Future.value();
}
