import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/features/bottom_nav_bar/screen/bottom_nav_bar.dart';
import 'package:quikle_rider/features/profile/data/models/rider_documents_model.dart';
import 'package:quikle_rider/features/profile/data/services/profile_services.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:flutter/material.dart';

// New State Model to track file and progress
class DocumentUploadState {
  File? file;
  double progress; // 0.0 to 1.0

  DocumentUploadState({required this.file, required this.progress});
}

enum DocumentType {
  profileImage,
  nationalId,
  drivingLicense,
  vehicleRegistration,
  vehicleInsurance,
}

class KycController extends GetxController {
  KycController({ProfileServices? profileServices})
    : _profileServices = profileServices ?? ProfileServices();

  final ProfileServices _profileServices;
  final ImagePicker _picker = ImagePicker();
  final ProfileController _profileController = Get.find<ProfileController>();
  static const List<String> idProofTypes = ['Aadhaar', 'PAN', 'Voter ID'];
  final idProofType = idProofTypes.first.obs;
  final idProofNumberController = TextEditingController();
  final drivingLicenseNumberController = TextEditingController();
  final vehicleRegistrationNumberController = TextEditingController();

  // Use a map to store the selected file and its individual upload progress
  final Map<DocumentType, DocumentUploadState> documentStates = {
    for (final type in DocumentType.values)
      type: DocumentUploadState(file: null, progress: 0.0),
  };

  final RxBool isUploadingDocuments = false.obs;
  final RxnString documentUploadError = RxnString();

  @override
  void onInit() {
    super.onInit();
    ever(_profileController.riderDocuments, (_) {
      final existingNid = riderDocuments?.nid;
      if (existingNid != null &&
          existingNid.isNotEmpty &&
          idProofNumberController.text.trim().isEmpty) {
        idProofNumberController.text = existingNid;
      }
      final existingIdType = riderDocuments?.nidType;
      if (existingIdType != null &&
          existingIdType.isNotEmpty &&
          idProofTypes.contains(existingIdType)) {
        idProofType.value = existingIdType;
      }
      final existingLicense = riderDocuments?.drivingLicense;
      if (existingLicense != null &&
          existingLicense.isNotEmpty &&
          drivingLicenseNumberController.text.trim().isEmpty) {
        drivingLicenseNumberController.text = existingLicense;
      }
      final existingReg = riderDocuments?.vehicleRegistrationNumber;
      if (existingReg != null &&
          existingReg.isNotEmpty &&
          vehicleRegistrationNumberController.text.trim().isEmpty) {
        vehicleRegistrationNumberController.text = existingReg;
      }
      update();
    });
  }

  @override
  void onClose() {
    idProofNumberController.dispose();
    drivingLicenseNumberController.dispose();
    vehicleRegistrationNumberController.dispose();
    super.onClose();
  }

  String get documentUploadErrorText =>
      documentUploadError.value?.isNotEmpty == true
      ? documentUploadError.value!
      : 'Unable to upload documents.';

  int get selectedFilesCount =>
      documentStates.values.where((state) => state.file != null).length;

  RiderDocumentsModel? get riderDocuments =>
      _profileController.riderDocuments.value;
  ProfileController get profileController => _profileController;

  String? existingDocumentUrl(DocumentType type) {
    final documents = riderDocuments;
    switch (type) {
      case DocumentType.profileImage:
        return documents?.profileImage ??
            _profileController.profile.value?.profileImage;
      case DocumentType.nationalId:
        return documents?.nationalIdDocument;
      case DocumentType.drivingLicense:
        return documents?.drivingLicenseDocument;
      case DocumentType.vehicleRegistration:
        return documents?.vehicleRegistrationDocument;
      case DocumentType.vehicleInsurance:
        return documents?.vehicleInsuranceDocument;
    }
  }

  Future<void> pickDocument(DocumentType type) async {
    if (type == DocumentType.profileImage) {
      await _pickImage(type);
    } else {
      await _pickFile(type);
    }
  }

  Future<void> _pickImage(DocumentType type) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (image == null) return;

