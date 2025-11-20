import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/features/profile/data/models/profile_model.dart';
import 'package:quikle_rider/features/profile/data/models/rider_documents_model.dart';
import 'package:quikle_rider/features/profile/data/models/vehicle_model.dart';
import 'package:quikle_rider/features/profile/data/services/profile_services.dart';

class ProfileController extends GetxController {
  ProfileController({ProfileServices? profileServices})
    : _profileServices = profileServices ?? ProfileServices();

  final ProfileServices _profileServices;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<ProfileModel> profile = Rxn<ProfileModel>();
  final RxBool isUpdatingProfile = false.obs;
  final RxnString profileUpdateError = RxnString();
  final RxBool isUploadingDocuments = false.obs;
  final RxnString documentUploadError = RxnString();
  final Rxn<RiderDocumentsModel> riderDocuments = Rxn<RiderDocumentsModel>();
  final RxBool isCreatingVehicle = false.obs;
  final RxnString vehicleCreationError = RxnString();
  final Rxn<VehicleModel> vehicleDetails = Rxn<VehicleModel>();

  bool get shouldShowLoadingHeader => isLoading.value && profile.value == null;

  bool get shouldShowErrorHeader {
    final hasError =
        errorMessage.value != null && errorMessage.value!.isNotEmpty;
    return hasError && profile.value == null;
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

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final accessToken = StorageService.accessToken;
    final refreshToken = StorageService.refreshToken;

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
}
