import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketConfig {
  // Get Socket.IO URL from environment variables
  static String get socketUrl {
    final baseUrl = dotenv.get('BASE_API_URL', fallback: 'http://localhost:3000/api');
    
    // IMPORTANT: Remove '/api' from the URL for Socket.IO connections
    final baseWithoutApi = baseUrl.endsWith('/api') 
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;
    
    return baseWithoutApi;
  }
  
  // Socket.IO namespaces
  static String get notificationsNamespace => '/notifications';
  static String get rfidNamespace => '/rfid';
}