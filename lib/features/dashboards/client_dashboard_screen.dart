import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:garbigo_frontend/core/config/app_config.dart';
import 'package:garbigo_frontend/core/network/api_client.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';

import 'package:garbigo_frontend/features/auth/models/user_model.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

class ClientDashboardScreen extends ConsumerStatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  ConsumerState<ClientDashboardScreen> createState() =>
      _ClientDashboardScreenState();
}

class _ClientDashboardScreenState
    extends ConsumerState<ClientDashboardScreen> {
  int _currentIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String _searchQuery = '';

  final List<String> _titles = const [
    'Home',
    'Schedule Pickup',
    'History',
    'Profile',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// ---------------------------
  /// FETCH COLLECTORS
  /// ---------------------------
  Future<List<UserModel>> _fetchCollectors() async {
    try {
      final dio = ref.read(dioProvider);
      dio.options.baseUrl = AppConfig.baseUrl;

      final response = await dio.get(
        '/users/collectors',
        queryParameters:
        _searchQuery.isNotEmpty ? {'search': _searchQuery} : null,
      );

      final List<dynamic> data = response.data;

      return data
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      Helpers.showToast(
        'Failed to load collectors',
        isError: true,
      );

      return [];
    }
  }

  /// ---------------------------
  /// SEARCH DEBOUNCE
  /// ---------------------------
  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
          () {
        if (!mounted) return;

        setState(() {
          _searchQuery = value.trim();
        });
      },
    );
  }

  Future<void> _refreshDashboard() async {
    if (!mounted) return;

    setState(() {});
  }

  /// ---------------------------
  /// APP BAR
  /// ---------------------------
  PreferredSizeWidget _buildAppBar(UserModel? user) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        _titles[_currentIndex],
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.person,
            color: Colors.black,
          ),
          onPressed: () {
            context.go('/profile');
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.black,
          ),
          onPressed: () {
            Helpers.showLogoutDialog(
              context,
                  () => ref.read(authProvider.notifier).logout(),
            );
          },
        ),
      ],
    );
  }

  /// ---------------------------
  /// SIDEBAR BUTTON
  /// ---------------------------
  Widget _sidebarButton(
      IconData icon,
      String title,
      int index,
      ) {
    final bool selected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (!mounted) return;

        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? Colors.green.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------------------
  /// SIDEBAR
  /// ---------------------------
  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(
                  Icons.recycling,
                  color: Colors.green,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Garbigo',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          _sidebarButton(Icons.home, 'Home', 0),
          _sidebarButton(Icons.schedule, 'Schedule Pickup', 1),
          _sidebarButton(Icons.history, 'History', 2),
          _sidebarButton(Icons.person, 'Profile', 3),
        ],
      ),
    );
  }

  /// ---------------------------
  /// STAT CARD
  /// ---------------------------
  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 34,
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }

  /// ---------------------------
  /// COLLECTOR CARD
  /// ---------------------------
  Widget _collectorCard(UserModel collector) {
    return GestureDetector(
      onTap: () {
        context.go('/profile/${collector.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage:
              collector.profilePictureUrl.isNotEmpty
                  ? NetworkImage(collector.profilePictureUrl)
                  : null,
              child: collector.profilePictureUrl.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${collector.firstName} ${collector.lastName ?? ""}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    collector.email,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }

  /// ---------------------------
  /// HOME PAGE
  /// ---------------------------
  Widget _buildHomeContent(bool isTablet) {
    final user = ref.watch(userProvider).user;

    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.firstName ?? "Client"} 👋',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find trusted waste collectors near you',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),

            /// SEARCH
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search collectors...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    _searchController.clear();

                    if (!mounted) return;

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  child: const Icon(Icons.clear),
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// STATS
            GridView.count(
              crossAxisCount: isTablet ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  'Collectors',
                  '120+',
                  Icons.people,
                ),
                _buildStatCard(
                  'Pickups',
                  '58',
                  Icons.local_shipping,
                ),
                _buildStatCard(
                  'Recycled',
                  '1.2T',
                  Icons.recycling,
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Available Collectors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            FutureBuilder<List<UserModel>>(
              future: _fetchCollectors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final collectors = snapshot.data ?? [];

                if (collectors.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No collectors found'),
                    ),
                  );
                }

                return Column(
                  children: collectors
                      .map((collector) =>
                      _collectorCard(collector))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------------------
  /// BODY SWITCHER
  /// ---------------------------
  Widget _buildBody(bool isTablet) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent(isTablet);

      case 1:
        return const Center(
          child: Text(
            'Schedule Pickup\n\nComing Soon...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22),
          ),
        );

      case 2:
        return const Center(
          child: Text(
            'Pickup History\n\nComing Soon...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22),
          ),
        );

      case 3:
        return const Center(
          child: Text(
            'Profile Section\n\nUse top-right icon',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        );

      default:
        return _buildHomeContent(isTablet);
    }
  }

  /// ---------------------------
  /// MOBILE BOTTOM NAV
  /// ---------------------------
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (!mounted) return;

        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  /// ---------------------------
  /// MAIN BUILD
  /// ---------------------------
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).user;
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isDesktop = screenWidth > 900;
    final bool isTablet = screenWidth > 700;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(user),

      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),

          Expanded(
            child: _buildBody(isTablet),
          ),
        ],
      ),

      bottomNavigationBar:
      isDesktop ? null : _buildBottomNav(),
    );
  }
}