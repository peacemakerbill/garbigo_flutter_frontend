import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:garbigo_frontend/core/constants/app_themes.dart';
import 'package:garbigo_frontend/routing/app_router.dart';
import 'package:garbigo_frontend/routing/router_notifier.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/location/providers/live_location_provider.dart';

// Created once, never disposed — survives all rebuilds.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);
  return AppRouter.createRouter(notifier);
}, dependencies: [routerNotifierProvider]);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use read, not watch — router must never be recreated.
    final router = ref.read(routerProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.token != null && next.role == 'COLLECTOR') {
        Future.delayed(const Duration(seconds: 2), () {
          ref.read(liveLocationProvider.notifier).requestPermissionAndStart();
        });
      }
    });

    return MaterialApp.router(
      title: 'Garbigo',
      theme: AppThemes.lightTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}