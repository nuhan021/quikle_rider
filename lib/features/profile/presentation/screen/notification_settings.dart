import 'package:flutter/material.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool orderNotifications = true;
  bool pushNotifications = true;
  bool sound = true;
  bool vibration = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: UnifiedProfileAppBar(title: "Notification Settings"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingTile(
              title: 'Order Notifications',
              subtitle: 'New orders, cancellations, status updates',
              value: orderNotifications,
              onChanged: (value) {
                setState(() {
                  orderNotifications = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              title: 'Push Notifications',
              subtitle: 'System updates, promotional offers',
              value: pushNotifications,
              onChanged: (value) {
                setState(() {
                  pushNotifications = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              title: 'Sound',
              subtitle: '',
              value: sound,
              onChanged: (value) {
                setState(() {
                  sound = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              title: 'Vibration',
              subtitle: '',
              value: vibration,
              onChanged: (value) {
                setState(() {
                  vibration = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            trackOutlineColor: WidgetStateProperty.all(AppColors.greenbutton2),
            focusColor: AppColors.greenbutton2,
            hoverColor: AppColors.greenbutton2,
            inactiveTrackColor: AppColors.primaryBackground,
            inactiveThumbColor: AppColors.greenbutton2,
            activeThumbColor: AppColors.primaryBackground,
            value: value,
            onChanged: onChanged,

            activeTrackColor: AppColors.greenbutton2,
          ),
        ],
      ),
    );
  }
}
