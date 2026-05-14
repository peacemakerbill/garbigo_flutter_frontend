class UserSummaryDto {
  final String id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;

  UserSummaryDto({
    required this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
  });

  factory UserSummaryDto.fromJson(Map<String, dynamic> json) {
    return UserSummaryDto(
      id: json['id'] ?? '',
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }
}