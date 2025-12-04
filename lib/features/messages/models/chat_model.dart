class ChatMessage {
  final String text;
  final DateTime time;
  final bool fromUser;
  final bool delivered;
  final String? senderName;
  final String? messageId;

  ChatMessage({
    required this.text,
    required this.time,
    required this.fromUser,
    this.delivered = true,
    this.senderName,
    this.messageId,
  });

  factory ChatMessage.fromSocket(
    Map<String, dynamic> data, {
    required int selfRiderId,
  }) {
    final text =
        (data['text'] ?? data['message'] ?? data['body'] ?? '').toString();
    final fromType =
        (data['from_type'] ?? data['sender_type'] ?? '').toString().toLowerCase();
    final fromId = int.tryParse('${data['from_id'] ?? ''}');
    final name =
        (data['from_name'] ?? data['sender_name'] ?? '').toString().trim();
    final messageId = data['message_id']?.toString();

    DateTime time = DateTime.now();
    final ts = data['timestamp']?.toString();
    if (ts != null && ts.isNotEmpty) {
      try {
        time = DateTime.parse(ts).toLocal();
      } catch (_) {}
    }

    final isFromMe = fromType.contains('rider') ||
        fromType.contains('riders') ||
        (fromId != null && fromId == selfRiderId);

    return ChatMessage(
      text: text.isEmpty ? data.toString() : text,
      time: time,
      fromUser: isFromMe,
      senderName: name.isEmpty ? null : name,
      messageId: messageId,
    );
  }
}