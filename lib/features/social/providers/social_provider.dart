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

  SocialState({
    this.isLoading = false,
    this.error,
    this.followingCache = const {},
  });

  SocialState copyWith({
    bool? isLoading,
    String? error,
    Map<String, bool>? followingCache,
  }) {
    return SocialState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      followingCache: followingCache ?? this.followingCache,
    );
  }
}

class SocialNotifier extends StateNotifier<SocialState> {
  SocialNotifier(this.ref) : super(SocialState());

  final Ref ref;
  Dio get _dio => ref.read(dioProvider);

  // ====================== FOLLOW ======================
  Future<void> follow(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.post('/social/follow/$userId');
      final newCache = Map<String, bool>.from(state.followingCache);
      newCache[userId] = true;
      state = state.copyWith(isLoading: false, followingCache: newCache);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> unfollow(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.delete('/social/follow/$userId');
      final newCache = Map<String, bool>.from(state.followingCache);
      newCache[userId] = false;
      state = state.copyWith(isLoading: false, followingCache: newCache);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<List<UserSummaryDto>> getFollowers(String userId) async {
    final response = await _dio.get('/social/followers/$userId');
    return (response.data as List).map((json) => UserSummaryDto.fromJson(json)).toList();
  }

  Future<List<UserSummaryDto>> getFollowing(String userId) async {
    final response = await _dio.get('/social/following/$userId');
    return (response.data as List).map((json) => UserSummaryDto.fromJson(json)).toList();
  }

  Future<FollowCheckDto> isFollowing(String userId) async {
    final response = await _dio.get('/social/is-following/$userId');
    return FollowCheckDto.fromJson(response.data);
  }

  // ====================== LIKE ======================
  Future<void> like(String targetId, {String? targetType}) async {
    await _dio.post('/social/like', data: {
      'targetId': targetId,
      'targetType': targetType?.toUpperCase() ?? 'USER',
    });
  }

  Future<void> unlike(String targetId, {String? targetType}) async {
    await _dio.delete('/social/like', data: {
      'targetId': targetId,
      'targetType': targetType?.toUpperCase() ?? 'USER',
    });
  }

  Future<LikeCheckDto> isLiked(String targetId, {String? targetType}) async {
    final response = await _dio.get('/social/is-liked', queryParameters: {
      'targetId': targetId,
      if (targetType != null) 'targetType': targetType.toUpperCase(),
    });
    return LikeCheckDto.fromJson(response.data);
  }

  Future<List<UserSummaryDto>> getUsersWhoLiked(String targetId, {String? targetType}) async {
    final response = await _dio.get('/social/likes/$targetId', queryParameters: {
      if (targetType != null) 'targetType': targetType.toUpperCase(),
    });
    return (response.data as List).map((json) => UserSummaryDto.fromJson(json)).toList();
  }

  // ====================== REVIEW ======================
  Future<void> addReview(SocialActionRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.post('/social/review', data: request.toJson());
      state = state.copyWith(isLoading: false);
    } catch (e) {
      String msg = "Failed to post review";
      if (e is DioException) msg = e.response?.data?.toString() ?? e.message ?? msg;
      state = state.copyWith(isLoading: false, error: msg);
      rethrow;
    }
  }

  Future<void> updateReview(String reviewId, ReviewUpdateRequest request) async {
    await _dio.put('/social/review/$reviewId', data: {
      'rating': request.rating,
      'comment': request.comment,
    });
  }

  Future<void> deleteReview(String reviewId) async {
    await _dio.delete('/social/review/$reviewId');
  }

  Future<List<ReviewResponseDto>> getReviews(String targetId, {String? targetType}) async {
    final response = await _dio.get('/social/reviews/$targetId',
        queryParameters: targetType != null ? {'targetType': targetType.toUpperCase()} : null);
    return (response.data as List)
        .map((json) => ReviewResponseDto.fromJson(json))
        .toList();
  }

  Future<List<UserSummaryDto>> getUsersWhoReviewed(String targetId, {String? targetType}) async {
    final response = await _dio.get('/social/reviewers/$targetId',
        queryParameters: targetType != null ? {'targetType': targetType.toUpperCase()} : null);
    return (response.data as List)
        .map((json) => UserSummaryDto.fromJson(json))
        .toList();
  }

  // ====================== STATS ======================
  Future<SocialStatsDto> getUserStats(String userId) async {
    final response = await _dio.get('/social/stats/$userId');
    return SocialStatsDto.fromJson(response.data);
  }
}

final socialProvider = StateNotifierProvider<SocialNotifier, SocialState>(
      (ref) => SocialNotifier(ref),
);