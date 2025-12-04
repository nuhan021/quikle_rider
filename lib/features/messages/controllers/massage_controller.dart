import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/features/messages/models/chat_model.dart';
import 'package:quikle_rider/features/messages/services/massage_socket_services.dart';



class MassageController {
  MassageController({int? customerId})
      : customerId = customerId ?? 1; // default customer side channel

  final int customerId;
  final MassageSocketService _socketService = MassageSocketService();
  final StreamController<ChatMessage> _incomingController =
      StreamController<ChatMessage>.broadcast();
  StreamSubscription? _socketSubscription;
  bool _chatStarted = false;
  final ValueNotifier<List<ChatMessage>> messages =
      ValueNotifier<List<ChatMessage>>([]);
  final ValueNotifier<bool> connectionStatus = ValueNotifier<bool>(false);
  int get _selfRiderId => StorageService.userId ?? 3;

  Stream<ChatMessage> get incomingMessages => _incomingController.stream;
  Stream<bool> get connectionChanges => _socketService.connectionChanges;

  bool get isConnected => _socketService.isConnected;

  Future<void> connect() async {
    _socketSubscription ??=
        _socketService.messageStream.listen(_handleIncomingMessage);

    _socketService.connectionChanges.listen((connected) {
      connectionStatus.value = connected;
    });

    // if (!_chatStarted) {
    //   await _startChatSession();
    //   _chatStarted = true;
    // }

    _socketService.connect(myid: _selfRiderId);
    AppLoggerHelper.info('Chat socket connected as rider $_selfRiderId');
  }

  void _handleIncomingMessage(Map<String, dynamic> data) {
    final message = ChatMessage.fromSocket(
      data,
      selfRiderId: _selfRiderId,
    );
    _incomingController.add(message);
    _appendMessage(message);
  }

  void sendMessage(String text) {
    final outgoing = ChatMessage(
      text: text,
      time: DateTime.now(),
      fromUser: true,
    );
    _appendMessage(outgoing);
    _socketService.sendMessage(customerId: 2, text: text);
  }

  void dispose() {
    _socketSubscription?.cancel();
    _socketService.dispose();
    _incomingController.close();
    messages.dispose();
    connectionStatus.dispose();
  }

  Future<void> _startChatSession() async {
    final riderId = _selfRiderId;
    final uri = Uri.parse(
      'https://quikle-u4dv.onrender.com/rider/chat/start/riders/$riderId/customers/$customerId',
    );

    try {
      AppLoggerHelper.debug(
        'Starting chat session rider=$riderId customer=$customerId → $uri',
      );
      final response = await http.post(
        uri,
        headers: const {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        AppLoggerHelper.info('Chat session started: ${response.body}');
      } else {
        AppLoggerHelper.warning(
          'Chat start failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      AppLoggerHelper.error('Chat start error', e);
    }
  }

  void _appendMessage(ChatMessage message) {
    final current = List<ChatMessage>.from(messages.value);
    current.add(message);
    messages.value = current;
  }
}
