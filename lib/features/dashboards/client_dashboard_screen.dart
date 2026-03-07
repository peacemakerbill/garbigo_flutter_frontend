import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

class ClientDashboardScreen extends ConsumerWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Dashboard'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, ${userState.user?.firstName ?? 'Client'}!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 32),
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule, size: 40),
                title: const Text('Next Collection'),
                subtitle: Text(userState.user?.collectionSchedule ?? 'Not scheduled'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to schedule details
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.recycling, size: 40),
                title: const Text('Waste Preferences'),
                subtitle: Text(userState.user?.wastePreferences ?? 'Not set'),
                trailing: const Icon(Icons.edit),
                onTap: () => context.go('/profile'),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/profile'),
                  icon: const Icon(Icons.person),
                  label: const Text('Profile'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Request pickup
                  },
                  icon: const Icon(Icons.local_shipping),
                  label: const Text('Request Pickup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}