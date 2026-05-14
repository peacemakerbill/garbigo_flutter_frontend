import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/social/providers/social_provider.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers mapped exactly to your UserModel fields
  late TextEditingController _usernameCtrl;
  late TextEditingController _firstNameCtrl;
  late TextEditingController _middleNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _wastePrefCtrl;
  late TextEditingController _scheduleCtrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchInitialData();
  }

  void _initializeControllers() {
    final user = ref.read(userProvider).user;
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _middleNameCtrl = TextEditingController(text: user?.middleName ?? '');
    _lastNameCtrl = TextEditingController(text: user?.lastName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    _addressCtrl = TextEditingController(text: user?.homeAddress ?? '');
    _wastePrefCtrl = TextEditingController(text: user?.wastePreferences ?? '');
    _scheduleCtrl = TextEditingController(text: user?.collectionSchedule ?? '');
  }

  void _fetchInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider).user;
      // 1. Fetch latest user details from backend
      ref.read(userProvider.notifier).fetchCurrentUser();
      // 2. Fetch live social stats (Followers, Rating, etc)
      if (user != null) {
        ref.read(socialProvider.notifier).getUserStats(user.id);
      }
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _wastePrefCtrl.dispose();
    _scheduleCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final updateData = {
        'username': _usernameCtrl.text.trim(),
        'firstName': _firstNameCtrl.text.trim(),
        'middleName': _middleNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'homeAddress': _addressCtrl.text.trim(),
        'wastePreferences': _wastePrefCtrl.text.trim(),
        'collectionSchedule': _scheduleCtrl.text.trim(),
      };

      await ref.read(userProvider.notifier).updateProfile(updateData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final socialState = ref.watch(socialProvider);

    // If data was updated in background, refresh the controller text
    ref.listen(userProvider, (previous, next) {
      if (previous?.user != next.user && next.user != null) {
        _usernameCtrl.text = next.user!.username;
        _firstNameCtrl.text = next.user!.firstName;
        _middleNameCtrl.text = next.user!.middleName;
        _lastNameCtrl.text = next.user!.lastName;
        _phoneCtrl.text = next.user!.phoneNumber;
        _addressCtrl.text = next.user!.homeAddress;
        _wastePrefCtrl.text = next.user!.wastePreferences;
        _scheduleCtrl.text = next.user!.collectionSchedule;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => Helpers.showToast("Logging out..."),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userProvider.notifier).fetchCurrentUser();
          if (userState.user != null) {
            await ref.read(socialProvider.notifier).getUserStats(userState.user!.id);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Photo & Backend URL check
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green.shade50,
                    backgroundImage: userState.user?.profilePictureUrl.isNotEmpty == true
                        ? NetworkImage(userState.user!.profilePictureUrl)
                        : null,
                    child: userState.user?.profilePictureUrl.isEmpty == true
                        ? const Icon(Icons.person, size: 50, color: Colors.green)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Live Stats Section from SocialProvider
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
                      _buildStatItem('Followers', socialState.stats?.followersCount ?? 0),
                      _buildStatItem('Likes', socialState.stats?.likesCount ?? 0),
                      _buildStatItem('Rating', socialState.stats?.averageRating.toStringAsFixed(1) ?? '0.0'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Editable Fields
                _buildFieldLabel("Personal Information"),
                _buildTextField(_usernameCtrl, 'Username', Icons.alternate_email),
                const SizedBox(height: 16),
                _buildTextField(_firstNameCtrl, 'First Name', Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField(_lastNameCtrl, 'Last Name', Icons.person_outline),

                const SizedBox(height: 24),
                _buildFieldLabel("Contact & Service"),
                _buildTextField(_phoneCtrl, 'Phone Number', Icons.phone_android),
                const SizedBox(height: 16),
                _buildTextField(_addressCtrl, 'Home Address', Icons.map_outlined),
                const SizedBox(height: 16),
                _buildTextField(_wastePrefCtrl, 'Waste Preferences', Icons.recycling),

                const SizedBox(height: 40),

                // Update Button with Loading State
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: userState.isLoading ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: userState.isLoading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Text('Update Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
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