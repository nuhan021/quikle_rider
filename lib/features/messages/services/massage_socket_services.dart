import 'dart:async';
import 'dart:convert';

import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Handles raw websocket interactions for chat messages.
class MassageSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<bool> get connectionChanges => _connectionController.stream;

  bool get isConnected => _channel != null;
  void connect({required int myid}) {
    if (_channel != null) return;

    final url =
        'ws://caditya619-backend-ng0e.onrender.com/rider/ws/chat/riders/$myid';
    AppLoggerHelper.debug('🔌 Connecting chat socket → $url');

    _channel = WebSocketChannel.connect(Uri.parse(url));
    AppLoggerHelper.debug('socket now connected now chat');
    _connectionController.add(true);

    _channel!.stream.listen(
      (event) {
        AppLoggerHelper.debug('📨 chat incoming: $event');
        final decoded = _parseEvent(event);
        if (decoded != null && _isMessagePayload(decoded)) {
          _messageController.add(decoded);
        }
      },
      onError: (err) {
        AppLoggerHelper.error('Chat socket error', err);
        _connectionController.add(false);
        _channel = null;
      },
      onDone: () {
        AppLoggerHelper.info('Chat socket closed');
        _connectionController.add(false);
        _channel = null;
      },
      cancelOnError: true,
    );
  }

  void sendMessage({
    required int customerId,
    required String text,
  }) {
    if (_channel == null) {
      AppLoggerHelper.warning('Cannot send chat message: socket not connected');
      return;
    }

    final payload = {
      'to_type': 'customers',
      'to_id': customerId,
      'text': text,
    };

    final encoded = jsonEncode(payload);
    AppLoggerHelper.debug('➡️ sending chartrtrt: $customerId');
    _channel!.sink.add(encoded);
  }

  Map<String, dynamic>? _parseEvent(dynamic event) {
    if (event == null) return null;
    if (event is Map<String, dynamic>) return event;
    if (event is String) {
      try {
        final decoded = jsonDecode(event);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'raw': decoded};
      } catch (_) {
        return {'raw': event};
      }
    }
    return {'raw': event.toString()};
  }

  bool _isMessagePayload(Map<String, dynamic> data) {
    if (data.containsKey('type')) {
      final type = data['type']?.toString().toLowerCase();
      if (type != null && type != 'messaging' && type != 'message') {
        return false;
      }
    }
    return data.containsKey('text') || data.containsKey('message');
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _connectionController.add(false);
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}
