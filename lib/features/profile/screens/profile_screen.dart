import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/profile/providers/profile_provider.dart';
import 'package:garbigo_frontend/features/social/providers/social_provider.dart';

import '../../../core/utils/helpers.dart';
import '../../auth/models/user_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  XFile? _selectedImage;

  // Controllers
  late TextEditingController _firstNameCtrl;
  late TextEditingController _middleNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _wastePrefCtrl;
  late TextEditingController _scheduleCtrl;

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  void _initializeControllers() {
    final user = ref.read(userProvider).user;
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _middleNameCtrl = TextEditingController(text: user?.middleName ?? '');
    _lastNameCtrl = TextEditingController(text: user?.lastName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    _addressCtrl = TextEditingController(text: user?.homeAddress ?? '');
    _wastePrefCtrl = TextEditingController(text: user?.wastePreferences ?? '');
    _scheduleCtrl = TextEditingController(text: user?.collectionSchedule ?? '');
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    try {
      await ref.read(userProvider.notifier).fetchCurrentUser();

      if (!mounted) return;

      final user = ref.read(userProvider).user;
      if (user != null) {
        setState(() => _currentUserId = user.id);

        if (_currentUserId != null) {
          ref.read(socialProvider(_currentUserId!).notifier).refreshAll(_currentUserId!);
        }

        _syncControllers(user);
      }
    } catch (e) {
      if (mounted) Helpers.showToast('Failed to load profile', isError: true);
    }
  }

  void _syncControllers(UserModel user) {
    _firstNameCtrl.text = user.firstName ?? '';
    _middleNameCtrl.text = user.middleName ?? '';
    _lastNameCtrl.text = user.lastName ?? '';
    _phoneCtrl.text = user.phoneNumber ?? '';
    _addressCtrl.text = user.homeAddress ?? '';
    _wastePrefCtrl.text = user.wastePreferences ?? '';
    _scheduleCtrl.text = user.collectionSchedule ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (image != null && mounted) {
      setState(() => _selectedImage = image);
      await ref.read(profileProvider.notifier).updateProfilePicture(image);

      if (mounted) {
        setState(() => _selectedImage = null);
      }
    }
  }

  ImageProvider? _getProfileImageProvider(UserModel? user) {
    if (user?.profilePictureUrl != null && user!.profilePictureUrl.isNotEmpty) {
      return NetworkImage(user.profilePictureUrl);
    }
    return null;
  }

  Future<void> _saveChanges() async {
    if (!mounted) return;

    final updateData = {
      'firstName': _firstNameCtrl.text.trim(),
      'middleName': _middleNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'phoneNumber': _phoneCtrl.text.trim(),
      'homeAddress': _addressCtrl.text.trim(),
      'wastePreferences': _wastePrefCtrl.text.trim(),
      'collectionSchedule': _scheduleCtrl.text.trim(),
    };

    updateData.removeWhere((key, value) => value == null || value.isEmpty);

    if (updateData.isEmpty) {
      Helpers.showToast('No changes to save');
      return;
    }

    await ref.read(profileProvider.notifier).updateProfileData(updateData);

    if (mounted) {
      setState(() => _isEditing = false);
    }
  }

  void _cancelEditing() {
    if (!mounted) return;
    final user = ref.read(userProvider).user;
    if (user != null) _syncControllers(user);

    setState(() => _isEditing = false);
  }

  // Updated: Proper navigation based on user role
  void _navigateToDashboard() {
    final role = ref.read(authProvider).role?.toUpperCase() ?? 'CLIENT';

    switch (role) {
      case 'ADMIN':
        context.go('/admin/dashboard');
        break;
      case 'COLLECTOR':
        context.go('/dashboard/collector');
        break;
      case 'OPERATIONS':
        context.go('/dashboard/operations');
        break;
      case 'FINANCE':
        context.go('/dashboard/finance');
        break;
      case 'SUPPORT':
        context.go('/dashboard/support');
        break;
      case 'CLIENT':
      default:
        context.go('/dashboard/client');
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _wastePrefCtrl.dispose();
    _scheduleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final profileState = ref.watch(profileProvider);
    final user = userState.user;

    final socialStats = _currentUserId != null
        ? ref.watch(socialProvider(_currentUserId!)).stats
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToDashboard,
        ),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: profileState.isLoading ? null : _cancelEditing,
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  // Profile Picture
                  Card(
                    elevation: 8,
                    shape: const CircleBorder(),
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: _isEditing ? _pickImage : null,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 92,
                              backgroundColor: Colors.green.shade50,
                              backgroundImage: _getProfileImageProvider(user),
                              child: _getProfileImageProvider(user) == null
                                  ? const Icon(Icons.person, size: 92, color: Colors.green)
                                  : null,
                            ),
                            if (_isEditing)
                              const CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.green,
                                child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Name and Username
                  Text(
                    '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim().isNotEmpty
                        ? '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim()
                        : 'Your Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text('@${user?.username ?? 'user'}', style: const TextStyle(color: Colors.grey, fontSize: 16)),

                  const SizedBox(height: 28),

                  // Social Stats
                  if (socialStats != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('Followers', socialStats.followersCount),
                            _buildStatItem('Likes', socialStats.likesCount),
                            _buildStatItem('Rating', '${socialStats.averageRating.toStringAsFixed(1)} ★'),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // Main Profile Information Card
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Personal Information'),
                          const SizedBox(height: 12),
                          _buildField('First Name', user?.firstName, _firstNameCtrl, _isEditing),
                          _buildDivider(),
                          _buildField('Middle Name', user?.middleName, _middleNameCtrl, _isEditing),
                          _buildDivider(),
                          _buildField('Last Name', user?.lastName, _lastNameCtrl, _isEditing),

                          const SizedBox(height: 32),

                          _buildSectionTitle('Contact & Service'),
                          const SizedBox(height: 12),
                          _buildField('Phone Number', user?.phoneNumber, _phoneCtrl, _isEditing),
                          _buildDivider(),
                          _buildField('Home Address', user?.homeAddress, _addressCtrl, _isEditing),
                          _buildDivider(),
                          _buildField('Waste Preferences', user?.wastePreferences, _wastePrefCtrl, _isEditing),
                          _buildDivider(),
                          _buildField('Collection Schedule', user?.collectionSchedule, _scheduleCtrl, _isEditing),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: profileState.isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Colors.green,
                        ),
                        child: profileState.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.green,
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, thickness: 1, color: Colors.black12),
    );
  }

  Widget _buildField(String label, String? value, TextEditingController ctrl, bool isEditing) {
    if (!isEditing) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          value?.isNotEmpty == true ? value! : 'Not provided',
          style: const TextStyle(fontSize: 16.5, height: 1.4),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
        ),
      ],
    );
  }
}