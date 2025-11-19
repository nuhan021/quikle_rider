import 'package:get/get.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/features/profile/data/models/profile_model.dart';
import 'package:quikle_rider/features/profile/data/services/profile_services.dart';

class ProfileController extends GetxController {
  ProfileController({ProfileServices? profileServices})
      : _profileServices = profileServices ?? ProfileServices();

  final ProfileServices _profileServices;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<ProfileModel> profile = Rxn<ProfileModel>();

  bool get shouldShowLoadingHeader => isLoading.value && profile.value == null;

  bool get shouldShowErrorHeader {
    final hasError = errorMessage.value != null && errorMessage.value!.isNotEmpty;
    return hasError && profile.value == null;
  }

  String get headerErrorText =>
      errorMessage.value?.isNotEmpty == true ? errorMessage.value! : 'Unable to fetch profile.';

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
}
