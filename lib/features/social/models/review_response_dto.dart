class ReviewResponseDto {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerProfilePictureUrl;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  ReviewResponseDto({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerProfilePictureUrl,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewResponseDto.fromJson(Map<String, dynamic> json) {
    return ReviewResponseDto(
      id: json['id'] ?? '',
      reviewerId: json['reviewerId'] ?? '',
      reviewerName: json['reviewerName'] ?? 'Unknown',
      reviewerProfilePictureUrl: json['reviewerProfilePictureUrl'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}