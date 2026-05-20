class LikeCheckDto {
  final bool liked;
  LikeCheckDto({required this.liked});

  factory LikeCheckDto.fromJson(Map<String, dynamic> json) {
    return LikeCheckDto(liked: json['liked'] ?? false);
  }
}