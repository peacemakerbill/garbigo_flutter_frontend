import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

// Auth Screens
import 'package:garbigo_frontend/features/auth/screens/signin_screen.dart';
import 'package:garbigo_frontend/features/auth/screens/signup_screen.dart';
import 'package:garbigo_frontend/features/auth/screens/verify_email_screen.dart';
import 'package:garbigo_frontend/features/auth/screens/forgot_password_screen.dart';
import 'package:garbigo_frontend/features/auth/screens/reset_password_screen.dart';

// Profile & Social
import 'package:garbigo_frontend/features/profile/screens/profile_screen.dart';
import 'package:garbigo_frontend/features/social/screens/other_user_profile_screen.dart';

// Admin
import 'package:garbigo_frontend/features/admin/screens/admin_dashboard_screen.dart';
import 'package:garbigo_frontend/features/admin/screens/user_management_screen.dart';

// Dashboards
import 'package:garbigo_frontend/features/dashboards/client_dashboard_screen.dart';
import 'package:garbigo_frontend/features/dashboards/collector_dashboard_screen.dart';
import 'package:garbigo_frontend/features/dashboards/operations_dashboard_screen.dart';
import 'package:garbigo_frontend/features/dashboards/finance_dashboard_screen.dart';
import 'package:garbigo_frontend/features/dashboards/support_dashboard_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/signin',
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final authState = container.read(authProvider);
      final userState = container.read(userProvider);

      final isLoggedIn = authState.token != null && authState.token!.isNotEmpty;
      final isAuthPath = ['/signin', '/signup', '/verify', '/forgot', '/reset']
          .contains(state.matchedLocation);

      // Not logged in → redirect to signin
      if (!isLoggedIn && !isAuthPath) {
        return '/signin';
      }

      // Logged in but trying to access auth pages → redirect to dashboard
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
    },
    routes: [
      // ====================== AUTH ROUTES ======================
      GoRoute(path: '/signin', builder: (context, state) => const SigninScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),

      GoRoute(
        path: '/verify',
        builder: (context, state) => VerifyEmailScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),

      GoRoute(path: '/forgot', builder: (context, state) => const ForgotPasswordScreen()),

      GoRoute(
        path: '/reset',
        builder: (context, state) => ResetPasswordScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),

      // ====================== PROFILE ROUTES ======================
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Other User's Profile (Social Feature)
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) => OtherUserProfileScreen(
          userId: state.pathParameters['id']!,
        ),
      ),

      // ====================== ADMIN ROUTES ======================
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagementScreen(),
      ),

      // ====================== DASHBOARDS ======================
      GoRoute(
        path: '/dashboard/client',
        builder: (context, state) => const ClientDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/collector',
        builder: (context, state) => const CollectorDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/operations',
        builder: (context, state) => const OperationsDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/finance',
        builder: (context, state) => const FinanceDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/support',
        builder: (context, state) => const SupportDashboardScreen(),
      ),
    ],
  );
}