    documentStates[type] = DocumentUploadState(
      file: File(image.path),
      progress: 0.0,
    );
    update(); // for GetX to update the UI
    await _simulateSingleUploadProgress(type);
  }

  Future<void> _pickFile(DocumentType type) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    final path = result?.files.single.path;
    if (path == null) return;

    documentStates[type] = DocumentUploadState(file: File(path), progress: 0.0);
    update();
    await _simulateSingleUploadProgress(type);
  }

  void removeSelection(DocumentType type) {
    documentStates[type] = DocumentUploadState(file: null, progress: 0.0);
    update();
  }

  Future<void> _simulateSingleUploadProgress(DocumentType type) async {
    documentStates[type]!.progress = 0.0;
    update();

    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (documentStates[type]?.file != null) {
        final progressValue = i * 0.1;
        documentStates[type]!.progress = progressValue;
        update();
      } else {
        break;
      }
    }

    if (documentStates[type]?.file != null) {
      documentStates[type]!.progress = 1.0;
      update();
    }
  }

  Future<void> handleUpload() async {
    if (documentStates.values.every((state) => state.file == null)) {
      Get.snackbar('Attention', 'Please select documents to upload.');
      return;
    }

    final filesMap = documentStates.map(
      (key, state) => MapEntry(key, state.file),
    );

    final success = await uploadDocuments(
      profileImage: filesMap[DocumentType.profileImage],
      nationalId: filesMap[DocumentType.nationalId],
      drivingLicense: filesMap[DocumentType.drivingLicense],
      vehicleRegistration: filesMap[DocumentType.vehicleRegistration],
      vehicleInsurance: filesMap[DocumentType.vehicleInsurance],
    );

    if (success) {
      for (final key in filesMap.keys) {
        if (filesMap[key] != null) {
          documentStates[key] = DocumentUploadState(file: null, progress: 0.0);
        }
      }
      _profileController.fetchProfile();
      Get.offAll(
        () => const BottomNavBar(),
        arguments: 3,
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 250),
      );
      Get.snackbar(
        '✅ Success',
        'Documents updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      for (var key in documentStates.keys) {
        documentStates[key]!.progress = 0.0;
      }
      Get.snackbar(
        '❌ Upload Failed',
        documentUploadErrorText.isNotEmpty
            ? documentUploadErrorText
            : 'An unexpected error occurred.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
    update();
  }

  Future<bool> uploadDocuments({
    File? profileImage,
    File? nationalId,
    File? drivingLicense,
    File? vehicleRegistration,
    File? vehicleInsurance,
  }) async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      documentUploadError.value = 'Missing credentials. Please login again.';
      return false;
    }

    if (nationalId == null || drivingLicense == null) {
      documentUploadError.value =
          'National ID and driving license are required.';
      return false;
    }

    if (idProofType.value.trim().isEmpty) {
      documentUploadError.value = 'ID type is required.';
      return false;
    }
    if (idProofNumberController.text.trim().isEmpty) {
      documentUploadError.value = 'National ID number is required.';
      return false;
    }
    if (drivingLicenseNumberController.text.trim().isEmpty) {
      documentUploadError.value = 'Driving license number is required.';
      return false;
    }
    if (vehicleRegistrationNumberController.text.trim().isEmpty) {
      documentUploadError.value = 'Vehicle registration number is required.';
      return false;
    }

    final hasSelection = [
      profileImage,
      nationalId,
      drivingLicense,
      vehicleRegistration,
      vehicleInsurance,
    ].any((file) => file != null);

    if (!hasSelection) {
      documentUploadError.value = 'Select at least one document to upload.';
      return false;
    }

    isUploadingDocuments.value = true;
    documentUploadError.value = null;
    try {
      final response = await _profileServices.uploadDocuments(
        accessToken: accessToken,
        profileImage: profileImage,
        nationalId: nationalId,
        drivingLicense: drivingLicense,
        vehicleRegistration: vehicleRegistration,
        vehicleInsurance: vehicleInsurance,
        idType: idProofType.value,
        nidNumber: idProofNumberController.text.trim(),
        drivingLicenseNumber: drivingLicenseNumberController.text.trim(),
        vehicleRegistrationNumber: vehicleRegistrationNumberController.text
            .trim(),
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final docs = RiderDocumentsModel.fromJson(
          response.responseData as Map<String, dynamic>,
        );
        _profileController.riderDocuments.value = docs;
        final profileImageUrl = docs.profileImage;
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          final currentProfile = _profileController.profile.value;
          if (currentProfile != null) {
            _profileController.profile.value = currentProfile.copyWith(
              profileImage: profileImageUrl,
            );
          }
        }
        return true;
      } else {
        documentUploadError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to upload documents.';
        return false;
      }
    } finally {
      isUploadingDocuments.value = false;
    }
  }
}

extension DocumentTypeMeta on DocumentType {
  String get label {
    switch (this) {
      case DocumentType.profileImage:
        return 'Profile Photo';
      case DocumentType.nationalId:
        return 'ID Proof (Any 1): Aadhaar / PAN / Voter ID';
      case DocumentType.drivingLicense:
        return 'Driving License';
      case DocumentType.vehicleRegistration:
        return 'Vehicle Registration';
      case DocumentType.vehicleInsurance:
        return 'Vehicle Insurance';
    }
  }

  String get hint {
    switch (this) {
      case DocumentType.profileImage:
        return 'Upload a clear headshot (Image)';
      case DocumentType.nationalId:
        return 'Upload your ID proof document (Any file)';
      case DocumentType.drivingLicense:
        return 'License copy or photo (Any file)';
      case DocumentType.vehicleRegistration:
        return 'Vehicle registration document (Any file)';
      case DocumentType.vehicleInsurance:
        return 'Insurance certificate or card (Any file)';
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentType.profileImage:
        return Icons.person_outline;
      case DocumentType.nationalId:
        return Icons.badge_outlined;
      case DocumentType.drivingLicense:
        return Icons.credit_card;
      case DocumentType.vehicleRegistration:
        return Icons.directions_car;
      case DocumentType.vehicleInsurance:
        return Icons.verified_user_outlined;
    }
  }

  bool get isImageType => this == DocumentType.profileImage;
}
