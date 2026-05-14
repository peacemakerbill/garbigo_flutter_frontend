class LikeCheckDto {
  final bool isLiked;
  LikeCheckDto(this.isLiked);

  factory LikeCheckDto.fromJson(Map<String, dynamic> json) {
    return LikeCheckDto(json['isLiked'] ?? false);
  }
}