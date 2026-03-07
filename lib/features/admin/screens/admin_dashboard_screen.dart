import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Helpers.showLogoutDialog(context, () {
              authNotifier.logout();
            }),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, Admin ${userState.user?.firstName ?? ''}!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildAdminCard(
                  context,
                  icon: Icons.people,
                  title: 'User Management',
                  subtitle: 'View, edit, activate users',
                  onTap: () => context.go('/admin/users'),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.analytics,
                  title: 'Reports & Analytics',
                  subtitle: 'View system statistics',
                  onTap: () {
                    // Future feature
                    Helpers.showToast('Coming soon');
                  },
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.location_on,
                  title: 'Live Tracking',
                  subtitle: 'Monitor collectors',
                  onTap: () {
                    // Can navigate to a map view of all collectors
                    Helpers.showToast('Live map coming soon');
                  },
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.settings,
                  title: 'System Settings',
                  subtitle: 'Configure app settings',
                  onTap: () {
                    Helpers.showToast('Settings coming soon');
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.go('/profile'),
                icon: const Icon(Icons.person),
                label: const Text('My Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}