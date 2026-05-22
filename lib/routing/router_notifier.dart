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

    // IMPORTANT: Wait until session restoration is complete
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
      return isAuthPath ? null : '/signin';
    }

    // 3. Protected routes
    const protectedRoutes = [
      '/profile',
      '/dashboard/client',
      '/dashboard/collector',
      '/dashboard/operations',
      '/dashboard/finance',
      '/dashboard/support',
      '/admin/dashboard',
    ];

    final isProtectedRoute = protectedRoutes.any((route) =>
    matchedLocation == route || matchedLocation.startsWith('$route/'));

    if (isProtectedRoute) {
      return null; // Allow access
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