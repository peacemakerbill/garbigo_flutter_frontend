import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:garbigo_frontend/core/config/app_config.dart';
import 'package:garbigo_frontend/core/network/api_client.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/auth/models/user_model.dart';

class ClientDashboardScreen extends ConsumerStatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  ConsumerState<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends ConsumerState<ClientDashboardScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _titles = ['Home', 'Schedule', 'History', 'Profile'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<UserModel>> _fetchCollectors(String? search) async {
    try {
      final dio = ref.read(dioProvider);
      dio.options.baseUrl = AppConfig.baseUrl;

      final response = await dio.get(
        '/users/collectors',
        queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
      );

      final List<dynamic> data = response.data;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      Helpers.showToast('Failed to load collectors', isError: true);
      return [];
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: // Home
        return _buildHomeContent();
      case 1: // Schedule
        return const Center(child: Text('Schedule Pickup\n\nComing Soon...', style: TextStyle(fontSize: 24)));
      case 2: // History
        return const Center(child: Text('Pickup History\n\nComing Soon...', style: TextStyle(fontSize: 24)));
      case 3: // Profile
        return const Center(child: Text('Profile Section\n\nUse top right icon', style: TextStyle(fontSize: 20)));
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final user = ref.watch(userProvider).user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${user?.firstName ?? "Client"} 👋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find trusted waste collectors near you',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search collectors by name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              })
                  : null,
            ),
            onChanged: (value) => setState(() => _searchQuery = value.trim()),
          ),
          const SizedBox(height: 32),

          // Quick Actions
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQuickAction(Icons.schedule, 'Schedule', Colors.blue, () => setState(() => _currentIndex = 1)),
              const SizedBox(width: 12),
              _buildQuickAction(Icons.history, 'History', Colors.orange, () => setState(() => _currentIndex = 2)),
            ],
          ),
          const SizedBox(height: 32),

          // Collectors
          const Text('Available Collectors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          FutureBuilder<List<UserModel>>(
            future: _fetchCollectors(_searchQuery),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No collectors found')));
              }

              final collectors = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: collectors.length,
                itemBuilder: (context, index) {
                  final collector = collectors[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: collector.profilePictureUrl.isNotEmpty
                            ? NetworkImage(collector.profilePictureUrl)
                            : null,
                        child: collector.profilePictureUrl.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      title: Text('${collector.firstName} ${collector.lastName ?? ""}'),
                      subtitle: Text(collector.email),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/profile/${collector.id}'),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String title, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).user;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 900;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Garbigo'),
            actions: [
              // Profile Avatar - Top Right
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: user?.profilePictureUrl != null && user!.profilePictureUrl.isNotEmpty
                        ? NetworkImage(user.profilePictureUrl)
                        : null,
                    child: (user?.profilePictureUrl == null || user!.profilePictureUrl.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white, size: 22)
                        : null,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => Helpers.showLogoutDialog(context, () => ref.read(authProvider.notifier).logout()),
              ),
            ],
          ),

          // Sidebar for large screens
          body: isLargeScreen
              ? Row(
            children: [
              // Sidebar
              Container(
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildSidebarItem(Icons.home, 'Home', 0),
                    _buildSidebarItem(Icons.schedule, 'Schedule Pickup', 1),
                    _buildSidebarItem(Icons.history, 'My History', 2),
                    _buildSidebarItem(Icons.person, 'My Profile', 3),
                    const Spacer(),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.recycling, color: Colors.green),
                      title: Text('Garbigo'),
                      subtitle: Text('v1.0'),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(child: _buildBody()),
            ],
          )
              : _buildBody(), // Mobile: Just body

          // Bottom Navigation for small screens
          bottomNavigationBar: isLargeScreen
              ? null
              : BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.green : Colors.grey),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      tileColor: isSelected ? Colors.green.withOpacity(0.1) : null,
      onTap: () => setState(() => _currentIndex = index),
    );
  }
}