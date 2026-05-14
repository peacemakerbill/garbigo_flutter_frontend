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

  /// Called by GoRouter on every navigation event and whenever
  /// [notifyListeners] fires (i.e. when auth or user state changes).
  String? redirect(String matchedLocation) {
    final authState = _ref.read(authProvider);
    final userState = _ref.read(userProvider);

    final isLoggedIn =
        authState.token != null && authState.token!.isNotEmpty;
    final isAuthPath = ['/signin', '/signup', '/verify', '/forgot', '/reset']
        .contains(matchedLocation);

    // Not logged in → go to sign-in
    if (!isLoggedIn && !isAuthPath) return '/signin';

    // Logged in but on an auth page → go to the correct dashboard
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

    return null;
  }
}

final routerNotifierProvider = ChangeNotifierProvider<RouterNotifier>(
      (ref) => RouterNotifier(ref),
);