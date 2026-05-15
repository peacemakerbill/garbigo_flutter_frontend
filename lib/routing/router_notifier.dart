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

    if (authState.isRestoring) return null;

    final isLoggedIn = authState.token != null && authState.token!.isNotEmpty;
    final isAuthPath = ['/signin', '/signup', '/verify', '/forgot', '/reset']
        .contains(matchedLocation);

    // Not logged in → go to signin
    if (!isLoggedIn && !isAuthPath) {
      return '/signin';
    }

    // Logged in users trying to access auth pages → redirect to dashboard
    if (isLoggedIn && isAuthPath) {
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

    // === IMPORTANT: Allow these routes for logged-in users ===
    const allowedRoutes = [
      '/profile',
      '/profile/',
      '/dashboard/client',
      '/dashboard/collector',
      '/admin/dashboard',
      // Add more routes here as needed
    ];

    if (isLoggedIn && allowedRoutes.any((route) => matchedLocation.startsWith(route))) {
      return null; // Allow access
    }

    return null;
  }
}

final routerNotifierProvider = ChangeNotifierProvider<RouterNotifier>(
      (ref) => RouterNotifier(ref),
);