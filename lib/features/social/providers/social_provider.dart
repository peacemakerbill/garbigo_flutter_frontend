import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/network/api_client.dart';
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
  final Map<String, bool> followingCache;
  final Map<String, bool> likedCache;
  final SocialStatsDto? stats;
  final List<ReviewResponseDto> reviews;
  final List<UserSummaryDto> followersList;
  final List<UserSummaryDto> followingList;

  SocialState({
    this.isLoading = false,
    this.error,
    this.followingCache = const {},
    this.likedCache = const {},
    this.stats,
    this.reviews = const [],
    this.followersList = const [],
    this.followingList = const [],
  });

  SocialState copyWith({
    bool? isLoading,
    String? error,
    Map<String, bool>? followingCache,
    Map<String, bool>? likedCache,
    SocialStatsDto? stats,
    List<ReviewResponseDto>? reviews,
    List<UserSummaryDto>? followersList,
    List<UserSummaryDto>? followingList,
  }) {
    return SocialState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      followingCache: followingCache ?? this.followingCache,
      likedCache: likedCache ?? this.likedCache,
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
  Dio get _dio => ref.read(dioProvider);

  // ====================== FOLLOW & UNFOLLOW ======================
  Future<void> follow(String userId) async {
    await _dio.post('/social/follow/$userId');
    _updateFollowCache(userId, true);
    await getUserStats(userId);
  }

  Future<void> unfollow(String userId) async {
    await _dio.delete('/social/follow/$userId');
    _updateFollowCache(userId, false);
    await getUserStats(userId);
  }

  void _updateFollowCache(String userId, bool status) {
    final newCache = Map<String, bool>.from(state.followingCache);
    newCache[userId] = status;
    state = state.copyWith(followingCache: newCache);
  }

  Future<void> checkFollowStatus(String userId) async {
    final response = await _dio.get('/social/is-following/$userId');
    _updateFollowCache(userId, FollowCheckDto.fromJson(response.data).isFollowing);
  }

  Future<void> getFollowers(String userId) async {
    final response = await _dio.get('/social/followers/$userId');
    final list = (response.data as List).map((e) => UserSummaryDto.fromJson(e)).toList();
    state = state.copyWith(followersList: list);
  }

  Future<void> getFollowing(String userId) async {
    final response = await _dio.get('/social/following/$userId');
    final list = (response.data as List).map((e) => UserSummaryDto.fromJson(e)).toList();
    state = state.copyWith(followingList: list);
  }

  // ====================== LIKE & UNLIKE ======================
  Future<void> like(String targetId, {String targetType = 'USER'}) async {
    await _dio.post('/social/like', data: {'targetId': targetId, 'targetType': targetType});
    _updateLikeCache(targetId, true);
    await getUserStats(targetId);
  }

  Future<void> unlike(String targetId, {String targetType = 'USER'}) async {
    await _dio.delete('/social/like', data: {'targetId': targetId, 'targetType': targetType});
    _updateLikeCache(targetId, false);
    await getUserStats(targetId);
  }

  void _updateLikeCache(String targetId, bool status) {
    final newCache = Map<String, bool>.from(state.likedCache);
    newCache[targetId] = status;
    state = state.copyWith(likedCache: newCache);
  }

  Future<void> checkLikeStatus(String targetId, {String targetType = 'USER'}) async {
    final response = await _dio.get('/social/is-liked', queryParameters: {
      'targetId': targetId,
      'targetType': targetType,
    });
    _updateLikeCache(targetId, LikeCheckDto.fromJson(response.data).isLiked);
  }

  // ====================== REVIEWS (Full CRUD) ======================
  Future<void> getReviews(String targetId, {String targetType = 'USER'}) async {
    final response = await _dio.get('/social/reviews/$targetId',
        queryParameters: {'targetType': targetType});
    final list = (response.data as List).map((e) => ReviewResponseDto.fromJson(e)).toList();
    state = state.copyWith(reviews: list);
  }

  Future<void> addReview(SocialActionRequest request) async {
    await _dio.post('/social/review', data: request.toJson());
    await getReviews(request.targetId, targetType: request.targetType ?? 'USER');
    await getUserStats(request.targetId);
  }

  Future<void> updateReview(String reviewId, String targetId, ReviewUpdateRequest request) async {
    await _dio.put('/social/review/$reviewId', data: request.toJson());
    await getReviews(targetId);
    await getUserStats(targetId);
  }

  Future<void> deleteReview(String reviewId, String targetId) async {
    await _dio.delete('/social/review/$reviewId');
    await getReviews(targetId);
    await getUserStats(targetId);
  }

  // ====================== STATS ======================
  Future<void> getUserStats(String userId) async {
    final response = await _dio.get('/social/stats/$userId');
    state = state.copyWith(stats: SocialStatsDto.fromJson(response.data));
  }
}

final socialProvider = StateNotifierProvider<SocialNotifier, SocialState>((ref) => SocialNotifier(ref));