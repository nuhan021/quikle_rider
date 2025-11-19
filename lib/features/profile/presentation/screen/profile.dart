// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/features/profile/presentation/screen/availability_settings.dart';
import 'package:quikle_rider/features/profile/presentation/screen/delivery_zone.dart';
import 'package:quikle_rider/features/profile/presentation/screen/help_support.dart';
import 'package:quikle_rider/features/profile/presentation/screen/my_profile.dart';
import 'package:quikle_rider/features/profile/presentation/screen/notification_settings.dart';
import 'package:quikle_rider/features/profile/presentation/screen/payment_method.dart';
import 'package:quikle_rider/features/profile/presentation/screen/vehicle_information.dart';
import 'package:quikle_rider/features/profile/widgets/profile_completion_card.dart';
import 'package:quikle_rider/features/wallet/widgets/tier_badge.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key}) {
    _controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
  }

  late final ProfileController _controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: UnifiedProfileAppBar(
          showActionButton: true,
          title: "Profile",
          action: "Notification",
          onActionPressed: () {},
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              /// Profile Header
              _buildProfileHeader(),
              SizedBox(height: 16.h),
              const ProfileCompletionCard(
                completionPercent: 85,
                missingItems: [
                  'Vehicle Insurance certificate',
                  'Emergency contact',
                ],
                motivationMessage: 'Complete 100% to unlock Gold tier',
                onCompleteNow: null,
              ),
              SizedBox(height: 30.h),
      
              // Menu Items Container
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      imagepath: "assets/icons/profileicon.png",
                      title: 'My Profile',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyProfilePage(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      imagepath: "assets/icons/vehicle.png",
                      title: 'Vehicle Information',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VehicleInformationPage(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      imagepath: "assets/icons/location.png",
                      title: 'Delivery Zone',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  DeliveryZonePage(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      imagepath: "assets/icons/payment.png",
                      title: 'Payment Method',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentMethodPage(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      imagepath: "assets/icons/avaiability.png",
                      title: 'Availability Settings',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AvailabilitySettingsPage(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      imagepath: "assets/icons/notification.png",
                      title: 'Notification Settings',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationSettingsPage(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      imagepath: "assets/icons/language.png",
                      title: 'Language Settings',
                      onTap: () {
                        _showLanguageDialog(context);
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      imagepath: "assets/icons/help.png",
                      title: 'Help & Support',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportPage(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      imagepath: "assets/icons/signout.png",
                      title: 'Sign out',
                      onTap: () => _showSignOutDialog(context),
                      isSignOut: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() {
      if (_controller.shouldShowLoadingHeader) {
        return _buildLoadingHeader();
      }

      if (_controller.shouldShowErrorHeader) {
        return _buildErrorHeader(_controller.headerErrorText);
      }

      return _buildProfileDetailsCard(
        name: _controller.displayName,
        email: _controller.displayEmail,
        imageUrl: _controller.profileImageUrl,
      );
    });
  }

  Widget _buildProfileDetailsCard({
    required String name,
    required String email,
    String? imageUrl,
  }) {
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    final displayName = name.trim().isNotEmpty ? name : 'Rider';
    final displayEmail =
        email.trim().isNotEmpty ? email : 'Email not available';
    final ImageProvider avatarProvider = hasImage
        ? NetworkImage(imageUrl!)
        : const AssetImage("assets/images/avatar.png");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: _profileCardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [TierBadge(tier: "Silver")],
            ),
          ),
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: avatarProvider,
          ),
          SizedBox(height: 12.h),
          Text(
            displayName,
            style: getTextStyle2(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            displayEmail,
            style: getTextStyle2(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: _profileCardDecoration(),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorHeader(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _profileCardDecoration(),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red[600],
            size: 40,
          ),
          SizedBox(height: 12.h),
          Text(
            'Unable to load profile',
            style: getTextStyle2(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: getTextStyle2(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _controller.fetchProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  BoxDecoration _profileCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String imagepath,
    required String title,
    required VoidCallback onTap,
    bool isSignOut = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Image.asset(
              imagepath,
              width: 24.sp,
              height: 24.sp,
              color: isSignOut ? Colors.red[600] : Colors.grey[700],
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: isSignOut ? Colors.red[600] : Colors.black87,
                ),
              ),
            ),
            if (!isSignOut)
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1.h,
      thickness: 0.5,
      color: Colors.grey[200],
      indent: 60.w,
      endIndent: 20.w,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final List<String> languages = ["English", "Spanish", "French", "German"];
    String selectedLang = languages.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Language Settings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Choose Language",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedLang,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      items: languages
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedLang = value!);
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Language set to $selectedLang"),
                            ),
                          );
                        },
                        child: const Text("Save Language"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
              onPressed: () => Navigator.pop(context),
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
                Navigator.pop(context);
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
