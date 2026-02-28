class AuthTokenModel {
  final String accessToken;
  final String refreshToken;

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
    );
  }
}
