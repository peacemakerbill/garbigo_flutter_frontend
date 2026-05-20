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
  final String? currentProfileId;
  final bool isFollowing;
  final bool isLiked;
  final SocialStatsDto? stats;
  final List<ReviewResponseDto> reviews;
  final List<UserSummaryDto> followersList;
  final List<UserSummaryDto> followingList;

  final String? profileDisplayName;
  final String? profileAvatarUrl;
  final String? profileEmail;
  final CurrentLocationDto? currentLocation;

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
    this.profileDisplayName,
    this.profileAvatarUrl,
    this.profileEmail,
    this.currentLocation,
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
    String? profileDisplayName,
    String? profileAvatarUrl,
    String? profileEmail,
    CurrentLocationDto? currentLocation,
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
      profileDisplayName: profileDisplayName ?? this.profileDisplayName,
      profileAvatarUrl: profileAvatarUrl ?? this.profileAvatarUrl,
      profileEmail: profileEmail ?? this.profileEmail,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}

class SocialNotifier extends StateNotifier<SocialState> {
  SocialNotifier(this.ref) : super(SocialState());

  final Ref ref;

  bool _actionInProgress = false;

  Dio get _dio {
    final dio = ref.read(dioProvider);
    dio.options.baseUrl = AppConfig.socialBase;
    return dio;
  }

  // ====================== INIT / RESET ======================
  Future<void> refreshAll(String userId) async {
    state = SocialState(currentProfileId: userId, isLoading: true);

    await Future.wait([
      _fetchProfileUser(userId),
      _fetchStats(userId),
      _fetchReviews(userId),
      _fetchFollowStatus(userId),
      _fetchLikeStatus(userId),
    ]);

    state = state.copyWith(isLoading: false);
  }

  // ====================== PROFILE SUMMARY ======================
  Future<void> _fetchProfileUser(String userId) async {
    try {
      final response = await _dio.get('/profile/$userId');
      final data = response.data as Map<String, dynamic>;

      final summary = UserSummaryDto.fromJson(data);

      state = state.copyWith(
        profileDisplayName: summary.fullName?.isNotEmpty == true
            ? summary.fullName
            : '${summary.firstName ?? ''} ${summary.lastName ?? ''}'.trim(),
        profileAvatarUrl: summary.profilePictureUrl,
        profileEmail: summary.email,
        currentLocation: summary.currentLocation,
      );
    } catch (e) {
      debugPrint('Profile user fetch error for $userId: $e');
      state = state.copyWith(
        profileDisplayName: null,
        profileAvatarUrl: null,
        profileEmail: null,
        currentLocation: null,
      );
    }
  }

  // ====================== FOLLOW STATUS ======================
  Future<void> _fetchFollowStatus(String userId) async {
    try {
      final response = await _dio.get('/is-following/$userId');
      final dto = FollowCheckDto.fromJson(response.data);
      state = state.copyWith(isFollowing: dto.following);
    } catch (e) {
      debugPrint('Follow status error: $e');
      state = state.copyWith(isFollowing: false);
    }
  }

  // ====================== LIKE STATUS ======================
  Future<void> _fetchLikeStatus(String userId, {String targetType = 'USER'}) async {
    try {
      final response = await _dio.get('/is-liked', queryParameters: {
        'targetId': userId,
        'targetType': targetType,
      });
      final dto = LikeCheckDto.fromJson(response.data);
      state = state.copyWith(isLiked: dto.liked);
    } catch (e) {
      debugPrint('Like status error: $e');
      state = state.copyWith(isLiked: false);
    }
  }

  // ====================== FOLLOW ACTIONS ======================
  Future<void> follow(String userId) async {
    if (_actionInProgress || state.isFollowing) return;
    _actionInProgress = true;
    state = state.copyWith(isFollowing: true);
    try {
      await _dio.post('/follow/$userId');
      Helpers.showToast('Followed successfully');
      await _fetchStats(userId);
    } catch (e) {
      state = state.copyWith(isFollowing: false);
      _handleError('Follow', e);
    } finally {
      _actionInProgress = false;
    }
  }

