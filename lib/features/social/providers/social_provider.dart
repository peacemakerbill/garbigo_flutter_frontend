import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/config/app_config.dart';
import 'package:garbigo_frontend/core/network/api_client.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import '../models/social_action_request.dart';
import '../models/user_summary_dto.dart';
import '../models/review_response_dto.dart';
import '../models/follow_check_dto.dart';
import '../models/like_check_dto.dart';
import '../models/social_stats_dto.dart';
import '../models/review_update_request.dart';

class SocialState {
  final bool isLoading;
  final String? error;
  final String? currentProfileId; // track which profile this state belongs to
  final bool isFollowing;
  final bool isLiked;
  final SocialStatsDto? stats;
  final List<ReviewResponseDto> reviews;
  final List<UserSummaryDto> followersList;
  final List<UserSummaryDto> followingList;

  SocialState({
    this.isLoading = false,
    this.error,
    this.currentProfileId,
    this.isFollowing = false,
    this.isLiked = false,
    this.stats,
    this.reviews = const [],
    this.followersList = const [],
    this.followingList = const [],
  });

  SocialState copyWith({
    bool? isLoading,
    String? error,
    String? currentProfileId,
    bool? isFollowing,
    bool? isLiked,
    SocialStatsDto? stats,
    List<ReviewResponseDto>? reviews,
    List<UserSummaryDto>? followersList,
    List<UserSummaryDto>? followingList,
  }) {
    return SocialState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentProfileId: currentProfileId ?? this.currentProfileId,
      isFollowing: isFollowing ?? this.isFollowing,
      isLiked: isLiked ?? this.isLiked,
      stats: stats ?? this.stats,
      reviews: reviews ?? this.reviews,
      followersList: followersList ?? this.followersList,
      followingList: followingList ?? this.followingList,
    );
  }
}

class SocialNotifier extends StateNotifier<SocialState> {
  SocialNotifier(this.ref) : super(SocialState());

  final Ref ref;

  /// Always use a fresh Dio pointed at the social base URL.
  /// The shared dioProvider may have its baseUrl mutated elsewhere,
  /// so we build a dedicated instance here to avoid URL conflicts.
  Dio get _dio {
    final dio = ref.read(dioProvider);
    dio.options.baseUrl = AppConfig.socialBase; // e.g. "https://api.garbigo.com/social-service"
    return dio;
  }

  // ====================== INIT / RESET ======================

  /// Call this every time a new profile is opened.
  /// Resets state so stale data from a previous profile never bleeds through.
  Future<void> refreshAll(String userId) async {
    // Reset to a clean slate for this profile
    state = SocialState(currentProfileId: userId, isLoading: true);

    await Future.wait([
      _fetchStats(userId),
      _fetchReviews(userId),
      _fetchFollowStatus(userId),
      _fetchLikeStatus(userId),
    ]);

    state = state.copyWith(isLoading: false);
  }

  // ====================== FOLLOW ======================

  Future<void> follow(String userId) async {
    // Optimistic update
    state = state.copyWith(
      isFollowing: true,
      stats: state.stats?._withFollowers((state.stats!.followersCount + 1)),
    );
    try {
      await _dio.post('/follow/$userId');
      // Confirm from server
      await _fetchStats(userId);
    } catch (e) {
      // Roll back
      state = state.copyWith(isFollowing: false);
      _handleError('Follow', e);
    }
  }

  Future<void> unfollow(String userId) async {
    // Optimistic update
    state = state.copyWith(
      isFollowing: false,
      stats: state.stats?._withFollowers(
        (state.stats!.followersCount - 1).clamp(0, double.maxFinite.toInt()),
      ),
    );
    try {
      await _dio.delete('/follow/$userId');
      await _fetchStats(userId);
    } catch (e) {
      // Roll back
      state = state.copyWith(isFollowing: true);
      _handleError('Unfollow', e);
    }
  }

  // ====================== LIKE ======================

  Future<void> like(String targetId, {String targetType = 'USER'}) async {
    state = state.copyWith(
      isLiked: true,
      stats: state.stats?._withLikes((state.stats!.likesCount + 1)),
    );
    try {
      await _dio.post('/like',
          data: {'targetId': targetId, 'targetType': targetType});
      await _fetchStats(targetId);
    } catch (e) {
      state = state.copyWith(isLiked: false);
      _handleError('Like', e);
    }
  }

  Future<void> unlike(String targetId, {String targetType = 'USER'}) async {
    state = state.copyWith(
      isLiked: false,
      stats: state.stats?._withLikes(
        (state.stats!.likesCount - 1).clamp(0, double.maxFinite.toInt()),
      ),
    );
    try {
      await _dio.delete('/like',
          data: {'targetId': targetId, 'targetType': targetType});
      await _fetchStats(targetId);
    } catch (e) {
      state = state.copyWith(isLiked: true);
      _handleError('Unlike', e);
    }
  }

