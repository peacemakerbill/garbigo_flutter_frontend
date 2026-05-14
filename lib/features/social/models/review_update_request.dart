class ReviewUpdateRequest {
  final int rating;
  final String? comment;

  ReviewUpdateRequest({
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}