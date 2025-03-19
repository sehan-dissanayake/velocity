import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/socket_service.dart';

class RfidHandler {
  final SocketService _socketService;
  final StreamController<Map<String, dynamic>> _rfidEventController = 
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get rfidEventStream => _rfidEventController.stream;

  RfidHandler({required SocketService socketService}) 
      : _socketService = socketService {
    
    // Listen for incoming RFID events
    _socketService.messageStream.listen((message) {
      if (message['type'] == 'rfid_event') {
        debugPrint('RFID event received: ${message['data']}');
        _rfidEventController.add(message['data']);
      }
    });
  }

  void dispose() {
    _rfidEventController.close();
  }
}