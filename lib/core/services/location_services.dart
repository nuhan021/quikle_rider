import 'dart:async';
import 'dart:convert';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:geolocator/geolocator.dart';

class LocationServices {
  LocationServices._();

  static final LocationServices instance = LocationServices._();

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  final _socketResponseController =
      StreamController<Map<String, double>>.broadcast();
  Stream<Map<String, double>> get socketResponse => _socketResponseController.stream;

  Timer? _sendTimer;
  bool _isConnecting = false;

  // static const double _dummyLat = 28.6139;
  // static const double _dummyLng = 77.2090;

  bool get isConnected => _channel != null;

  Future<void> connectAndStart() async {
    if (isConnected || _isConnecting) return;
    _isConnecting = true;

    final riderId = StorageService.userId;
    if (riderId == null) {
      AppLoggerHelper.debug('LocationServices: missing riderId, cannot connect');
      _isConnecting = false;
      return;
    }

    final hasPermission = await _ensurePermissions();
    if (!hasPermission) {
      _isConnecting = false;
      return;
    }

    final wsUrl = Uri.parse('ws://caditya619-backend-ng0e.onrender.com/rider/ws/location/riders/$riderId');
    final channel = WebSocketChannel.connect(wsUrl);
    _channel = channel;

    _channelSubscription?.cancel();
    _channelSubscription = channel.stream.listen(
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
        AppLoggerHelper.debug('LocationServices: WebSocket connection closed');
        _stopSendingLocation();
        _channel = null;
      },
      onError: (error) {
        AppLoggerHelper.debug('LocationServices: WebSocket error: $error');
        _stopSendingLocation();
        _channel = null;
      },
    );

    _startSendingLocation();
    _isConnecting = false;
  }

  void _startSendingLocation() {
    _sendTimer?.cancel();
    sendCurrentLocation();
    _sendTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      sendCurrentLocation();
    });
    AppLoggerHelper.debug('Location service started (10s interval)');
 
  }

  Future<void> sendCurrentLocation() async {
    try {
      if (!isConnected) return;

      final hasPermission = await _ensurePermissions();
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      // final locationData = {
      //   "lat": _dummyLat,
      //   "lng": _dummyLng,
      // };
       final currentlocationdata = {
        "lat": position.latitude,
        "lng": position.longitude,
      };
      
      _channel?.sink.add(jsonEncode(currentlocationdata));
      AppLoggerHelper.debug('LocationServices: sent $currentlocationdata');
    } catch (e) {
      AppLoggerHelper.debug('Unable to fetch location for websocket: $e');
    }
  }

  Future<void> disconnect() async {
    _stopSendingLocation();
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void _stopSendingLocation() {
    _sendTimer?.cancel();
    _sendTimer = null;
  }

  Future<bool> _ensurePermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLoggerHelper.debug(
        'LocationServices: location service disabled, cannot send location',
      );
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      AppLoggerHelper.debug(
        'LocationServices: location permission denied, cannot send location',
      );
      return false;
    }
    return true;
  }

  void dispose() {
    disconnect();
    _socketResponseController.close();
  }
}
