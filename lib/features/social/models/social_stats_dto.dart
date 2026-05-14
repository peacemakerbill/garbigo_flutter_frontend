class SocialStatsDto {
  final int followersCount;
  final int followingCount;
  final int likesCount;
  final double averageRating;

  SocialStatsDto({
    required this.followersCount,
    required this.followingCount,
    required this.likesCount,
    required this.averageRating,
  });

  factory SocialStatsDto.fromJson(Map<String, dynamic> json) {
    return SocialStatsDto(
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
    );
  }
}