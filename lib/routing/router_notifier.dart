import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
    _ref.listen<UserState>(userProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(String matchedLocation) {
    final authState = _ref.read(authProvider);
    final userState = _ref.read(userProvider);

    // If the application is still restoring the session, don't redirect anywhere yet
    if (authState.isRestoring) return null;

    final isLoggedIn = authState.token != null && authState.token!.isNotEmpty;
    final isAuthPath = ['/signin', '/signup', '/verify', '/forgot', '/reset']
        .contains(matchedLocation);

    // 1. Unauthenticated users must be forced to the authentication paths
    if (!isLoggedIn) {
      return isAuthPath ? null : '/signin';
    }

    // 2. Authenticated Whitelist: If logged in and hitting a declared valid route,
    // allow immediate access and bypass any dashboard role-routing logic below.
    const allowedRoutes = [
      '/profile',
      '/dashboard/client',
      '/dashboard/collector',
      '/dashboard/operations',
      '/dashboard/finance',
      '/dashboard/support',
      '/admin/dashboard',
    ];

    if (allowedRoutes.any((route) => matchedLocation == route || matchedLocation.startsWith('$route/'))) {
      return null;
    }

    // 3. Logged-in users attempting to hit auth landing pages, or caught in fallback paths ('/' or empty)
    if (isAuthPath || matchedLocation == '/' || matchedLocation.isEmpty) {
      final role = userState.user?.role ?? authState.role ?? 'CLIENT';
      switch (role) {
        case 'ADMIN':
          return '/admin/dashboard';
        case 'COLLECTOR':
          return '/dashboard/collector';
        case 'OPERATIONS':
          return '/dashboard/operations';
        case 'FINANCE':
          return '/dashboard/finance';
        case 'SUPPORT':
          return '/dashboard/support';
        case 'CLIENT':
        default:
          return '/dashboard/client';
      }
    }

    // Fallback safe pass-through for unhandled sub-routes
    return null;
  }
}

final routerNotifierProvider = ChangeNotifierProvider<RouterNotifier>(
      (ref) => RouterNotifier(ref),
);