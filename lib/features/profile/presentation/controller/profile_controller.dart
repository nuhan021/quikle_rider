// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/features/profile/data/models/help_support_request.dart';
import 'package:quikle_rider/features/profile/data/models/profile_completion_model.dart';
import 'package:quikle_rider/features/profile/data/models/profile_model.dart';
import 'package:quikle_rider/features/profile/data/models/referral_dashboard.dart';
import 'package:quikle_rider/features/profile/data/models/rider_documents_model.dart';
import 'package:quikle_rider/features/profile/data/models/training_resource.dart';
import 'package:quikle_rider/features/profile/data/models/vehicle_model.dart';
import 'package:quikle_rider/features/profile/data/services/profile_services.dart';

class ProfileController extends GetxController {
  ProfileController({ProfileServices? profileServices})
    : _profileServices = profileServices ?? ProfileServices();

  final ProfileServices _profileServices;

  // 📊 State: profile & documents
  final RxBool isavaiabilityProfile = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isprofilecompleted = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<ProfileModel> profile = Rxn<ProfileModel>();
  final RxBool isUpdatingProfile = false.obs;
  final RxnString profileUpdateError = RxnString();
  final RxBool isUploadingDocuments = false.obs;
  final RxnString documentUploadError = RxnString();
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

  // 🚗 State: vehicles
  final RxBool isCreatingVehicle = false.obs;
  final RxnString vehicleCreationError = RxnString();
  final RxList<VehicleModel> vehicleList = <VehicleModel>[].obs;
  final RxBool isVehicleListLoading = false.obs;
  final RxnString vehicleListError = RxnString();
  final Rxn<VehicleModel> vehicleDetails = Rxn<VehicleModel>();
  final List<String> vehicleTypes = const ['Bike', 'Car', 'Truck', 'Van'];
  late final RxString selectedVehicleType = vehicleTypes.first.obs;
  final GlobalKey<FormState> vehicleFormKey = GlobalKey<FormState>();
  final TextEditingController licensePlateController = TextEditingController();
  final TextEditingController vehicleModelController = TextEditingController();
  bool _hasRequestedVehicleList = false;

  // 🆘 State: help & support
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

  // ✅ State: completion & referral
  final RxBool isProfileCompletionLoading = false.obs;
  final RxnString profileCompletionError = RxnString();
  final Rxn<ProfileCompletionModel> profileCompletion =
      Rxn<ProfileCompletionModel>();
  final Rxn<ReferralDashboard> referralDashboard = Rxn<ReferralDashboard>();
  final RxBool isReferralDashboardLoading = false.obs;
  final RxnString referralDashboardError = RxnString();
  final Rxn<Uint8List> referralQrImage = Rxn<Uint8List>();
  final RxBool isReferralQrLoading = false.obs;
  final RxnString referralQrError = RxnString();

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
      _normalizeVerificationStatus(isVerified.value) == 'verified';

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

  String? get phoneNumber => profile.value?.phone;

  String get profileUpdateErrorText =>
      profileUpdateError.value?.isNotEmpty == true
      ? profileUpdateError.value!
      : 'Unable to update profile.';

  String get documentUploadErrorText =>
      documentUploadError.value?.isNotEmpty == true
      ? documentUploadError.value!
      : 'Unable to upload documents.';
  String get vehicleCreationErrorText =>
      vehicleCreationError.value?.isNotEmpty == true
      ? vehicleCreationError.value!
      : 'Unable to save vehicle information.';
  double get completionPercent =>
      profileCompletion.value?.completionPercentage ?? 0;
  List<String> get missingCompletionItems =>
      profileCompletion.value?.missingFields ?? const <String>[];
  String get completionMessage =>
      profileCompletion.value?.message.isNotEmpty == true
      ? profileCompletion.value!.message
      : 'Complete your profile to unlock new tiers.';

  void resetProfileFetchState() {
    _hasAttemptedProfileFetch = false;
    errorMessage.value = null;
  }

