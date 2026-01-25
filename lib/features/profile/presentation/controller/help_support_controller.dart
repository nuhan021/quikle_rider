import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/features/profile/data/models/help_support_request.dart';
import 'package:quikle_rider/features/profile/data/services/profile_services.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:flutter/material.dart';

class HelpSupportController extends GetxController {
  HelpSupportController({ProfileServices? profileServices})
    : _profileServices = profileServices ?? ProfileServices();

  final ProfileServices _profileServices;
  final ProfileController _profileController = Get.find<ProfileController>();

  final RxBool isSubmittingHelpSupport = false.obs;
  final RxnString helpSupportError = RxnString();
  final RxList<HelpSupportRequest> supportHistory = <HelpSupportRequest>[].obs;
  final RxBool isSupportHistoryLoading = false.obs;
  final RxnString supportHistoryError = RxnString();
  bool _hasLoadedSupportHistory = false;
  final List<String> helpIssueTypes = const [
    'Select an issue type',
    'Account Issues',
    'Payment Problems',
    'Order Issues',
    'App Technical Problems',
    'Vehicle Registration',
    'Other',
  ];
  late final RxString selectedHelpIssueType = helpIssueTypes.first.obs;
  final TextEditingController helpDescriptionController =
      TextEditingController();
  final Rxn<File> helpAttachment = Rxn<File>();
  final RxnString helpAttachmentName = RxnString();

  bool get isVerifiedApproved => _profileController.isVerifiedApproved;

  void clearForLogout() {
    isSubmittingHelpSupport.value = false;
    helpSupportError.value = null;
    supportHistory.clear();
    isSupportHistoryLoading.value = false;
    supportHistoryError.value = null;
    _hasLoadedSupportHistory = false;
    selectedHelpIssueType.value = helpIssueTypes.first;
    helpDescriptionController.clear();
    helpAttachment.value = null;
    helpAttachmentName.value = null;
  }

  @override
  void onClose() {
    helpDescriptionController.dispose();
    super.onClose();
  }

  void updateHelpIssueType(String issueType) {
    selectedHelpIssueType.value = issueType;
  }

  Future<void> pickHelpAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final path = file.path;
      if (path == null) return;
      helpAttachment.value = File(path);
      helpAttachmentName.value = file.name;
    } catch (error) {
      AppLoggerHelper.error('Help support attachment pick failed: $error');
      Get.snackbar(
        'Attachment Error',
        'Unable to pick attachment. Please try again.',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.red[900],
      );
    }
  }

  void removeHelpAttachment() {
    helpAttachment.value = null;
    helpAttachmentName.value = null;
  }

  void resetHelpSupportForm() {
    selectedHelpIssueType.value = helpIssueTypes.first;
    helpDescriptionController.clear();
    removeHelpAttachment();
  }

  Future<bool> submitHelpSupportForm() async {
    final subject = selectedHelpIssueType.value;
    final description = helpDescriptionController.text.trim();

    if (subject == helpIssueTypes.first || description.isEmpty) {
      helpSupportError.value = 'Please fill in all required fields';
      Get.snackbar(
        'Missing Information',
        helpSupportError.value!,
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.red[900],
      );
      return false;
    }

    final success = await submitHelpAndSupport(
      subject: subject,
      description: description,
      attachment: helpAttachment.value,
    );

    if (success) {
      Get.snackbar(
        'Success',
        'Your issue has been submitted successfully.',
        backgroundColor: Colors.green.withValues(alpha: 0.2),
        colorText: Colors.green[900],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      resetHelpSupportForm();
      fetchSupportHistory();
      return true;
    } else {
      final error =
          helpSupportError.value ?? 'Unable to submit issue. Please try again.';
      Get.snackbar(
        'Submission Failed',
        error,
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.red[900],
      );
      return false;
    }
  }

  Future<void> fetchSupportHistory() async {
    final token = StorageService.accessToken;
    if (token == null) {
      supportHistory.clear();
      supportHistoryError.value = 'Missing credentials. Please login again.';
      return;
    }

    isSupportHistoryLoading.value = true;
    supportHistoryError.value = null;
    try {
      final response = await _profileServices.listHelpSupportRequests(
        accessToken: token,
      );

      if (response.isSuccess && response.responseData is List) {
        final raw = response.responseData as List<dynamic>;
        final entries = raw
            .whereType<Map<String, dynamic>>()
            .map(HelpSupportRequest.fromJson)
            .toList();
        supportHistory.assignAll(entries);
        _hasLoadedSupportHistory = true;
      } else {
        supportHistory.clear();
        supportHistoryError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to load support history.';
      }
    } catch (error) {
      supportHistory.clear();
      supportHistoryError.value = 'Unable to load support history.';
      AppLoggerHelper.error('Failed to fetch support history: $error');
    } finally {
      isSupportHistoryLoading.value = false;
    }
  }

  Future<void> ensureSupportHistoryLoaded() async {
    if (_hasLoadedSupportHistory) return;
    await fetchSupportHistory();
  }

  Future<bool> submitHelpAndSupport({
    required String subject,
    required String description,
    File? attachment,
  }) async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      helpSupportError.value = 'Missing credentials. Please login again.';
      return false;
    }

    isSubmittingHelpSupport.value = true;
    helpSupportError.value = null;
    try {
      final response = await _profileServices.createHelpAndSupport(
        accessToken: accessToken,
        subject: subject,
        description: description,
        attachment: attachment,
      );

      if (response.isSuccess) {
        return true;
      } else {
        helpSupportError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to submit help request.';
        return false;
      }
    } finally {
      isSubmittingHelpSupport.value = false;
    }
  }
}
