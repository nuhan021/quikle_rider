class RiderDocumentsModel {
  final int? id;
  final String? profileImage;
  final String? nationalIdDocument;
  final String? drivingLicenseDocument;
  final String? vehicleRegistrationDocument;
  final String? vehicleInsuranceDocument;
  final bool? isAvailable;
  final bool? isVerified;
  final String? createdAt;
  final String? updatedAt;
  final String? drivingLicense;
  final String? nid;

  const RiderDocumentsModel({
    this.id,
    this.profileImage,
    this.nationalIdDocument,
    this.drivingLicenseDocument,
    this.vehicleRegistrationDocument,
    this.vehicleInsuranceDocument,
    this.isAvailable,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
    this.drivingLicense,
    this.nid,
  });

  factory RiderDocumentsModel.fromJson(Map<String, dynamic> json) {
    return RiderDocumentsModel(
      id: json['id'] as int?,
      profileImage: json['profile_image']?.toString(),
      nationalIdDocument: json['national_id_document']?.toString(),
      drivingLicenseDocument: json['driving_license_document']?.toString(),
      vehicleRegistrationDocument:
          json['vehicle_registration_document']?.toString(),
      vehicleInsuranceDocument:
          json['vehicle_insurance_document']?.toString(),
      isAvailable: json['is_available'] as bool?,
      isVerified: json['is_verified'] as bool?,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      drivingLicense: json['driving_license']?.toString(),
      nid: json['nid']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_image': profileImage,
      'national_id_document': nationalIdDocument,
      'driving_license_document': drivingLicenseDocument,
      'vehicle_registration_document': vehicleRegistrationDocument,
      'vehicle_insurance_document': vehicleInsuranceDocument,
      'is_available': isAvailable,
      'is_verified': isVerified,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'driving_license': drivingLicense,
      'nid': nid,
    };
  }
}
