// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key, required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasData = controller.profile.value != null;
      final isLoading = controller.isLoading.value;
      final hasError = controller.shouldShowErrorHeader;
      final hasAttempted = controller.hasAttemptedProfileFetch;

      if (!isLoading && !hasData && !hasAttempted) {
        controller.fetchProfile();
        return _buildLoadingHeader();
      }

      if (controller.shouldShowLoadingHeader) {
        return _buildLoadingHeader();
      }

      if (hasError && hasAttempted) {
        return _buildErrorHeader(controller.headerErrorText);
      }

      return _buildProfileDetailsCard(
        name: controller.displayName,
        email: controller.displayEmail,
        imageUrl: controller.profileImageUrl,
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
    final displayEmail = email.trim().isNotEmpty
        ? email
        : 'Email not available';
    final Widget avatar = hasImage
        ? Image.network(
            imageUrl.trim(),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                "assets/images/quickle_black.png",
                fit: BoxFit.cover,
              );
            },
          )
        : Image.asset(
            "assets/images/empty_profile.jpg",
            fit: BoxFit.cover,
          );
    final bool isVerified = controller.isVerifiedApproved;
    final bool isPending = controller.isVerificationPending;
    final String statusLabel = controller.verificationStatusLabel;
    final Color statusColor = isVerified
        ? const Color(0xFF1E8E3E)
        : isPending
            ? const Color(0xFFB26A00)
            : const Color(0xFFD93025);
    final Color statusBackground = isVerified
        ? const Color(0xFFE6F4EA)
        : isPending
            ? const Color(0xFFFFF4E5)
            : const Color(0xFFFDECEC);
    final IconData statusIcon = isVerified
        ? Icons.verified
        : isPending
            ? Icons.schedule
            : Icons.error_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: _profileCardDecoration(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0.h,
            right: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: statusBackground,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusIcon,
                    size: 14,
                    color: statusColor,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    statusLabel,
                    style: getTextStyle2(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: avatar,
                  ),
                ),
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
        ],
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: _profileCardDecoration(),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorHeader(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: _profileCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile unavailable',
            style: getTextStyle2(
              fontSize: 16,
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
              onPressed: controller.fetchProfile,
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
