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

import 'client_widgets/client_sidebar.dart';
import 'client_widgets/schedule_pickup_content.dart';
import 'client_widgets/pickup_history_content.dart';

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
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<List<UserModel>> _fetchCollectors() async {
    // If there is no token the user has logged out. Return silently so the
    // catch block never fires a toast against a cleared session.
    final token = ref.read(authProvider).token;
    if (token == null || token.isEmpty) return [];

    try {
      final dio = ref.read(dioProvider);
      dio.options.baseUrl = AppConfig.baseUrl;

      final response = await dio.get(
        '/users/collectors',
        queryParameters:
        _searchQuery.isNotEmpty ? {'search': _searchQuery} : null,
      );

      final List<dynamic> data = response.data;

      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      // Only show the error toast when we know the user is still logged in,
      // which prevents a stale in-flight request from toasting after logout.
      if (!mounted) return [];
      final stillLoggedIn = ref.read(authProvider).token != null;
      if (stillLoggedIn) {
        Helpers.showToast('Failed to load collectors', isError: true);
      }
      return [];
    }
  }

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

  Widget _buildProfileAvatar(
      UserModel? user, {
        double radius = 18,
      }) {
    final hasImage =
        user?.profilePictureUrl != null &&
            user!.profilePictureUrl.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage:
      hasImage ? NetworkImage(user.profilePictureUrl) : null,
      child: hasImage
          ? null
          : const Icon(
        Icons.person,
        color: Colors.grey,
        size: 20,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(UserModel? user) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        _currentIndex < _titles.length
            ? _titles[_currentIndex]
            : 'Profile',
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
            child: _buildProfileAvatar(
              user,
              radius: 15,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.black87,
          ),
          onPressed: () => Helpers.showLogoutDialog(
            context,
                () => ref.read(authProvider.notifier).logout(),
          ),
        ),
      ],
    );
  }

  // ==================== HOME CONTENT ====================

  Widget _buildHomeContent(BuildContext context) {
    final user = ref.watch(userProvider).user;

    final fullName =
    '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1100;

    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 24,
          vertical: isMobile ? 14 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== HERO ====================

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                isMobile ? 22 : 30,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF22C55E),
                    Color(0xFF15803D),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${fullName.isNotEmpty ? fullName : "Client"} 👋',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find trusted waste collectors near you',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isMobile ? 14 : 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 20 : 28),

            // ==================== SEARCH ====================

            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
              ),
              decoration: InputDecoration(
                hintText: 'Search collectors...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 20,
                  vertical: isMobile ? 14 : 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: isMobile ? 24 : 32),

            // ==================== OVERVIEW ====================

            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                int crossAxisCount;
                double childAspectRatio;
                double spacing;

                if (width >= 1400) {
                  crossAxisCount = 4;
                  childAspectRatio = 1.8;
                  spacing = 20;
                } else if (width >= 1100) {
                  crossAxisCount = 4;
                  childAspectRatio = 1.6;
                  spacing = 18;
                } else if (width >= 800) {
                  crossAxisCount = 3;
                  childAspectRatio = 1.45;
                  spacing = 16;
                } else if (width >= 600) {
                  crossAxisCount = 2;
                  childAspectRatio = 1.35;
                  spacing = 14;
                } else if (width >= 420) {
                  crossAxisCount = 2;
                  childAspectRatio = 1.28;
                  spacing = 12;
                } else {
                  crossAxisCount = 1;
                  childAspectRatio = 1.9;
                  spacing = 12;
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: childAspectRatio,
                  children: const [
                    _StatCard(
                      title: 'Active Collectors',
                      value: '120+',
                      icon: Icons.people_alt_rounded,
                      color: Color(0xFF22C55E),
                    ),
                    _StatCard(
                      title: 'Pickups Completed',
                      value: '58',
                      icon:
                      Icons.local_shipping_rounded,
                      color: Color(0xFF3B82F6),
                    ),
                    _StatCard(
                      title: 'Waste Recycled',
                      value: '1.2T',
                      icon: Icons.recycling_rounded,
                      color: Color(0xFF8B5CF6),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: isMobile ? 28 : 36),

            // ==================== COLLECTORS ====================

            const Text(
              'Available Collectors',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 16),

            FutureBuilder<List<UserModel>>(
              future: _fetchCollectors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child:
                      CircularProgressIndicator(),
                    ),
                  );
                }

                final collectors = snapshot.data ?? [];

                if (collectors.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No collectors found',
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount: collectors.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 14),
                  itemBuilder: (_, i) => _CollectorCard(
                    collector: collectors[i],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent(context);

      case 1:
        return const SchedulePickupContent();

      case 2:
        return const PickupHistoryContent();

      default:
        return _buildHomeContent(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).user;

    final isDesktop =
        MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(user),
      body: Row(
        children: [
          if (isDesktop)
            ClientSidebar(
              currentIndex: _currentIndex,
              onIndexChanged: (i) {
                setState(() {
                  _currentIndex = i;
                });
              },
            ),
          Expanded(
            child: _buildBody(context),
          ),
        ],
      ),
      bottomNavigationBar:
      isDesktop ? null : _buildBottomNav(user),
    );
  }

  Widget _buildBottomNav(UserModel? user) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 3) {
          context.go('/profile');
          return;
        }

        setState(() {
          _currentIndex = index;
        });
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'Schedule',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: _buildProfileAvatar(
            user,
            radius: 11,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}

// ==================== PREMIUM RESPONSIVE STAT CARD ====================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool mobile = width < 600;
    final bool tablet =
        width >= 600 && width < 1100;

    final double padding =
    mobile ? 18 : tablet ? 20 : 24;

    final double iconSize =
    mobile ? 24 : tablet ? 28 : 32;

    final double valueSize =
    mobile ? 24 : tablet ? 28 : 34;

    final double titleSize =
    mobile ? 13 : tablet ? 14 : 15;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(
              mobile ? 10 : 12,
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
                height: 1,
                letterSpacing: -1,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== COLLECTOR CARD ====================

class _CollectorCard extends StatelessWidget {
  final UserModel collector;

  const _CollectorCard({
    super.key,
    required this.collector,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;

    return GestureDetector(
      onTap: () =>
          context.go('/profile/${collector.id}'),
      child: Container(
        padding: EdgeInsets.all(
          isMobile ? 16 : 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: isMobile ? 28 : 34,
              backgroundImage:
              collector.profilePictureUrl
                  .isNotEmpty
                  ? NetworkImage(
                collector
                    .profilePictureUrl,
              )
                  : null,
              child:
              collector.profilePictureUrl
                  .isEmpty
                  ? Icon(
                Icons.person,
                size:
                isMobile ? 28 : 32,
              )
                  : null,
            ),

            SizedBox(width: isMobile ? 14 : 18),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${collector.firstName} ${collector.lastName}',
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w700,
                      fontSize:
                      isMobile ? 15 : 17,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    collector.email,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                      Colors.grey.shade600,
                      fontSize:
                      isMobile ? 13 : 14,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: isMobile ? 16 : 18,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }
}