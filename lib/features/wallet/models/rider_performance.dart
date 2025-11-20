class RiderPerformance {
  const RiderPerformance({
    required this.totalDeliveries,
    required this.acceptanceRate,
    required this.onTimeRate,
  });

  factory RiderPerformance.fromJson(Map<String, dynamic> json) {
    return RiderPerformance(
      totalDeliveries: json['total_deliveries'] is int
          ? json['total_deliveries'] as int
          : int.tryParse('${json['total_deliveries']}') ?? 0,
      acceptanceRate: json['acceptance_rate']?.toString() ?? '--',
      onTimeRate: json['on_time_rate']?.toString() ?? '--',
    );
  }

  final int totalDeliveries;
  final String acceptanceRate;
  final String onTimeRate;
}
