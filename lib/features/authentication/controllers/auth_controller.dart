import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/firebase/firebase_service.dart';
import 'package:quikle_rider/core/services/firebase/notification_service.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/features/authentication/data/services/auth_servies.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
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
  final isVerifying = false.obs;
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

    isVerifying.value = true;
    try {
      if (_isSignupFlow) {
        await _submitSignup(otpValue);
      } else {
        await _loginWithOtp(otpValue);
      }
    } finally {
      isVerifying.value = false;
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
        final profileController = Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController(), permanent: true);
        await profileController.refreshForLogin(resetState: true);
        final resolvedUserId = await _postLoginSetup(
          accessToken: accessToken,
          refreshToken: refreshToken,
          tokenType: tokenType,
          initialData: data,
        );
        AppLoggerHelper.debug('User ID : $resolvedUserId');
        AppLoggerHelper.debug(
          'Logged in successfully. Access token: $accessToken',
        );
        if (resolvedUserId != null) {
          await NotificationService.instance.sendInstantNotification(
            userId: resolvedUserId,
            title: "success",
            body: "Login",
          );
        }
        AppLoggerHelper.debug(
          'Logged in successfully. Refresh token: $refreshToken',
        );
        AppLoggerHelper.debug('Logged in successfully. Token type: $tokenType');

        Get.offAllNamed(AppRoute.getWelcomeScreen());

        Get.snackbar(
          'Login Successful',
          'You have logged in successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
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

      if (response.isSuccess) {
        FlutterLocalNotificationsPlugin().show(
          0,
          'OTP Sent',
          'An OTP has been sent to ${response.responseData['message']}',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'otp_notification_channel',
              'OTP Notification',
              channelDescription: 'Channel for OTP notifications',
              importance: Importance.high,
            ),
          ),
        );
      }
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

  Future<bool> _syncFcmToken({
    required int userId,
    required String accessToken,
    required String tokenType,
  }) async {
    try {
      final refreshedToken = await FirebaseService.instance.refreshToken();
      final existing = StorageService.cachedFcmToken;
      final token = refreshedToken?.isNotEmpty == true
          ? refreshedToken
          : existing?.isNotEmpty == true
          ? existing
          : await FirebaseService.instance.waitForToken();
      final finalToken = token ?? StorageService.cachedFcmToken;

      if (finalToken == null || finalToken.isEmpty) {
        AppLoggerHelper.debug('FCM token unavailable.');
        return false;
      }

      await StorageService.cacheFcmToken(finalToken);
      AppLoggerHelper.debug('FCM token saved locally: $finalToken');

      final platform = Platform.isIOS
          ? 'ios'
          : Platform.isAndroid
          ? 'android'
          : Platform.operatingSystem;

      final success = await NotificationService.instance.saveFcmToken(
        userId: userId,
        token: finalToken,
        platform: platform,
        authorization:
            '${tokenType.trim().isEmpty ? 'Bearer' : tokenType.trim()} $accessToken',
      );

      return success;
    } catch (error) {
      AppLoggerHelper.debug('Error syncing FCM token: $error');
      return false;
    }
  }

  Future<int?> _postLoginSetup({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required Map<String, dynamic> initialData,
  }) async {
    try {
      final fetchedUserId = await _fetchUserId(
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
      );
      final inlineUserId = _extractUserId(initialData);
      final cachedUserId = StorageService.userId;

      final resolvedUserId = fetchedUserId ?? inlineUserId ?? cachedUserId;
      if (resolvedUserId != null) {
        await StorageService.saveUserId(resolvedUserId);
        AppLoggerHelper.debug('User ID saved post-login: $resolvedUserId');

        final fcmSynced = await _syncFcmToken(
          userId: resolvedUserId,
          accessToken: accessToken,
          tokenType: tokenType,
        );
        AppLoggerHelper.debug(
          fcmSynced
              ? 'FCM token synced for user $resolvedUserId'
              : 'FCM token sync skipped or failed for user $resolvedUserId',
        );
      } else {
        AppLoggerHelper.debug('Unable to resolve user id post-login.');
      }
    } catch (error) {
      AppLoggerHelper.debug('Post login setup failed: $error');
    }
    return StorageService.userId;
  }

  Future<int?> _fetchUserId({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
  }) async {
    final response = await _authServices.verifyToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
    );
    if (!response.isSuccess) {
      AppLoggerHelper.debug(
        'verify-token failed (${response.statusCode}): ${response.errorMessage}',
      );
      return null;
    }
    final profile = response.responseData;
    if (profile is! Map<String, dynamic>) {
      AppLoggerHelper.debug('verify-token returned unexpected body: $profile');
      return null;
    }
    final id = profile['id'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  int? _extractUserId(Map<String, dynamic> data) {
    final directId = _parseInt(data['user_id'] ?? data['id']);
    if (directId != null) return directId;

    final userData = data['user'];
    if (userData is Map<String, dynamic>) {
      return _parseInt(userData['id'] ?? userData['user_id']);
    }
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
