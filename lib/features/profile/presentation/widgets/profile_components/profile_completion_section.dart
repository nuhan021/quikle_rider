// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/features/profile/presentation/widgets/profile_components/profile_completion_card.dart';

class ProfileCompletionSection extends StatelessWidget {
  const ProfileCompletionSection({super.key, required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isProfileCompletionLoading.value;
      final completion = controller.profileCompletion.value;
      final error = controller.profileCompletionError.value;
      final shouldDisplay =
          isLoading || completion != null || (error?.isNotEmpty ?? false);

      if (!shouldDisplay) {
        return const SizedBox.shrink();
      }

      Widget content;
      if (isLoading) {
        content = Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 32.h),
          decoration: _profileCardDecoration(),
          child: const Center(child: CircularProgressIndicator()),
        );
      } else if (completion == null) {
        content = _buildCompletionErrorCard(
          error ?? 'Unable to load profile completion.',
        );
      } else {
        content = ProfileCompletionCard(
          completionPercent: completion.completionPercentage,
          missingItems: completion.missingFields,
          onCompleteNow: null,
        );
      }

      return Column(
        children: [
          content,
          SizedBox(height: 30.h),
        ],
      );
    });
  }

  Widget _buildCompletionErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: _profileCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile completion unavailable',
            style: getTextStyle2(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: getTextStyle2(fontSize: 13, color: Colors.black54),
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.fetchProfileCompletion,
              child: const Text('Retry'),
            ),
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
}
