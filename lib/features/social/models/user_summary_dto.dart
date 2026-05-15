class UserSummaryDto {
  final String id;
  final String? username;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? fullName;
  final String? profilePictureUrl;
  final String? email;
  final String? phoneNumber;
  final String? role;
  final bool active;
  final CurrentLocationDto? currentLocation;

  UserSummaryDto({
    required this.id,
    this.username,
    this.firstName,
    this.middleName,
    this.lastName,
    this.fullName,
    this.profilePictureUrl,
    this.email,
    this.phoneNumber,
    this.role,
    this.active = true,
    this.currentLocation,
  });

  factory UserSummaryDto.fromJson(Map<String, dynamic> json) {
    return UserSummaryDto(
      id: json['id'] ?? '',
      username: json['username'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      fullName: json['fullName'],
      profilePictureUrl: json['profilePictureUrl'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      active: json['active'] ?? true,
      currentLocation: json['currentLocation'] != null
          ? CurrentLocationDto.fromJson(json['currentLocation'])
          : null,
    );
  }
}

class CurrentLocationDto {
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime? timestamp;

  CurrentLocationDto({
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.timestamp,
  });

  factory CurrentLocationDto.fromJson(Map<String, dynamic> json) {
    return CurrentLocationDto(
      userId: json['userId'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : null,
    );
  }
}