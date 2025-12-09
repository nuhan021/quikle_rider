import 'package:flutter/material.dart';
import 'package:quikle_rider/features/messages/controllers/massage_controller.dart';
import 'package:quikle_rider/features/messages/models/chat_partner.dart';
import 'package:quikle_rider/features/messages/presentation/massage_screen.dart';
import 'package:quikle_rider/features/messages/widgets/massage_load_shimmer.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  late final MassageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MassageController();
    _controller.fetchChatPartners();
    _controller.refreshActiveStatus();
    _controller.startChatSession();
    _controller.fetchChatHistory();

    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Conversations',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.partnersLoading,
        builder: (_, loading, __) {
          return ValueListenableBuilder<List<ChatPartner>>(
            valueListenable: _controller.chatPartners,
            builder: (_, partners, __) {
              return ValueListenableBuilder<String?>(
                valueListenable: _controller.partnersError,
                builder: (_, error, __) {
                  if (loading && partners.isEmpty) {
                    return const MassageLoadShimmer();
                  }

                  if (error != null && partners.isEmpty) {
                    return _ErrorState(
                      message: error,
                      onRetry: _controller.fetchChatPartners,
                    );
                  }

                  if (partners.isEmpty) {
                    return _EmptyState(onRefresh: _controller.fetchChatPartners);
                  }

                  return RefreshIndicator(
                    onRefresh: () => _controller.fetchChatPartners(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (_, index) => _ConversationTile(
                        partner: partners[index],
                        index: index,
                        onTap: () {
                          _openConversation(partners[index]);
                        },
                      ),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: partners.length,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _openConversation(ChatPartner partner) {
    final id = partner.customerId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this conversation.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MassageScreen(
          customerId: id,
          partnerLabel: partner.displayLabel,
          partnerType: partner.type,
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.partner,
    required this.index,
    required this.onTap,
  });

  final ChatPartner partner;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.amber.shade100,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.displayLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${partner.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      partner.type,
                      style: TextStyle(
                        color: Colors.amber.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forum_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your chat partners will appear here.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
