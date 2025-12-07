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
  final _composerController = TextEditingController();
  final _scrollController = ScrollController();
  final _timeFormatter = DateFormat('h:mm a');

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildComposer(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.support_agent, color: Colors.amber.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Support',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _controller.connectionStatus,
                builder: (_, connected, __) => Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: connected ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: connected
                            ? [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)]
                            : null,
                      ),
                    ),
                    Text(
                      connected ? 'Online' : 'Connecting...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ValueListenableBuilder<List<ChatMessage>>(
      valueListenable: _controller.messages,
      builder: (_, messages, __) {
        if (messages.isEmpty) return _buildEmptyState();
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (_, i) => _buildMessageBubble(messages[i]),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.fromUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, size: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: [Colors.amber.shade400, Colors.amber.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && msg.senderName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        msg.senderName!,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeFormatter.format(msg.time),
                    style: TextStyle(
                      color: isMe ? Colors.white.withOpacity(0.8) : Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(

       
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),

                    )
                  ]
                ),

                child: TextField(
                  controller: _composerController,
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none,
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.amber.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline, size: 48, color: Colors.amber.shade600),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<bool>(
            valueListenable: _controller.connectionStatus,
            builder: (_, connected, __) => Column(
              children: [
                Text(
                  connected ? 'Start Conversation' : 'Connecting...',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  connected ? 'Send a message to begin chatting' : 'Please wait a moment',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;
    _composerController.clear();
    _controller.sendMessage(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }
}