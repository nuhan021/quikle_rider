class WalletSummary {
  WalletSummary({
    required this.deliveries,
    required this.deliveryPay,
    required this.weeklyBonuses,
    required this.weeklyStatuses,
    required this.excellenceBonus,
    required this.subtotal,
    required this.topUp,
    required this.finalEarnings,
    required this.currentBalance,
    required this.bonusDeliveries,
    required this.bonusAcceptance,
    required this.bonusOnTime,
    required this.forecast,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      deliveries: json['deliveries'] is int ? json['deliveries'] as int : int.tryParse('${json['deliveries']}') ?? 0,
      deliveryPay: _toDouble(json['delivery_pay']),
      weeklyBonuses: _toDouble(json['weekly_bonuses']),
      weeklyStatuses: (json['weekly_statuses'] as List<dynamic>? ?? [])
          .map((status) => WeeklyStatus.fromJson(status as Map<String, dynamic>))
          .toList(),
      excellenceBonus: _toDouble(json['excellence_bonus']),
      subtotal: _toDouble(json['subtotal']),
      topUp: _toDouble(json['top_up']),
      finalEarnings: _toDouble(json['final_earnings']),
      currentBalance: _toDouble(json['current_balance']),
      bonusDeliveries: (json['bonus_status']?['deliveries'] as String?) ?? '--',
      bonusAcceptance: (json['bonus_status']?['acceptance'] as String?) ?? '--',
      bonusOnTime: (json['bonus_status']?['on_time'] as String?) ?? '--',
      forecast: WalletForecast.fromJson(json['forecast'] as Map<String, dynamic>? ?? {}),
    );
  }

  final int deliveries;
  final double deliveryPay;
  final double weeklyBonuses;
  final List<WeeklyStatus> weeklyStatuses;
  final double excellenceBonus;
  final double subtotal;
  final double topUp;
  final double finalEarnings;
  final double currentBalance;
  final String bonusDeliveries;
  final String bonusAcceptance;
  final String bonusOnTime;
  final WalletForecast forecast;

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class WalletForecast {
  WalletForecast({
    required this.current,
    required this.target,
    required this.percentage,
    required this.remainingDeliveries,
  });

  factory WalletForecast.fromJson(Map<String, dynamic> json) {
    final rawTarget = WalletSummary._toDouble(json['target']);
    return WalletForecast(
      current: WalletSummary._toDouble(json['current']),
      target: rawTarget < 0 ? 0 : rawTarget,
      percentage: WalletSummary._toDouble(json['percentage']),
      remainingDeliveries: WalletSummary._toDouble(json['remaining_deliveries']),
    );
  }

  final double current;
  final double target;
  final double percentage;
  final double remainingDeliveries;
}

class WeeklyStatus {
  WeeklyStatus({
    required this.week,
    required this.status,
    required this.bonus,
  });

  factory WeeklyStatus.fromJson(Map<String, dynamic> json) {
    return WeeklyStatus(
      week: json['week'] is int ? json['week'] as int : int.tryParse('${json['week']}') ?? 0,
      status: (json['status'] as String?) ?? '',
      bonus: WalletSummary._toDouble(json['bonus']),
    );
  }

  final int week;
  final String status;
  final double bonus;
}
