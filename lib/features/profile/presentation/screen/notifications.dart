import 'package:flutter/material.dart';

class NotificationItem {
  final String title;
  final String timeAgo;
  final bool isUrgent;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.timeAgo,
    this.isUrgent = false,
    this.isRead = false,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Urgent: Order #12345 needs immediate attention',
      timeAgo: '10 minutes ago',
      isUrgent: true,
    ),
    NotificationItem(
      title: 'New order assigned to you',
      timeAgo: '25 minutes ago',
    ),
    NotificationItem(
      title: 'Customer has requested a delay',
      timeAgo: '45 minutes ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildNotificationTile(notification),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _markAllAsRead,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: const Text(
                  'Mark All As Read',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem notification) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification indicator dot
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.transparent
                  : (notification.isUrgent ? Colors.red : Colors.blue),
              shape: BoxShape.circle,
            ),
          ),
          // Notification content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: notification.isRead
                        ? FontWeight.w400
                        : FontWeight.w500,
                    color: notification.isRead
                        ? Colors.grey[600]
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.timeAgo,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Options menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
            onSelected: (value) {
              switch (value) {
                case 'read':
                  _markAsRead(notification);
                  break;
                case 'delete':
                  _deleteNotification(notification);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'read',
                child: Text('Mark as read'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      final index = notifications.indexOf(notification);
      notifications[index] = NotificationItem(
        title: notification.title,
        timeAgo: notification.timeAgo,
        isUrgent: notification.isUrgent,
        isRead: true,
      );
    });
  }

  void _deleteNotification(NotificationItem notification) {
    setState(() {
      notifications.remove(notification);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      notifications = notifications
          .map(
            (notification) => NotificationItem(
              title: notification.title,
              timeAgo: notification.timeAgo,
              isUrgent: notification.isUrgent,
              isRead: true,
            ),
          )
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
