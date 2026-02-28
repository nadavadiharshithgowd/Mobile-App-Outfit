class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? profilePhoto;
  final String authProvider;
  final DateTime dateJoined;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.profilePhoto,
    required this.authProvider,
    required this.dateJoined,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      authProvider: json['auth_provider'] as String? ?? 'email',
      dateJoined: DateTime.parse(json['date_joined'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'profile_photo': profilePhoto,
      'auth_provider': authProvider,
      'date_joined': dateJoined.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? profilePhoto,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      authProvider: authProvider,
      dateJoined: dateJoined,
    );
  }
}
