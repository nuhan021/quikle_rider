class ProfileCompletionModel {
  const ProfileCompletionModel({
    required this.completionPercentage,
    required this.totalFields,
    required this.filledFields,
    required this.missingFields,
    required this.isComplete,
    required this.message,
  });

  final double completionPercentage;
  final int totalFields;
  final int filledFields;
  final List<String> missingFields;
  final bool isComplete;
  final String message;

  factory ProfileCompletionModel.fromJson(Map<String, dynamic> json) {
    final missing = json['missing_fields'];
    return ProfileCompletionModel(
      completionPercentage:
          (json['completion_percentage'] as num?)?.toDouble() ?? 0,
      totalFields: (json['total_fields'] as num?)?.toInt() ?? 0,
      filledFields: (json['filled_fields'] as num?)?.toInt() ?? 0,
      missingFields: missing is List
          ? missing
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
          : const <String>[],
      isComplete: json['is_complete'] == true,
      message: (json['message'] as String?)?.trim() ?? '',
    );
  }
}
