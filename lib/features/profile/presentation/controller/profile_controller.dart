// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/features/profile/data/models/profile_completion_model.dart';
import 'package:quikle_rider/features/profile/data/models/profile_model.dart';
import 'package:quikle_rider/features/profile/data/models/rider_documents_model.dart';
import 'package:quikle_rider/features/profile/data/models/training_resource.dart';
import 'package:quikle_rider/features/profile/data/services/profile_services.dart';
import 'package:quikle_rider/routes/app_routes.dart';

class ProfileController extends GetxController {
  ProfileController({ProfileServices? profileServices})
    : _profileServices = profileServices ?? ProfileServices();

  final ProfileServices _profileServices;

  // 📊 State: profile & documents
  final RxBool isavaiabilityProfile = false.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<ProfileModel> profile = Rxn<ProfileModel>();
  final RxBool isUpdatingProfile = false.obs;
  final RxnString profileUpdateError = RxnString();
  final Rxn<bool> isDocumentUploaded = Rxn<bool>();
  final RxBool isDocumentStatusLoading = false.obs;
  final RxnString documentStatusError = RxnString();
  final RxnString isVerified = RxnString();
  final RxBool isVerificationLoading = false.obs;
  final RxnString verificationError = RxnString();
  final Rxn<RiderDocumentsModel> riderDocuments = Rxn<RiderDocumentsModel>();
  final RxList<TrainingResource> trainingVideos = <TrainingResource>[].obs;
  final RxList<TrainingResource> trainingPdfs = <TrainingResource>[].obs;
  final RxBool isTrainingVideosLoading = false.obs;
  final RxBool isTrainingPdfsLoading = false.obs;
  final RxnString trainingVideosError = RxnString();
  final RxnString trainingPdfsError = RxnString();
  bool _hasLoadedTrainingVideos = false;
  bool _hasLoadedTrainingPdfs = false;

  //deleting rider Profile 
  final RxBool isDeletingProfile = false.obs;
  final RxnString deleteProfileError = RxnString();

  // ✅ State: completion
  final RxBool isProfileCompletionLoading = false.obs;
  final RxnString profileCompletionError = RxnString();
  final Rxn<ProfileCompletionModel> profileCompletion =
      Rxn<ProfileCompletionModel>();

  // ⏰ State: availability
  var startTime = TimeOfDay.now().obs;
  var endTime = TimeOfDay.now().obs;
  var isAvailable = false.obs;
  bool _hasAttemptedProfileFetch = false;

  bool get shouldShowLoadingHeader => isLoading.value && profile.value == null;

  bool get shouldShowErrorHeader {
    final hasError =
        errorMessage.value != null && errorMessage.value!.isNotEmpty;
    return hasError && profile.value == null;
  }

  bool get hasAttemptedProfileFetch => _hasAttemptedProfileFetch;

  static const Map<String, String> verificationStatusLabels = {
    'not_verified': 'Not Verified',
    'pending_approval': 'Pending Approval',
    'verified': 'Verified',
    'rejected': 'Rejected',
  };

  String get verificationStatusLabel {
    final normalized = _normalizeVerificationStatus(isVerified.value);
    if (normalized == null) return 'Not Verified';
    return verificationStatusLabels[normalized] ?? normalized;
  }

  bool get isVerifiedApproved =>
      _normalizeVerificationStatus(isVerified.value) == 'approved';

  bool get isVerificationRejected =>
      _normalizeVerificationStatus(isVerified.value) == 'rejected';

  bool get isVerificationPending =>
      _normalizeVerificationStatus(isVerified.value) == 'pending_approval';

  String? _normalizeVerificationStatus(dynamic value) {
    if (value == null) return null;
    if (value is bool) {
      return value ? 'verified' : 'not_verified';
    }
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    final normalized = raw
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .replaceAll('__', '_');
    if (verificationStatusLabels.containsKey(normalized)) {
      return normalized;
    }
    return normalized;
  }

  String get headerErrorText => errorMessage.value?.isNotEmpty == true
      ? errorMessage.value!
      : 'Unable to fetch profile.';

  String get displayName {
    final name = profile.value?.name ?? '';
    final trimmed = name.trim();
    return trimmed.isNotEmpty ? trimmed : 'Rider';
  }

  String get displayEmail {
    final email = profile.value?.email ?? '';
    final trimmed = email.trim();
    return trimmed.isNotEmpty ? trimmed : 'Email not available';
  }

