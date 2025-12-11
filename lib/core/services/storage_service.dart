import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _userIdKey = 'user_id';

  static SharedPreferences? _preferences;

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
  }
}
