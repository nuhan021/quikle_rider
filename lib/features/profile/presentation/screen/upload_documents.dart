// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/features/profile/presentation/controller/kyc_controller.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';

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
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: const UnifiedProfileAppBar(title: 'Profile & Documents'),
      body: GetBuilder<KycController>(
        builder: (_) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 24.h),
                Text(
                  'Required Documents',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                ...DocumentType.values
                    .map((type) => _buildDocumentCard(type))
                    .toList(),
                SizedBox(height: 24.h),
                _buildUploadButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(height: 48.h, image: AssetImage("assets/images/logo.png")),
          SizedBox(height: 12.h),
          Text.rich(
            TextSpan(
              text: 'Profile & ',
              style: getTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              children: [
                TextSpan(
                  text: 'Documents',
                  style: getTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Verification required to start earning',
            style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'All documents must be verified to access Gold tier benefits.',
                    style: getTextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentType type) {
    final state = _kycController.documentStates[type]!;
    final file = state.file;
    final progress = state.progress;
    final existingUrl = _kycController.existingDocumentUrl(type);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: getTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (type == DocumentType.drivingLicense) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Expires: 2028-03-15',
                        style: getTextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _statusChip('Pending'),
            ],
          ),
          SizedBox(height: 16.h),
          _buildPreviewArea(type, file, existingUrl),
          if (progress > 0.0 && progress < 1.0) ...[
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primary,
              minHeight: 6.h,
            ),
            SizedBox(height: 4.h),
            Text(
              '${(progress * 100).toInt()}% uploading...',
              style: getTextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
          SizedBox(height: 16.h),
          if (type == DocumentType.profileImage)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _kycController.pickDocument(type),
                style: ElevatedButton.styleFrom(
                  side: BorderSide.none,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_rounded, color: Colors.white),
                    SizedBox(width: 8.w),
                    const Text('Upload Photo'),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => existingUrl,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: const Text('View'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _kycController.pickDocument(type),
                    style: ElevatedButton.styleFrom(
                      side: BorderSide.none,
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: const Text('Re-upload'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statusChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: getTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ).copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildPreviewArea(DocumentType type, File? file, String? existingUrl) {
    if (type.isImageType) {
      ImageProvider? imageProvider;
      if (file != null) {
        imageProvider = FileImage(file);
      } else if (existingUrl != null && existingUrl.isNotEmpty) {
        imageProvider = NetworkImage(existingUrl);
      }

      return Container(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: CircleAvatar(
          radius: 40.w,
          backgroundColor: AppColors.primary.withOpacity(0.15),
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Icon(Icons.cloud_upload_outlined, size: 32.sp)
              : null,
        ),
      );
    }

    final preview = _buildFilePreview(file, existingUrl, type);
    return Container(
      height: 120.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: preview,
    );
  }

  Widget _buildUploadButton() {
    return Obx(() {
      final isLoading = _kycController.isUploadingDocuments.value;
      final filesToUploadCount = _kycController.selectedFilesCount;
      final buttonText = filesToUploadCount > 0
          ? 'Save $filesToUploadCount Document${filesToUploadCount > 1 ? 's' : ''}'
          : 'Save Documents';

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : _kycController.handleUpload,
          style: ElevatedButton.styleFrom(
            side: BorderSide.none,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.w),
            ),
            elevation: 8,
          ),
          child: isLoading
              ? SizedBox(
                  height: 22.h,
                  width: 22.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      );
    });
  }
}

Widget _buildFilePreview(File? file, String? existingUrl, DocumentType type) {
  final displayName = file != null
      ? file.path.split('/').last
      : (existingUrl != null && existingUrl.isNotEmpty
            ? existingUrl.split('/').last
            : 'No file selected');

  final hasFile =
      file != null || (existingUrl != null && existingUrl.isNotEmpty);

  return Center(
    child: Padding(
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFile ? Icons.insert_drive_file : type.icon,
            size: 32.sp,
            color: hasFile ? Colors.blue.shade700 : Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          Text(
            displayName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              color: hasFile ? Colors.black87 : Colors.grey[500],
              fontWeight: hasFile ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
