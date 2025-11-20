class LeaderboardStanding {
  const LeaderboardStanding({
    required this.rank,
    required this.totalRiders,
    required this.totalDeliveries,
    required this.prizeMoney,
    required this.score,
    required this.breakdown,
  });

  factory LeaderboardStanding.fromJson(Map<String, dynamic> json) {
    return LeaderboardStanding(
      rank: _toInt(json['rank']),
      totalRiders: _toInt(json['total_riders']),
      totalDeliveries: _toInt(json['total_deliveries']),
      prizeMoney: _toDouble(json['prize_money']),
      score: _toInt(json['score']),
      breakdown: LeaderboardBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>? ?? {}),
    );
  }

  final int rank;
  final int totalRiders;
  final int totalDeliveries;
  final double prizeMoney;
  final int score;
  final LeaderboardBreakdown breakdown;

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class LeaderboardBreakdown {
  const LeaderboardBreakdown({
    required this.deliveriesPoints,
    required this.ratingPoints,
    required this.onTimePoints,
  });

  factory LeaderboardBreakdown.fromJson(Map<String, dynamic> json) {
    return LeaderboardBreakdown(
      deliveriesPoints: LeaderboardStanding._toDouble(json['deliveries_pts']),
      ratingPoints: LeaderboardStanding._toDouble(json['rating_pts']),
      onTimePoints: LeaderboardStanding._toDouble(json['on_time_pts']),
    );
  }

  final double deliveriesPoints;
  final double ratingPoints;
  final double onTimePoints;
}
