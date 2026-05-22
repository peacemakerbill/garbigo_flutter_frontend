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

    // Still restoring session → don't redirect
    if (authState.isRestoring) {
      return null;
    }

    final isLoggedIn = authState.token != null && authState.token!.isNotEmpty;
    final isVerified = authState.verified;

    // All allowed auth-related paths
    final isAuthPath = [
      '/signin',
      '/signup',
      '/verify',
      '/auth/verify',
      '/resend-verification',
      '/forgot',
      '/reset',
      '/auth/reset-password/confirm',
    ].contains(matchedLocation);

    // 1. Not logged in → force to signin (except auth pages)
    if (!isLoggedIn) {
      return isAuthPath ? null : '/signin';
    }

    // 2. Logged in BUT NOT VERIFIED → block access to dashboard
    if (isLoggedIn && !isVerified) {
      if (isAuthPath) {
        return null; // Allow auth pages
      }
      // Force unverified users back to signin
      return '/signin';
    }

    // 3. Verified user accessing protected routes
    const allowedRoutes = [
      '/profile',
      '/dashboard/client',
      '/dashboard/collector',
      '/dashboard/operations',
      '/dashboard/finance',
      '/dashboard/support',
      '/admin/dashboard',
      '/admin/users',
    ];

    final isAllowedRoute = allowedRoutes.any((route) =>
    matchedLocation == route || matchedLocation.startsWith('$route/'));

    if (isAllowedRoute) {
      return null;
    }

    // 4. Default dashboard redirect for verified users
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

    return null;
  }
}

final routerNotifierProvider = ChangeNotifierProvider<RouterNotifier>(
      (ref) => RouterNotifier(ref),
);