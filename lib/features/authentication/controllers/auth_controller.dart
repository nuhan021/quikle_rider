import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/routes/app_routes.dart';

class AuthController extends GetxController {
  final phoneController = TextEditingController();
  final phoneFocusNode = FocusNode();
  final isPhoneFocused = false.obs;

  final otpControllers =
      List<TextEditingController>.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List<FocusNode>.generate(6, (_) => FocusNode());
  final currentOtp = ''.obs;
  final resendTimer = 27.obs;
  final canResend = false.obs;
  Timer? _resendCountdown;

  final fullNameController = TextEditingController();
  final accountPhoneController = TextEditingController();
  final drivingLicenseController = TextEditingController();
  final vehicleLicenseController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  static const _resendDuration = 27;
  String? _pendingPhoneNumber;

  String get phoneNumberForOtp =>
      _pendingPhoneNumber ?? '+1 (654) 654-5648'; // fallback demo number

  @override
  void onInit() {
    super.onInit();
    phoneFocusNode.addListener(
      () => isPhoneFocused.value = phoneFocusNode.hasFocus,
    );
  }

  @override
  void onClose() {
    _resendCountdown?.cancel();
    phoneController.dispose();
    phoneFocusNode.dispose();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in otpFocusNodes) {
      node.dispose();
    }
    fullNameController.dispose();
    accountPhoneController.dispose();
    drivingLicenseController.dispose();
    vehicleLicenseController.dispose();
    super.onClose();
  }

  void navigateToOtp() {
    if (phoneController.text.isEmpty) {
      Get.snackbar(
        'Phone Required',
        'Enter your phone number to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _pendingPhoneNumber = phoneController.text;
    _resetOtpFields();
    _startResendTimer();
    Get.toNamed(AppRoute.getLoginOtp(), arguments: {
      'phone': _pendingPhoneNumber,
    });
  }

  void onOtpChanged(int index, String value, BuildContext context) {
    // Only keep a single character per field
    if (value.length > 1) {
      value = value.substring(value.length - 1);
      otpControllers[index].text = value;
      otpControllers[index].selection =
          TextSelection.collapsed(offset: value.length);
    }

    if (value.isNotEmpty && index < otpFocusNodes.length - 1) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }

    currentOtp.value = _collectOtp();
    if (currentOtp.value.length == 6) {
      verifyOtp(context);
    }
  }

  Future<void> verifyOtp(BuildContext context) async {
    if (currentOtp.value.length != 6) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB800)),
        ),
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 2));
    if (Get.isDialogOpen ?? false) {
      Get.back(); // close loader
    }

    Get.offNamed(AppRoute.getWelcomeScreen());
  }

  void resendCode() {
    if (!canResend.value) return;

    _resetOtpFields();
    _startResendTimer();

    otpFocusNodes.first.requestFocus();

    Get.snackbar(
      'Code Sent',
      'A new verification code has been sent to $phoneNumberForOtp',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFFB800),
      colorText: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }

  void createAccount(BuildContext context) {
    if (!(formKey.currentState?.validate() ?? false)) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB800)),
        ),
      ),
    );

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Account Created',
        'Your account has been created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFB800),
        titleText: const Text(
          'Account Created',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        messageText: const Text(
          'Your account has been created successfully!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        duration: const Duration(seconds: 3),
      );

      Get.offNamed(AppRoute.getWelcomeScreen());
    });
  }

  void _resetOtpFields() {
    for (final controller in otpControllers) {
      controller.clear();
    }
    currentOtp.value = '';
    canResend.value = false;
    resendTimer.value = _resendDuration;
  }

  String _collectOtp() {
    return otpControllers.map((controller) => controller.text).join();
  }

  void _startResendTimer() {
    _resendCountdown?.cancel();
    resendTimer.value = _resendDuration;
    canResend.value = false;

    _resendCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        timer.cancel();
        canResend.value = true;
      }
    });
  }
}
