class HomeModel {
  final bool isOnline;
  final List<AssignmentModel> assignments;
  final StatsModel stats;

  const HomeModel({
    required this.isOnline,
    required this.assignments,
    required this.stats,
  });

  HomeModel copyWith({
    bool? isOnline,
    List<AssignmentModel>? assignments,
    StatsModel? stats,
  }) {
    return HomeModel(
      isOnline: isOnline ?? this.isOnline,
      assignments: assignments ?? this.assignments,
      stats: stats ?? this.stats,
    );
  }
}

class StatsModel {
  final String todayDeliveries;
  final String weekDeliveries;
  final String rating;

  const StatsModel({
    required this.todayDeliveries,
    required this.weekDeliveries,
    required this.rating,
  });

  StatsModel copyWith({
    String? todayDeliveries,
    String? weekDeliveries,
    String? rating,
  }) {
    return StatsModel(
      todayDeliveries: todayDeliveries ?? this.todayDeliveries,
      weekDeliveries: weekDeliveries ?? this.weekDeliveries,
      rating: rating ?? this.rating,
    );
  }
}

class AssignmentModel {
  final String orderId;
  final String customerName;
  final String arrivalTime;
  final String address;
  final String distance;
  final String total;
  final bool isUrgent;
  final bool isCombined;

  const AssignmentModel({
    required this.orderId,
    required this.customerName,
    required this.arrivalTime,
    required this.address,
    required this.distance,
    required this.total,
    required this.isUrgent,
    required this.isCombined,
  });

  AssignmentModel copyWith({
    String? orderId,
    String? customerName,
    String? arrivalTime,
    String? address,
    String? distance,
    String? total,
    bool? isUrgent,
    bool? isCombined,
  }) {
    return AssignmentModel(
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      total: total ?? this.total,
      isUrgent: isUrgent ?? this.isUrgent,
      isCombined: isCombined ?? this.isCombined,
    );
  }
}
