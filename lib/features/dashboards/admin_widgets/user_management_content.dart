import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/features/auth/models/user_model.dart';
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
        // Header with Add Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
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
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showUserFormDialog(context, userNotifier),
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
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
                      onTap: () => _showUserDetailDialog(context, user), // ← Click card to view details
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
                                const Chip(label: Text('Verified'), backgroundColor: Colors.green, labelStyle: TextStyle(color: Colors.white)),
                              if (!user.active)
                                const Chip(label: Text('Inactive'), backgroundColor: Colors.red, labelStyle: TextStyle(color: Colors.white)),
                              if (user.archived)
                                const Chip(label: Text('Archived'), backgroundColor: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) {
                          if (action == 'edit') {
                            _showUserFormDialog(context, userNotifier, user: user);
                          } else if (action == 'delete') {
                            _showDeleteDialog(context, user.id, userNotifier);
                          } else {
                            userNotifier.toggleUserStatus(user.id, action);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'activate', child: Text('Activate')),
                          const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
                          const PopupMenuItem(value: 'verify', child: Text('Verify')),
                          const PopupMenuItem(value: 'unverify', child: Text('Unverify')),
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

  // ==================== USER DETAIL DIALOG ====================
  void _showUserDetailDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailDialog(user: user),
    );
  }

  // ==================== USER FORM DIALOG ====================
  void _showUserFormDialog(BuildContext context, UserNotifier notifier, {UserModel? user}) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        user: user,
        onSave: (data) {
          if (user == null) {
            notifier.createUser(data);
          } else {
            notifier.updateUser(user.id, data);
          }
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String userId, UserNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('Cancel')),
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

// ==================== NEW: USER DETAIL DIALOG ====================
class UserDetailDialog extends StatelessWidget {
  final UserModel user;

  const UserDetailDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('User Details'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: user.profilePictureUrl.isNotEmpty
                      ? NetworkImage(user.profilePictureUrl)
                      : null,
                  child: user.profilePictureUrl.isEmpty
                      ? Text(
                    user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 40),
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Full Name', '${user.firstName} ${user.middleName} ${user.lastName}'.trim()),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Phone', user.phoneNumber),
              _buildDetailRow('Role', user.role),
              _buildDetailRow('Address', user.homeAddress),
              _buildDetailRow('Verified', user.verified ? 'Yes' : 'No'),
              _buildDetailRow('Active', user.active ? 'Yes' : 'No'),
              _buildDetailRow('Archived', user.archived ? 'Yes' : 'No'),
              if (user.wastePreferences.isNotEmpty)
                _buildDetailRow('Waste Preferences', user.wastePreferences),
              if (user.collectionSchedule.isNotEmpty)
                _buildDetailRow('Collection Schedule', user.collectionSchedule),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== USER FORM DIALOG (Unchanged from previous) ====================
class UserFormDialog extends StatefulWidget {
  final UserModel? user;
  final Function(Map<String, dynamic>) onSave;

  const UserFormDialog({super.key, this.user, required this.onSave});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'CLIENT';
  bool _isLoading = false;

  final List<String> _roles = ['CLIENT', 'COLLECTOR', 'ADMIN'];

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      final u = widget.user!;
      _firstNameController.text = u.firstName;
      _middleNameController.text = u.middleName;
      _lastNameController.text = u.lastName;
      _emailController.text = u.email;
      _phoneController.text = u.phoneNumber;
      _addressController.text = u.homeAddress;
      _selectedRole = u.role;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'firstName': _firstNameController.text.trim(),
      'middleName': _middleNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'homeAddress': _addressController.text.trim(),
      'role': _selectedRole,
      if (widget.user == null && _passwordController.text.isNotEmpty)
        'password': _passwordController.text,
    };

    widget.onSave(data);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Create New User' : 'Edit User'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name'), validator: (v) => v?.trim().isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _middleNameController, decoration: const InputDecoration(labelText: 'Middle Name')),
                const SizedBox(height: 12),
                TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name'), validator: (v) => v?.trim().isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => v?.trim().isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
                const SizedBox(height: 12),
                TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Home Address'), maxLines: 2),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),
                if (widget.user == null) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) => v?.isEmpty == true ? 'Password is required for new users' : null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.user == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}