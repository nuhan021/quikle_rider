import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/features/profile/data/models/vehicle_model.dart';
import 'package:quikle_rider/features/profile/data/services/profile_services.dart';

class VehicleController extends GetxController {
  VehicleController({ProfileServices? profileServices})
    : _profileServices = profileServices ?? ProfileServices();

  final ProfileServices _profileServices;

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

  String get vehicleCreationErrorText =>
      vehicleCreationError.value?.isNotEmpty == true
      ? vehicleCreationError.value!
      : 'Unable to save vehicle information.';

  void clearForLogout() {
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
  }

  @override
  void onClose() {
    licensePlateController.dispose();
    vehicleModelController.dispose();
    super.onClose();
  }

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
        backgroundColor: Colors.green.withValues(alpha: 0.2),
        colorText: Colors.green[900],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } else {
      Get.snackbar(
        'Unable to save vehicle',
        vehicleCreationErrorText,
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

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
}
