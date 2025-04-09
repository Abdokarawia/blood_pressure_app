class UserModel {
  final String? uid;
  final String? name;
  final String email;
  final String? phone;
  final DateTime? dateOfBirth;
  final DateTime? createdAt;

  UserModel({
    this.uid,
    this.name,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}