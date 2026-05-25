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

    if (authState.isRestoring) {
      return null;
    }

    final isLoggedIn = authState.token != null && authState.token!.isNotEmpty;
    final isVerified = authState.verified;

    final userRole = (userState.user?.role ?? authState.role ?? 'CLIENT').toUpperCase();

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

    if (!isLoggedIn) {
      return isAuthPath ? null : '/signin';
    }

    if (isLoggedIn && !isVerified) {
      return isAuthPath ? null : '/signin';
    }

    // Role-based dashboard protection
    final Map<String, List<String>> roleAllowedRoutes = {
      'ADMIN': ['/admin/dashboard', '/profile'],
      'SUPPORT': ['/dashboard/support', '/profile'],
      'OPERATIONS': ['/dashboard/operations', '/profile'],
      'FINANCE': ['/dashboard/finance', '/profile'],
      'COLLECTOR': ['/dashboard/collector', '/profile'],
      'CLIENT': ['/dashboard/client', '/profile'],
    };

    // Check if accessing a dashboard route
    if (matchedLocation.startsWith('/dashboard/') || matchedLocation == '/admin/dashboard') {
      final allowedRoutes = roleAllowedRoutes[userRole] ?? roleAllowedRoutes['CLIENT']!;

      bool isAllowed = allowedRoutes.any((route) =>
      matchedLocation == route || matchedLocation.startsWith('$route/'));

      if (!isAllowed) {
        // Redirect to user's correct dashboard
        switch (userRole) {
          case 'ADMIN':
            return '/admin/dashboard';
          case 'SUPPORT':
            return '/dashboard/support';
          case 'OPERATIONS':
            return '/dashboard/operations';
          case 'FINANCE':
            return '/dashboard/finance';
          case 'COLLECTOR':
            return '/dashboard/collector';
          case 'CLIENT':
          default:
            return '/dashboard/client';
        }
      }
    }

    // Allow profile for all logged-in users
    if (matchedLocation == '/profile' || matchedLocation.startsWith('/profile/')) {
      return null;
    }

    // Default redirect for root and auth paths
    if (isAuthPath || matchedLocation == '/' || matchedLocation.isEmpty) {
      switch (userRole) {
        case 'ADMIN':
          return '/admin/dashboard';
        case 'SUPPORT':
          return '/dashboard/support';
        case 'OPERATIONS':
          return '/dashboard/operations';
        case 'FINANCE':
          return '/dashboard/finance';
        case 'COLLECTOR':
          return '/dashboard/collector';
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