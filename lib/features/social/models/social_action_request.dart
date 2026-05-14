class SocialActionRequest {
  final String targetId;
  final String? targetType;
  final int? rating;
  final String? comment;

  SocialActionRequest({
    required this.targetId,
    this.targetType,
    this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'targetId': targetId,
      'targetType': targetType?.toUpperCase(),
      'rating': rating,
      'comment': comment,
    }..removeWhere((key, value) => value == null);
  }
}