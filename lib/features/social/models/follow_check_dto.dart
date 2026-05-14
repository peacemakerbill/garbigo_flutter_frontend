class FollowCheckDto {
  final bool isFollowing;
  FollowCheckDto(this.isFollowing);

  factory FollowCheckDto.fromJson(Map<String, dynamic> json) {
    return FollowCheckDto(json['isFollowing'] ?? false);
  }
}