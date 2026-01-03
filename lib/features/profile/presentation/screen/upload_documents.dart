// ignore_for_file: deprecated_member_use

import 'dart:io';

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 16.h),
                ...DocumentType.values
                    .map((type) => _buildDocumentCard(type))
                    .toList(),
                SizedBox(height: 20.h),
                _buildUploadButton(),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () => Get.offAllNamed(AppRoute.getBottomNavBar()),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black54,
                  ),
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
        color: Colors.white,
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
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.4),
            ),
            child: const Icon(Icons.folder_open, color: Colors.black),
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

  Widget _buildDocumentCard(DocumentType type) {
    final state = _kycController.documentStates[type]!;
    final file = state.file;
    final progress = state.progress;
    final existingUrl = _kycController.existingDocumentUrl(type);
    final status = _resolveStatus(type, file, existingUrl);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
                      _sectionTitle(type),
                      style: getTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(status),
            ],
          ),
          SizedBox(height: 14.h),
          if (type == DocumentType.profileImage) ...[
            _buildProfilePhotoRow(file, existingUrl),
            SizedBox(height: 12.h),
            _buildPrimaryButton(
              label: 'Upload Photo',
              icon: Icons.upload_rounded,
              onPressed: () => _kycController.pickDocument(type),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: type == DocumentType.nationalId
                      ? _buildIdProofFields()
                      : _buildHintBlock(type),
                ),
                SizedBox(width: 12.w),
                _buildUploadTile(type, file, existingUrl),
              ],
            ),
            if (progress > 0.0 && progress < 1.0) ...[
              SizedBox(height: 12.h),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: AppColors.primary,
                minHeight: 5.h,
              ),
              SizedBox(height: 4.h),
              Text(
                '${(progress * 100).toInt()}% uploading...',
                style: getTextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryButton(
                    label: 'View',
                    onPressed: _canViewDocument(file, existingUrl)
                        ? () => _openPreview(type, file, existingUrl)
                        : null,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildPrimaryButton(
                    label: _canViewDocument(file, existingUrl)
                        ? 'Re-upload'
                        : 'Upload',
                    onPressed: () => _kycController.pickDocument(type),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(_DocumentStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.label,
        style: getTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ).copyWith(color: status.textColor),
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

  Widget _buildIdProofFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          value: _kycController.idProofType.value,
          items: KycController.idProofTypes
              .map(
                (type) => DropdownMenuItem<String>(
                  
                  value: type,
                  child: Text(type),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            _kycController.idProofType.value = value;
            _kycController.update();
          },
          decoration: _inputDecoration('ID Proof Type'),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _kycController.idProofNumberController,
          keyboardType: TextInputType.text,
          decoration: _inputDecoration('ID Proof Number'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: getTextStyle(
        font: CustomFonts.inter,
        fontSize: 13,
        color: Colors.grey[500],
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.black, width: 1.0),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ),
    );
  }

  String _sectionTitle(DocumentType type) {
    switch (type) {
      case DocumentType.profileImage:
        return 'Profile Photo';
      case DocumentType.nationalId:
        return 'ID Proof';
      case DocumentType.drivingLicense:
        return 'Driving License';
      case DocumentType.vehicleRegistration:
        return 'Vehicle Registration';
      case DocumentType.vehicleInsurance:
        return 'Vehicle Insurance';
    }
  }

  Widget _buildProfilePhotoRow(File? file, String? existingUrl) {
    final imageProvider = _resolveImageProvider(file, existingUrl);
    return Row(
      children: [
        Container(
          height: 56.w,
          width: 56.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.6),
            color: AppColors.primary.withOpacity(0.12),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(Icons.photo_camera_outlined, color: Colors.black)
                : null,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            'Upload a clear face photo.',
            style: getTextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  ImageProvider? _resolveImageProvider(File? file, String? existingUrl) {
    if (file != null) return FileImage(file);
    if (existingUrl != null && existingUrl.isNotEmpty) {
      return NetworkImage(existingUrl);
    }
    return null;
  }

  Widget _buildHintBlock(DocumentType type) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(type.icon, color: Colors.grey[600], size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              type.hint,
              style: getTextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTile(DocumentType type, File? file, String? existingUrl) {
    final hasFile =
        file != null || (existingUrl != null && existingUrl.isNotEmpty);
    final displayName = file != null
        ? file.path.split('/').last
        : (existingUrl != null && existingUrl.isNotEmpty
              ? existingUrl.split('/').last
              : 'No file');

    return Container(
      width: 100.w,
      height: 100.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFile ? Icons.insert_drive_file : Icons.cloud_upload_outlined,
            color: hasFile ? Colors.black87 : Colors.grey[500],
            size: 26.sp,
          ),
          SizedBox(height: 6.h),
          Text(
            hasFile ? displayName : 'Upload',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: getTextStyle(
              fontSize: 10,
              color: hasFile ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18.sp),
            SizedBox(width: 6.w),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.backgroundDark,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  bool _canViewDocument(File? file, String? existingUrl) {
    return file != null || (existingUrl != null && existingUrl.isNotEmpty);
  }

  void _openPreview(DocumentType type, File? file, String? existingUrl) {
    final isImage = type.isImageType;
    if (isImage) {
      final provider = _resolveImageProvider(file, existingUrl);
      if (provider == null) return;
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image(
              image: provider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
      return;
    }
    final name = file?.path.split('/').last ??
        existingUrl?.split('/').last ??
        'Document';
    Get.snackbar('Document Ready', name);
  }

  _DocumentStatus _resolveStatus(
    DocumentType type,
    File? file,
    String? existingUrl,
  ) {
    final hasFile = file != null || (existingUrl?.isNotEmpty ?? false);
    if (!hasFile) {
      return const _DocumentStatus(
        label: 'Not Uploaded',
        background: Color(0xFFE0E0E0),
        textColor: Color(0xFF616161),
      );
    }

    final docVerified = _kycController.riderDocuments?.isVerified;
    final isVerified =
        docVerified ?? _kycController.profileController.isVerified.value;
    if (isVerified == true) {
      return const _DocumentStatus(
        label: 'Approved',
        background: Color(0xFFE6F4EA),
        textColor: Color(0xFF2E7D32),
      );
    }

    final verificationError =
        _kycController.profileController.verificationError.value ?? '';
    final isRejected = verificationError.toLowerCase().contains('rejected') ||
        verificationError.toLowerCase().contains('declined');
    if (isRejected) {
      return const _DocumentStatus(
        label: 'Rejected',
        background: Color(0xFFFDECEA),
        textColor: Color(0xFFC62828),
      );
    }

    return const _DocumentStatus(
      label: 'Submitted',
      background: Color(0xFFFFF4E5),
      textColor: Color(0xFFB26A00),
    );
  }
}

class _DocumentStatus {
  const _DocumentStatus({
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;
}
