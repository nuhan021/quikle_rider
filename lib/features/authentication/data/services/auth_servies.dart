import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quikle_rider/core/models/response_data.dart';
import 'package:quikle_rider/core/utils/constants/api_constants.dart';

class AuthServies {
  AuthServies({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _verifyTokenUri = Uri.parse(
    'https://caditya619-backend.onrender.com/auth/verify-token/',
  );

  Future<ResponseData> sendOtp({
    required String phone,
    required String purpose,
  }) {
    return _postForm(
      path: '/auth/send_otp/',
      body: {'phone': phone, 'purpose': purpose},
    );
  }

  Future<ResponseData> login({
    required String phone,
    required String otp,
    String purpose = 'rider_login',
  }) {
    return _postForm(
      path: '/auth/login/',
      body: {'phone': phone, 'otp': otp, 'purpose': purpose},
    );
  }

  Future<ResponseData> signUp({
    required String phone,
    required String name,
    required String otp,
    required String nid,
    required String drivingLicense,
  }) {
    return _postForm(
      path: '/auth/rider/signup/',
      body: {
        'phone': phone,
        'name': name,
        'otp': otp,
        'nid': nid,
        'driving_license': drivingLicense,
      },
    );
  }

  Future<ResponseData> _postForm({
    required String path,
    required Map<String, String> body,
  }) async {
    try {
      final uri = Uri.parse('$baseurl$path');
      final response = await _client.post(
        uri,
        headers: const {
          'accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      final decodedBody = _decodeResponseBody(response.body);
      final success = response.statusCode >= 200 && response.statusCode < 300;
      final message = success ? '' : _extractErrorMessage(decodedBody);

      return ResponseData(
        isSuccess: success,
        statusCode: response.statusCode,
        errorMessage: message,
        responseData: decodedBody,
      );
    } catch (error) {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        errorMessage: 'Unable to connect. Please try again.',
        responseData: error.toString(),
      );
    }
  }

  dynamic _decodeResponseBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _extractErrorMessage(dynamic decodedBody) {
    if (decodedBody is Map<String, dynamic>) {
      if (decodedBody['detail'] is String) {
        return decodedBody['detail'] as String;
      }
      if (decodedBody['message'] is String) {
        return decodedBody['message'] as String;
      }
      if (decodedBody['detail'] is List) {
        final errors = decodedBody['detail'] as List<dynamic>;
        return errors
            .map((error) {
              if (error is Map && error['msg'] is String) {
                return error['msg'] as String;
              }
              return error.toString();
            })
            .join(', ');
      }
    }
    return 'Something went wrong. Please try again.';
  }

  Future<Map<String, dynamic>?> fetchUserProfile({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
  }) async {
    try {
      final response = await _client.get(
        _verifyTokenUri,
        headers: {
          'accept': 'application/json',
          'Authorization':
              '${tokenType.trim().isEmpty ? 'Bearer' : tokenType.trim()} $accessToken',
          'refresh-token': refreshToken,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = _decodeResponseBody(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (_) {}
    return null;
  }
}
