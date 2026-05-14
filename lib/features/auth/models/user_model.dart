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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
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
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'homeAddress': homeAddress,
      'profilePictureUrl': profilePictureUrl,
      'role': role,
      'wastePreferences': wastePreferences,
      'collectionSchedule': collectionSchedule,
      'verified': verified,
      'active': active,
      'archived': archived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}