  Future<void> unfollow(String userId) async {
    if (_actionInProgress || !state.isFollowing) return;
    _actionInProgress = true;
    state = state.copyWith(isFollowing: false);
    try {
      await _dio.delete('/follow/$userId');
      Helpers.showToast('Unfollowed successfully');
      await _fetchStats(userId);
    } catch (e) {
      state = state.copyWith(isFollowing: true);
      _handleError('Unfollow', e);
    } finally {
      _actionInProgress = false;
    }
  }

  // ====================== LIKE ACTIONS ======================
  Future<void> like(String targetId, {String targetType = 'USER'}) async {
    if (_actionInProgress || state.isLiked) return;
    _actionInProgress = true;
    state = state.copyWith(isLiked: true);
    try {
      await _dio.post('/like', data: {'targetId': targetId, 'targetType': targetType});
      Helpers.showToast('Liked successfully');
      await _fetchStats(targetId);
    } catch (e) {
      state = state.copyWith(isLiked: false);
      _handleError('Like', e);
    } finally {
      _actionInProgress = false;
    }
  }

  Future<void> unlike(String targetId, {String targetType = 'USER'}) async {
    if (_actionInProgress || !state.isLiked) return;
    _actionInProgress = true;
    state = state.copyWith(isLiked: false);
    try {
      await _dio.delete('/like', data: {'targetId': targetId, 'targetType': targetType});
      Helpers.showToast('Unliked successfully');
      await _fetchStats(targetId);
    } catch (e) {
      state = state.copyWith(isLiked: true);
      _handleError('Unlike', e);
    } finally {
      _actionInProgress = false;
    }
  }

  // ====================== REVIEWS ======================
  Future<void> addReview(SocialActionRequest request) async {
    try {
      final response = await _dio.post('/review', data: request.toJson());
      final msg = _extractMessage(response.data) ?? 'Review added successfully';
      await Future.wait([
        _fetchReviews(request.targetId),
        _fetchStats(request.targetId),
      ]);
      Helpers.showToast(msg);
    } catch (e) {
      _handleError('Add Review', e);
    }
  }

  Future<void> updateReview(
      String reviewId, String targetId, ReviewUpdateRequest request) async {
    try {
      final response = await _dio.put('/review/$reviewId', data: request.toJson());
      final msg = _extractMessage(response.data) ?? 'Review updated successfully';
      await Future.wait([
        _fetchReviews(targetId),
        _fetchStats(targetId),
      ]);
      Helpers.showToast(msg);
    } catch (e) {
      _handleError('Update Review', e);
    }
  }

  Future<void> deleteReview(String reviewId, String targetId) async {
    final previous = state.reviews;
    state = state.copyWith(
      reviews: state.reviews.where((r) => r.id != reviewId).toList(),
    );
    try {
      final response = await _dio.delete('/review/$reviewId');
      final msg = _extractMessage(response.data) ?? 'Review deleted';
      await _fetchStats(targetId);
      Helpers.showToast(msg);
    } catch (e) {
      state = state.copyWith(reviews: previous);
      _handleError('Delete Review', e);
    }
  }

  // ====================== FOLLOWERS / FOLLOWING ======================
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

  Future<void> _fetchReviews(String userId, {String targetType = 'USER'}) async {
    try {
      final response = await _dio.get('/reviews/$userId',
          queryParameters: {'targetType': targetType});
      final list = (response.data as List)
          .map((e) => ReviewResponseDto.fromJson(e))
          .toList();
      state = state.copyWith(reviews: list);
    } catch (e) {
      debugPrint('Reviews fetch error: $e');
    }
  }

  // ====================== HELPERS ======================
  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is Map) return data['message'] as String?;
    return null;
  }

  void _handleError(String action, dynamic e) {
    final msg = e is DioException
        ? (e.response?.data is Map
        ? (e.response!.data['message'] ?? e.message ?? e.toString())
        : (e.response?.data?.toString() ?? e.message ?? e.toString()))
        : e.toString();
    state = state.copyWith(error: msg);
    Helpers.showToast('$action failed: $msg', isError: true);
    debugPrint('Social $action Error: $msg');
  }
}

final socialProvider =
StateNotifierProvider.family<SocialNotifier, SocialState, String>(
      (ref, userId) => SocialNotifier(ref),
);

// Stats Extension
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