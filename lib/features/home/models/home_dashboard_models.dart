import 'package:intl/intl.dart';

enum AssignmentStatus {
  pending,
  accepted,
  rejected,
}

extension AssignmentStatusX on AssignmentStatus {
  String get label {
    switch (this) {
      case AssignmentStatus.pending:
        return 'Pending';
      case AssignmentStatus.accepted:
        return 'Accepted';
      case AssignmentStatus.rejected:
        return 'Rejected';
    }
  }
}

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
  final double distanceInKm;
  final double totalAmount;
  final String currency;
  final double basePay;
  final double distancePay;
  final String orderType;
  final bool isUrgent;
  final bool isCombined;
  final AssignmentStatus status;

  const Assignment({
    required this.id,
    required this.customerName,
    required this.expectedArrival,
    required this.address,
    required this.distanceInKm,
    required this.totalAmount,
    required this.basePay,
    required this.distancePay,
    required this.orderType,
    this.currency = '₹',
    this.isUrgent = false,
    this.isCombined = false,
    this.status = AssignmentStatus.pending,
  });

  String get formattedArrival =>
      'Arrives by ${DateFormat.jm().format(expectedArrival)}';

  String get formattedDistance =>
      '${distanceInKm.toStringAsFixed(1)} km';

  String get formattedTotal {
    final amount = totalAmount % 1 == 0
        ? totalAmount.toStringAsFixed(0)
        : totalAmount.toStringAsFixed(2);
    if (currency.trim().isEmpty) return amount;
    return '$currency$amount';
  }

  String get formattedPayoutLabel => 'Order Payout: ${formattedTotal}';

  String get formattedBreakdown {
    final base = basePay % 1 == 0
        ? basePay.toStringAsFixed(0)
        : basePay.toStringAsFixed(2);
    final distanceAmount = distancePay % 1 == 0
        ? distancePay.toStringAsFixed(0)
        : distancePay.toStringAsFixed(2);
    return 'Base: $currency$base | Distance (${distanceInKm.toStringAsFixed(0)}km): $currency$distanceAmount | Type: $orderType';
  }

  Assignment copyWith({
    String? id,
    String? customerName,
    DateTime? expectedArrival,
    String? address,
    double? distanceInKm,
    double? totalAmount,
    String? currency,
    double? basePay,
    double? distancePay,
    String? orderType,
    bool? isUrgent,
    bool? isCombined,
    AssignmentStatus? status,
  }) {
    return Assignment(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      expectedArrival: expectedArrival ?? this.expectedArrival,
      address: address ?? this.address,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      basePay: basePay ?? this.basePay,
      distancePay: distancePay ?? this.distancePay,
      orderType: orderType ?? this.orderType,
      isUrgent: isUrgent ?? this.isUrgent,
      isCombined: isCombined ?? this.isCombined,
      status: status ?? this.status,
    );
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['order_id'] as String,
      customerName: json['customer_name'] as String,
      expectedArrival: DateTime.parse(json['expected_arrival'] as String),
      address: json['address'] as String,
      distanceInKm: (json['distance_km'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? '₹',
      basePay: (json['base_pay'] as num).toDouble(),
      distancePay: (json['distance_pay'] as num).toDouble(),
      orderType: json['order_type'] as String,
      isUrgent: json['is_urgent'] as bool? ?? false,
      isCombined: json['is_combined'] as bool? ?? false,
      status: AssignmentStatus.values.firstWhere(
        (value) => value.name == (json['status'] as String? ?? 'pending'),
        orElse: () => AssignmentStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': id,
      'customer_name': customerName,
      'expected_arrival': expectedArrival.toIso8601String(),
      'address': address,
      'distance_km': distanceInKm,
      'total_amount': totalAmount,
      'currency': currency,
      'base_pay': basePay,
      'distance_pay': distancePay,
      'order_type': orderType,
      'is_urgent': isUrgent,
      'is_combined': isCombined,
      'status': status.name,
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
