import 'dart:async';
import 'dart:convert';

import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _locationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get locationStream => _locationController.stream;

  Stream<bool> get connectionChanges => _connectionController.stream;

  bool get isConnected => _channel != null;

  /// CONNECTss
  void connect(int riderId) {
    if (_channel != null) {}

    final url =
        "wss://quikle-u4dv.onrender.com/rider/ws/location/riders/$riderId";

    print("🔌 Connecting WebSocket → $url");

    _channel = WebSocketChannel.connect(Uri.parse(url));

    /// LISTEN FOR SERVER MESSAGES
    _channel!.stream.listen(
      (event) {
        final decoded = _parseEvent(event);
        if (decoded != null) {
          _locationController.add(decoded);
          print("📩 Received Response → $decoded");
        }
      },
      // onDone: () {
      //   print("❌ WebSocket Disconnected (onDone)");
      //   _channel = null;
      //   _connectionController.add(false);
      //   _locationController.addError("WebSocket disconnected");
      // },
      onError: (err) {
        print("⚠️ WebSocket Error → $err");
        _channel = null;
        _connectionController.add(false);
        _locationController.addError(err);
      },
      cancelOnError: true,
    );

    print("🟢 WebSocket Connected");
    _connectionController.add(true);
  }

  Map<String, dynamic>? _parseEvent(dynamic event) {
    if (event is Map<String, dynamic>) {
      return event;
    }

    if (event is String) {
      try {
        final decoded = jsonDecode(event);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {"raw": decoded};
      } catch (_) {
        return {"raw": event};
      }
    }

    return {"raw": event.toString()};
  }

  /// SEND JSON
  void sendLocation(double lat, double lng) {
    if (_channel == null) {
      _locationController.addError("Cannot send → WebSocket not connected");
      print("⚠️ Cannot send → WebSocket is not connected");
      return;
    }

    final jsonMessage = jsonEncode({"lat": lat, "lng": lng});

    print("➡ Sending: $jsonMessage");

    AppLoggerHelper.debug("➡ response : $jsonMessage");

    _channel!.sink.add(jsonMessage);
  }

  /// DISCONNECT
  void disconnect() {
    if (_channel != null) {
      print("🔌 Closing WebSocket");
      _channel!.sink.close();
      _channel = null;
      _connectionController.add(false);
    }
  }

  void dispose() {
    disconnect();
    _locationController.close();
    _connectionController.close();
  }
}
