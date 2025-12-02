import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:quikle_rider/core/models/response_data.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/constants/api_constants.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';

class ProfileServices {
  ProfileServices({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;


  Future<ResponseData> getProfile({
    required String accessToken,
    required String refreshToken,
  }) async {
    final uri = Uri.parse('$baseurl/rider/rider-profile/me/');

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

  Future<ResponseData> getProfileCompletion({
    required String accessToken,
  }) async {
    final uri = Uri.parse('$baseurl/rider/profile/completion');

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
        errorMessage:
            'Unable to fetch profile completion. Please try again.',
        responseData: error.toString(),
      );
    }
  }

  Future<ResponseData> updateProfile({
    required String accessToken,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('$baseurl/rider/rider-profile/me/');

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

  Future<ResponseData> createVehicle({
    required String accessToken,
    required String vehicleType,
    required String licensePlateNumber,
    String? model,
  }) async {
    final uri = Uri.parse('$baseurl/rider/vehicles/me/');
    final Map<String, dynamic> payload = {
      'vehicle_type': vehicleType,
      'license_plate_number': licensePlateNumber,
    };
    if (model != null && model.trim().isNotEmpty) {
      payload['model'] = model;
    }

    try {
      final response = await _client.post(
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
        errorMessage: 'Unable to save vehicle information. Please try again.',
        responseData: error.toString(),
      );
    }
  }

  Future<ResponseData> listVehicles({required String accessToken}) async {
    final uri = Uri.parse('$baseurl/rider/list/vehicles/');

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
        errorMessage: 'Unable to fetch vehicles. Please try again.',
        responseData: error.toString(),
      );
    }
  }

  Future<ResponseData> createHelpAndSupport({
    required String accessToken,
    required String subject,
    required String description,
    File? attachment,
  }) async {
    final uri = Uri.parse('$baseurl/rider/help-and-support/me/');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        })
        ..fields['subject'] = subject
        ..fields['description'] = description;

      if (attachment != null) {
        request.files.add(
          await http.MultipartFile.fromPath('attachments', attachment.path),
        );
      }

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
        errorMessage:
            'Unable to submit help request. Please check your connection and try again.',
        responseData: error.toString(),
      );
    }
  }

  Future<ResponseData> listHelpSupportRequests({
    required String accessToken,
  }) async {
    final uri = Uri.parse('$baseurl/rider/help-and-support-requests/me/');

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
        errorMessage: 'Unable to load support history. Please try again.',
        responseData: error.toString(),
      );
    }
  }

  Future<ResponseData> getVehicle({
    required String accessToken,
    required int vehicleId,
  }) async {
    final uri = Uri.parse('$baseurl/rider/vehicles/$vehicleId/');

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
        errorMessage: 'Unable to load vehicle information. Please try again.',
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
    final uri = Uri.parse('$baseurl/rider/rider-documents/me/');

    try {
      final request = http.MultipartRequest('PUT', uri);
      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      /// Helper to add a file to the multipart request.
      /// If the file is null or does not exist, it adds an empty part
      /// to ensure the backend receives all expected fields, which might
      /// be a requirement to avoid a 422 Unprocessable Entity error.
      Future<void> addFile(String field, File? file) async {
        if (file != null && await file.exists()) {
          final mediaType = _mediaTypeForFile(file);
          request.files.add(
            await http.MultipartFile.fromPath(
              field,
              file.path,
              contentType: mediaType,
            ),
          );
        } else {
          // Send an empty file part if the file is null.
          request.files.add(
            http.MultipartFile(
              field,
              Stream.empty(),
              0,
              filename: '', // Empty filename.
              contentType: MediaType(
                'application',
                'octet-stream',
              ), // Default content type.
            ),
          );
        }
      }

      await addFile('pi', profileImage);
      await addFile('nid', nationalId);
      await addFile('dl', drivingLicense);
      await addFile('vr', vehicleRegistration);
      await addFile('vi', vehicleInsurance);

      // --- DEBUGGING START ---
      print('--- Sending Document Upload Request ---');
      print('URL: ${request.method} ${request.url}');
      print('Headers: ${request.headers}');
      print(
        'Files: ${request.files.map((f) => 'field: ${f.field}, filename: ${f.filename}, length: ${f.length}, contentType: ${f.contentType}').toList()}',
      );
      // --- DEBUGGING END ---

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final decodedBody = _decodeResponseBody(response.body);
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      // --- DEBUGGING START ---
      print('--- Received Document Upload Response ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('------------------------------------');
      // --- DEBUGGING END ---

      return ResponseData(
        isSuccess: isSuccess,
        statusCode: response.statusCode,
        errorMessage: isSuccess ? '' : _extractErrorMessage(decodedBody),
        responseData: decodedBody,
      );
    } catch (error, stackTrace) {
      // --- DEBUGGING START ---
      print('--- Document Upload Request Failed ---');
      print('Error: $error');
      print('Stack Trace: $stackTrace');
      print('--------------------------------------');
      // --- DEBUGGING END ---
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        errorMessage: 'Unable to upload documents. Please try again.',
        responseData: error.toString(),
      );
    }
  }

  MediaType? _mediaTypeForFile(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.png')) return MediaType('image', 'png');
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (path.endsWith('.webp')) return MediaType('image', 'webp');
    if (path.endsWith('.gif')) return MediaType('image', 'gif');
    if (path.endsWith('.pdf')) return MediaType('application', 'pdf');
    return null;
  }

  Future<Map<String, dynamic>?> updateRiderAvailability({
    required String token,
    required bool isAvailable,
    required String startAt,
    required String endAt,
  }) async {
    final url = Uri.parse('$baseurl/rider/rider-availability/me/');

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final body = {
      'is_available': isAvailable.toString(),
      'start_at': startAt,
      'end_at': endAt,
    };

    AppLoggerHelper.debug('Updating rider availability with body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLoggerHelper.debug("result: ${response.statusCode}");
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRiderAvailability({
    required String token,
  }) async {
    final url = Uri.parse('$baseurl/rider/rider-availability/me/');
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      AppLoggerHelper.debug(
        'Failed to fetch availability. Status: ${response.statusCode}',
      );
      return null;
    } catch (e) {
      AppLoggerHelper.error('Error fetching availability: $e');
      return null;
    }
  }
}
