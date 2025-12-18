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
}

