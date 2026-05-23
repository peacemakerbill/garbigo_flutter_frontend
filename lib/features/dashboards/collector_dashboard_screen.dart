import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/auth/models/user_model.dart';

import 'collector_widgets/collector_sidebar.dart';
import 'collector_widgets/collector_home_content.dart';
import 'collector_widgets/active_jobs_content.dart';
import 'collector_widgets/collector_pickup_history_content.dart';

class CollectorDashboardScreen extends ConsumerStatefulWidget {
  const CollectorDashboardScreen({super.key});

  @override
  ConsumerState<CollectorDashboardScreen> createState() =>
      _CollectorDashboardScreenState();
}

class _CollectorDashboardScreenState
    extends ConsumerState<CollectorDashboardScreen> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    'Dashboard',
    'Active Jobs',
    'History',
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).user;
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(user),
      body: Row(
        children: [
          if (isDesktop)
            CollectorSidebar(
              currentIndex: _currentIndex,
              onIndexChanged: (i) {
                setState(() => _currentIndex = i);
              },
            ),
          Expanded(
            child: _buildBody(context),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(user),
    );
  }

  PreferredSizeWidget _buildAppBar(UserModel? user) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        _titles[_currentIndex],
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 19,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildProfileAvatar(user, radius: 15),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black87),
          onPressed: () => Helpers.showLogoutDialog(
            context,
                () => ref.read(authProvider.notifier).logout(),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(UserModel? user, {double radius = 18}) {
    final hasImage = user?.profilePictureUrl != null &&
        user!.profilePictureUrl.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: hasImage ? NetworkImage(user.profilePictureUrl) : null,
      child: hasImage
          ? null
          : const Icon(Icons.person, color: Colors.grey, size: 20),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return const CollectorHomeContent();
      case 1:
        return const ActiveJobsContent();
      case 2:
        return const CollectorPickupHistoryContent();
      default:
        return const CollectorHomeContent();
    }
  }

  Widget _buildBottomNav(UserModel? user) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index == 3) {
          context.go('/profile');
          return;
        }
        setState(() => _currentIndex = index);
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.work_rounded),
          label: 'Jobs',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: _buildProfileAvatar(user, radius: 11),
          label: 'Profile',
        ),
      ],
    );
  }
}