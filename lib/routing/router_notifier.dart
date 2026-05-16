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
    final isAuthPath = ['/signin', '/signup', '/verify', '/forgot', '/reset']
        .contains(matchedLocation);

    // 1. Unauthenticated users → force login
    if (!isLoggedIn) {
      return isAuthPath ? null : '/signin';
    }

    // 2. Protected routes that are always allowed when logged in
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
    matchedLocation == route ||
        matchedLocation.startsWith('$route/'));

    if (isAllowedRoute) {
      return null; // Allow access
    }

    // 3. Default dashboard redirect (only for root or auth pages)
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

    // Fallback: allow other routes
    return null;
  }
}

final routerNotifierProvider = ChangeNotifierProvider<RouterNotifier>(
      (ref) => RouterNotifier(ref),
);