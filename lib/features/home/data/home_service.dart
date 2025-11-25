import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quikle_rider/core/models/response_data.dart';
import 'package:quikle_rider/core/services/storage_service.dart';

class HomeService {
  HomeService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://caditya619-backend.onrender.com';

  Future<ResponseData> toggleOnlineStatus({required bool isOnline}) async {
    final accessToken = StorageService.accessToken;
    final tokenType = StorageService.tokenType ?? 'Bearer';

    if (accessToken == null || accessToken.isEmpty) {
      return ResponseData(
        isSuccess: false,
        statusCode: 401,
        errorMessage: 'Not authenticated',
        responseData: null,
      );
    }

    try {
      final uri = Uri.parse('$_baseUrl/rider/go-online-offline');
      final response = await _client.put(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': '$tokenType $accessToken',
        },
        body: {'is_online': isOnline.toString()},
      );

      final decodedBody = _decodeResponse(response.body);
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      return ResponseData(
        isSuccess: isSuccess,
        statusCode: response.statusCode,
        errorMessage: isSuccess ? '' : _extractErrorMessage(decodedBody),
        responseData: decodedBody,
      );
    } catch (error) {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        errorMessage: 'Unable to update status.',
        responseData: error.toString(),
      );
    }
  }

  dynamic _decodeResponse(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _extractErrorMessage(dynamic decodedBody) {
    if (decodedBody is Map<String, dynamic>) {
      if (decodedBody['message'] is String) {
        return decodedBody['message'] as String;
      }
      if (decodedBody['detail'] is String) {
        return decodedBody['detail'] as String;
      }
    }
    return 'Failed to update status. Please try again.';
  }
}
