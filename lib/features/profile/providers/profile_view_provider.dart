import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/config/app_config.dart';
import 'package:garbigo_frontend/core/network/api_client.dart';
import '../models/profile_view_dto.dart';

class ProfileViewState {
  final bool isLoading;
  final String? error;
  final ProfileViewStatsDto? stats;
  final List<ProfileViewDto> whoViewedMe;
  final List<ProfileViewDto> whoIViewed;

  ProfileViewState({
    this.isLoading = false,
    this.error,
    this.stats,
    this.whoViewedMe = const [],
    this.whoIViewed = const [],
  });

  ProfileViewState copyWith({
    bool? isLoading,
    String? error,
    ProfileViewStatsDto? stats,
    List<ProfileViewDto>? whoViewedMe,
    List<ProfileViewDto>? whoIViewed,
  }) {
    return ProfileViewState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      whoViewedMe: whoViewedMe ?? this.whoViewedMe,
      whoIViewed: whoIViewed ?? this.whoIViewed,
    );
  }
}

class ProfileViewNotifier extends StateNotifier<ProfileViewState> {
  ProfileViewNotifier(this.ref) : super(ProfileViewState());

  final Ref ref;

  Dio get _dio {
    final dio = ref.read(dioProvider);
    dio.options.baseUrl = AppConfig.baseUrl;
    return dio;
  }

  /// Record a profile view (called when someone visits a profile)
  Future<void> recordProfileView(String viewedUserId) async {
    try {
      await _dio.post('/profile-views/$viewedUserId');
    } catch (e) {
      debugPrint('Profile view recording failed (silent): $e');
    }
  }

  /// Load profile view statistics and lists for current user
  Future<void> loadProfileViews() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final statsRes = await _dio.get('/profile-views/my-stats');
      final whoViewedRes = await _dio.get('/profile-views/who-viewed-me');
      final whoIViewedRes = await _dio.get('/profile-views/who-i-viewed');

      state = state.copyWith(
        isLoading: false,
        stats: ProfileViewStatsDto.fromJson(statsRes.data),
        whoViewedMe: (whoViewedRes.data as List)
            .map((e) => ProfileViewDto.fromJson(e))
            .toList(),
        whoIViewed: (whoIViewedRes.data as List)
            .map((e) => ProfileViewDto.fromJson(e))
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile views',
      );
      debugPrint('Profile views load error: $e');
    }
  }
}

final profileViewProvider =
StateNotifierProvider<ProfileViewNotifier, ProfileViewState>(
      (ref) => ProfileViewNotifier(ref),
);