  // ====================== REVIEWS ======================

  Future<void> addReview(SocialActionRequest request) async {
    try {
      await _dio.post('/review', data: request.toJson());
      await Future.wait([
        _fetchReviews(request.targetId),
        _fetchStats(request.targetId),
      ]);
      Helpers.showToast('Review added successfully');
    } catch (e) {
      _handleError('Add Review', e);
    }
  }

  Future<void> updateReview(
      String reviewId, String targetId, ReviewUpdateRequest request) async {
    try {
      await _dio.put('/review/$reviewId', data: request.toJson());
      await Future.wait([
        _fetchReviews(targetId),
        _fetchStats(targetId),
      ]);
      Helpers.showToast('Review updated successfully');
    } catch (e) {
      _handleError('Update Review', e);
    }
  }

  Future<void> deleteReview(String reviewId, String targetId) async {
    // Optimistic: remove from list immediately
    final previous = state.reviews;
    state = state.copyWith(
      reviews: state.reviews.where((r) => r.id != reviewId).toList(),
    );
    try {
      await _dio.delete('/review/$reviewId');
      await _fetchStats(targetId);
      Helpers.showToast('Review deleted');
    } catch (e) {
      state = state.copyWith(reviews: previous); // roll back
      _handleError('Delete Review', e);
    }
  }

  // ====================== FOLLOWERS / FOLLOWING LISTS ======================

  Future<void> getFollowers(String userId) async {
    try {
      final response = await _dio.get('/followers/$userId');
      final list = (response.data as List)
          .map((e) => UserSummaryDto.fromJson(e))
          .toList();
      state = state.copyWith(followersList: list);
    } catch (e) {
      _handleError('Get Followers', e);
    }
  }

  Future<void> getFollowing(String userId) async {
    try {
      final response = await _dio.get('/following/$userId');
      final list = (response.data as List)
          .map((e) => UserSummaryDto.fromJson(e))
          .toList();
      state = state.copyWith(followingList: list);
    } catch (e) {
      _handleError('Get Following', e);
    }
  }

  // ====================== PRIVATE FETCHERS ======================

  Future<void> _fetchStats(String userId) async {
    try {
      final response = await _dio.get('/stats/$userId');
      state = state.copyWith(stats: SocialStatsDto.fromJson(response.data));
    } catch (e) {
      debugPrint('Stats fetch error: $e');
    }
  }

  Future<void> _fetchReviews(String userId,
      {String targetType = 'USER'}) async {
    try {
      final response = await _dio.get('/reviews/$userId',
          queryParameters: {'targetType': targetType});
      final list =
      (response.data as List).map((e) => ReviewResponseDto.fromJson(e)).toList();
      state = state.copyWith(reviews: list);
    } catch (e) {
      debugPrint('Reviews fetch error: $e');
    }
  }

  Future<void> _fetchFollowStatus(String userId) async {
    try {
      final response = await _dio.get('/is-following/$userId');
      state = state.copyWith(
          isFollowing: FollowCheckDto.fromJson(response.data).isFollowing);
    } catch (e) {
      debugPrint('Follow status error: $e');
    }
  }

  Future<void> _fetchLikeStatus(String userId,
      {String targetType = 'USER'}) async {
    try {
      final response = await _dio.get('/is-liked', queryParameters: {
        'targetId': userId,
        'targetType': targetType,
      });
      state =
          state.copyWith(isLiked: LikeCheckDto.fromJson(response.data).isLiked);
    } catch (e) {
      debugPrint('Like status error: $e');
    }
  }

  // ====================== ERROR HELPER ======================

  void _handleError(String action, dynamic e) {
    final msg = e is DioException
        ? (e.response?.data?['message'] ?? e.message ?? e.toString())
        : e.toString();
    state = state.copyWith(error: msg);
    Helpers.showToast('$action failed: $msg', isError: true);
    debugPrint('Social $action Error: $msg');
  }
}

/// Per-profile scoped provider — pass the userId as the family argument.
/// This guarantees each profile gets its own isolated state with no bleed-over.
final socialProvider =
StateNotifierProvider.family<SocialNotifier, SocialState, String>(
      (ref, userId) => SocialNotifier(ref),
);

// ---------------------------------------------------------------------------
// Extension to cleanly produce updated SocialStatsDto copies
// ---------------------------------------------------------------------------
extension _StatsUpdate on SocialStatsDto {
  SocialStatsDto _withFollowers(int count) => SocialStatsDto(
    followersCount: count,
    followingCount: followingCount,
    likesCount: likesCount,
    averageRating: averageRating,
  );

  SocialStatsDto _withLikes(int count) => SocialStatsDto(
    followersCount: followersCount,
    followingCount: followingCount,
    likesCount: count,
    averageRating: averageRating,
  );
}