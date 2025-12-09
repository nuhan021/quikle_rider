// ignore_for_file: unused_element

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quikle_rider/core/utils/constants/api_constants.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/features/messages/models/chat_model.dart';
import 'package:quikle_rider/features/messages/models/chat_partner.dart';
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
  final ValueNotifier<List<ChatPartner>> chatPartners =
      ValueNotifier<List<ChatPartner>>([]);
  final ValueNotifier<bool> partnersLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> partnersError = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isActiveForMessaging = ValueNotifier<bool>(false);
  final ValueNotifier<bool> activeStatusLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> historyLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> historyError = ValueNotifier<String?>(null);
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
    _socketService.sendMessage(customerId: customerId, text: text);
  }

  void dispose() {
    _socketSubscription?.cancel();
    _socketService.dispose();
    _incomingController.close();
    messages.dispose();
    connectionStatus.dispose();
    chatPartners.dispose();
    partnersLoading.dispose();
    partnersError.dispose();
    isActiveForMessaging.dispose();
    activeStatusLoading.dispose();
    historyLoading.dispose();
    historyError.dispose();
  }

  Future<void> _startChatSession() async {
    final riderId = _selfRiderId;
    final uri = Uri.parse(
      '$baseurl/rider/chat/start/riders/$riderId/customers/$customerId',
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

  Future<void> fetchChatHistory({int limit = 50}) async {
    historyLoading.value = true;
    historyError.value = null;
    final riderId = _selfRiderId;
    final uri = Uri.parse(
      '$baseurl/rider/chat/history/customers/$customerId/riders/$riderId',
    ).replace(
      queryParameters: {'limit': '$limit'},
    );

    try {
      final response = await http.get(
        uri,
        headers: const {'accept': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final history = decoded['messages'];
        if (history is List) {
          final parsed = history
              .whereType<Map<String, dynamic>>()
              .map(
                (data) => ChatMessage.fromSocket(
                  data,
                  selfRiderId: riderId,
                ),
              )
              .toList();
          parsed.sort((a, b) => a.time.compareTo(b.time));
          messages.value = parsed;
        } else {
          messages.value = [];
        }
      } else {
        historyError.value =
            'Unable to load chat history (${response.statusCode})';
        AppLoggerHelper.warning(
          'Chat history failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      historyError.value = 'Unable to load chat history';
      AppLoggerHelper.error('Chat history error', e);
    } finally {
      historyLoading.value = false;
    }
  }

  Future<void> fetchChatPartners() async {
    partnersLoading.value = true;
    partnersError.value = null;
    final riderId = _selfRiderId;
    final uri =
        Uri.parse('$baseurl/rider/chat/partners/riders/$riderId');

    try {
      final response = await http.get(
        uri,
        headers: const {'accept': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final partnersJson = decoded['partners'];
        if (partnersJson is List) {
          final parsedPartners = partnersJson
              .map((e) {
                if (e is Map<String, dynamic>) {
                  return ChatPartner.fromJson(e);
                }
                if (e is Map) {
                  return ChatPartner.fromJson(
                    Map<String, dynamic>.from(e),
                  );
                }
                return null;
              })
              .whereType<ChatPartner>()
              .where((p) => p.isValid)
              .toList();
          chatPartners.value = parsedPartners;
          AppLoggerHelper.info(
            'Loaded ${parsedPartners.length} chat partners for rider $riderId',
          );
        } else {
          partnersError.value = 'No partners found';
          chatPartners.value = [];
        }
      } else {
        partnersError.value =
            'Unable to load conversations (${response.statusCode})';
        AppLoggerHelper.warning(
          'Chat partners failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      partnersError.value = 'Unable to load conversations';
      AppLoggerHelper.error('Chat partners error', e);
    } finally {
      partnersLoading.value = false;
    }
  }

  Future<void> refreshActiveStatus() async {
    activeStatusLoading.value = true;
    final uri = Uri.parse('$baseurl/rider/active-users').replace(
      queryParameters: {
        'client_type': 'riders',
        'purpose': 'messaging',
      },
    );
    try {
      final response = await http.get(
        uri,
        headers: const {'accept': 'application/json'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final key = 'messaging:riders';
        final activeList = decoded[key];
        if (activeList is List) {
          final ids = activeList.map((e) => e.toString()).toSet();
          isActiveForMessaging.value = ids.contains('$_selfRiderId');
        } else {
          isActiveForMessaging.value = false;
        }
      } else {
        AppLoggerHelper.warning(
          'Active check failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      AppLoggerHelper.error('Active status error', e);
    } finally {
      activeStatusLoading.value = false;
    }
  }
}
