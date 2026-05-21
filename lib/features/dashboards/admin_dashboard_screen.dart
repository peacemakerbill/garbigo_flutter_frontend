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
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends ConsumerState<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    'Dashboard',
    'User Management',
    'Reports',
    'Live Tracking',
    'Settings',
  ];

  Widget _buildProfileAvatar(
      UserModel? user, {
        double radius = 18,
      }) {
    final hasImage =
        user?.profilePictureUrl.isNotEmpty == true;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage:
      hasImage
          ? NetworkImage(user!.profilePictureUrl)
          : null,
      child:
      hasImage
          ? null
          : Icon(
        Icons.person,
        color: Colors.grey.shade600,
        size: radius,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(UserModel? user) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(
        _titles[_currentIndex],
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _buildProfileAvatar(
              user,
              radius: 18,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.logout_rounded,
            color: Colors.black87,
          ),
          onPressed:
              () => Helpers.showLogoutDialog(
            context,
                () => ref
                .read(authProvider.notifier)
                .logout(),
          ),
        ),
        const SizedBox(width: 4),
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
        return const _ComingSoon();

      default:
        return const _AdminHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).user;

    final width = MediaQuery.of(context).size.width;

    final isDesktop = width >= 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(user),
      body: Row(
        children: [
          if (isDesktop)
            AdminSidebar(
              currentIndex: _currentIndex,
              onIndexChanged:
                  (index) => setState(
                    () => _currentIndex = index,
              ),
            ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 250,
              ),
              child: _buildBody(),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
      isDesktop ? null : _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF16A34A),
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        onTap:
            (index) => setState(
              () => _currentIndex = index,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_rounded),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ==================== RESPONSIVE HOME CONTENT ====================

class _AdminHomeContent extends StatelessWidget {
  const _AdminHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1100;
    final isDesktop = width >= 1100;

    final horizontalPadding =
    isMobile
        ? 14.0
        : isTablet
        ? 20.0
        : 28.0;

    final titleSize =
    isMobile
        ? 24.0
        : isTablet
        ? 30.0
        : 38.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // ================= HERO =================

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              isMobile ? 22 : 30,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                30,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF16A34A),
                  Color(0xFF15803D),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(
                    0.22,
                  ),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin 👋',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Monitor users, collections, analytics and platform activity in real time.',
                  style: TextStyle(
                    fontSize:
                    isMobile ? 14 : 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 26 : 34),

          // ================= OVERVIEW =================

          Row(
            children: [
              Text(
                'Overview',
                style: TextStyle(
                  fontSize:
                  isMobile ? 20 : 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 16 : 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              int crossAxisCount;
              double aspectRatio;
              double spacing;

              if (width >= 1600) {
                crossAxisCount = 4;
                aspectRatio = 1.7;
                spacing = 22;
              } else if (width >= 1200) {
                crossAxisCount = 4;
                aspectRatio = 1.45;
                spacing = 20;
              } else if (width >= 900) {
                crossAxisCount = 3;
                aspectRatio = 1.35;
                spacing = 18;
              } else if (width >= 600) {
                crossAxisCount = 2;
                aspectRatio = 1.28;
                spacing = 16;
              } else if (width >= 420) {
                crossAxisCount = 2;
                aspectRatio = 1.05;
                spacing = 12;
              } else {
                crossAxisCount = 1;
                aspectRatio = 1.9;
                spacing = 12;
              }

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspectRatio,
                children: const [
                  _StatCard(
                    icon: Icons.people_alt_rounded,
                    title: 'Total Users',
                    value: '2,847',
                    color: Color(0xFF3B82F6),
                  ),

                  _StatCard(
                    icon: Icons.recycling_rounded,
                    title: 'Collections Today',
                    value: '184',
                    color: Color(0xFF16A34A),
                  ),

                  _StatCard(
                    icon: Icons.star_rounded,
                    title: 'Avg Rating',
                    value: '4.8',
                    color: Color(0xFFF59E0B),
                  ),

                  _StatCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Pending Requests',
                    value: '12',
                    color: Color(0xFFF97316),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: isMobile ? 32 : 40),

          // ================= QUICK ACTIONS =================

          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: isMobile ? 16 : 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              int crossAxisCount;

              if (width >= 1200) {
                crossAxisCount = 4;
              } else if (width >= 800) {
                crossAxisCount = 3;
              } else if (width >= 500) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 1;
              }

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: const [
                  _QuickActionCard(
                    icon: Icons.people_alt_rounded,
                    title: 'Manage Users',
                  ),

                  _QuickActionCard(
                    icon: Icons.analytics_rounded,
                    title: 'View Reports',
                  ),

                  _QuickActionCard(
                    icon: Icons.location_on_rounded,
                    title: 'Track Trucks',
                  ),

                  _QuickActionCard(
                    icon: Icons.settings_rounded,
                    title: 'System Settings',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ==================== PREMIUM STAT CARD ====================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet =
        width >= 600 && width < 1100;

    final padding =
    isMobile ? 18.0 : 22.0;

    final iconSize =
    isMobile
        ? 24.0
        : isTablet
        ? 28.0
        : 34.0;

    final valueSize =
    isMobile
        ? 24.0
        : isTablet
        ? 30.0
        : 36.0;

    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 250,
      ),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          28,
        ),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(
              isMobile ? 10 : 14,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: color,
              size: iconSize,
            ),
          ),

          const Spacer(),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                color: Colors.black87,
                height: 1,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize:
              isMobile ? 13 : 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== QUICK ACTION CARD ====================

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickActionCard({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width <
            600;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        24,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          24,
        ),
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(
            isMobile ? 16 : 20,
          ),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(24),
            border: Border.all(
              color: Colors.grey.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.03,
                ),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  12,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF16A34A,
                  ).withOpacity(0.12),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Color(0xFF16A34A),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:
                    isMobile ? 14 : 16,
                    fontWeight:
                    FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== COMING SOON ====================

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width <
            600;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          padding: EdgeInsets.all(
            isMobile ? 28 : 40,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              30,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.04,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(
                  18,
                ),
                decoration: BoxDecoration(
                  color: Colors.green
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  size: 42,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Feature Coming Soon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:
                  isMobile ? 22 : 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'This module is currently under development and will be available soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:
                  isMobile ? 14 : 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}