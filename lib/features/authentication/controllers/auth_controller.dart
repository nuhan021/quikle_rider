import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/features/authentication/data/services/auth_servies.dart';
import 'package:quikle_rider/routes/app_routes.dart';

class AuthController extends GetxController {
  static const int _otpLength = 6;
  final AuthServies _authServices = AuthServies();

  final phoneController = TextEditingController();
  final phoneFocusNode = FocusNode();
  final isPhoneFocused = false.obs;

  final otpControllers = List<TextEditingController>.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final otpFocusNodes = List<FocusNode>.generate(
    _otpLength,
    (_) => FocusNode(),
  );
  final currentOtp = ''.obs;
  final resendTimer = 27.obs;
  final canResend = false.obs;
  Timer? _resendCountdown;
  bool _isSignupFlow = false;
  String _currentOtpPurpose = 'rider_login';
  Map<String, String>? _pendingSignupPayload;

  final fullNameController = TextEditingController();
  final accountPhoneController = TextEditingController();
  final drivingLicenseController = TextEditingController();
  final vehicleLicenseController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  static const _resendDuration = 27;
  String? _pendingPhoneNumber;

  String get phoneNumberForOtp =>
      (_pendingPhoneNumber ?? phoneController.text).trim();

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

  Future<void> navigateToOtp() async {
    final phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      Get.snackbar(
        'Phone Required',
        'Enter your phone number to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _isSignupFlow = false;
    _pendingSignupPayload = null;
    final otpSent = await _requestOtp(
      phoneNumber: phoneNumber,
      purpose: 'rider_login',
    );

    if (otpSent) {
      Get.toNamed(
        AppRoute.getLoginOtp(),
        arguments: {'phone': _pendingPhoneNumber},
      );
    }
  }

  void onOtpChanged(int index, String value, BuildContext context) {
    // Only keep a single character per field
    if (value.length > 1) {
      value = value.substring(value.length - 1);
      otpControllers[index].text = value;
      otpControllers[index].selection = TextSelection.collapsed(
        offset: value.length,
      );
    }

    if (value.isNotEmpty && index < otpFocusNodes.length - 1) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }

    currentOtp.value = _collectOtp();
    if (!_isSignupFlow && currentOtp.value.length == _otpLength) {
      verifyOtp(context);
    }
  }

  Future<void> verifyOtp(BuildContext context) async {
    final otpValue = currentOtp.value.trim();
    final requiredLength = _isSignupFlow ? 4 : _otpLength;
    if (otpValue.length < requiredLength) {
      Get.snackbar(
        'Invalid Code',
        'Enter the full verification code.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_isSignupFlow) {
      await _submitSignup(otpValue);
    } else {
      await _loginWithOtp(otpValue);
    }
  }

  Future<void> resendCode() async {
    if (!canResend.value || _pendingPhoneNumber == null) return;
    await _requestOtp(
      phoneNumber: _pendingPhoneNumber!,
      purpose: _currentOtpPurpose,
    );
  }

  Future<void> createAccount(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    final name = fullNameController.text.trim();
    final phone = accountPhoneController.text.trim();
    final drivingLicense = drivingLicenseController.text.trim();
    final nid = vehicleLicenseController.text.trim();

    _pendingSignupPayload = {
      'name': name,
      'phone': phone,
      'driving_license': drivingLicense,
      'nid': nid,
    };
    _isSignupFlow = true;

    final otpSent = await _requestOtp(
      phoneNumber: phone,
      purpose: 'rider_signup',
    );

    if (otpSent) {
      Get.toNamed(
        AppRoute.getLoginOtp(),
        arguments: {'phone': _pendingPhoneNumber},
      );
    }
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

  Future<void> _loginWithOtp(String otpValue) async {
    final phoneNumber = _pendingPhoneNumber ?? phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      Get.snackbar(
        'Phone Required',
        'Please enter your phone number again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final response = await _runWithLoader(
      () => _authServices.login(phone: phoneNumber, otp: otpValue),
    );

    if (response.isSuccess) {
      final data = response.responseData;
      if (data is Map<String, dynamic>) {
        final accessToken = data['access_token']?.toString() ?? '';
        final refreshToken = data['refresh_token']?.toString() ?? '';
        final tokenType = data['token_type']?.toString() ?? 'Bearer';

        if (accessToken.isEmpty || refreshToken.isEmpty) {
          Get.snackbar(
            'Login Error',
            'Invalid token data received.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        await StorageService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          tokenType: tokenType,
        );
        AppLoggerHelper.debug(
          'Logged in successfully. Access token: $accessToken',
        );
        AppLoggerHelper.debug(
          'Logged in successfully. Refresh token: $refreshToken',
        );
        AppLoggerHelper.debug('Logged in successfully. Token type: $tokenType');

        Get.offAllNamed(AppRoute.getWelcomeScreen());
      } else {
        Get.snackbar(
          'Login Error',
          'Unexpected response format from server.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Login Failed',
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to verify code. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> _requestOtp({
    required String phoneNumber,
    required String purpose,
  }) async {
    _pendingPhoneNumber = phoneNumber;
    _currentOtpPurpose = purpose;

    final response = await _runWithLoader(
      () => _authServices.sendOtp(phone: phoneNumber, purpose: purpose),
    );

    if (response.isSuccess) {
      _resetOtpFields();
      _startResendTimer();
      Get.snackbar(
        'Code Sent',
        'A verification code has been sent to $phoneNumber',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFB800),
        colorText: Colors.black,
        duration: const Duration(seconds: 3),
      );
      return true;
    } else {
      Get.snackbar(
        'Failed to send OTP',
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> _submitSignup(String otpValue) async {
    final signupPayload = _pendingSignupPayload;
    if (signupPayload == null) {
      Get.snackbar(
        'Signup Error',
        'Please fill up the form again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final response = await _runWithLoader(
      () => _authServices.signUp(
        phone: signupPayload['phone'] ?? '',
        name: signupPayload['name'] ?? '',
        otp: otpValue,
        nid: signupPayload['nid'] ?? '',
        drivingLicense: signupPayload['driving_license'] ?? '',
      ),
    );

    if (response.isSuccess) {
      _isSignupFlow = false;
      _pendingSignupPayload = null;
      fullNameController.clear();
      accountPhoneController.clear();
      drivingLicenseController.clear();
      vehicleLicenseController.clear();

      Get.snackbar(
        'Account Created',
        'Your account has been created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFB800),
        colorText: Colors.black,
        duration: const Duration(seconds: 3),
      );

      Get.offAllNamed(AppRoute.getWelcomeScreen());
    } else {
      Get.snackbar(
        'Signup Failed',
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to create account. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<T> _runWithLoader<T>(Future<T> Function() task) async {
    Get.dialog<void>(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB800)),
        ),
      ),
      barrierDismissible: false,
    );
    try {
      return await task();
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }
}
