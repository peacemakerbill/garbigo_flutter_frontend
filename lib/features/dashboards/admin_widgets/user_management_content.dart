import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

class UserManagementContent extends ConsumerStatefulWidget {
  const UserManagementContent({super.key});

  @override
  ConsumerState<UserManagementContent> createState() => _UserManagementContentState();
}

class _UserManagementContentState extends ConsumerState<UserManagementContent> {
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

    return Column(
      children: [
        // Search Bar
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

        // Content Area
        Expanded(
          child: Builder(
            builder: (context) {
              if (userState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userState.error != null) {
                return Center(
                  child: Text(
                    'Error: ${userState.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (userState.allUsers.isEmpty) {
                return const Center(child: Text('No users found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: userState.allUsers.length,
                itemBuilder: (context, index) {
                  final user = userState.allUsers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profilePictureUrl.isNotEmpty
                            ? NetworkImage(user.profilePictureUrl)
                            : null,
                        child: user.profilePictureUrl.isEmpty
                            ? Text(user.firstName?.isNotEmpty == true ? user.firstName![0] : '?')
                            : null,
                      ),
                      title: Text('${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email),
                          Text('Role: ${user.role}'),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (user.verified)
                                const Chip(
                                  label: Text('Verified'),
                                  backgroundColor: Colors.green,
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                              if (!user.active)
                                const Chip(
                                  label: Text('Inactive'),
                                  backgroundColor: Colors.red,
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                              if (user.archived)
                                const Chip(
                                  label: Text('Archived'),
                                  backgroundColor: Colors.grey,
                                ),
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
                              _showDeleteDialog(context, user.id, userNotifier);
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
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, String userId, UserNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ctx.pop();
              notifier.deleteUser(userId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}