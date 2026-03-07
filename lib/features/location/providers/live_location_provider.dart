import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:garbigo_frontend/core/config/app_config.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';

class LiveLocationState {
  final Position? currentPosition;
  final bool isTracking;
  final bool permissionGranted;
  final String? error;

  LiveLocationState({
    this.currentPosition,
    this.isTracking = false,
    this.permissionGranted = false,
    this.error,
  });

  LiveLocationState copyWith({
    Position? currentPosition,
    bool? isTracking,
    bool? permissionGranted,
    String? error,
  }) {
    return LiveLocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      isTracking: isTracking ?? this.isTracking,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      error: error,
    );
  }
}

class LiveLocationNotifier extends StateNotifier<LiveLocationState> {
  LiveLocationNotifier(this.ref) : super(LiveLocationState());

  final Ref ref;
  StreamSubscription<Position>? _positionStream;

  Future<void> requestPermissionAndStart() async {
    state = state.copyWith(isTracking: true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(error: 'Location service disabled');
      return;
    }

    var permission = await Permission.location.request();
    if (permission.isDenied || permission.isPermanentlyDenied) {
      state = state.copyWith(error: 'Location permission denied');
      return;
    }

    state = state.copyWith(permissionGranted: true);

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: Duration(seconds: 30),
      ),
    ).listen(
          (Position position) {
        state = state.copyWith(currentPosition: position);
        _sendToBackend(position);
      },
      onError: (error) {
        state = state.copyWith(error: error.toString());
      },
    );
  }

  Future<void> _sendToBackend(Position position) async {
    final token = ref.read(authProvider).token;
    if (token == null) return;

    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.usersBase));
      await dio.post(
        '/live-location',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': position.timestamp.toIso8601String(),
        },
      );
    } catch (e) {
      // Silent — don't interrupt user
      print('Location send failed: $e');
    }
  }

  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    state = LiveLocationState();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}

final liveLocationProvider = StateNotifierProvider<LiveLocationNotifier, LiveLocationState>((ref) {
  final notifier = LiveLocationNotifier(ref);
  // Auto-start if user is Collector
  final role = ref.watch(authProvider).role;
  if (role == 'COLLECTOR') {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.requestPermissionAndStart();
    });
  }
  return notifier;
});