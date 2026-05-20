class FollowCheckDto {
  final bool following;
  FollowCheckDto({required this.following});

  factory FollowCheckDto.fromJson(Map<String, dynamic> json) {
    return FollowCheckDto(following: json['following'] ?? false);
  }
}