// features/auth/models/auth_response_model.dart
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
      token: json['token'] as String,
      role: json['role'] as String,
      verified: json['verified'] as bool? ?? false,
    );
  }
}