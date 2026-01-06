import 'package:quikle_rider/core/models/response_data.dart';
import 'package:quikle_rider/core/services/network_caller.dart';
import 'package:quikle_rider/core/utils/constants/api_constants.dart';

class OrderServices {
  OrderServices({NetworkCaller? networkCaller})
      : _networkCaller = networkCaller ?? NetworkCaller();

  final NetworkCaller _networkCaller;

  Future<ResponseData> getOrders({
    required String accessToken,
    int skip = 0,
    int limit = 10,
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/orders/?skip=$skip&limit=$limit',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to fetch orders. Please try again.',
    );
  }

  Future<ResponseData> fetchoffer_order({
    required String accessToken,
    int offset = 0,
    int limit = 10,
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/rider-offered-orders/?limit=$limit&offset=$offset',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to fetch current orders. Please try again.',
    );
  }

  Future<ResponseData> fetchActiveOrders({
    required String accessToken,
    int offset = 0,
    int limit = 10,
  }) {
    return _networkCaller.getRequest(
      '$baseurl/rider/rider/active-orders/?limit=$limit&offset=$offset',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to fetch active orders. Please try again.',
    );
  }

  Future<ResponseData> markOrderOnWay({
    required String accessToken,
    required String orderId,
  }) {
    return _networkCaller.postRequest(
      '$baseurl/rider/rider/mark-on-way/$orderId/',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to update order status. Please try again.',
    );
  }

  Future<ResponseData> markOrderDelivered({
    required String accessToken,
    required String orderId,
  }) {
    return _networkCaller.postRequest(
      '$baseurl/rider/mark-delivered/$orderId/',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      defaultErrorMessage: 'Unable to update order status. Please try again.',
    );
  }
}
