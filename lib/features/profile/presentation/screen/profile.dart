// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/widgets/connection_lost.dart';
import 'package:quikle_rider/features/home/controllers/homepage_controller.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/features/profile/presentation/widgets/profile_components/profile_completion_section.dart';
import 'package:quikle_rider/features/profile/presentation/widgets/profile_components/profile_header_section.dart';
import 'package:quikle_rider/features/profile/presentation/widgets/profile_components/profile_menu_section.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key}) {
    _controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    if (_controller.profile.value == null) {
      _controller.resetProfileFetchState();
    }
  }

  late final ProfileController _controller;
  final HomepageController _homeController = Get.find<HomepageController>();

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 64.w,
                  width: 64.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: const Color(0xFFE53935),
                    size: 34.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Delete account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "This action is permanent and will remove your profile and data.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          side: BorderSide.none,
                          backgroundColor: const Color(0xFFE53935),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Delete",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: UnifiedProfileAppBar(
          showActionButton: true,
          isback: false,
          title: "Profile",
          action: "Notification",
          onActionPressed: () {},
        ),
        body: Obx(
          () => _homeController.hasConnection.value == false
              ? ConnectionLost()
              : SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      ProfileHeaderSection(controller: _controller),
                      SizedBox(height: 16.h),
                      ProfileCompletionSection(controller: _controller),
                      ProfileMenuSection(controller: _controller),
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                         
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delete account",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "Remove your profile permanently.",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showDeleteAccountDialog(context),
                                icon: Icon(
                                  Iconsax.profile_delete,
                                  size: 18.sp,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "Delete account",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide.none,
                                  backgroundColor: const Color(0xFFE53935),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 0,
                                ),
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
    );
  }
}
