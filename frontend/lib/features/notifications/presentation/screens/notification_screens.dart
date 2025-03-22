import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/notifications/background_notification_manager.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101114),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF101114),
              Color(0xFF15171A),
              Color(0xFF1A1D22),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Consumer<BackgroundNotificationManager>(
                  builder: (context, manager, _) {
                    final notifications = manager.notifications;
                    
                    if (notifications.isEmpty) {
                      return _buildEmptyState();
                    }

                    
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: notifications.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final isRfid = notification['type'] == 'rfid';
                        final isRead = notification['read'] ?? false;
                        
                        return _buildNotificationCard(
                          context: context,
                          notification: notification,
                          isRfid: isRfid,
                          isRead: isRead,
                          manager: manager,
                          index: index,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ).animate(controller: _animationController)
               .fadeIn(duration: 300.ms, delay: 100.ms)
               .slideX(begin: -0.2, end: 0, duration: 300.ms, delay: 100.ms),
              
              const SizedBox(width: 16),
              
              Text(
                "Notifications",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate(controller: _animationController)
               .fadeIn(duration: 300.ms, delay: 150.ms),
               
              const SizedBox(width: 12),
              
              Consumer<BackgroundNotificationManager>(
                builder: (context, manager, _) {
                  return PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                    ),
                    color: const Color(0xFF1A1D22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_sweep_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Clear All',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'mark_all_read',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.mark_email_read_rounded,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mark All as Read',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'clear_all') {
                        _showClearAllConfirmation(context, manager);
                      } else if (value == 'mark_all_read') {
                        manager.clearAll();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'All notifications marked as read',
                              style: GoogleFonts.montserrat(),
                            ),
                            backgroundColor: Colors.green.shade800,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Filter tabs (optional)
          Consumer<BackgroundNotificationManager>(
            builder: (context, manager, _) {
              final totalCount = manager.notifications.length;
              final unreadCount = manager.notifications
                  .where((n) => !(n['read'] ?? false))
                  .length;
              
              return Row(
                children: [
                  _buildFilterChip(
                    label: 'All ($totalCount)',
                    isActive: true,
                    onTap: () {
                      // Filter logic here
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    label: 'Unread ($unreadCount)',
                    isActive: false,
                    onTap: () {
                      // Filter logic here
                    },
                  ),
                ],
              );
            },
          ).animate(controller: _animationController)
           .fadeIn(duration: 400.ms, delay: 300.ms)
           .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required Map<String, dynamic> notification,
    required bool isRfid,
    required bool isRead,
    required BackgroundNotificationManager manager,
    required int index,
  }) {
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final timestamp = notification['timestamp'] ?? '';
    
    // Determine icon and colors based on notification type and read status
    final IconData iconData = isRfid ? Icons.nfc_rounded : Icons.notifications_outlined;
    final Color iconColor = isRfid ? Colors.amber : Colors.lightBlue;
    final Color cardColor = isRead 
        ? Colors.grey.withOpacity(0.05)
        : Colors.amber.withOpacity(0.06);
    final Color borderColor = isRead
        ? Colors.grey.withOpacity(0.1)
        : Colors.amber.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.amber.withOpacity(0.05),
          highlightColor: Colors.amber.withOpacity(0.05),
          onTap: () {
            manager.markAsRead(notification['id']);
            _showNotificationDetails(context, notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDateTime(timestamp),
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(controller: _animationController)
     .fadeIn(duration: 400.ms, delay: 200.ms + (index * 50).ms)
     .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 200.ms + (index * 50).ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No Notifications Yet",
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You'll see notifications here when they arrive",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate(controller: _animationController)
     .fadeIn(duration: 600.ms, delay: 300.ms)
     .scale(
       begin: const Offset(0.9, 0.9),
       end: const Offset(1.0, 1.0),
       duration: 600.ms,
       delay: 300.ms,
     );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.amber.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.amber : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.amber : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      // If less than 24 hours, show relative time
      if (difference.inHours < 24) {
        if (difference.inMinutes < 1) {
          return 'Just now';
        } else if (difference.inHours < 1) {
          return '${difference.inMinutes} min ago';
        } else {
          return '${difference.inHours} hr ago';
        }
      }
      
      // If less than 7 days, show day of week and time
      if (difference.inDays < 7) {
        final dayName = [
          'Monday', 'Tuesday', 'Wednesday',
          'Thursday', 'Friday', 'Saturday', 'Sunday'
        ][date.weekday - 1];
        return '$dayName at ${DateFormat('h:mm a').format(date)}';
      }
      
      // Otherwise show the full date
      return DateFormat('MMM dd, yyyy • h:mm a').format(date);
    } catch (_) {
      return '';
    }
  }

  void _showNotificationDetails(BuildContext context, Map<String, dynamic> notification) {
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final timestamp = notification['timestamp'] ?? '';
    final isRfid = notification['type'] == 'rfid';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1D22),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isRfid 
                        ? Colors.amber.withOpacity(0.1) 
                        : Colors.lightBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRfid ? Icons.nfc_rounded : Icons.notifications_outlined,
                      color: isRfid ? Colors.amber : Colors.lightBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Details',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Type', notification['type'] ?? 'Unknown'),
                    _buildDetailRow('ID', '${notification['id'] ?? 'Unknown'}'),
                    _buildDetailRow('Time', _formatDateTime(timestamp)),
                    _buildDetailRow('Status', notification['read'] ?? false ? 'Read' : 'Unread'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade300,
                      side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(
                      'Got it',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation(BuildContext context, BackgroundNotificationManager manager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D22),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        title: Text(
          'Clear All Notifications',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade300,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade400,
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              manager.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All notifications cleared',
                    style: GoogleFonts.montserrat(),
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Clear All',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}