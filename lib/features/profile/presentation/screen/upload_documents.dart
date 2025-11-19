import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/features/profile/data/models/rider_documents_model.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';

class UploadDocumentsPage extends StatefulWidget {
  const UploadDocumentsPage({super.key});

  @override
  State<UploadDocumentsPage> createState() => _UploadDocumentsPageState();
}

// =============================================================================
// ENHANCED STATE CLASS
// =============================================================================
class _UploadDocumentsPageState extends State<UploadDocumentsPage> {
  late final ProfileController _controller;
  final ImagePicker _picker = ImagePicker();

  // Use a map to store the selected file and its individual upload progress
  final Map<_DocumentType, DocumentUploadState> _documentStates = {
    for (final type in _DocumentType.values)
      type: DocumentUploadState(file: null, progress: 0.0),
  };

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    // Ensuring ScreenUtil is initialized if used, otherwise remove .w/.h

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Light background
      appBar: const UnifiedProfileAppBar(title: 'Upload Documents'),
      body: Obx(() {
        final documents = _controller.riderDocuments.value;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            children: [
              Wrap(
                spacing: 16.w,
                runSpacing: 16.h,
                children: _DocumentType.values
                    .map((type) => _buildDocumentCard(type, documents))
                    .toList(),
              ),
              SizedBox(height: 32.h),
              _buildUploadButton(),
            ],
          ),
        );
      }),
    );
  }

  // ===========================================================================
  // STYLISH DOCUMENT CARD WITH PROGRESS BAR
  // ===========================================================================
  Widget _buildDocumentCard(
    _DocumentType type,
    RiderDocumentsModel? documents,
  ) {
    final state = _documentStates[type]!;
    final file = state.file;
    final progress = state.progress;
    final existingUrl = _existingUrl(type, documents);
    final preview = type.isImageType
        ? _buildImagePreview(file, existingUrl, type)
        : _buildFilePreview(file, existingUrl, type);

    final cardWidth = (Get.width - 56.w) / 2;

    return SizedBox(
      width: cardWidth,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(
            color: file != null ? Colors.blue.shade100 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // Increased shadow
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Use min size for better fit
          children: [
            // Title and Hint
            Text(
              type.label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1E1E),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              type.hint,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),

            // Preview Area (Fixed height for consistency)
            Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10.w),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.w),
                child: preview,
              ),
            ),
            SizedBox(height: 12.h),

            // Progress Bar (Only visible if progress > 0 and < 1)
            if (progress > 0.0 && progress < 1.0) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue.shade600,
                minHeight: 6.h,
              ),
              SizedBox(height: 4.h),
              Text(
                '${(progress * 100).toInt()}% Uploading...',
                style: TextStyle(fontSize: 10.sp, color: Colors.blue.shade600),
              ),
              SizedBox(height: 8.h),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: progress > 0.0 && progress < 1.0
                        ? null
                        : () => _pickDocument(type),
                    icon: Icon(
                      file != null
                          ? Icons.change_circle_outlined
                          : Icons.upload_rounded,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                    label: Text(
                      file != null ? 'Change' : 'Upload',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: file != null
                          ? Colors.black
                          : Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 4.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                if (file != null)
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: IconButton(
                      onPressed: () => _removeSelection(type),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20.sp,
                        color: Colors.red.shade600,
                      ),
                      tooltip: 'Remove',
                      padding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // STYLISH UPLOAD BUTTON
  // ===========================================================================
  Widget _buildUploadButton() {
    return Obx(() {
      final isLoading = _controller.isUploadingDocuments.value;
      final filesToUploadCount = _documentStates.values
          .where((s) => s.file != null)
          .length;
      final buttonText = filesToUploadCount > 0
          ? 'Save $filesToUploadCount Document${filesToUploadCount > 1 ? 's' : ''}'
          : 'Save Documents';

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : _handleUpload,
          style: ElevatedButton.styleFrom(
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

  // ===========================================================================
  // PICKING LOGIC
  // ===========================================================================
  Future<void> _pickDocument(_DocumentType type) async {
    if (type.isImageType) {
      await _pickImage(type);
    } else {
      await _pickFile(type);
    }
  }

  Future<void> _pickImage(_DocumentType type) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (image == null) return;

    setState(() {
      _documentStates[type] = DocumentUploadState(
        file: File(image.path),
        progress: 0.0,
      );
    });
  }

  Future<void> _pickFile(_DocumentType type) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    final path = result?.files.single.path;
    if (path == null) return;

    setState(() {
      _documentStates[type] = DocumentUploadState(
        file: File(path),
        progress: 0.0,
      );
    });
  }

  void _removeSelection(_DocumentType type) {
    setState(() {
      _documentStates[type] = DocumentUploadState(file: null, progress: 0.0);
    });
  }

  // ===========================================================================
  // SIMULATED UPLOAD LOGIC WITH PROGRESS
  // ===========================================================================
  Future<void> _simulateUploadProgress() async {
    final filesToUpload = _documentStates.entries.where(
      (e) => e.value.file != null,
    );
    if (filesToUpload.isEmpty) return;

    // Reset all progress to 0 before starting
    setState(() {
      for (var entry in filesToUpload) {
        _documentStates[entry.key]!.progress = 0.0;
      }
    });

    // Simulate progress in 10 steps
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() {
        final progressValue = i * 0.1;
        for (var entry in filesToUpload) {
          _documentStates[entry.key]!.progress = progressValue;
        }
      });
    }

    // Set progress to 1.0 (completed)
    setState(() {
      for (var entry in filesToUpload) {
        _documentStates[entry.key]!.progress = 1.0;
      }
    });
  }

  Future<void> _handleUpload() async {
    if (_documentStates.values.every((state) => state.file == null)) {
      Get.snackbar('Attention', 'Please select documents to upload.');
      return;
    }

    // Start simulation (comment this out if you integrate real progress)
    await _simulateUploadProgress();

    // Extract files from the state map
    final filesMap = _documentStates.map(
      (key, state) => MapEntry(key, state.file),
    );

    final success = await _controller.uploadDocuments(
      profileImage: filesMap[_DocumentType.profileImage],
      nationalId: filesMap[_DocumentType.nationalId],
      drivingLicense: filesMap[_DocumentType.drivingLicense],
      vehicleRegistration: filesMap[_DocumentType.vehicleRegistration],
      vehicleInsurance: filesMap[_DocumentType.vehicleInsurance],
    );

    // After API call completes
    setState(() {
      if (success) {
        // Clear only the files that were uploaded successfully
        for (final key in filesMap.keys) {
          if (filesMap[key] != null) {
            _documentStates[key] = DocumentUploadState(
              file: null,
              progress: 0.0,
            );
          }
        }
        Get.snackbar(
          '✅ Success',
          'Documents updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // If failed, reset progress but keep the selected files
        for (var key in _documentStates.keys) {
          _documentStates[key]!.progress = 0.0;
        }
        Get.snackbar(
          '❌ Upload Failed',
          _controller.documentUploadErrorText.isNotEmpty
              ? _controller.documentUploadErrorText
              : 'An unexpected error occurred.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
        );
      }
    });
  }

  String? _existingUrl(_DocumentType type, RiderDocumentsModel? documents) {
    switch (type) {
      case _DocumentType.profileImage:
        return documents?.profileImage ??
            _controller.profile.value?.profileImage;
      case _DocumentType.nationalId:
        return documents?.nationalIdDocument;
      case _DocumentType.drivingLicense:
        return documents?.drivingLicenseDocument;
      case _DocumentType.vehicleRegistration:
        return documents?.vehicleRegistrationDocument;
      case _DocumentType.vehicleInsurance:
        return documents?.vehicleInsuranceDocument;
    }
  }
}

// =============================================================================
// HELPER CLASSES AND ENUMS
// =============================================================================

// New State Model to track file and progress
class DocumentUploadState {
  File? file;
  double progress; // 0.0 to 1.0

  DocumentUploadState({required this.file, required this.progress});
}

enum _DocumentType {
  profileImage,
  nationalId,
  drivingLicense,
  vehicleRegistration,
  vehicleInsurance,
}

extension _DocumentTypeMeta on _DocumentType {
  // ... (Keep existing extensions: label, hint, icon, isImageType)
  String get label {
    switch (this) {
      case _DocumentType.profileImage:
        return 'Profile Photo';
      case _DocumentType.nationalId:
        return 'National ID';
      case _DocumentType.drivingLicense:
        return 'Driving License';
      case _DocumentType.vehicleRegistration:
        return 'Vehicle Registration';
      case _DocumentType.vehicleInsurance:
        return 'Vehicle Insurance';
    }
  }

  String get hint {
    switch (this) {
      case _DocumentType.profileImage:
        return 'Upload a clear headshot (Image)';
      case _DocumentType.nationalId:
        return 'Front side of your ID (Any file)';
      case _DocumentType.drivingLicense:
        return 'License copy or photo (Any file)';
      case _DocumentType.vehicleRegistration:
        return 'Vehicle registration document (Any file)';
      case _DocumentType.vehicleInsurance:
        return 'Insurance certificate or card (Any file)';
    }
  }

  IconData get icon {
    switch (this) {
      case _DocumentType.profileImage:
        return Icons.person_outline;
      case _DocumentType.nationalId:
        return Icons.badge_outlined;
      case _DocumentType.drivingLicense:
        return Icons.credit_card;
      case _DocumentType.vehicleRegistration:
        return Icons.directions_car;
      case _DocumentType.vehicleInsurance:
        return Icons.verified_user_outlined;
    }
  }

  bool get isImageType => this == _DocumentType.profileImage;
}

// =============================================================================
// PREVIEW WIDGETS (Slightly improved styling)
// =============================================================================
Widget _buildFilePreview(File? file, String? existingUrl, _DocumentType type) {
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

Widget _buildImagePreview(File? file, String? existingUrl, _DocumentType type) {
  // Use a Stack to ensure the placeholder icon/text is visible if the network image fails
  return Stack(
    fit: StackFit.expand,
    children: [
      if (file != null) Image.file(file, fit: BoxFit.cover),

      if (file == null && existingUrl != null && existingUrl.isNotEmpty)
        Image.network(
          existingUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(type),
        ),

      if (file == null && (existingUrl == null || existingUrl.isEmpty))
        _buildPlaceholder(type),
    ],
  );
}

Widget _buildPlaceholder(_DocumentType type) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(type.icon, size: 32.sp, color: Colors.grey[400]),
      SizedBox(height: 4.h),
      Text(
        'No image yet',
        style: TextStyle(color: Colors.grey[500], fontSize: 10.sp),
      ),
    ],
  );
}
