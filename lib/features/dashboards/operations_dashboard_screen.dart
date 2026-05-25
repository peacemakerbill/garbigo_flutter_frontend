import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:garbigo_frontend/features/auth/models/user_model.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';

import 'operations_widgets/operations_sidebar.dart';
import 'operations_widgets/operations_home_content.dart';
import 'operations_widgets/operations_schedules_content.dart';
import 'operations_widgets/operations_routes_content.dart';
import 'operations_widgets/operations_collections_content.dart';
import 'operations_widgets/operations_reports_content.dart';

class OperationsDashboardScreen extends ConsumerStatefulWidget {
  const OperationsDashboardScreen({super.key});

  @override
  ConsumerState<OperationsDashboardScreen> createState() =>
      _OperationsDashboardScreenState();
}

class _OperationsDashboardScreenState
    extends ConsumerState<OperationsDashboardScreen> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    'Dashboard',
    'Schedules',
    'Routes',
    'Collections',
    'Reports',
  ];

  Widget _buildProfileAvatar(UserModel? user, {double radius = 18}) {
    final hasImage = user?.profilePictureUrl != null && user!.profilePictureUrl.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: hasImage ? NetworkImage(user.profilePictureUrl) : null,
      child: hasImage ? null : const Icon(Icons.person, color: Colors.grey, size: 20),
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

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const OperationsHomeContent();
      case 1:
        return const OperationsSchedulesContent();
      case 2:
        return const OperationsRoutesContent();
      case 3:
        return const OperationsCollectionsContent();
      case 4:
        return const OperationsReportsContent();
      default:
        return const OperationsHomeContent();
    }
  }

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
            OperationsSidebar(
              currentIndex: _currentIndex,
              onIndexChanged: (i) => setState(() => _currentIndex = i),
            ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(user),
    );
  }

  Widget _buildBottomNav(UserModel? user) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 5) {
          context.go('/profile');
          return;
        }
        setState(() => _currentIndex = index);
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedules'),
        const BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Routes'),
        const BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Collections'),
        const BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
        BottomNavigationBarItem(
          icon: _buildProfileAvatar(user, radius: 11),
          label: 'Profile',
        ),
      ],
    );
  }
}