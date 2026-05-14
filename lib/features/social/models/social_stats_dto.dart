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
      // Use .toInt() to handle potential Long/int variations from the API
      followersCount: (json['followersCount'] ?? 0).toInt(),
      followingCount: (json['followingCount'] ?? 0).toInt(),
      likesCount: (json['likesCount'] ?? 0).toInt(),
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
    );
  }
}