// features/auth/models/user_model.dart
class UserModel {
  final String id;
  final String username;
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String homeAddress;
  final String profilePictureUrl;
  final String role;
  final String wastePreferences;
  final String collectionSchedule;
  final bool verified;
  final bool active;
  final bool archived;

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.homeAddress,
    required this.profilePictureUrl,
    required this.role,
    required this.wastePreferences,
    required this.collectionSchedule,
    required this.verified,
    required this.active,
    required this.archived,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      homeAddress: json['homeAddress'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      role: json['role'] ?? 'CLIENT',
      wastePreferences: json['wastePreferences'] ?? '',
      collectionSchedule: json['collectionSchedule'] ?? '',
      verified: json['verified'] ?? false,
      active: json['active'] ?? true,
      archived: json['archived'] ?? false,
    );
  }
}