  void clearForLogout() {
    isavaiabilityProfile.value = false;
    isLoading.value = false;
    isprofilecompleted.value = false;
    errorMessage.value = null;
    profile.value = null;
    isUpdatingProfile.value = false;
    profileUpdateError.value = null;
    isUploadingDocuments.value = false;
    documentUploadError.value = null;
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

    isCreatingVehicle.value = false;
    vehicleCreationError.value = null;
    vehicleList.clear();
    isVehicleListLoading.value = false;
    vehicleListError.value = null;
    vehicleDetails.value = null;
    selectedVehicleType.value = vehicleTypes.first;
    vehicleFormKey.currentState?.reset();
    licensePlateController.clear();
    vehicleModelController.clear();
    _hasRequestedVehicleList = false;

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

    isProfileCompletionLoading.value = false;
    profileCompletionError.value = null;
    profileCompletion.value = null;
    referralDashboard.value = null;
    isReferralDashboardLoading.value = false;
    referralDashboardError.value = null;
    referralQrImage.value = null;
    isReferralQrLoading.value = false;
    referralQrError.value = null;

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

    Future<void> safeFetch(
      Future<void> Function() action,
      String label,
    ) async {
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
    helpDescriptionController.dispose();
    licensePlateController.dispose();
    vehicleModelController.dispose();
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

  // 🧾 Vehicle form helpers
  void setVehicleType(String type) {
    if (!vehicleTypes.contains(type)) return;
    selectedVehicleType.value = type;
  }

  void resetVehicleForm() {
    selectedVehicleType.value = vehicleTypes.first;
    licensePlateController.clear();
    vehicleModelController.clear();
    vehicleFormKey.currentState?.reset();
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
    debugPrint('access token in practice file: $accessToken');
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
          final value =
              data['verification_status'] ?? data['is_verified'];
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
        final isprofilecompleted = response.responseData['is_complete'] as bool;
        AppLoggerHelper.debug("profile update: ${isprofilecompleted}");



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
              (item) => TrainingResource.fromJson(
                item,
                fallbackType: 'video',
              ),
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
            .map(
              (item) => TrainingResource.fromJson(
                item,
                fallbackType: 'pdf',
              ),
            )
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

  List<dynamic>? _extractListFromResponse(
    dynamic data, {
    String? primaryKey,
  }) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final value = data[primaryKey] ??
          data['results'] ??
          data['data'] ??
          data['items'];
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

  // 🎁 Referral program data
  Future<void> fetchReferralDashboard() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      referralDashboard.value = null;
      referralDashboardError.value =
          'Missing credentials. Please login again.';
      return;
    }

    isReferralDashboardLoading.value = true;
    referralDashboardError.value = null;
    try {
      final response = await _profileServices.getReferralDashboard(
        accessToken: accessToken,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        referralDashboard.value = ReferralDashboard.fromJson(
          response.responseData as Map<String, dynamic>,
        );
      } else {
        referralDashboard.value = null;
        referralDashboardError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to load referral details.';
      }
    } finally {
      isReferralDashboardLoading.value = false;
    }
  }

  Future<void> fetchReferralQrImage() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      referralQrImage.value = null;
      referralQrError.value = 'Missing credentials. Please login again.';
      return;
    }

