import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/socket_service.dart';

class NotificationHandler {
  final SocketService _socketService;
  final List<Map<String, dynamic>> _notifications = [];
  final StreamController<Map<String, dynamic>> _notificationController = 
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  List<Map<String, dynamic>> get notifications => _notifications;

  NotificationHandler({required SocketService socketService}) 
      : _socketService = socketService {
    
    // Listen for incoming notifications
    _socketService.messageStream.listen((message) {
      if (message['type'] == 'notification') {
        _notifications.add(message['data']);
        _notificationController.add(message['data']);
      }
    });
  }

  void subscribeToChannels(List<String> channels) {
    _socketService.sendMessage({
      'type': 'subscribe',
      'channels': channels,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void dispose() {
    _notificationController.close();
  }
}