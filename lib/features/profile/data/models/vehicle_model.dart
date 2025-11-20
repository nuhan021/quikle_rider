class VehicleModel {
  final int? id;
  final String vehicleType;
  final String licensePlateNumber;
  final String? model;
  final String? createdAt;
  final String? updatedAt;

  const VehicleModel({
    this.id,
    required this.vehicleType,
    required this.licensePlateNumber,
    this.model,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: _tryParseInt(json['id']),
      vehicleType: json['vehicle_type']?.toString() ?? '',
      model: json['model']?.toString(),
      licensePlateNumber: json['license_plate_number']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_type': vehicleType,
      'model': model,
      'license_plate_number': licensePlateNumber,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  VehicleModel copyWith({
    int? id,
    String? vehicleType,
    String? model,
    String? licensePlateNumber,
    String? createdAt,
    String? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      vehicleType: vehicleType ?? this.vehicleType,
      model: model ?? this.model,
      licensePlateNumber: licensePlateNumber ?? this.licensePlateNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
