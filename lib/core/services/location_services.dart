import 'dart:async';
import 'dart:convert';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:geolocator/geolocator.dart';

class LocationServices {
  late WebSocketChannel _channel;
  final _socketResponseController = StreamController<Map<String, double>>.broadcast();
  Stream<Map<String, double>> get socketResponse => _socketResponseController.stream;

  Timer? _sendTimer;

  void connect() async {
    final riderId = StorageService.userId.toString();
    final wsUrl = Uri.parse('wss://quikle-u4dv.onrender.com/rider/ws/location/riders/$riderId');
    _channel = WebSocketChannel.connect(wsUrl);

    _channel.stream.listen(
      (message) {
        final decodedMessage = jsonDecode(message);
        if (decodedMessage is Map<String, dynamic> &&
            decodedMessage.containsKey('lat') &&
            decodedMessage.containsKey('lng')) {
          _socketResponseController.add({
            'lat': decodedMessage['lat'].toDouble(),
            'lng': decodedMessage['lng'].toDouble(),
          });
        }
      },
      onDone: () {
        print('WebSocket connection closed');
        // Optionally try to reconnect
      },
      onError: (error) {
        print('WebSocket error: $error');
        // Optionally try to reconnect
      },
    );

    _startSendingLocation();
  }

  void _startSendingLocation() {
    _sendTimer?.cancel();
    _sendCurrentLocation();
    _sendTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _sendCurrentLocation();
    });
    AppLoggerHelper.debug('Location service started (20s interval)');
 
  }

  Future<void> _sendCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final locationData = {
        "lat": position.latitude,
        "lng": position.longitude,
      };
      _channel.sink.add(jsonEncode(locationData));
      AppLoggerHelper.debug("$locationData");
    } catch (e) {
      AppLoggerHelper.debug('Unable to fetch location for websocket: $e');
    }
  }

  void disconnect() {
    _sendTimer?.cancel();
    _channel.sink.close();
    _socketResponseController.close();
  }
}
