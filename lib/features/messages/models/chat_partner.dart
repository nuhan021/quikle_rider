class ChatPartner {
  final String type;
  final String id;

  const ChatPartner({
    required this.type,
    required this.id,
  });

  factory ChatPartner.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ChatPartner(type: '', id: '');
    final type = json['type']?.toString() ?? '';
    final id = json['id']?.toString() ?? '';
    return ChatPartner(type: type, id: id);
  }

  bool get isValid => type.isNotEmpty && id.isNotEmpty;

  int? get customerId => int.tryParse(id);

  String get displayLabel {
    if (type.isEmpty) return 'Partner $id';
    final normalized = type.replaceAll('_', ' ');
    return '${_capitalize(normalized)} $id';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
