import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/core/utils/socket_service.dart';
import 'package:frontend/features/auth/provider/auth_provider.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/core/utils/storage_service.dart';
import 'package:frontend/core/config/websocket_config.dart';
import 'package:frontend/features/rfid/rfid_handler.dart';
import 'package:frontend/features/notifications/notification_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SocketService? _notificationService;
  SocketService? _rfidService;
  NotificationHandler? _notificationHandler;
  RfidHandler? _rfidHandler;
  
  bool _notificationConnected = false;
  bool _rfidConnected = false;
  final List<String> _eventLogs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSocketServices();
    });
  }

  @override
  void dispose() {
    _disposeSocketServices();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeSocketServices() async {
    final token = await StorageService.getToken();
    if (token == null) {
      _logEvent('❌ No authentication token available');
      return;
    }

    final baseUrl = WebSocketConfig.socketUrl;
    _logEvent('🔌 Socket.IO base URL: $baseUrl');

    // Initialize notification socket
    _notificationService = SocketService(
      url: baseUrl,
      namespace: WebSocketConfig.notificationsNamespace,
      token: token,
    );
    _notificationService!.connect();
    
    // Set up notification connection status check
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _notificationConnected = _notificationService!.isConnected);
        _logEvent(_notificationConnected 
            ? '🔗 Connected to notification socket' 
            : '❌ Failed to connect to notification socket');
            
        if (_notificationConnected) {
          _notificationHandler = NotificationHandler(socketService: _notificationService!);
          _setupNotificationListener();
          _subscribeToNotificationChannels();
        }
      }
    });

    // Initialize RFID socket
    _rfidService = SocketService(
      url: baseUrl,
      namespace: WebSocketConfig.rfidNamespace,
      token: token,
    );
    _rfidService!.connect();
    
    // Set up RFID connection status check
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _rfidConnected = _rfidService!.isConnected);
        _logEvent(_rfidConnected 
            ? '🔗 Connected to RFID socket' 
            : '❌ Failed to connect to RFID socket');
            
        if (_rfidConnected) {
          _rfidHandler = RfidHandler(socketService: _rfidService!);
          _setupRfidListener();
        }
      }
    });
  }

  void _setupNotificationListener() {
    _notificationHandler!.notificationStream.listen((notification) {
      _logEvent('📢 New notification: ${jsonEncode(notification)}');
    });
  }

  void _setupRfidListener() {
    _rfidHandler!.rfidEventStream.listen((rfidEvent) {
      _logEvent('🔖 RFID event: ${jsonEncode(rfidEvent)}');
    });
  }

  void _subscribeToNotificationChannels() {
    _notificationHandler!.subscribeToChannels(['user_notifications']);
    _logEvent('📨 Sent subscription request to notification channels');
  }

  void _disposeSocketServices() {
    _notificationHandler?.dispose();
    _rfidHandler?.dispose();
    _notificationService?.dispose();
    _rfidService?.dispose();
  }

  void _logEvent(String event) {
    if (mounted) {
      setState(() {
        _eventLogs.add('[${DateTime.now().toString().split('.')[0]}] $event');
      });
      
      // Scroll to bottom of logs
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendPing() async {
    final pingMessage = {
      'type': 'ping',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    if (_notificationService?.isConnected == true) {
      _notificationService!.sendMessage(pingMessage);
      _logEvent('📤 Sent ping to notification service');
    }
    
    if (_rfidService?.isConnected == true) {
      _rfidService!.sendMessage(pingMessage);
      _logEvent('📤 Sent ping to RFID service');
    }
  }

  Future<void> _testNotification() async {
    final token = await StorageService.getToken();
    final baseApiUrl = dotenv.get('BASE_API_URL', fallback: 'http://localhost:3000/api');
    
    try {
      // Get current user ID
      final userId = await StorageService.getUserId(); 
      
      if (userId == null) {
        _logEvent('❌ Error: No user ID available');
        return;
      }
      
      final response = await http.post(
        Uri.parse('$baseApiUrl/notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'title': 'Test Notification',
          'message': 'This is a test notification sent at ${DateTime.now()}',
          'type': 'info',
        }),
      );
      
      if (response.statusCode == 200) {
        _logEvent('🔔 Notification test request sent successfully');
      } else {
        _logEvent('❌ Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logEvent('❌ Error sending test notification: $e');
    }
  }

  Future<void> _testRfidEvent() async {
    final token = await StorageService.getToken();
    final baseApiUrl = dotenv.get('BASE_API_URL', fallback: 'http://localhost:3000/api');
    
    try {
      // Get current user ID
      final userId = await StorageService.getUserId();
      
      if (userId == null) {
        _logEvent('❌ Error: No user ID available');
        return;
      }
      
      final response = await http.post(
        Uri.parse('$baseApiUrl/rfid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'station_id': 'station_123',
          'station_name': 'Central Station',
          'event_type': 'entry',
        }),
      );
      
      if (response.statusCode == 200) {
        _logEvent('🚪 RFID event test request sent successfully');
      } else {
        _logEvent('❌ Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logEvent('❌ Error sending test RFID event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket.IO Testing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              _disposeSocketServices();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
            body: Column(
        children: [
          // Connection status indicators
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _connectionStatusWidget(
                  'Notifications',
                  _notificationConnected,
                ),
                _connectionStatusWidget('RFID Events', _rfidConnected),
              ],
            ),
          ),

          // Event log
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _eventLogs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    _eventLogs[index],
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                );
              },
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _sendPing,
                  child: const Text('Send Ping'),
                ),
                ElevatedButton(
                  onPressed: _testNotification,
                  child: const Text('Test Notification'),
                ),
                ElevatedButton(
                  onPressed: _testRfidEvent,
                  child: const Text('Test RFID Event'),
                ),
              ],
            ),
          ),

          // Connection buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Wrap(
              spacing: 8.0,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:
                      _notificationConnected ? null : _initializeSocketServices,
                  child: const Text('Connect'),
                ),
                ElevatedButton(
                  onPressed:
                      !_notificationConnected && !_rfidConnected
                          ? null
                          : _disposeSocketServices,
                  child: const Text('Disconnect'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectionStatusWidget(String name, bool isConnected) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(name),
      ],
    );
  }
}