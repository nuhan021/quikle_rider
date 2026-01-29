import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _userIdKey = 'user_id';
  static const String _verificationStatusKey = 'verification_status';
  static const String _documentUploadStatusKey = 'document_upload_status';

  static SharedPreferences? _preferences;
  static String? _cachedVerificationStatus;
  static bool _verificationStatusLoaded = false;
  static bool? _cachedDocumentUploadStatus;
  static bool _documentUploadStatusLoaded = false;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    AppLoggerHelper.debug('has token ${refreshToken}');
    AppLoggerHelper.debug('User id ${userId}');
  }

  static bool hasToken() {
    final token = _preferences?.getString(_accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
  }) async {
    await _preferences?.setString(_accessTokenKey, accessToken);
    await _preferences?.setString(_refreshTokenKey, refreshToken);
    await _preferences?.setString(_tokenTypeKey, tokenType);
  }

  static Future<void> logoutUser() async {
    await clearAll();
  }

  static String? get accessToken => _preferences?.getString(_accessTokenKey);
  static String? get refreshToken => _preferences?.getString(_refreshTokenKey);
  static String? get tokenType => _preferences?.getString(_tokenTypeKey);
  static String? get cachedVerificationStatus {
    if (_verificationStatusLoaded) return _cachedVerificationStatus;
    if (_preferences == null) return null;
    _cachedVerificationStatus = _preferences?.getString(_verificationStatusKey);
    _verificationStatusLoaded = true;
    return _cachedVerificationStatus;
  }

  static bool? get cachedDocumentUploadStatus {
    if (_documentUploadStatusLoaded) return _cachedDocumentUploadStatus;
    if (_preferences == null) return null;
    _cachedDocumentUploadStatus =
        _preferences?.getBool(_documentUploadStatusKey);
    _documentUploadStatusLoaded = true;
    return _cachedDocumentUploadStatus;
  }

  static Future<void> cacheVerificationStatus(String? status) async {
    _cachedVerificationStatus = status;
    _verificationStatusLoaded = true;
    if (status == null || status.isEmpty) {
      await _preferences?.remove(_verificationStatusKey);
    } else {
      await _preferences?.setString(_verificationStatusKey, status);
    }
  }

  static Future<void> cacheDocumentUploadStatus(bool? status) async {
    _cachedDocumentUploadStatus = status;
    _documentUploadStatusLoaded = true;
    if (status == null) {
      await _preferences?.remove(_documentUploadStatusKey);
    } else {
      await _preferences?.setBool(_documentUploadStatusKey, status);
    }
  }

  static Future<void> cacheFcmToken(String token) async {
    await _preferences?.setString(_fcmTokenKey, token);
  }

  static String? get cachedFcmToken => _preferences?.getString(_fcmTokenKey);

  static Future<void> saveUserId(int id) async {
    await _preferences?.setInt(_userIdKey, id);
  }

  static int? get userId => _preferences?.getInt(_userIdKey);

  static Future<void> clearAll() async {
    await _preferences?.clear();
    _cachedVerificationStatus = null;
    _verificationStatusLoaded = false;
    _cachedDocumentUploadStatus = null;
    _documentUploadStatusLoaded = false;
  }
}
