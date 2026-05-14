class AuthResponseModel {
  final String token;
  final String role;
  final bool verified;

  AuthResponseModel({
    required this.token,
    required this.role,
    required this.verified,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      role: json['role'] ?? 'CLIENT',
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'role': role,
      'verified': verified,
    };
  }
}