  String? get profileImageUrl {
    final image = profile.value?.profileImage ?? '';
    final trimmed = image.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  String get profileUpdateErrorText =>
      profileUpdateError.value?.isNotEmpty == true
      ? profileUpdateError.value!
      : 'Unable to update profile.';

  void resetProfileFetchState() {
    _hasAttemptedProfileFetch = false;
    errorMessage.value = null;
  }

  void clearForLogout() {
    isavaiabilityProfile.value = false;
    isLoading.value = false;
    errorMessage.value = null;
    profile.value = null;
    isUpdatingProfile.value = false;
    profileUpdateError.value = null;
    isDocumentUploaded.value = null;
    isDocumentStatusLoading.value = false;
    documentStatusError.value = null;
    isVerified.value = null;
    isVerificationLoading.value = false;
    verificationError.value = null;
    riderDocuments.value = null;
    trainingVideos.clear();
    trainingPdfs.clear();
    isTrainingVideosLoading.value = false;
    isTrainingPdfsLoading.value = false;
    trainingVideosError.value = null;
    trainingPdfsError.value = null;
    _hasLoadedTrainingVideos = false;
    _hasLoadedTrainingPdfs = false;
    isProfileCompletionLoading.value = false;
    profileCompletionError.value = null;
    profileCompletion.value = null;

    startTime.value = TimeOfDay.now();
    endTime.value = TimeOfDay.now();
    isAvailable.value = false;
    _hasAttemptedProfileFetch = false;
  }

  Future<void> refreshForLogin({bool resetState = false}) async {
    if (resetState) {
      clearForLogout();
    } else {
      resetProfileFetchState();
    }

    Future<void> safeFetch(Future<void> Function() action, String label) async {
      try {
        await action();
      } catch (error) {
        AppLoggerHelper.error('Profile refresh failed ($label): $error');
      }
    }

    await safeFetch(fetchProfile, 'profile');
    await safeFetch(fetchAvailabilitySettings, 'availability');
    await safeFetch(fetchProfileCompletion, 'completion');
    await safeFetch(fetchDocumentUploadStatus, 'documents');
    await safeFetch(fetchVerificationStatus, 'verification');
  }

  // 🧭 Lifecycle hooks
  @override
  void onInit() {
    super.onInit();
    refreshForLogin();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // 🛠️ Time helpers for availability
  /// Formats TimeOfDay to API expected string "HH:mm:ss.SSSZ"
  String _formatTimeForApi(TimeOfDay time) {
    final now = DateTime.now();
    // Create a DateTime with today's date and the selected time
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    // Format: 04:09:52.681
    final formatter = DateFormat('HH:mm:ss.SSS');

    // Append 'Z' to indicate UTC/Zulu time as per your curl example
    return "${formatter.format(dt)}Z";
  }

  /// Formats a TimeOfDay for user-friendly display like 8:00 AM.
  String _formatTimeForDisplay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  TimeOfDay? _parseTimeOfDayFromApi(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return null;
    final match = RegExp(r'(\d{2}):(\d{2})').firstMatch(rawTime);
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  void _updateAvailabilityFromResponse(Map<String, dynamic> payload) {
    final availability = payload['is_available'];
    if (availability is bool) {
      isAvailable.value = availability;
    } else if (availability is String) {
      isAvailable.value = availability.toLowerCase() == 'true';
    }

    final startAtRaw = payload['start_at'] ?? payload['strat_at'];
    final parsedStart = _parseTimeOfDayFromApi(
      startAtRaw == null ? null : startAtRaw.toString(),
    );
    if (parsedStart != null) {
      startTime.value = parsedStart;
    }

    final endAtRaw = payload['end_at'];
    final parsedEnd = _parseTimeOfDayFromApi(
      endAtRaw == null ? null : endAtRaw.toString(),
    );
    if (parsedEnd != null) {
      endTime.value = parsedEnd;
    }
  }

  // 🔄 Availability toggles/setters
  void toggleAvailability(bool value) {
    isAvailable.value = value;
  }

  void setStartTime(TimeOfDay time) {
    startTime.value = time;
  }

  void setEndTime(TimeOfDay time) {
    endTime.value = time;
  }

  // ☎️ Availability API calls
  Future<void> fetchAvailabilitySettings() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final response = await _profileServices.getRiderAvailability(
        token: token,
      );
      if (response != null) {
        _updateAvailabilityFromResponse(response);
      }
    } catch (e) {
      AppLoggerHelper.error('Failed to fetch availability: $e');
    }
  }

  // 👤 Profile fetch & update
  Future<void> fetchProfile() async {
    final accessToken = StorageService.accessToken;
    final refreshToken = StorageService.refreshToken;
    _hasAttemptedProfileFetch = true;

    if (accessToken == null || refreshToken == null) {
      errorMessage.value = 'Missing credentials. Please login again.';
      profile.value = null;
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _profileServices.getProfile(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        profile.value = ProfileModel.fromJson(
          response.responseData as Map<String, dynamic>,
        );
        errorMessage.value = null;
      } else {
        profile.value = null;
        errorMessage.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to fetch profile.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  // 📄 Document upload status
  Future<void> fetchDocumentUploadStatus() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      documentStatusError.value = 'Missing credentials. Please login again.';
      isDocumentUploaded.value = null;
      return;
    }

    isDocumentStatusLoading.value = true;
    documentStatusError.value = null;
    try {
      final response = await _profileServices.getDocumentUploadStatus(
        accessToken: accessToken,
      );

      if (response.isSuccess) {
        final data = response.responseData;
        bool? uploaded;
        if (data is Map<String, dynamic>) {
          final value = data['is_document_uploaded'];
          if (value is bool) {
            uploaded = value;
          } else if (value is String) {
            uploaded = value.toLowerCase() == 'true';
          }
        } else if (data is bool) {
          uploaded = data;
        }
        isDocumentUploaded.value = uploaded;
      } else {
        documentStatusError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to check document status.';
        isDocumentUploaded.value = null;
      }
    } catch (error) {
      AppLoggerHelper.error('Failed to fetch document status: $error');
      documentStatusError.value = 'Unable to check document status.';
      isDocumentUploaded.value = null;
    } finally {
      isDocumentStatusLoading.value = false;
    }
  }

  Future<void> fetchVerificationStatus() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      verificationError.value = 'Missing credentials. Please login again.';
      isVerified.value = null;
      return;
    }

    isVerificationLoading.value = true;
    verificationError.value = null;
    try {
      final response = await _profileServices.getVerificationStatus(
        accessToken: accessToken,
      );

      if (response.isSuccess) {
        final data = response.responseData;
        String? status;
        if (data is Map<String, dynamic>) {
          final value = data['verification_status'] ?? data['is_verified'];
          status = _normalizeVerificationStatus(value);
        } else if (data is String || data is bool) {
          status = _normalizeVerificationStatus(data);
        }
        isVerified.value = status;
      } else {
        verificationError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to check verification status.';
        isVerified.value = null;
      }
    } catch (error) {
      AppLoggerHelper.error('Failed to fetch verification status: $error');
      verificationError.value = 'Unable to check verification status.';
      isVerified.value = null;
    } finally {
      isVerificationLoading.value = false;
    }
  }

