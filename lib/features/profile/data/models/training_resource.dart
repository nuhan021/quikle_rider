class TrainingResource {
  TrainingResource({
    this.id,
    required this.title,
    required this.url,
    required this.type,
    this.description,
    this.duration,
    this.thumbnail,
  });

  final int? id;
  final String title;
  final String url;
  final String type;
  final String? description;
  final String? duration;
  final String? thumbnail;

  factory TrainingResource.fromJson(
    Map<String, dynamic> json, {
    required String fallbackType,
  }) {
    final rawUrl = json['url'] ??
        json['link'] ??
        json['video_url'] ??
        json['pdf_url'] ??
        json['file_url'] ??
        json['file'] ??
        json['path'];

    final rawTitle = json['title'] ?? json['name'] ?? json['file_name'];

    return TrainingResource(
      id: (json['id'] as num?)?.toInt(),
      title: rawTitle?.toString().trim().isNotEmpty == true
          ? rawTitle.toString()
          : 'Untitled',
      url: rawUrl?.toString() ?? '',
      type: (json['type'] ??
              json['resource_type'] ??
              fallbackType)
          .toString(),
      description: json['description']?.toString() ??
          json['summary']?.toString(),
      duration: json['duration']?.toString() ?? json['length']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
    );
  }
}
