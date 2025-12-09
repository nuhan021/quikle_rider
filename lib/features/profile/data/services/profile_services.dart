import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:quikle_rider/core/models/response_data.dart';
import 'package:quikle_rider/core/services/network_caller.dart';
import 'package:quikle_rider/core/utils/constants/api_constants.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';

class ProfileServices {
  ProfileServices({NetworkCaller? networkCaller})
      : _networkCaller = networkCaller ?? NetworkCaller();

  final NetworkCaller _networkCaller;

  Future<ResponseData> getDocumentUploadStatus({
    required String accessToken,
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/is-document-uploaded/',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage:
          'Unable to check document status. Please try again.',
    );
  }

  Future<ResponseData> getVerificationStatus({
    required String accessToken,
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/is-verified',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to check verification status. Please try again.',
    );
  }

  Future<ResponseData> getProfile({
    required String accessToken,
    required String refreshToken,
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/rider-profile/me/',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'refresh-token': refreshToken,
      },
      defaultErrorMessage: 'Unable to fetch profile. Please try again.',
    );
  }

  Future<ResponseData> getProfileCompletion({
    required String accessToken,
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/profile/completion',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage:
          'Unable to fetch profile completion. Please try again.',
    );
  }

  Future<ResponseData> getTrainingVideos({
    required String accessToken,
  }) async {
    final response = await _networkCaller.getRequest(
      '$baseurl/rider/videos',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to load training videos. Please try again.',
    );
    AppLoggerHelper.debug("response Videos :${response.responseData}");
    return response;
  }

  Future<ResponseData> getTrainingPdfs({
    required String accessToken,
  }) async {
    final response = await _networkCaller.getRequest(
      '$baseurl/rider/pdfs',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to load training PDFs. Please try again.',
    );
    AppLoggerHelper.debug("response pdf :${response.responseData}");
    return response;
  }

  Future<ResponseData> getRiderRatings({
    required String accessToken,
    String language = 'eng',
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/rider/rider-ratings/?lng=$language',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to load rider ratings. Please try again.',
    );
  }

  Future<ResponseData> updateProfile({
    required String accessToken,
    required Map<String, dynamic> payload,
  }) {
    return _networkCaller.putRequest(
      '$baseurl/rider/rider-profile/me/',
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: payload,
      defaultErrorMessage: 'Unable to update profile. Please try again.',
    );
  }

  Future<ResponseData> createVehicle({
    required String accessToken,
    required String vehicleType,
    required String licensePlateNumber,
    String? model,
  }) {
    final uri = Uri.parse('$baseurl/rider/vehicles/me/');
    final Map<String, dynamic> payload = {
      'vehicle_type': vehicleType,
      'license_plate_number': licensePlateNumber,
    };
    if (model != null && model.trim().isNotEmpty) {
      payload['model'] = model;
    }

    return _networkCaller.postRequest(
      uri.toString(),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: payload,
      defaultErrorMessage:
          'Unable to save vehicle information. Please try again.',
    );
  }

  Future<ResponseData> listVehicles({required String accessToken}) {
    return _networkCaller.getRequest(
      '$baseurl/rider/list/vehicles/',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to fetch vehicles. Please try again.',
    );
  }

  Future<ResponseData> createHelpAndSupport({
    required String accessToken,
    required String subject,
    required String description,
    File? attachment,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseurl/rider/help-and-support/me/'),
    )
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

    return _networkCaller.sendMultipart(
      request,
      defaultErrorMessage:
          'Unable to submit help request. Please check your connection and try again.',
    );
  }

  Future<ResponseData> listHelpSupportRequests({
    required String accessToken,
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/help-and-support-requests/me/',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to load support history. Please try again.',
    );
  }

  Future<ResponseData> getVehicle({
    required String accessToken,
    required int vehicleId,
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/vehicles/$vehicleId/',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage:
          'Unable to load vehicle information. Please try again.',
    );
  }

  Future<ResponseData> uploadDocuments({
    required String accessToken,
    File? profileImage,
    File? nationalId,
    File? drivingLicense,
    File? vehicleRegistration,
    File? vehicleInsurance,
  }) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseurl/rider/rider-documents/me/'),
    );
    request.headers.addAll({
      'accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    });

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
        request.files.add(
          http.MultipartFile(
            field,
            Stream.empty(),
            0,
            filename: '',
            contentType: MediaType('application', 'octet-stream'),
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

    final response = await _networkCaller.sendMultipart(
      request,
      defaultErrorMessage: 'Unable to upload documents. Please try again.',
    );

    // --- DEBUGGING START ---
    print('--- Received Document Upload Response ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.responseData}');
    print('------------------------------------');
    // --- DEBUGGING END ---

    return response;
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
    final body = {
      'is_available': isAvailable.toString(),
      'start_at': startAt,
      'end_at': endAt,
    };

    AppLoggerHelper.debug('Updating rider availability with body: $body');

    final response = await _networkCaller.postRequest(
      '$baseurl/rider/rider-availability/me/',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
      encodeJson: false,
      defaultErrorMessage: 'Unable to update status.',
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      AppLoggerHelper.debug("result: ${response.statusCode}");
      return response.responseData as Map<String, dynamic>;
    }

    return null;
  }

  Future<Map<String, dynamic>?> getRiderAvailability({
    required String token,
  }) async {
    final response = await _networkCaller.getRequest(
      '$baseurl/rider/rider-availability/me/',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      defaultErrorMessage: 'Unable to fetch availability.',
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return response.responseData as Map<String, dynamic>;
    }

    AppLoggerHelper.debug(
      'Failed to fetch availability. Status: ${response.statusCode}',
    );
    return null;
  }

  Future<ResponseData> getReferralDashboard({
    required String accessToken,
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/referral/dashboard',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage:
          'Unable to load referral dashboard. Please try again.',
    );
  }

  Future<ResponseData> getReferralQrImage({
    required String accessToken,
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/referral/qr',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      returnBytesOnSuccess: true,
      defaultErrorMessage: 'Unable to load referral QR code. Please try again.',
    );
  }

  Future<ResponseData> startQuiz({
    required String accessToken,
  }) async {
    final response = await _networkCaller.getRequest(
      '$baseurl/rider/start',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to start quiz. Please try again.',
    );
    AppLoggerHelper.debug("response quiz ${response.responseData}");
    return response;
  }

  Future<ResponseData> submitQuiz({
    required String accessToken,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _networkCaller.postRequest(
      '$baseurl/rider/submit',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: payload,
      defaultErrorMessage: 'Unable to submit quiz. Please try again.',
    );
    AppLoggerHelper.debug("response quiz ${response.responseData}");
    return response;
  }


}

