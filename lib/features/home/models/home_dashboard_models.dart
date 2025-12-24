import 'package:intl/intl.dart';

enum AssignmentStatus {
  pending,
  accepted,
  rejected,
  outForDelivery,
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
      case AssignmentStatus.outForDelivery:
        return 'Out for delivery';
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
  final String deleverystatus;
  final String? orderStatus;
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
  final String ?tierLabel;

  const Assignment({
    required this.deleverystatus,
    this.orderStatus,
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
    this.tierLabel = 'Tier Rate',
  });

  String get formattedArrival =>
      'Arrives by ${DateFormat.jm().format(expectedArrival)}';

  String get formattedDistance =>
      '${_formatDistance(distanceInKm)} km';

  String get formattedTotal {
    final amount = totalAmount % 1 == 0
        ? totalAmount.toStringAsFixed(0)
        : totalAmount.toStringAsFixed(2);
    if (currency.trim().isEmpty) return amount;
    return '$currency$amount';
  }

  String get formattedPayoutLabel => 'Order Payout: ${formattedTotal}';

  String get formattedBreakdown {
    final base = _formatCurrency(basePay);
    final distanceAmount = _formatCurrency(distancePay);
    final distanceLabel = _formatDistance(distanceInKm);
    final ratePerKm = distanceInKm == 0
        ? null
        : distancePay / distanceInKm;
    final rateLabel =
        ratePerKm == null ? '' : ' (at $currency${_formatRatePerKm(ratePerKm)}/km)';
    return [
      '$tierLabel: $currency$base',
      'Distance (${distanceLabel}km): $currency$distanceAmount$rateLabel',
      'Type: $orderType',
    ].join('\n');
  }

  Assignment copyWith({
    String? id,
    String? deleverystatus,
    String? orderStatus,
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
    String? tierLabel,
  }) {
    return Assignment(
      deleverystatus: deleverystatus ?? this.deleverystatus,
      orderStatus: orderStatus ?? this.orderStatus,
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
      tierLabel: tierLabel ?? this.tierLabel,
    );
  }

  factory Assignment.fromUpcomingOrderJson(Map<String, dynamic> json) {
    final etaMinutes = (json['eta_minutes'] as num?)?.toInt();
    final now = DateTime.now();
    final estimatedDeliveryRaw = json['estimated_delivery'] as String?;
    final estimatedDelivery = estimatedDeliveryRaw == null
        ? null
        : DateTime.tryParse(estimatedDeliveryRaw);
    final expectedArrival = estimatedDelivery ??
        (etaMinutes == null
            ? now.add(const Duration(minutes: 45))
            : now.add(Duration(minutes: etaMinutes)));

    final distanceValue =
        _parseDouble(json['pickup_distance_km'] ?? json['distance_km'] ?? json['distance'] ?? 0);
    final basePayValue = _parseDouble(json['base_rate'] ?? json['base_pay']);
    final distancePayValue =
        _parseDouble(json['distance_bonus'] ?? json['distance_pay']);
    final totalValue = _parseDouble(
      json['total'] ??
          json['total_payout'] ??
          json['total_amount'] ??
          basePayValue + distancePayValue,
    );

    final rawId = (json['id'] ?? json['order_id'] ?? '—').toString();
    final orderId = rawId.isEmpty ? '—' : rawId;
    final orderType =
        (json['delivery_type'] ?? json['order_type'] ?? 'Delivery').toString();
    final normalizedType = orderType.toLowerCase().trim();
    final combinedFromType =
        normalizedType == 'combined' || normalizedType.contains('combined');
    final apiStatusRaw = json['status']?.toString() ?? '';
    final apiStatus = apiStatusRaw.trim().isEmpty ? null : apiStatusRaw;
    final metadata = json['metadata'];
    final shippingAddress = metadata is Map<String, dynamic>
        ? metadata['shipping_address'] as Map<String, dynamic>?
        : null;
    final vendorInfo = metadata is Map<String, dynamic>
        ? metadata['vendor_info'] as Map<String, dynamic>?
        : null;
    final customerName = (shippingAddress?['full_name'] ??
            shippingAddress?['name'] ??
            json['customer_name'] ??
            (json['customer_id'] != null
                ? 'Customer #${json['customer_id']}'
                : 'Customer'))
        .toString();
    final addressLine1 = shippingAddress?['address_line1']?.toString() ?? '';
    final addressLine2 = shippingAddress?['address_line2']?.toString() ?? '';
    final city = shippingAddress?['city']?.toString() ?? '';
    final state = shippingAddress?['state']?.toString() ?? '';
    final postal = shippingAddress?['postal_code']?.toString() ?? '';
    final addressParts = [
      addressLine1,
      addressLine2,
      city,
      state,
      postal,
    ].where((part) => part.trim().isNotEmpty).toList();
    final fallbackAddress =
        'Vendor ${vendorInfo?['vendor_id'] ?? '-'} → Customer ${json['customer_id'] ?? '-'}';
    final address =
        addressParts.isEmpty ? fallbackAddress : addressParts.join(', ');

    return Assignment(
      id: orderId,
      customerName: customerName,
      expectedArrival: expectedArrival,
      deleverystatus: orderType,
      orderStatus: apiStatus,
      address: (json['delivery_address'] ?? json['address'] ?? address)
          .toString(),
      distanceInKm: distanceValue,
      totalAmount: totalValue,
      basePay: basePayValue,
      distancePay: distancePayValue,
      orderType: orderType,
      currency: (json['currency'] ?? '₹').toString(),
      isUrgent: json['is_on_time'] == false,
      isCombined: json['is_combined'] as bool? ?? combinedFromType,
      status: _statusFromApi(json['status'] as String?),
      tierLabel: (json['tier_label'] ?? 'Payout Rate').toString(),
    );
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['order_id'] as String,
      customerName: json['customer_name'] as String,
      deleverystatus: json['delivery_type'] as String? ?? 'Pending',
      orderStatus: json['status'] as String?,
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
      tierLabel: json['tier_label'] as String? ?? 'Tier Rate',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': id,
      'customer_name': customerName,
      'status': orderStatus,
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
      'tier_label': tierLabel,
    };
  }

  static String _formatDistance(double value) {
    return value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  static String _formatCurrency(double value) {
    return value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  static String _formatRatePerKm(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    if ((value * 10) % 1 == 0) return value.toStringAsFixed(1);
    return value.toStringAsFixed(2);
  }

  static AssignmentStatus _statusFromApi(String? status) {
    final normalized = status?.toLowerCase().replaceAll(' ', '') ?? '';
    if (normalized.isEmpty || normalized == 'pending' || normalized == 'assigned') {
      return AssignmentStatus.pending;
    }
    if (normalized == 'outfordelivery') {
      return AssignmentStatus.outForDelivery;
    }
    if (normalized.contains('reject') || normalized.contains('cancel')) {
      return AssignmentStatus.rejected;
    }
    return AssignmentStatus.accepted;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0;
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
