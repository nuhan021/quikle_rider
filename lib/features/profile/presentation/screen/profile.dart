import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/custom_tab_bar/custom_tab_bar.dart';
import 'package:quikle_rider/features/profile/presentation/screen/help_support.dart';
import 'package:quikle_rider/features/profile/presentation/screen/my_profile.dart';
import 'package:quikle_rider/features/profile/presentation/screen/payment_method.dart';
import 'package:quikle_rider/features/profile/presentation/screen/vehicle_information.dart';
import 'package:quikle_rider/features/profile/presentation/screen/delivery_zone.dart';
import 'package:quikle_rider/features/profile/presentation/screen/availability_settings.dart';
import 'package:quikle_rider/features/profile/presentation/screen/notification_settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isOnline = true; // State for toggle switch

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil if not already done in your app
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTabBar(
        title: 'Profile',
        isOnline: _isOnline,
        onToggle: _toggleOnlineStatus,
        currentIndex: 3, // Assuming ProfileScreen is the fourth tab
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(25.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundImage: const AssetImage(
                      'assets/profile_avatar.png',
                    ),
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    'Vikram Rajput',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'vikramrajput@gmail.com',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            // Menu Items
            _buildMenuItem(
              context: context,
              icon: Icons.person_outline,
              title: 'My Profile',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MyProfilePage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.directions_car_outlined,
              title: 'Vehicle Information',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const VehicleInformationPage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.location_on_outlined,
              title: 'Delivery Zone',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DeliveryZonePage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.payment_outlined,
              title: 'Payment Method',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PaymentMethodPage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.access_time_outlined,
              title: 'Availability Settings',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AvailabilitySettingsPage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.edit_notifications,
              title: 'Notification Settings',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsPage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.language_outlined,
              title: 'Language Settings',
              onTap: () {
                // TODO: Implement navigation for Language Settings
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportPage(),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
            _buildMenuItem(
              context: context,
              icon: Icons.logout,
              title: 'Sign out',
              onTap: () {
                _showSignOutDialog(context);
              },
              isSignOut: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSignOut = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.h),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 5.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isSignOut ? Colors.red[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: isSignOut ? Colors.red[600] : Colors.grey[700],
            size: 20.sp,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: isSignOut ? Colors.red[600] : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          title: Text(
            'Sign Out',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle sign out logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              ),
              child: Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
