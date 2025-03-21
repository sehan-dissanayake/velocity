import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/notifications/background_notification_manager.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              Provider.of<BackgroundNotificationManager>(context, listen: false).clearAll();
            },
          ),
        ],
      ),
      body: Consumer<BackgroundNotificationManager>(
        builder: (context, manager, _) {
          final notifications = manager.notifications;
          
          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet'),
            );
          }
          
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isRfid = notification['type'] == 'rfid';
              final isRead = notification['read'] ?? false;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: isRead ? Colors.white : Colors.blue[50],
                child: ListTile(
                  leading: Icon(
                    isRfid ? Icons.nfc : Icons.notifications,
                    color: isRfid ? Colors.orange : Colors.blue,
                  ),
                  title: Text(notification['title'] ?? 'Notification'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification['message'] ?? ''),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(notification['timestamp'] ?? ''),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    manager.markAsRead(notification['id']);
                    _showNotificationDetails(context, notification);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDateTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  void _showNotificationDetails(BuildContext context, Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? 'Notification'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification['message'] ?? ''),
              const SizedBox(height: 16),
              const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  notification.toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}