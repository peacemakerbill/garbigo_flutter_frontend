import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/network/api_client.dart';
import '../models/social_action_request.dart';
import '../models/user_summary_dto.dart';
import '../models/review_response_dto.dart';
import '../models/follow_check_dto.dart';
import '../models/like_check_dto.dart';
import '../models/social_stats_dto.dart';

class SocialState {
  final bool isLoading;
  final String? error;

  SocialState({this.isLoading = false, this.error});

  SocialState copyWith({bool? isLoading, String? error}) {
    return SocialState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
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
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> unfollow(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.delete('/social/follow/$userId');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<List<UserSummaryDto>> getFollowers(String userId) async {
    final response = await _dio.get('/social/followers/$userId');
    return (response.data as List)
        .map((json) => UserSummaryDto.fromJson(json))
        .toList();
  }

  Future<List<UserSummaryDto>> getFollowing(String userId) async {
    final response = await _dio.get('/social/following/$userId');
    return (response.data as List)
        .map((json) => UserSummaryDto.fromJson(json))
        .toList();
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

  Future<List<UserSummaryDto>> getUsersWhoLiked(
      String targetId, {
        String? targetType,
      }) async {
    final response = await _dio.get('/social/likes/$targetId', queryParameters: {
      if (targetType != null) 'targetType': targetType.toUpperCase(),
    });
    return (response.data as List)
        .map((json) => UserSummaryDto.fromJson(json))
        .toList();
  }

  // ====================== REVIEW ======================

  Future<void> addReview(SocialActionRequest request) async {
    await _dio.post('/social/review', data: request.toJson());
  }

  Future<void> updateReview(String reviewId, int rating, String? comment) async {
    await _dio.put('/social/review/$reviewId', data: {
      'rating': rating,
      'comment': comment,
    });
  }

  Future<void> deleteReview(String reviewId) async {
    await _dio.delete('/social/review/$reviewId');
  }

  Future<List<ReviewResponseDto>> getReviews(
      String targetId, {
        String? targetType,
      }) async {
    final response = await _dio.get('/social/reviews/$targetId', queryParameters: {
      if (targetType != null) 'targetType': targetType.toUpperCase(),
    });
    return (response.data as List)
        .map((json) => ReviewResponseDto.fromJson(json))
        .toList();
  }

  Future<List<UserSummaryDto>> getUsersWhoReviewed(
      String targetId, {
        String? targetType,
      }) async {
    final response = await _dio.get('/social/reviewers/$targetId', queryParameters: {
      if (targetType != null) 'targetType': targetType.toUpperCase(),
    });
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