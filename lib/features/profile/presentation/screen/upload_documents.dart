// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/core/utils/constants/enums.dart';
import 'package:quikle_rider/features/profile/presentation/controller/kyc_controller.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/features/profile/presentation/widgets/document_upload_card.dart';
import 'package:quikle_rider/routes/app_routes.dart';

class UploadDocumentsPage extends StatelessWidget {
  UploadDocumentsPage({super.key}) : _kycController = _ensureKycController();

  final KycController _kycController;

  static KycController _ensureKycController() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    return Get.isRegistered<KycController>()
        ? Get.find<KycController>()
        : Get.put(KycController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const UnifiedProfileAppBar(title: 'Profile & Documents'),
      body: GetBuilder<KycController>(
        builder: (_) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                SizedBox(height: 16.h),
                ...DocumentType.values
                    .map(
                      (type) => DocumentUploadCard(
                        type: type,
                        kycController: _kycController,
                      ),
                    )
                    .toList(),
                SizedBox(height: 20.h),
                _buildUploadButton(),
                SizedBox(height: 5.h),
                TextButton(
                  onPressed: () => Get.offAllNamed(AppRoute.getBottomNavBar()),
                  style: TextButton.styleFrom(foregroundColor: Colors.black54),
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52.w,
            width: 52.w,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.4),
            ),

            child: const Icon(
              Icons.cloud_upload_outlined,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Documents',
                  style: getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Complete verification to start accepting orders.',
                  style: getTextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Obx(() {
      final isLoading = _kycController.isUploadingDocuments.value;
      final filesToUploadCount = _kycController.selectedFilesCount;
      final buttonText = filesToUploadCount > 0
          ? 'Save & Submit (${filesToUploadCount} file${filesToUploadCount > 1 ? 's' : ''})'
          : 'Save & Submit for Verification';

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : _kycController.handleUpload,
          style: ElevatedButton.styleFrom(
            side: BorderSide.none,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.w),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? Center(
                  child: LoadingAnimationWidget.inkDrop(
                    color: Colors.black,
                    size: 35.w,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
