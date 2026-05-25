import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

class AdminHomeContent extends ConsumerWidget {
  const AdminHomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;

    final fullName =
    '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1100;
    final isDesktop = width >= 1100;

    final horizontalPadding =
    isMobile ? 14.0 : isTablet ? 20.0 : 28.0;

    final titleSize = isMobile ? 24.0 : isTablet ? 30.0 : 38.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HERO =================
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 22 : 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF16A34A), Color(0xFF15803D)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.22),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${fullName.isNotEmpty ? fullName : "Admin"} 👋',
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
                    fontSize: isMobile ? 14 : 16,
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
                  fontSize: isMobile ? 20 : 24,
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
                physics: const NeverScrollableScrollPhysics(),
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
              int crossAxisCount = width >= 1200
                  ? 4
                  : width >= 800
                  ? 3
                  : width >= 500
                  ? 2
                  : 1;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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

// ==================== STAT CARD ====================
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
    final isTablet = width >= 600 && width < 1100;

    final padding = isMobile ? 18.0 : 22.0;
    final iconSize = isMobile ? 24.0 : isTablet ? 28.0 : 34.0;
    final valueSize = isMobile ? 24.0 : isTablet ? 30.0 : 36.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: iconSize),
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
              fontSize: isMobile ? 13 : 15,
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
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
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
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