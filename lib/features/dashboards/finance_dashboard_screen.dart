import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:garbigo_frontend/features/auth/models/user_model.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';

import 'finance_widgets/finance_sidebar.dart';
import 'finance_widgets/finance_home_content.dart';
import 'finance_widgets/finance_invoices_content.dart';
import 'finance_widgets/finance_payments_content.dart';
import 'finance_widgets/finance_reports_content.dart';

class FinanceDashboardScreen extends ConsumerStatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  ConsumerState<FinanceDashboardScreen> createState() =>
      _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends ConsumerState<FinanceDashboardScreen> {
  int _currentIndex = 0;

  final List<String> _titles = const [
    'Dashboard',
    'Invoices',
    'Payments',
    'Reports',
    'Settings',
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
        return const FinanceHomeContent();
      case 1:
        return const FinanceInvoicesContent();
      case 2:
        return const FinancePaymentsContent();
      case 3:
        return const FinanceReportsContent();
      case 4:
        return const _ComingSoon();
      default:
        return const FinanceHomeContent();
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
            FinanceSidebar(
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
        const BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Invoices'),
        const BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payments'),
        const BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
        const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        BottomNavigationBarItem(
          icon: _buildProfileAvatar(user, radius: 11),
          label: 'Profile',
        ),
      ],
    );
  }
}

// ==================== COMING SOON ====================
class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: EdgeInsets.all(isMobile ? 28 : 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.construction_rounded, size: 42, color: Colors.green),
              ),
              const SizedBox(height: 20),
              Text(
                'Feature Coming Soon',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: isMobile ? 22 : 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                'This module is currently under development.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}