    isReferralQrLoading.value = true;
    referralQrError.value = null;
    try {
      final response = await _profileServices.getReferralQrImage(
        accessToken: accessToken,
      );

      if (response.isSuccess) {
        final data = response.responseData;
        if (data is Uint8List) {
          referralQrImage.value = data;
        } else if (data is List<int>) {
          referralQrImage.value = Uint8List.fromList(data);
        } else {
          referralQrImage.value = null;
          referralQrError.value = 'QR code response invalid.';
        }
      } else {
        referralQrImage.value = null;
        referralQrError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to load referral QR.';
      }
    } finally {
      isReferralQrLoading.value = false;
    }
  }

  // ✏️ Profile updates
  Future<bool> updateProfileData({
    required String name,
    required String email,
    required String drivingLicense,
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
        payload: {
          'name': name,
          'email': email,
          'driving_license': drivingLicense,
          'nid': nid,
        },
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

  // 📤 Document uploads
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
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final docs = RiderDocumentsModel.fromJson(
          response.responseData as Map<String, dynamic>,
        );
        riderDocuments.value = docs;
        final profileImageUrl = docs.profileImage;
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          final currentProfile = profile.value;
          if (currentProfile != null) {
            profile.value = currentProfile.copyWith(
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

  // 🚗 Vehicle create & list
  Future<bool> createVehicle({
    required String vehicleType,
    required String licensePlateNumber,
    String? model,
  }) async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      vehicleCreationError.value = 'Missing credentials. Please login again.';
      return false;
    }

    isCreatingVehicle.value = true;
    vehicleCreationError.value = null;
    try {
      final response = await _profileServices.createVehicle(
        accessToken: accessToken,
        vehicleType: vehicleType,
        licensePlateNumber: licensePlateNumber,
        model: model,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final vehicle = VehicleModel.fromJson(
          response.responseData as Map<String, dynamic>,
        );
        vehicleDetails.value = vehicle;
        final vehicleId = vehicle.id;
        if (vehicleId != null) {
          await fetchVehicleDetails(vehicleId: vehicleId);
        }
        await fetchVehiclesList();
        return true;
      } else {
        vehicleCreationError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to save vehicle information.';
        return false;
      }
    } finally {
      isCreatingVehicle.value = false;
    }
  }

  Future<void> submitVehicleInformation() async {
    final formState = vehicleFormKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final licensePlate = licensePlateController.text.trim();
    final modelText = vehicleModelController.text.trim();

    final success = await createVehicle(
      vehicleType: selectedVehicleType.value.toLowerCase(),
      licensePlateNumber: licensePlate,
      model: modelText.isEmpty ? null : modelText,
    );
    resetVehicleForm();
    Get.back();
    if (success) {
      Get.snackbar(
        'Vehicle Saved',
        'Vehicle information saved successfully.',
        backgroundColor: Colors.green.withOpacity(0.2),
        colorText: Colors.green[900],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } else {
      Get.snackbar(
        'Unable to save vehicle',
        vehicleCreationErrorText,
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void updateHelpIssueType(String issueType) {
    selectedHelpIssueType.value = issueType;
  }

  // 🆘 Help & support flows
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
        backgroundColor: Colors.red.withOpacity(0.2),
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
        backgroundColor: Colors.red.withOpacity(0.2),
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
        backgroundColor: Colors.green.withOpacity(0.2),
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
        backgroundColor: Colors.red.withOpacity(0.2),
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

  // 🗺️ Demo route request placeholder for map features
  RoutesApiRequest request = RoutesApiRequest(
    origin: PointLatLng(37.7749, -122.4194),
    destination: PointLatLng(37.3382, -121.8863),
    travelMode: TravelMode.driving,
    routeModifiers: RouteModifiers(
      avoidTolls: true,
      avoidHighways: false,
      avoidFerries: true,
      avoidIndoor: false,
    ),
    routingPreference: RoutingPreference.trafficAware,
    units: Units.metric,
    polylineQuality: PolylineQuality.highQuality,
  );

  // 🚛 Vehicle list fetch
  Future<void> fetchVehiclesList() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      vehicleList.clear();
      vehicleListError.value = 'Missing credentials. Please login again.';
      return;
    }

    _hasRequestedVehicleList = true;
    isVehicleListLoading.value = true;
    vehicleListError.value = null;
    try {
      final response = await _profileServices.listVehicles(
        accessToken: accessToken,
      );

      if (response.isSuccess && response.responseData is List) {
        final rawList = response.responseData as List<dynamic>;
        final vehicles = rawList
            .whereType<Map<String, dynamic>>()
            .map(VehicleModel.fromJson)
            .toList();
        vehicleList.assignAll(vehicles);
      } else {
        vehicleList.clear();
        vehicleListError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to fetch vehicles.';
      }
    } catch (error) {
      vehicleList.clear();
      vehicleListError.value = 'Unable to fetch vehicles.';
      AppLoggerHelper.error('Vehicle list fetch failed: $error');
    } finally {
      isVehicleListLoading.value = false;
    }
  }

  Future<void> ensureVehicleListLoaded() async {
    if (_hasRequestedVehicleList && vehicleList.isNotEmpty) {
      return;
    }
    await fetchVehiclesList();
  }

  Future<VehicleModel?> fetchVehicleDetails({required int vehicleId}) async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null) {
      return null;
    }

    final response = await _profileServices.getVehicle(
      accessToken: accessToken,
      vehicleId: vehicleId,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      final vehicle = VehicleModel.fromJson(
        response.responseData as Map<String, dynamic>,
      );
      vehicleDetails.value = vehicle;
      return vehicle;
    }
    return null;
  }

  // ⏱️ Availability save
  /// Calls the Service to update data
  Future<void> updateAvailabilitySettings() async {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Error",
        "Authentication token not found.",
        backgroundColor: Colors.red.withOpacity(0.1),
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
          backgroundColor: Colors.green.withOpacity(0.2),
          colorText: Colors.green[900],
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          "Failed",
          "Could not update settings. Please try again.",
          backgroundColor: Colors.red.withOpacity(0.2),
          colorText: Colors.red[900],
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.red[900],
      );
    } finally {
      isavaiabilityProfile.value = false;
    }
  }
}
