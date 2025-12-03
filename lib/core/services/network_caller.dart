import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/response_data.dart';

class NetworkCaller {
  NetworkCaller({http.Client? client, this.timeoutDuration = 10})
      : _client = client ?? http.Client();

  final http.Client _client;
  final int timeoutDuration;

  Future<ResponseData> getRequest(
    String url, {
    Map<String, String>? headers,
    bool returnBytesOnSuccess = false,
    String defaultErrorMessage = 'Unexpected error occurred.',
  }) async {
    log('GET Request: $url');
    return _sendRequest(
      method: 'GET',
      url: url,
      headers: headers,
      returnBytesOnSuccess: returnBytesOnSuccess,
      defaultErrorMessage: defaultErrorMessage,
    );
  }

  Future<ResponseData> postRequest(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool encodeJson = true,
    String defaultErrorMessage = 'Unexpected error occurred.',
  }) async {
    log('POST Request: $url');
    return _sendRequest(
      method: 'POST',
      url: url,
      headers: headers,
      body: body,
      encodeJson: encodeJson,
      defaultErrorMessage: defaultErrorMessage,
    );
  }

  Future<ResponseData> putRequest(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool encodeJson = true,
    String defaultErrorMessage = 'Unexpected error occurred.',
  }) async {
    log('PUT Request: $url');
    return _sendRequest(
      method: 'PUT',
      url: url,
      headers: headers,
      body: body,
      encodeJson: encodeJson,
      defaultErrorMessage: defaultErrorMessage,
    );
  }

  Future<ResponseData> sendMultipart(
    http.MultipartRequest request, {
    bool returnBytesOnSuccess = false,
    String defaultErrorMessage = 'Unexpected error occurred.',
  }) async {
    log('${request.method} Multipart: ${request.url}');
    log('Multipart Headers: ${request.headers}');
    try {
      final streamedResponse = await _client
          .send(request)
          .timeout(Duration(seconds: timeoutDuration));
      final response = await http.Response.fromStream(streamedResponse);
      return _buildResponseData(
        response,
        returnBytesOnSuccess: returnBytesOnSuccess,
      );
    } catch (error) {
      return _handleError(error, defaultErrorMessage);
    }
  }

  Future<ResponseData> _sendRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
    bool encodeJson = true,
    bool returnBytesOnSuccess = false,
    String defaultErrorMessage = 'Unexpected error occurred.',
  }) async {
    final uri = Uri.parse(url);
    log('Headers: ${headers ?? {}}');
    if (body != null) {
      log('Body: $body');
    }

    try {
      late http.Response response;
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(Duration(seconds: timeoutDuration));
          break;
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: headers,
                body: _prepareBody(body, encodeJson),
              )
              .timeout(Duration(seconds: timeoutDuration));
          break;
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: headers,
                body: _prepareBody(body, encodeJson),
              )
              .timeout(Duration(seconds: timeoutDuration));
          break;
        default:
          throw UnsupportedError('Unsupported method $method');
      }

      return _buildResponseData(
        response,
        returnBytesOnSuccess: returnBytesOnSuccess,
      );
    } catch (error) {
      return _handleError(error, defaultErrorMessage);
    }
  }

  Object? _prepareBody(Object? body, bool encodeJson) {
    if (body == null) return null;
    if (!encodeJson) return body;
    return jsonEncode(body);
  }

  ResponseData _buildResponseData(
    http.Response response, {
    bool returnBytesOnSuccess = false,
  }) {
    log('Response Status: ${response.statusCode}');
    log('Response Body: ${response.body}');

    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    final decodedBody =
        returnBytesOnSuccess && isSuccess ? response.bodyBytes : _decodeResponse(response.body);

    return ResponseData(
      isSuccess: isSuccess,
      statusCode: response.statusCode,
      responseData: decodedBody,
      errorMessage: isSuccess ? '' : _extractErrorMessage(decodedBody),
    );
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
      if (decodedBody['detail'] is String) {
        return decodedBody['detail'] as String;
      }
      if (decodedBody['message'] is String) {
        return decodedBody['message'] as String;
      }
    }
    return 'Something went wrong. Please try again.';
  }

  ResponseData _handleError(dynamic error, String defaultErrorMessage) {
    log('Request Error: $error');

    if (error is TimeoutException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 408,
        responseData: error.toString(),
        errorMessage: 'Request timeout. Please try again later.',
      );
    }

    return ResponseData(
      isSuccess: false,
      statusCode: 500,
      responseData: error.toString(),
      errorMessage: defaultErrorMessage,
    );
  }
}
