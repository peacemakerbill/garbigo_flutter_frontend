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
        // Enhanced Header
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email or phone...',
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        userNotifier.getAllUsers();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onSubmitted: (value) => userNotifier.getAllUsers(search: value),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showUserFormDialog(context, userNotifier),
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Add New User'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        userState.error!,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => userNotifier.getAllUsers(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (userState.allUsers.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No users found', style: TextStyle(fontSize: 18)),
                      Text('Try adjusting your search', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: userState.allUsers.length,
                itemBuilder: (context, index) {
                  final user = userState.allUsers[index];
                  return _buildUserCard(context, user, userNotifier);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== ENHANCED USER CARD ====================
  Widget _buildUserCard(BuildContext context, UserModel user, UserNotifier notifier) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showUserDetailDialog(context, user),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundImage: user.profilePictureUrl.isNotEmpty
                    ? NetworkImage(user.profilePictureUrl)
                    : null,
                child: user.profilePictureUrl.isEmpty
                    ? Text(
                  user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )
                    : null,
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}'.trim(),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(user.email, style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStatusChip(user.role, Colors.blue),
                        const SizedBox(width: 8),
                        if (user.verified) _buildStatusChip('Verified', Colors.green),
                        if (!user.active) _buildStatusChip('Inactive', Colors.red),
                        if (user.archived) _buildStatusChip('Archived', Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (action) {
                  if (action == 'edit') {
                    _showUserFormDialog(context, notifier, user: user);
                  } else if (action == 'delete') {
                    _showDeleteDialog(context, user.id, notifier);
                  } else {
                    notifier.toggleUserStatus(user.id, action);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit User')),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
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
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
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

// ==================== USER DETAIL DIALOG (Enhanced) ====================
class UserDetailDialog extends StatelessWidget {
  final UserModel user;

  const UserDetailDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundImage: user.profilePictureUrl.isNotEmpty
                    ? NetworkImage(user.profilePictureUrl)
                    : null,
                child: user.profilePictureUrl.isEmpty
                    ? Text(
                  user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                )
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                '${user.firstName} ${user.middleName} ${user.lastName}'.trim(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(user.email, style: const TextStyle(color: Colors.grey)),
              const Divider(height: 32),

              _buildDetailRow(Icons.badge_rounded, 'Role', user.role),
              _buildDetailRow(Icons.phone_rounded, 'Phone', user.phoneNumber),
              _buildDetailRow(Icons.location_on_rounded, 'Address', user.homeAddress),
              _buildDetailRow(Icons.verified_user_rounded, 'Verified', user.verified ? 'Yes' : 'No'),
              _buildDetailRow(Icons.check_circle_rounded, 'Active', user.active ? 'Yes' : 'No'),
              _buildDetailRow(Icons.archive_rounded, 'Archived', user.archived ? 'Yes' : 'No'),

              if (user.wastePreferences.isNotEmpty)
                _buildDetailRow(Icons.eco_rounded, 'Waste Preferences', user.wastePreferences),
              if (user.collectionSchedule.isNotEmpty)
                _buildDetailRow(Icons.schedule_rounded, 'Collection Schedule', user.collectionSchedule),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 16),
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
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

// ==================== USER FORM DIALOG ====================
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
      if (widget.user == null && _passwordController.text.trim().isNotEmpty)
        'password': _passwordController.text.trim(),
    };

    widget.onSave(data);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.user == null ? 'Create New User' : 'Edit User',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Form Fields with better spacing and styling
                  TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name'), validator: (v) => v?.trim().isEmpty == true ? 'Required' : null),
                  const SizedBox(height: 14),
                  TextFormField(controller: _middleNameController, decoration: const InputDecoration(labelText: 'Middle Name')),
                  const SizedBox(height: 14),
                  TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name'), validator: (v) => v?.trim().isEmpty == true ? 'Required' : null),
                  const SizedBox(height: 14),
                  TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email Address'), keyboardType: TextInputType.emailAddress, validator: (v) => v?.trim().isEmpty == true ? 'Required' : null),
                  const SizedBox(height: 14),
                  TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
                  const SizedBox(height: 14),
                  TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Home Address'), maxLines: 2),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                    onChanged: (val) => setState(() => _selectedRole = val!),
                  ),

                  if (widget.user == null) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) => v?.trim().isEmpty == true ? 'Password is required' : null,
                    ),
                  ],

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _save,
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(widget.user == null ? 'Create User' : 'Update User'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}