  Future<void> waitForVerificationFetch() async {
    if (isVerified.value != null) {
      return;
    }
    await isVerified.stream.firstWhere((value) => value != null);
  }

  // 🧩 Profile completion progress
  Future<void> fetchProfileCompletion() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      profileCompletionError.value = 'Missing credentials. Please login again.';
      profileCompletion.value = null;
      return;
    }

    isProfileCompletionLoading.value = true;
    profileCompletionError.value = null;
    try {
      final response = await _profileServices.getProfileCompletion(
        accessToken: accessToken,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        profileCompletion.value = ProfileCompletionModel.fromJson(
          response.responseData as Map<String, dynamic>,
        );
      } else {
        profileCompletion.value = null;
        profileCompletionError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to fetch profile completion.';
      }
    } finally {
      isProfileCompletionLoading.value = false;
    }
  }

  Future<void> fetchTrainingVideos() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      trainingVideos.clear();
      trainingVideosError.value = 'Missing credentials. Please login again.';
      return;
    }

    isTrainingVideosLoading.value = true;
    trainingVideosError.value = null;
    try {
      final response = await _profileServices.getTrainingVideos(
        accessToken: accessToken,
      );

      final raw = _extractListFromResponse(
        response.responseData,
        primaryKey: 'videos',
      );

      if (response.isSuccess && raw != null) {
        final parsed = raw
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => TrainingResource.fromJson(item, fallbackType: 'video'),
            )
            .where((item) => item.url.isNotEmpty)
            .toList();
        trainingVideos.assignAll(parsed);
      } else {
        trainingVideos.clear();
        trainingVideosError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to load training videos.';
      }
    } catch (error) {
      trainingVideos.clear();
      trainingVideosError.value = 'Unable to load training videos.';
      AppLoggerHelper.error('Training videos fetch failed: $error');
    } finally {
      _hasLoadedTrainingVideos = true;
      isTrainingVideosLoading.value = false;
    }
  }

  Future<void> fetchTrainingPdfs() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      trainingPdfs.clear();
      trainingPdfsError.value = 'Missing credentials. Please login again.';
      return;
    }

    isTrainingPdfsLoading.value = true;
    trainingPdfsError.value = null;
    try {
      final response = await _profileServices.getTrainingPdfs(
        accessToken: accessToken,
      );

      final raw = _extractListFromResponse(
        response.responseData,
        primaryKey: 'pdfs',
      );

      if (response.isSuccess && raw != null) {
        final parsed = raw
            .whereType<Map<String, dynamic>>()
            .map((item) => TrainingResource.fromJson(item, fallbackType: 'pdf'))
            .where((item) => item.url.isNotEmpty)
            .toList();
        trainingPdfs.assignAll(parsed);
      } else {
        trainingPdfs.clear();
        trainingPdfsError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to load training PDFs.';
      }
    } catch (error) {
      trainingPdfs.clear();
      trainingPdfsError.value = 'Unable to load training PDFs.';
      AppLoggerHelper.error('Training PDFs fetch failed: $error');
    } finally {
      _hasLoadedTrainingPdfs = true;
      isTrainingPdfsLoading.value = false;
    }
  }

  List<dynamic>? _extractListFromResponse(dynamic data, {String? primaryKey}) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final value =
          data[primaryKey] ?? data['results'] ?? data['data'] ?? data['items'];
      if (value is List) return value;
    }
    return null;
  }

  Future<void> ensureTrainingResourcesLoaded() async {
    if (!_hasLoadedTrainingVideos) {
      await fetchTrainingVideos();
    }
    if (!_hasLoadedTrainingPdfs) {
      await fetchTrainingPdfs();
    }
  }

  // ✏️ Profile updates
  Future<bool> updateProfileData({
    required String name,
    required String email,

    required String nid,
  }) async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      profileUpdateError.value = 'Missing credentials. Please login again.';
      return false;
    }

    isUpdatingProfile.value = true;
    profileUpdateError.value = null;
    try {
      final response = await _profileServices.updateProfile(
        accessToken: accessToken,
        payload: {'name': name, 'email': email, 'nid': nid},
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final updatedProfile = ProfileModel.fromJson(
          response.responseData as Map<String, dynamic>,
        );
        profile.value = updatedProfile;
        errorMessage.value = null;
        return true;
      } else {
        profileUpdateError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to update profile.';
        return false;
      }
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // ⏱️ Availability save
  /// Calls the Service to update data
  Future<void> updateAvailabilitySettings() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Error",
        "Authentication token not found.",
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isavaiabilityProfile.value = true;

      // Prepare data
      String startAtStr = _formatTimeForApi(startTime.value);
      String endAtStr = _formatTimeForApi(endTime.value);

      // Call the API
      final result = await _profileServices.updateRiderAvailability(
        token: token,
        isAvailable: isAvailable.value,
        startAt: startAtStr,
        endAt: endAtStr,
      );

      // Handle Response
      if (result != null) {
        _updateAvailabilityFromResponse(result);
        final updatedFrom = _formatTimeForDisplay(startTime.value);
        final updatedTo = _formatTimeForDisplay(endTime.value);
        Get.snackbar(
          "Success",
          "Availability updated: $updatedFrom - $updatedTo",
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          colorText: Colors.green[900],
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          "Failed",
          "Could not update settings. Please try again.",
          backgroundColor: Colors.red.withValues(alpha: 0.2),
          colorText: Colors.red[900],
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.red[900],
      );
    } finally {
      isavaiabilityProfile.value = false;
    }
  }


  // Delete Profile data
  Future<void> deleteriderprofile() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Error",
        "Authentication token not found.",
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return;
    }

    final riderProfileId = StorageService.userId;
    if (riderProfileId == null) {
      Get.snackbar(
        "Error",
        "Rider profile id not found.",
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isDeletingProfile.value = true;
      final response = await _profileServices.deleteprofile(
        riderProfileId: riderProfileId,
        accessToken: token,
      );

      if (response.isSuccess) {
        await StorageService.logoutUser();
        clearForLogout();
        Get.snackbar(
          "Deleted",
          "Your account has been deleted.",
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          colorText: Colors.green[900],
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        await Future.delayed(const Duration(milliseconds: 600));
        Get.offAllNamed(AppRoute.getLoginScreen());
      } else {
        Get.snackbar(
          "Failed",
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : "Could not delete account. Please try again.",
          backgroundColor: Colors.red.withValues(alpha: 0.2),
          colorText: Colors.red[900],
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.red[900],
      );
    } finally {
      isDeletingProfile.value = false;
    }
  }
}
