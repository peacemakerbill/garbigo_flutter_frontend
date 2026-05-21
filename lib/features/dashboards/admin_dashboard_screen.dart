import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/models/user_model.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

import 'admin_widgets/admin_sidebar.dart';
import 'admin_widgets/user_management_content.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Dashboard',
    'User Management',
    'Reports',
    'Live Tracking',
    'Settings',
  ];

  Widget _buildProfileAvatar(UserModel? user, {double radius = 18}) {
    final hasImage = user?.profilePictureUrl.isNotEmpty == true;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: hasImage ? NetworkImage(user!.profilePictureUrl) : null,
      child: hasImage ? null : const Icon(Icons.person, color: Colors.grey),
    );
  }

  PreferredSizeWidget _buildAppBar(UserModel? user) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(_titles[_currentIndex]),
      actions: [
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildProfileAvatar(user, radius: 17),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
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
        return const _AdminHomeContent();
      case 1:
        return const UserManagementContent();
      case 2:
      case 3:
      case 4:
        return const Center(
          child: Text(
            'Feature Coming Soon...',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        );
      default:
        return const _AdminHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).user;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(user),
      body: Row(
        children: [
          if (isDesktop)
            AdminSidebar(
              currentIndex: _currentIndex,
              onIndexChanged: (index) => setState(() => _currentIndex = index),
            ),
          Expanded(child: _buildBody()),
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
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Tracking'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}

// ==================== ADMIN HOME CONTENT ====================
class _AdminHomeContent extends StatelessWidget {
  const _AdminHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, Admin!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Here\'s what\'s happening in your system today.'),
          const SizedBox(height: 40),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1100 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.6,
            children: [
              _buildStatCard(Icons.people, 'Total Users', '2,847', Colors.blue),
              _buildStatCard(Icons.recycling, 'Collections Today', '184', Colors.green),
              _buildStatCard(Icons.star, 'Avg Rating', '4.8', Colors.amber),
              _buildStatCard(Icons.warning, 'Pending Requests', '12', Colors.orange),
            ],
          ),

          const SizedBox(height: 40),
          const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // You can add more quick action cards here
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}