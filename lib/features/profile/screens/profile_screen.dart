import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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

    // Safe delayed load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  void _initializeControllers() {
    final user = ref.read(userProvider).user;
    _currentUserId = user?.id;

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
      if (mounted) {
        Helpers.showToast('Failed to load profile', isError: true);
      }
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
      imageQuality: 80,
    );
    if (image != null && mounted) {
      setState(() => _selectedImage = image);
    }
  }

  ImageProvider? _getProfileImageProvider(UserModel? user) {
    if (_selectedImage != null) {
      if (kIsWeb) {
        return NetworkImage(_selectedImage!.path);
      } else {
        return FileImage(File(_selectedImage!.path));
      }
    }

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

    await ref.read(profileProvider.notifier).updateProfile(
      data: updateData,
      imageFile: _selectedImage,
    );

    if (mounted) {
      setState(() {
        _isEditing = false;
        _selectedImage = null;
      });
    }
  }

  void _cancelEditing() {
    if (!mounted) return;

    final user = ref.read(userProvider).user;
    if (user != null) _syncControllers(user);

    setState(() {
      _isEditing = false;
      _selectedImage = null;
    });
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.green.shade50,
                      backgroundImage: _getProfileImageProvider(user),
                      child: (_getProfileImageProvider(user) == null)
                          ? const Icon(Icons.person, size: 70, color: Colors.green)
                          : null,
                    ),
                    if (_isEditing)
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim().isNotEmpty
                    ? '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim()
                    : 'Your Profile',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Text('@${user?.username ?? 'user'}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              // Social Stats
              if (socialStats != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Followers', socialStats.followersCount),
                      _buildStatItem('Likes', socialStats.likesCount),
                      _buildStatItem('Rating', socialStats.averageRating.toStringAsFixed(1)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Profile Information
              _buildInfoSection(user, _isEditing),

              const SizedBox(height: 40),

              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: profileState.isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: profileState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(UserModel? user, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Information'),
        _buildField('First Name', user?.firstName, _firstNameCtrl, isEditing),
        _buildField('Middle Name', user?.middleName, _middleNameCtrl, isEditing),
        _buildField('Last Name', user?.lastName, _lastNameCtrl, isEditing),

        const SizedBox(height: 24),
        _buildSectionTitle('Contact & Service'),
        _buildField('Phone Number', user?.phoneNumber, _phoneCtrl, isEditing),
        _buildField('Home Address', user?.homeAddress, _addressCtrl, isEditing),
        _buildField('Waste Preferences', user?.wastePreferences, _wastePrefCtrl, isEditing),
        _buildField('Collection Schedule', user?.collectionSchedule, _scheduleCtrl, isEditing),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
      ),
    );
  }

  Widget _buildField(String label, String? value, TextEditingController ctrl, bool isEditing) {
    if (!isEditing) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          value?.isNotEmpty == true ? value! : 'Not provided',
          style: const TextStyle(fontSize: 15),
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
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Column(
      children: [
        Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}