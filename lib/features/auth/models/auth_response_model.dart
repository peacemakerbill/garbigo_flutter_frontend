class AuthResponseModel {
  final String token;
  final String role;
  final String dashboardUrl;

  AuthResponseModel({
    required this.token,
    required this.role,
    required this.dashboardUrl,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      role: json['role'] as String,
      dashboardUrl: json['dashboardUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'role': role,
      'dashboardUrl': dashboardUrl,
    };
  }
}