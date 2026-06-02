// features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/profile/providers/profile_provider.dart';
import 'package:garbigo_frontend/features/profile/providers/profile_view_provider.dart';
import 'package:garbigo_frontend/features/social/providers/social_provider.dart';

import '../../../core/utils/helpers.dart';
import '../../auth/models/user_model.dart';
import '../models/profile_view_dto.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  bool _isEditing = false;
  XFile? _selectedImage;
  late TabController _tabController;

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
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
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
      final user = ref.read(userProvider).user;

      if (user != null && mounted) {
        setState(() => _currentUserId = user.id);
        _syncControllers(user);

        if (_currentUserId != null) {
          ref.read(socialProvider(_currentUserId!).notifier).refreshAll(_currentUserId!);
          ref.read(profileViewProvider.notifier).loadProfileViews();
        }
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
      setState(() => _selectedImage = null);
    }
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

    // Remove fields that are empty or null
    updateData.removeWhere((key, value) =>
    value == null || (value as String).trim().isEmpty);

    if (updateData.isEmpty) {
      Helpers.showToast('No changes to save');
      return;
    }

    // Call the provider
    await ref.read(profileProvider.notifier).updateProfileData(updateData);

    // Refresh local controllers with latest data from backend
    if (mounted) {
      final updatedUser = ref.read(userProvider).user;
      if (updatedUser != null) {
        _syncControllers(updatedUser);
      }
      setState(() => _isEditing = false);
    }
  }

  void _cancelEditing() {
    final user = ref.read(userProvider).user;
    if (user != null) _syncControllers(user);
    setState(() => _isEditing = false);
  }

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
    _tabController.dispose();
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
    final profileViewState = ref.watch(profileViewProvider);
    final user = userState.user;

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
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Social'),
              Tab(text: 'Views'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(user, profileState),
                _buildSocialTab(user),
                _buildViewsTab(profileViewState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TABS ====================

  Widget _buildOverviewTab(UserModel? user, ProfileState profileState) {
    return SingleChildScrollView(
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
                          backgroundImage: user?.profilePictureUrl != null
                              ? NetworkImage(user!.profilePictureUrl)
                              : null,
                          child: user?.profilePictureUrl == null
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
              Text(
                '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim().isNotEmpty
                    ? '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim()
                    : 'Your Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text('@${user?.username ?? 'user'}', style: const TextStyle(color: Colors.grey, fontSize: 16)),

              const SizedBox(height: 32),

              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: profileState.isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    );
  }

  Widget _buildSocialTab(UserModel? user) {
    final socialState = _currentUserId != null
        ? ref.watch(socialProvider(_currentUserId!))
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              if (socialState?.stats != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Followers', socialState!.stats!.followersCount),
                        _buildStatItem('Following', socialState.stats!.followingCount),
                        _buildStatItem('Likes', socialState.stats!.likesCount),
                        _buildStatItem('Rating', '${socialState.stats!.averageRating.toStringAsFixed(1)}★'),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              const Text('More social features coming soon...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewsTab(ProfileViewState viewState) {
    if (viewState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewState.error != null) {
      return Center(child: Text('Error: ${viewState.error}'));
    }

    final stats = viewState.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Profile View Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Total Views', stats?.totalViews ?? 0),
                      _buildStatColumn('Unique', stats?.uniqueViewers ?? 0),
                      _buildStatColumn('Today', stats?.todayViews ?? 0),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text('Who Viewed Me', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildViewersList(viewState.whoViewedMe, 'No one has viewed your profile yet'),

          const SizedBox(height: 24),
          const Text('Who I Viewed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildViewersList(viewState.whoIViewed, 'You haven\'t viewed any profiles yet'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int value) {
    return Column(
      children: [
        Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildViewersList(List<ProfileViewDto> viewers, String emptyMessage) {
    if (viewers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewers.length,
      itemBuilder: (context, index) {
        final view = viewers[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: view.viewerProfilePictureUrl != null
                ? NetworkImage(view.viewerProfilePictureUrl!)
                : null,
            child: view.viewerProfilePictureUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(view.viewerName),
          subtitle: Text(view.viewedAt.toString().substring(0, 16)),
          trailing: view.isAnonymous ? const Text('Anonymous', style: TextStyle(fontSize: 12)) : null,
        );
      },
    );
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Column(
      children: [
        Text('$value', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5)),
      ],
    );
  }
}