import 'package:intl/intl.dart';

class HomeStat {
  final String id;
  final String title;
  final String subtitle;
  final num value;
  final String? unit;

  const HomeStat({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.value,
    this.unit,
  });

  String get displayValue {
    if (unit == null || unit!.isEmpty) {
      return value is double ? _formatNumeric(value.toDouble()) : value.toString();
    }
    if (value is double) {
      return '${_formatNumeric(value.toDouble())} $unit';
    }
    return '$value $unit';
  }

  static String _formatNumeric(double value) {
    // `#,##0.#` keeps one decimal place only when needed.
    return NumberFormat('#,##0.#').format(value);
  }

  factory HomeStat.fromJson(Map<String, dynamic> json) {
    return HomeStat(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      value: json['value'] as num,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'value': value,
      if (unit != null) 'unit': unit,
    };
  }
}

class Assignment {
  final String id;
  final String customerName;
  final DateTime expectedArrival;
  final String address;
  final double distanceInMiles;
  final double totalAmount;
  final String currency;
  final bool isUrgent;
  final bool isCombined;

  const Assignment({
    required this.id,
    required this.customerName,
    required this.expectedArrival,
    required this.address,
    required this.distanceInMiles,
    required this.totalAmount,
    this.currency = '',
    this.isUrgent = false,
    this.isCombined = false,
  });

  String get formattedArrival =>
      'Arrives by ${DateFormat.jm().format(expectedArrival)}';

  String get formattedDistance =>
      '${distanceInMiles.toStringAsFixed(1)} mile';

  String get formattedTotal {
    final amount = totalAmount.toStringAsFixed(2);
    if (currency.trim().isEmpty) return amount;
    return '$currency$amount';
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['order_id'] as String,
      customerName: json['customer_name'] as String,
      expectedArrival: DateTime.parse(json['expected_arrival'] as String),
      address: json['address'] as String,
      distanceInMiles: (json['distance_miles'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? '',
      isUrgent: json['is_urgent'] as bool? ?? false,
      isCombined: json['is_combined'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': id,
      'customer_name': customerName,
      'expected_arrival': expectedArrival.toIso8601String(),
      'address': address,
      'distance_miles': distanceInMiles,
      'total_amount': totalAmount,
      'currency': currency,
      'is_urgent': isUrgent,
      'is_combined': isCombined,
    };
  }
}

class HomeDashboardData {
  final List<HomeStat> stats;
  final List<Assignment> assignments;

  const HomeDashboardData({
    required this.stats,
    required this.assignments,
  });

  factory HomeDashboardData.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'] as List<dynamic>? ?? [];
    final assignmentsJson = json['assignments'] as List<dynamic>? ?? [];

    return HomeDashboardData(
      stats: statsJson
          .map((e) => HomeStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      assignments: assignmentsJson
          .map((e) => Assignment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats.map((e) => e.toJson()).toList(),
      'assignments': assignments.map((e) => e.toJson()).toList(),
    };
  }
}
