import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;
  final String _url;
  final String _namespace;
  final String? _token;
  bool _isConnected = false;
  final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();

  SocketService({
    required String url, 
    required String namespace, 
    String? token
  }) : _url = url,
       _namespace = namespace,
       _token = token;

  bool get isConnected => _isConnected;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  void connect() {
    try {
      debugPrint('Connecting to Socket.IO: $_url with namespace $_namespace');
      
      _socket = IO.io('$_url$_namespace', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': _token}
      });

      _socket!.onConnect((_) {
        debugPrint('Socket.IO connected to $_namespace');
        _isConnected = true;
      });

      _socket!.onDisconnect((_) {
        debugPrint('Socket.IO disconnected from $_namespace');
        _isConnected = false;
      });

      _socket!.onConnectError((error) {
        debugPrint('Socket.IO connection error on $_namespace: $error');
        _isConnected = false;
      });

      _socket!.on('notification', (data) {
        debugPrint('Notification received: $data');
        _messageController.add({'type': 'notification', 'data': data});
      });

      _socket!.on('rfid_event', (data) {
        debugPrint('RFID event received: $data');
        _messageController.add({'type': 'rfid_event', 'data': data});
      });

      _socket!.on('pong', (data) {
        debugPrint('Ping response received: $data');
        _messageController.add({'type': 'pong', 'data': data});
      });

      _socket!.connect();
    } catch (e) {
      debugPrint('Error connecting to Socket.IO: $e');
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_socket != null && _isConnected) {
      final type = message['type'];
      debugPrint('Emitting $type event to Socket.IO');
      _socket!.emit(type, message);
    } else {
      debugPrint('Cannot send message: Socket not connected');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}