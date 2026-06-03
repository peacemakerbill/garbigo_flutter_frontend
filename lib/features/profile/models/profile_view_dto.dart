class ProfileViewDto {
  final String? viewerId;
  final String viewerName;
  final String? viewerProfilePictureUrl;
  final DateTime viewedAt;
  final bool isAnonymous;

  ProfileViewDto({
    this.viewerId,
    required this.viewerName,
    this.viewerProfilePictureUrl,
    required this.viewedAt,
    required this.isAnonymous,
  });

  factory ProfileViewDto.fromJson(Map<String, dynamic> json) {
    return ProfileViewDto(
      viewerId: json['viewerId'],
      viewerName: json['viewerName'] ?? 'Anonymous User',
      viewerProfilePictureUrl: json['viewerProfilePictureUrl'],
      viewedAt: json['viewedAt'] != null
          ? DateTime.parse(json['viewedAt'])
          : DateTime.now(),
      isAnonymous: json['anonymous'] ?? json['isAnonymous'] ?? true,
    );
  }
}

class ProfileViewStatsDto {
  final int totalViews;
  final int uniqueViewers;
  final int todayViews;
  final List<ProfileViewDto> recentViewers;

  ProfileViewStatsDto({
    required this.totalViews,
    required this.uniqueViewers,
    required this.todayViews,
    required this.recentViewers,
  });

  factory ProfileViewStatsDto.fromJson(Map<String, dynamic> json) {
    return ProfileViewStatsDto(
      totalViews: (json['totalViews'] ?? 0).toInt(),
      uniqueViewers: (json['uniqueViewers'] ?? 0).toInt(),
      todayViews: (json['todayViews'] ?? 0).toInt(),
      recentViewers: (json['recentViewers'] as List? ?? [])
          .map((e) => ProfileViewDto.fromJson(e))
          .toList(),
    );
  }
}