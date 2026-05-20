import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garbigo_frontend/core/config/app_config.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  ProfileState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this.ref) : super(ProfileState());

  final Ref ref;

  /// Upload profile picture instantly when user selects image
  Future<void> updateProfilePicture(XFile imageFile) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
      final token = ref.read(authProvider).token;
      if (token == null) throw Exception('Not authenticated');

      final formData = FormData();

      MultipartFile multipartFile;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes, filename: imageFile.name);
      } else {
        multipartFile = await MultipartFile.fromFile(imageFile.path, filename: imageFile.name);
      }

      formData.files.add(MapEntry('profilePicture', multipartFile));

      await dio.put(
        '/users/profile/picture',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      await ref.read(userProvider.notifier).fetchCurrentUser();

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Profile picture updated successfully',
      );
      Helpers.showToast('Profile picture updated');
    } catch (e) {
      String msg = 'Failed to update profile picture';
      if (e is DioException) {
        msg = e.response?.data?['message']?.toString() ??
            e.response?.data?['error']?.toString() ??
            e.message ?? msg;
      }
      state = state.copyWith(isLoading: false, error: msg);
      Helpers.showToast(msg, isError: true);
    }
  }

  /// Update only text fields (used by Save Changes button)
  Future<void> updateProfileData(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
      final token = ref.read(authProvider).token;
      if (token == null) throw Exception('Not authenticated');

      final updateData = data.map((key, value) =>
          MapEntry(key, value?.toString().trim()));

      await dio.put(
        '/users/profile',
        data: updateData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      await ref.read(userProvider.notifier).fetchCurrentUser();

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Profile updated successfully',
      );
      Helpers.showToast('Profile updated successfully');
    } catch (e) {
      String msg = 'Update failed';
      if (e is DioException) {
        msg = e.response?.data?['message']?.toString() ??
            e.response?.data?['error']?.toString() ??
            e.message ?? msg;
      }
      state = state.copyWith(isLoading: false, error: msg);
      Helpers.showToast(msg, isError: true);
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
      (ref) => ProfileNotifier(ref),
);