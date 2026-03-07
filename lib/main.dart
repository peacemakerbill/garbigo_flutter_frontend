import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/constants/app_themes.dart';
import 'package:garbigo_frontend/routing/app_router.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/location/providers/live_location_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state to start live location when user logs in as Collector
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.token != null && next.role == 'COLLECTOR') {
        // Start live location tracking when Collector logs in
        Future.delayed(const Duration(seconds: 2), () {
          ref.read(liveLocationProvider.notifier).requestPermissionAndStart();
        });
      }
    });

    return MaterialApp.router(
      title: 'Garbigo',
      theme: AppThemes.lightTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}