import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/auth/models/user_model.dart';

class SupportSidebar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const SupportSidebar({
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
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.recycling, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Garbigo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(),
          _SidebarButton(icon: Icons.dashboard, title: 'Dashboard', index: 0, currentIndex: currentIndex, onTap: onIndexChanged),
          _SidebarButton(icon: Icons.support_agent, title: 'Tickets', index: 1, currentIndex: currentIndex, onTap: onIndexChanged),
          _SidebarButton(icon: Icons.people, title: 'Customers', index: 2, currentIndex: currentIndex, onTap: onIndexChanged),
          _SidebarButton(icon: Icons.book, title: 'Knowledge Base', index: 3, currentIndex: currentIndex, onTap: onIndexChanged),
          _SidebarButton(icon: Icons.analytics, title: 'Reports', index: 4, currentIndex: currentIndex, onTap: onIndexChanged),
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
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.green.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.green : Colors.grey),
            const SizedBox(width: 14),
            Text(title, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _ProfileSidebarButton extends StatelessWidget {
  final UserModel? user;

  const _ProfileSidebarButton({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final bool selected = GoRouterState.of(context).matchedLocation == '/profile';

    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.green.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _buildProfileAvatar(),
            const SizedBox(width: 14),
            const Text('Profile', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final hasImage = user?.profilePictureUrl != null && user!.profilePictureUrl.isNotEmpty;
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: hasImage ? NetworkImage(user!.profilePictureUrl) : null,
      child: hasImage ? null : const Icon(Icons.person, color: Colors.grey, size: 18),
    );
  }
}