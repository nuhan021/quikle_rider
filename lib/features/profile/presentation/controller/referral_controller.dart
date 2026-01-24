import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/features/profile/data/models/referral_dashboard.dart';
import 'package:quikle_rider/features/profile/data/services/profile_services.dart';

class ReferralController extends GetxController {
  ReferralController({ProfileServices? profileServices})
    : _profileServices = profileServices ?? ProfileServices();

  final ProfileServices _profileServices;

  final Rxn<ReferralDashboard> referralDashboard = Rxn<ReferralDashboard>();
  final RxBool isReferralDashboardLoading = false.obs;
  final RxnString referralDashboardError = RxnString();
  final Rxn<Uint8List> referralQrImage = Rxn<Uint8List>();
  final RxBool isReferralQrLoading = false.obs;
  final RxnString referralQrError = RxnString();

  void clearForLogout() {
    referralDashboard.value = null;
    isReferralDashboardLoading.value = false;
    referralDashboardError.value = null;
    referralQrImage.value = null;
    isReferralQrLoading.value = false;
    referralQrError.value = null;
  }

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
}
