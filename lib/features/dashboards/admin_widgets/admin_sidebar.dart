import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

import '../../auth/models/user_model.dart';

class AdminSidebar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const AdminSidebar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;

    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.recycling, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text(
                  'Garbigo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Divider(),

          _SidebarButton(
            icon: Icons.dashboard,
            title: 'Dashboard',
            index: 0,
            currentIndex: currentIndex,
            onTap: onIndexChanged,
          ),
          _SidebarButton(
            icon: Icons.people,
            title: 'User Management',
            index: 1,
            currentIndex: currentIndex,
            onTap: onIndexChanged,
          ),
          _SidebarButton(
            icon: Icons.analytics,
            title: 'Reports',
            index: 2,
            currentIndex: currentIndex,
            onTap: onIndexChanged,
          ),
          _SidebarButton(
            icon: Icons.location_on,
            title: 'Live Tracking',
            index: 3,
            currentIndex: currentIndex,
            onTap: onIndexChanged,
          ),
          _SidebarButton(
            icon: Icons.settings,
            title: 'Settings',
            index: 4,
            currentIndex: currentIndex,
            onTap: onIndexChanged,
          ),

          const Spacer(),
          const Divider(),
          _ProfileSidebarButton(user: user),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SidebarButton({
    required this.icon,
    required this.title,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.green.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.green : Colors.grey.shade700),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSidebarButton extends StatelessWidget {
  final UserModel? user;

  const _ProfileSidebarButton({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final bool selected = GoRouterState.of(context).matchedLocation == '/profile';

    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.green.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: user?.profilePictureUrl.isNotEmpty == true
                  ? NetworkImage(user!.profilePictureUrl)
                  : null,
              child: user?.profilePictureUrl.isEmpty == true
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
            const SizedBox(width: 16),
            const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}