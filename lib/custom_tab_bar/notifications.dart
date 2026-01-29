import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/features/notifications/controller/notification_controller.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = NotificationController.to;
      controller.fetchNotifications(
        showLoader: controller.notifications.isEmpty,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.to;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: UnifiedProfileAppBar(title: "Notifications"),
      body: Obx(() {
        final notifications = controller.notifications;
        final hasUnread = controller.hasUnread;
        final isLoading = controller.isLoading.value;
        final errorMessage = controller.errorMessage.value;

        if (isLoading && notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage != null &&
            errorMessage.isNotEmpty &&
            notifications.isEmpty) {
          return _buildErrorState(
            errorMessage,
            onRetry: () => controller.fetchNotifications(),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    controller.fetchNotifications(showLoader: false),
                child: notifications.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _buildEmptyState(),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildNotificationTile(
                              context,
                              controller,
                              notification,
                              screenWidth,
                            ),
                          );
                        },
                      ),
              ),
            ),
            if (hasUnread)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: SizedBox(
                  width: screenWidth * 0.9,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      controller.markAllAsRead();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications marked as read'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Mark All As Read',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Manrope',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            color: Colors.grey[400],
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'You\'re all caught up',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New updates will show up here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    String message, {
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 52,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationController controller,
    AppNotification notification,
    double screenWidth,
  ) {
    return InkWell(
      onTap: () {
        controller.openNotification(notification);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: screenWidth * 0.9,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isUrgent
                ? const Color(0x4DFF0000)
                : const Color(0xFFFFFFFF),
            width: 0.8,
          ),
          boxShadow: [
            const BoxShadow(
              color: Color(0x1A9E9E9E),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: notification.isRead
                          ? Colors.grey[600]
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: notification.isRead
                          ? Colors.grey[600]
                          : Colors.black,
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
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
              onSelected: (value) {
                switch (value) {
                  case 'read':
                    controller.markAsRead(notification.id);
                    break;
                  case 'delete':
                    controller.removeNotification(notification.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification deleted'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) => const [
                PopupMenuItem<String>(
                  value: 'read',
                  child: Text('Mark as read'),
                ),
                PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
