import 'package:garbigo_frontend/features/auth/models/user_model.dart';

class AuthResponseModel {
  final String token;
  final String role;
  final bool verified;
  final UserModel? user;

  AuthResponseModel({
    required this.token,
    required this.role,
    required this.verified,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      role: json['role'] ?? 'CLIENT',
      verified: json['verified'] ?? false,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'role': role,
      'verified': verified,
      if (user != null) 'user': user!.toJson(),
    };
  }
}