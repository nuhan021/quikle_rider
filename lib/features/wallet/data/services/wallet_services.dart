import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quikle_rider/core/models/response_data.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';

class WalletServices {
  WalletServices({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://caditya619-backend.onrender.com';

  Future<ResponseData> fetchWalletSummary({
    required String accessToken,
    required String period,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/rider/wallet/',
    ).replace(queryParameters: {'period': period});

    try {
      final response = await _client.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final decodedBody = _decodeResponseBody(response.body);
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      AppLoggerHelper.debug("response wallet $decodedBody");
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
        errorMessage: 'Unable to fetch wallet details. Please try again.',
        responseData: error.toString(),
      );
    }
  }

  Future<ResponseData> fetchPerformance({
    required String accessToken,
  }) async {
    final uri = Uri.parse('$_baseUrl/rider/performance/');
    try {
      final response = await _client.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      final decodedBody = _decodeResponseBody(response.body);
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
        errorMessage: 'Unable to fetch performance data. Please try again.',
        responseData: error.toString(),
      );
    }
  }

  Future<ResponseData> fetchLeaderboard({
    required String accessToken,
  }) async {
    final uri = Uri.parse('$_baseUrl/rider/leaderboard/');
    try {
      final response = await _client.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      final decodedBody = _decodeResponseBody(response.body);
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
        errorMessage: 'Unable to fetch leaderboard. Please try again.',
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
    }
    return 'Something went wrong. Please try again.';
  }
}
