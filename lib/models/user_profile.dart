class UserProfile {
  final int? id;
  final String fullName;
  final String designation;
  final String district;
  final String tehsil;
  final String mobileNumber;
  final DateTime registrationDate;
  final bool isVerified;

  UserProfile({
    this.id,
    required this.fullName,
    required this.designation,
    required this.district,
    required this.tehsil,
    required this.mobileNumber,
    required this.registrationDate,
    this.isVerified = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'designation': designation,
      'district': district,
      'tehsil': tehsil,
      'mobile_number': mobileNumber,
      'registration_date': registrationDate.toIso8601String(),
      'is_verified': isVerified ? 1 : 0,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      designation: map['designation'] as String,
      district: map['district'] as String,
      tehsil: map['tehsil'] as String,
      mobileNumber: map['mobile_number'] as String,
      registrationDate: DateTime.parse(map['registration_date'] as String),
      isVerified: (map['is_verified'] as int) == 1,
    );
  }

  UserProfile copyWith({
    int? id,
    String? fullName,
    String? designation,
    String? district,
    String? tehsil,
    String? mobileNumber,
    DateTime? registrationDate,
    bool? isVerified,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      designation: designation ?? this.designation,
      district: district ?? this.district,
      tehsil: tehsil ?? this.tehsil,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      registrationDate: registrationDate ?? this.registrationDate,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
