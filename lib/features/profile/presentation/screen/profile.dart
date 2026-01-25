// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
                      
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
