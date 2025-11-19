import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:quikle_rider/core/models/response_data.dart';

class ProfileServices {
  ProfileServices({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://caditya619-backend.onrender.com';

  Future<ResponseData> getProfile({
    required String accessToken,
    required String refreshToken,
  }) async {
    final uri = Uri.parse('$_baseUrl/rider/rider-profile/me/');

    try {
      final response = await _client.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'refresh-token': refreshToken,
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
        errorMessage: 'Unable to fetch profile. Please try again.',
        responseData: error.toString(),
      );
    }
  }

  Future<ResponseData> updateProfile({
    required String accessToken,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('$_baseUrl/rider/rider-profile/me/');

    try {
      final response = await _client.put(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
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
        errorMessage: 'Unable to update profile. Please try again.',
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

  Future<ResponseData> uploadDocuments({
    required String accessToken,
    File? profileImage,
    File? nationalId,
    File? drivingLicense,
    File? vehicleRegistration,
    File? vehicleInsurance,
  }) async {
    final uri = Uri.parse('$_baseUrl/rider/rider-documents/me/');

    try {
      final request = http.MultipartRequest('PUT', uri);
      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      Future<void> addFile(String field, File? file) async {
        if (file == null) return;
        request.files.add(await http.MultipartFile.fromPath(field, file.path));
      }

      await addFile('pi', profileImage);
      await addFile('nid', nationalId);
      await addFile('dl', drivingLicense);
      await addFile('vr', vehicleRegistration);
      await addFile('vi', vehicleInsurance);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
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
        errorMessage: 'Unable to upload documents. Please try again.',
        responseData: error.toString(),
      );
    }
  }
}
