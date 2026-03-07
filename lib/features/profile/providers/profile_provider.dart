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

  Future<void> updateProfile({
    Map<String, dynamic>? data,  // ← Now optional (was required, causing the error)
    XFile? imageFile,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.usersBase));
      final token = ref.read(authProvider).token;
      if (token == null) throw 'Not authenticated';

      FormData formData = FormData.fromMap(data ?? {}); // Use empty map if no text data

      if (imageFile != null) {
        MultipartFile multipartFile;

        if (kIsWeb) {
          // Web: Use bytes
          final bytes = await imageFile.readAsBytes();
          multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: imageFile.name,
          );
        } else {
          // Mobile: Use file path
          multipartFile = await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.name,
          );
        }

        formData.files.add(MapEntry('profilePicture', multipartFile));
      }

      // Prevent empty request
      if (formData.fields.isEmpty && formData.files.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      await dio.put(
        '/profile',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Refresh current user
      await ref.read(userProvider.notifier).fetchCurrentUser();

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Profile updated successfully!',
      );
      Helpers.showToast('Profile updated successfully');
    } catch (e) {
      String msg = 'Failed to update profile';
      if (e is DioException) {
        msg = e.response?.data?['message'] ?? e.message ?? msg;
      }
      state = state.copyWith(isLoading: false, error: msg);
      Helpers.showToast(msg, isError: true);
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});