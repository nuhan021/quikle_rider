class ProfileModel {
  final String name;
  final String email;
  final String phone;
  final String drivingLicense;
  final String nid;
  final String? profileImage;

  const ProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.drivingLicense,
    required this.nid,
    this.profileImage,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      drivingLicense: json['driving_license']?.toString() ?? '',
      nid: json['nid']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'driving_license': drivingLicense,
      'nid': nid,
      'profile_image': profileImage,
    };
  }

  ProfileModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? drivingLicense,
    String? nid,
    String? profileImage,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      drivingLicense: drivingLicense ?? this.drivingLicense,
      nid: nid ?? this.nid,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
