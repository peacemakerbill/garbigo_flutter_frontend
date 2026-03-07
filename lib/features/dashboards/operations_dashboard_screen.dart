import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';

class OperationsDashboardScreen extends ConsumerWidget {
  const OperationsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Helpers.showLogoutDialog(context, () {
              authNotifier.logout();
            }),
          ),
        ],
      ),
      body: const Center(
        child: Text('Operations Dashboard - Manage schedules, routes, and collections'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/profile'),
        child: const Icon(Icons.person),
      ),
    );
  }
}