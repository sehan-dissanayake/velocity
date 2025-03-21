import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/background_socket_handler.dart';

class BackgroundNotificationManager extends ChangeNotifier {
  final BackgroundSocketHandler _socketHandler = BackgroundSocketHandler();
  final List<Map<String, dynamic>> _notifications = [];
  
  BackgroundNotificationManager() {
    _setupListeners();
  }
  
  // Properties
  bool get isRunning => _socketHandler.isRunning;
  bool get notificationsConnected => _socketHandler.notificationsConnected;
  bool get rfidConnected => _socketHandler.rfidConnected;
  bool get runInBackground => _socketHandler.runInBackground;
  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);
  
  set runInBackground(bool value) {
    _socketHandler.runInBackground = value;
    notifyListeners();
  }
  
  // Methods
  Future<void> startService() async {
    await _socketHandler.start();
    notifyListeners();
  }
  
  void stopService() {
    _socketHandler.stop();
    notifyListeners();
  }
  
  void _setupListeners() {
    _socketHandler.notificationStream.listen((notification) {
      _notifications.insert(0, notification);
      notifyListeners();
    });
    
    _socketHandler.rfidEventStream.listen((rfidEvent) {
      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': 'RFID Event',
        'message': 'Card scanned at ${rfidEvent['station_name'] ?? 'unknown location'}',
        'type': 'rfid',
        'timestamp': DateTime.now().toIso8601String(),
        'data': rfidEvent,
      };
      
      _notifications.insert(0, notification);
      notifyListeners();
    });
  }
  
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['read'] = true;
      notifyListeners();
    }
  }
  
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}