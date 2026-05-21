import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).getAllUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => userNotifier.getAllUsers(search: _searchController.text),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name, email, or phone',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    userNotifier.getAllUsers();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (value) => userNotifier.getAllUsers(search: value),
            ),
          ),
          if (userState.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (userState.error != null)
            Expanded(child: Center(child: Text('Error: ${userState.error}', style: const TextStyle(color: Colors.red))))
          else if (userState.allUsers.isEmpty)
              const Expanded(child: Center(child: Text('No users found')))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: userState.allUsers.length,
                  itemBuilder: (context, index) {
                    final user = userState.allUsers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.profilePictureUrl.isNotEmpty ? NetworkImage(user.profilePictureUrl) : null,
                          child: user.profilePictureUrl.isEmpty ? Text(user.firstName[0]) : null,
                        ),
                        title: Text('${user.firstName} ${user.lastName}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            Text('Role: ${user.role}'),
                            Row(
                              children: [
                                if (user.verified) const Chip(label: Text('Verified'), backgroundColor: Colors.green),
                                if (!user.active) const Chip(label: Text('Inactive'), backgroundColor: Colors.red),
                                if (user.archived) const Chip(label: Text('Archived'), backgroundColor: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            switch (action) {
                              case 'activate':
                                userNotifier.toggleUserStatus(user.id, 'activate');
                                break;
                              case 'deactivate':
                                userNotifier.toggleUserStatus(user.id, 'deactivate');
                                break;
                              case 'verify':
                                userNotifier.toggleUserStatus(user.id, 'verify');
                                break;
                              case 'unverify':
                                userNotifier.toggleUserStatus(user.id, 'unverify');
                                break;
                              case 'archive':
                                userNotifier.toggleUserStatus(user.id, 'archive');
                                break;
                              case 'unarchive':
                                userNotifier.toggleUserStatus(user.id, 'unarchive');
                                break;
                              case 'delete':
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete User'),
                                    content: const Text('Are you sure? This cannot be undone.'),
                                    actions: [
                                      TextButton(onPressed: () => ctx.pop(), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () {
                                          ctx.pop();
                                          userNotifier.deleteUser(user.id);
                                        },
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'activate', child: Text('Activate')),
                            const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
                            const PopupMenuItem(value: 'verify', child: Text('Verify Email')),
                            const PopupMenuItem(value: 'unverify', child: Text('Unverify Email')),
                            const PopupMenuItem(value: 'archive', child: Text('Archive')),
                            const PopupMenuItem(value: 'unarchive', child: Text('Unarchive')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}