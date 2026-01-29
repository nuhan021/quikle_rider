import 'package:quikle_rider/core/models/response_data.dart';
import 'package:quikle_rider/core/services/location_services.dart';
import 'package:quikle_rider/core/services/network_caller.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/constants/api_constants.dart';

class HomeService {
  HomeService({NetworkCaller? networkCaller})
      : _networkCaller = networkCaller ?? NetworkCaller();

  final NetworkCaller _networkCaller;

  // Future<ResponseData> fetchUpcomingOrders({String? orderId}) async {
  //   final accessToken = StorageService.accessToken;
  //   final tokenType = StorageService.tokenType ?? 'Bearer';

  //   if (accessToken == null || accessToken.isEmpty) {
  //     return _unauthenticatedResponse();
  //   }

  //   final path =
  //       orderId == null ? '$baseurl/rider/orders/' : '$baseurl/rider/orders/$orderId/';
  //   return _networkCaller.getRequest(
  //     path,
  //     headers: {
  //       'accept': 'application/json',
  //       'Authorization': '$tokenType $accessToken',
  //     },
  //     defaultErrorMessage: 'Unable to fetch upcoming orders.',
  //   );
  // }

  Future<ResponseData> fetchOfferedOrders({
    int offset = 0,
    required int limit,
  }) async {
    final accessToken = StorageService.accessToken;
    final tokenType = StorageService.tokenType ?? 'Bearer';

    if (accessToken == null || accessToken.isEmpty) {
      return _unauthenticatedResponse();
    }

    return _networkCaller.getRequest(
      '$baseurl/rider/rider-offered-orders/?limit=$limit&offset=$offset',
      headers: {
        'accept': 'application/json',
        'Authorization': '$tokenType $accessToken',
      },
      defaultErrorMessage: 'Unable to fetch offered orders.',
    );
  }

  Future<ResponseData> acceptOfferedOrder({required String orderId}) async {
    final accessToken = StorageService.accessToken;
    final tokenType = StorageService.tokenType ?? 'Bearer';

    if (accessToken == null || accessToken.isEmpty) {
      return _unauthenticatedResponse();
    }

    return _networkCaller.postRequest(
      '$baseurl/rider/riders/orders/$orderId/accept',
      headers: {
        'accept': 'application/json',
        'Authorization': '$tokenType $accessToken',
      },
      encodeJson: false,
      defaultErrorMessage: 'Unable to accept order. Please try again.',
    );
  }

  Future<ResponseData> rejectOfferedOrder({
    required String orderId,
    String reason = 'string',
  }) async {
    final accessToken = StorageService.accessToken;
    final tokenType = StorageService.tokenType ?? 'Bearer';

    if (accessToken == null || accessToken.isEmpty) {
      return _unauthenticatedResponse();
    }

    return _networkCaller.postRequest(
      '$baseurl/rider/rider/reject/$orderId/',
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': '$tokenType $accessToken',
      },
      body: {'reason': reason},
      encodeJson: false,
      defaultErrorMessage: 'Unable to reject order. Please try again.',
    );
  }

  Future<ResponseData> toggleOnlineStatus({required bool isOnline}) async {
    final accessToken = StorageService.accessToken;
    final tokenType = StorageService.tokenType ?? 'Bearer';

    if (accessToken == null || accessToken.isEmpty) {
      return _unauthenticatedResponse();
    }

    final responseData = await _networkCaller.putRequest(
      '$baseurl/rider/go-online-offline',
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': '$tokenType $accessToken',
      },
      body: {'is_online': isOnline.toString()},
      encodeJson: false,
      defaultErrorMessage: 'Unable to update status.',
    );

    if (responseData.isSuccess) {
      if (isOnline) {
        await LocationServices.instance.connectAndStart();
      } else {
        await LocationServices.instance.disconnect();
      }
    }

    return responseData;
  }

  ResponseData _unauthenticatedResponse() {
    return ResponseData(
      isSuccess: false,
      statusCode: 401,
      errorMessage: 'Not authenticated',
      responseData: null,
    );
  }
    Future<ResponseData> getOnlineStatus({
    required String accessToken,
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/is-online-status/',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to fetch online status. Please try again.',
    );
  }
}
