class HelpSupportRequest {
  final String id;
  final String subject;
  final String description;
  final String? attachment;
  final String createdAt;
  final String? resolvedAt;

  const HelpSupportRequest({
    required this.id,
    required this.subject,
    required this.description,
    required this.attachment,
    required this.createdAt,
    required this.resolvedAt,
  });

  factory HelpSupportRequest.fromJson(Map<String, dynamic> json) {
    return HelpSupportRequest(
      id: json['id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      attachment: json['attachment']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      resolvedAt: json['resolved_at']?.toString(),
    );
  }
}
