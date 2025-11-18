import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';

  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    AppLoggerHelper.debug('has token ${refreshToken}');
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
    await _preferences?.remove(_accessTokenKey);
    await _preferences?.remove(_refreshTokenKey);
    await _preferences?.remove(_tokenTypeKey);
  }

  static String? get accessToken => _preferences?.getString(_accessTokenKey);
  static String? get refreshToken => _preferences?.getString(_refreshTokenKey);
  static String? get tokenType => _preferences?.getString(_tokenTypeKey);
}
