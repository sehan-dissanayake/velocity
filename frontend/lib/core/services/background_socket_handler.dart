import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/socket_service.dart';
import 'package:frontend/core/config/websocket_config.dart';
import 'package:frontend/core/services/notification_service.dart';
import 'package:frontend/core/utils/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Isolate port names
const String _socketIsolatePortName = 'socket_isolate_port';
const String _mainIsolatePortName = 'main_isolate_port';

// Background handler that manages socket connections
class BackgroundSocketHandler {
  static final BackgroundSocketHandler _instance = BackgroundSocketHandler._();
  factory BackgroundSocketHandler() => _instance;
  
  bool _isRunning = false;
  bool get isRunning => _isRunning;
  
  // Settings
  bool _runInBackground = false;
  bool get runInBackground => _runInBackground;
  set runInBackground(bool value) {
    _runInBackground = value;
    _saveSettings();
  }
  
  // Status
  bool _notificationsConnected = false;
  bool _rfidConnected = false;
  
  bool get notificationsConnected => _notificationsConnected;
  bool get rfidConnected => _rfidConnected;
  
  // Communication ports
  SendPort? _backgroundSendPort;
  ReceivePort? _receivePort;
  
  // Event controllers
  final StreamController<Map<String, dynamic>> _notificationsController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _rfidEventsController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get notificationStream => _notificationsController.stream;
  Stream<Map<String, dynamic>> get rfidEventStream => _rfidEventsController.stream;
  
  BackgroundSocketHandler._();
  
  // Initialize the background socket handler
  Future<void> init() async {
    await _loadSettings();
    debugPrint('BackgroundSocketHandler initialized, runInBackground: $_runInBackground');
    
    // Set up receiver for messages from background isolate
    _receivePort = ReceivePort('main_isolate_receiver');
    IsolateNameServer.registerPortWithName(
      _receivePort!.sendPort, 
      _mainIsolatePortName
    );
    
    _receivePort!.listen(_handleMessageFromIsolate);
    
    // Auto-start background service if enabled
    if (_runInBackground) {
      start();
    }
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _runInBackground = prefs.getBool('socket_run_in_background') ?? false;
  }
  
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('socket_run_in_background', _runInBackground);
  }
  
  // Start the background socket handler
  Future<void> start() async {
    if (_isRunning) return;
    
    final token = await StorageService.getToken();
    if (token == null) {
      debugPrint('Cannot start background socket handler: No token available');
      return;
    }
    
    // Set up background isolate
    await Isolate.spawn(
      _startSocketIsolate,
      _IsolateSetupData(
        token: token,
        socketUrl: WebSocketConfig.socketUrl,
        notificationsNamespace: WebSocketConfig.notificationsNamespace,
        rfidNamespace: WebSocketConfig.rfidNamespace,
      ),
    );
    
    debugPrint('Background socket isolate spawned');
    _isRunning = true;
  }
  
  // Stop the background socket handler
  void stop() {
    if (!_isRunning) return;
    
    if (_backgroundSendPort != null) {
      _backgroundSendPort!.send({'command': 'stop'});
      _backgroundSendPort = null;
    }
    
    _isRunning = false;
    _notificationsConnected = false;
    _rfidConnected = false;
  }
  
  // Handle messages from background isolate
  void _handleMessageFromIsolate(dynamic message) {
    if (message is! Map<String, dynamic>) return;
    
    debugPrint('Received message from socket isolate: ${message['type']}');
    
    switch (message['type']) {
      case 'init':
        _backgroundSendPort = message['sendPort'];
        break;
        
      case 'status':
        _notificationsConnected = message['notificationsConnected'] ?? false;
        _rfidConnected = message['rfidConnected'] ?? false;
        break;
        
      case 'notification':
        final notificationData = message['data'];
        _notificationsController.add(notificationData);
        
        // Show local notification
        NotificationService().showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: notificationData['title'] ?? 'New Notification',
          body: notificationData['message'] ?? 'You received a new notification',
          payload: jsonEncode(notificationData), 
        );
        break;
        
      case 'rfid_event':
        final rfidData = message['data'];
        _rfidEventsController.add(rfidData);
        
        // Show local notification for RFID event
        NotificationService().showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: 'RFID Event',
          body: 'Card scanned at ${rfidData['station_name'] ?? 'unknown location'}',
          payload: rfidData,
        );
        break;
    }
  }
  
  void dispose() {
    stop();
    _notificationsController.close();
    _rfidEventsController.close();
    
    if (_receivePort != null) {
      _receivePort!.close();
      IsolateNameServer.removePortNameMapping(_mainIsolatePortName);
    }
  }
}

// Function that runs in the background isolate
@pragma('vm:entry-point')
void _startSocketIsolate(_IsolateSetupData setupData) {
  debugPrint('Socket isolate started');
  
  // Set up receiver for messages from main isolate
  final receivePort = ReceivePort('socket_isolate_receiver');
  IsolateNameServer.registerPortWithName(
    receivePort.sendPort, 
    _socketIsolatePortName
  );
  
  // Get send port for main isolate
  final mainSendPort = IsolateNameServer.lookupPortByName(_mainIsolatePortName);
  if (mainSendPort == null) {
    debugPrint('Could not find main isolate send port');
    return;
  }
  
  // Send initial message with this isolate's send port
  mainSendPort.send({
    'type': 'init',
    'sendPort': receivePort.sendPort,
  });
  
  // Create socket services
  SocketService? notificationsService, rfidService;
  bool notificationsConnected = false;
  bool rfidConnected = false;
  
  // Connect to notification socket
  notificationsService = SocketService(
    url: setupData.socketUrl,
    namespace: setupData.notificationsNamespace,
    token: setupData.token,
  );
  notificationsService.connect();
  
  // Connect to RFID socket
  rfidService = SocketService(
    url: setupData.socketUrl,
    namespace: setupData.rfidNamespace,
    token: setupData.token,
  );
  rfidService.connect();
  
  // Listen for connection status changes and messages
  notificationsService.messageStream.listen((message) {
    if (message['type'] == 'notification') {
      mainSendPort.send({
        'type': 'notification',
        'data': message['data'],
      });
    }
  });
  
  rfidService.messageStream.listen((message) {
    if (message['type'] == 'rfid_event') {
      mainSendPort.send({
        'type': 'rfid_event',
        'data': message['data'],
      });
    }
  });
  
  // Send status updates periodically
  Timer.periodic(const Duration(seconds: 2), (timer) {
    final newNotificationsConnected = notificationsService?.isConnected ?? false;
    final newRfidConnected = rfidService?.isConnected ?? false;
    
    if (newNotificationsConnected != notificationsConnected || 
        newRfidConnected != rfidConnected) {
      notificationsConnected = newNotificationsConnected;
      rfidConnected = newRfidConnected;
      
      mainSendPort.send({
        'type': 'status',
        'notificationsConnected': notificationsConnected,
        'rfidConnected': rfidConnected,
      });
    }
  });
  
  // Handle commands from main isolate
  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      if (message['command'] == 'stop') {
        notificationsService?.dispose();
        rfidService?.dispose();
        Isolate.current.kill(priority: Isolate.immediate);
      }
    }
  });
}

// Data class for setup information
class _IsolateSetupData {
  final String token;
  final String socketUrl;
  final String notificationsNamespace;
  final String rfidNamespace;
  
  _IsolateSetupData({
    required this.token,
    required this.socketUrl,
    required this.notificationsNamespace,
    required this.rfidNamespace,
  });
}