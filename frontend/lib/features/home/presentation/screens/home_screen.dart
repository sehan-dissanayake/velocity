import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/provider/auth_provider.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/notifications/background_notification_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    
    // Start the background service if it's not running
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationManager = Provider.of<BackgroundNotificationManager>(
        context, 
        listen: false
      );
      
      if (!notificationManager.isRunning) {
        notificationManager.startService();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Velociti Home'),
        actions: [
          // Notifications icon with badge
          Consumer<BackgroundNotificationManager>(
            builder: (context, manager, _) {
              final unreadCount = manager.notifications
                  .where((n) => !(n['read'] ?? false))
                  .length;
                  
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Stop background service before logout
              final notificationManager = Provider.of<BackgroundNotificationManager>(
                context, 
                listen: false
              );
              notificationManager.stopService();
              
              // Logout
              await authProvider.logout();
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
          // Connection status
          Consumer<BackgroundNotificationManager>(
            builder: (context, manager, _) {
              return Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statusIndicator(
                      'Notifications', 
                      manager.notificationsConnected,
                    ),
                    _statusIndicator(
                      'RFID Events', 
                      manager.rfidConnected,
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Recent notifications
          Expanded(
            child: Consumer<BackgroundNotificationManager>(
              builder: (context, manager, _) {
                if (manager.notifications.isEmpty) {
                  return const Center(
                    child: Text('No notifications yet'),
                  );
                }
                
                return ListView.builder(
                  itemCount: manager.notifications.length > 3 
                      ? 3 
                      : manager.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = manager.notifications[index];
                    final isRfid = notification['type'] == 'rfid';
                    final isRead = notification['read'] ?? false;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: isRead ? null : Colors.blue[50],
                      child: ListTile(
                        leading: Icon(
                          isRfid ? Icons.nfc : Icons.notifications,
                          color: isRfid ? Colors.orange : Colors.blue,
                        ),
                        title: Text(notification['title'] ?? 'Notification'),
                        subtitle: Text(notification['message'] ?? ''),
                        trailing: Text(
                          _formatTime(notification['timestamp'] ?? ''),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          manager.markAsRead(notification['id']);
                          // Show details or navigate
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // View all button
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
            icon: const Icon(Icons.list),
            label: const Text('View All Notifications'),
          ),
          
          const SizedBox(height: 16),
          
          // // Background service control
          // Consumer<BackgroundNotificationManager>(
          //   builder: (context, manager, _) {
          //     return Padding(
          //       padding: const EdgeInsets.all(16.0),
          //       child: Row(
          //         children: [
          //           const Text('Run in background:'),
          //           const Spacer(),
          //           Switch(
          //             value: manager.runInBackground,
          //             onChanged: (value) {
          //               manager.runInBackground = value;
          //             },
          //           ),
          //         ],
          //       ),
          //     );
          //   },
          // ),
          
          // Service control buttons
          Consumer<BackgroundNotificationManager>(
            builder: (context, manager, _) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: manager.isRunning ? null : manager.startService,
                      child: const Text('Start Service'),
                    ),
                    ElevatedButton(
                      onPressed: manager.isRunning ? manager.stopService : null,
                      child: const Text('Stop Service'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _statusIndicator(String name, bool isActive) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(name),
      ],
    );
  }
  
  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}