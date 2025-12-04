// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quikle_rider/features/messages/controllers/massage_controller.dart';
import 'package:quikle_rider/features/messages/models/chat_model.dart';

class MassageScreen extends StatefulWidget {
  const MassageScreen({super.key});

  @override
  State<MassageScreen> createState() => _MassageScreenState();
}

class _MassageScreenState extends State<MassageScreen> {
  late final MassageController _controller;
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DateFormat _timeFormatter = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    _controller = MassageController();
    _controller.messages.addListener(_scrollToBottom);
    _controller.connect();
  }

  @override
  void dispose() {
    _controller.messages.removeListener(_scrollToBottom);
    _controller.dispose();
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            const Text(
              'Rider chat',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            ValueListenableBuilder<bool>(
              valueListenable: _controller.connectionStatus,
              builder: (_, connected, __) => _statusDot(connected),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ValueListenableBuilder<List<ChatMessage>>(
                valueListenable: _controller.messages,
                builder: (_, messages, __) {
                  if (messages.isEmpty) {
                    return _emptyState();
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _messageBubble(messages[index]),
                  );
                },
              ),
            ),
          ),
          _composer(),
        ],
      ),
    );
  }

  Widget _messageBubble(ChatMessage message) {
    final isRider = message.fromUser;
    final bubbleColor =
        isRider ? Colors.amber.shade500 : Colors.black.withOpacity(0.85);
    final textColor = isRider ? Colors.black : Colors.white;

    return Align(
      alignment: isRider ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          isRider ? 12 : 64,
          6,
          isRider ? 64 : 12,
          6,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: Radius.circular(isRider ? 4 : 16),
            bottomRight: Radius.circular(isRider ? 16 : 4),
          ),
          border: Border.all(
            color: isRider ? Colors.amber.shade600 : Colors.black,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isRider ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isRider && message.senderName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.senderName!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: textColor,
                fontSize: 14.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _timeFormatter.format(message.time),
              style: TextStyle(
                color: isRider
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.75),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _composer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _composerController,
                style: const TextStyle(color: Colors.black87),
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  hintText: 'Message customer...',
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDot(bool connected) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: connected ? Colors.amber.shade600 : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 46, color: Colors.black.withOpacity(0.3)),
          const SizedBox(height: 8),
          ValueListenableBuilder<bool>(
            valueListenable: _controller.connectionStatus,
            builder: (_, connected, __) => Text(
              connected ? 'Say hello to your customer' : 'Connecting…',
              style: TextStyle(
                color: Colors.black.withOpacity(0.45),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    final raw = _composerController.text.trim();
    if (raw.isEmpty) return;
    _composerController.clear();
    _controller.sendMessage(raw);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
}
