// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/features/profile/presentation/controller/kyc_controller.dart';

class DocumentUploadCard extends StatelessWidget {
  const DocumentUploadCard({
    super.key,
    required this.type,
    required this.kycController,
  });

  final DocumentType type;
  final KycController kycController;

  @override
  Widget build(BuildContext context) {
    final state = kycController.documentStates[type]!;
    final file = state.file;
    final progress = state.progress;
    final existingUrl = kycController.existingDocumentUrl(type);
    final status = _resolveStatus(type, file, existingUrl);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          left: BorderSide(color: _getBorderColor(), width: 4.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(status),
          SizedBox(height: 16.h),
          if (type == DocumentType.profileImage)
            _buildProfileSection(file, existingUrl)
          else
            _buildDocumentSection(file, existingUrl, progress),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    switch (type) {
      case DocumentType.vehicleInsurance:
        return AppColors.buttoncolor;
      case DocumentType.drivingLicense:
        return AppColors.greenbutton;
      case DocumentType.vehicleRegistration:
        return AppColors.beakYellow;
      case DocumentType.nationalId:
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildHeader(_DocumentStatus status) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: _getBorderColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(type.icon, color: _getBorderColor(), size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            _sectionTitle(),
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        _statusChip(status),
      ],
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
        style: getTextStyle(fontSize: 11, fontWeight: FontWeight.w600)
            .copyWith(color: status.textColor),
      ),
    );
  }

  Widget _buildProfileSection(File? file, String? existingUrl) {
    final imageProvider = _resolveImageProvider(file, existingUrl);

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 100.w,
              width: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
                color: Colors.white,
              ),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Icon(Icons.photo_camera_outlined,
                        color: Colors.grey[400], size: 40)
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 32.w,
                width: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'Tap to upload a clear photo',
          style: getTextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        SizedBox(height: 16.h),
        _buildPrimaryButton(
          label: 'Upload Photo',
          icon: Icons.cloud_upload_outlined,
          onPressed: () => kycController.pickDocument(type),
        ),
      ],
    );
  }

  Widget _buildDocumentSection(File? file, String? existingUrl, double progress) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildFormFields()),
            SizedBox(width: 12.w),
            _buildUploadBox(file, existingUrl),
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
        SizedBox(height: 16.h),
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
                label: _canViewDocument(file, existingUrl) ? 'Re-upload' : 'Upload',
                onPressed: () => kycController.pickDocument(type),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (type == DocumentType.nationalId) ...[
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            value: kycController.idProofType.value,
            items: KycController.idProofTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                kycController.idProofType.value = value;
                kycController.update();
              }
            },
            decoration: _inputDecoration('Select ID Type'),
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: kycController.idProofNumberController,
            decoration: _inputDecoration('Enter ID Number'),
          ),
        ] else if (type == DocumentType.drivingLicense)
          TextFormField(
            controller: kycController.drivingLicenseNumberController,
            decoration: _inputDecoration('Enter License Number'),
          )
        else if (type == DocumentType.vehicleRegistration)
          TextFormField(
            controller: kycController.vehicleRegistrationNumberController,
            decoration: _inputDecoration('Enter Registration Number'),
          ),
        SizedBox(height: 12.h),
        _buildHintBlock(),
      ],
    );
  }

  Widget _buildHintBlock() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              type.hint,
              style: getTextStyle(fontSize: 12, color: Colors.blue[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox(File? file, String? existingUrl) {
    final hasFile = file != null || (existingUrl?.isNotEmpty ?? false);

    return GestureDetector(
      onTap: () => kycController.pickDocument(type),
      child: Container(
        width: 100.w,
        height: 120.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFile ? Icons.insert_drive_file : Icons.cloud_upload_outlined,
                color: hasFile ? AppColors.primary : Colors.grey[500],
                size: 28.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              hasFile ? 'Uploaded' : 'Tap to Upload',
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: hasFile ? AppColors.primary : Colors.grey[600],
              ),
            ),
          ],
        ),
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
        side: BorderSide.none,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 18.sp), SizedBox(width: 8.w)],
          Text(label, style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
        padding: EdgeInsets.symmetric(vertical: 14.h),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
      child: Text(
        label,
        style: getTextStyle(fontSize: 14, color: AppColors.backgroundDark),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: getTextStyle(fontSize: 13, color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    );
  }

  String _sectionTitle() {
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

  ImageProvider? _resolveImageProvider(File? file, String? existingUrl) {
    if (file != null) return FileImage(file);
    if (existingUrl != null && existingUrl.isNotEmpty) return NetworkImage(existingUrl);
    return null;
  }

  bool _canViewDocument(File? file, String? existingUrl) =>
      file != null || (existingUrl?.isNotEmpty ?? false);

  void _openPreview(DocumentType type, File? file, String? existingUrl) {
    if (type.isImageType) {
      final provider = _resolveImageProvider(file, existingUrl);
      if (provider == null) return;
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image(image: provider, fit: BoxFit.cover),
          ),
        ),
      );
      return;
    }
    Get.snackbar('Document Ready', 'File is available to view');
  }

  _DocumentStatus _resolveStatus(DocumentType type, File? file, String? existingUrl) {
    final hasFile = file != null || (existingUrl?.isNotEmpty ?? false);
    if (!hasFile) {
      return const _DocumentStatus(
        label: 'Not Uploaded',
        background: Color(0xFFE0E0E0),
        textColor: Color(0xFF616161),
      );
    }

    final isVerified =
        kycController.riderDocuments?.isVerified ??
        kycController.profileController.isVerifiedApproved;
    if (isVerified) {
      return const _DocumentStatus(
        label: 'Approved',
        background: Color(0xFFE6F4EA),
        textColor: Color(0xFF2E7D32),
      );
    }

    if (kycController.profileController.isVerificationRejected) {
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