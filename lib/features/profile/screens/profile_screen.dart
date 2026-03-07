import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/profile/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _firstNameCtrl;
  late TextEditingController _middleNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _wastePrefCtrl;
  late TextEditingController _scheduleCtrl;

  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    final user = ref.read(userProvider).user;
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _middleNameCtrl = TextEditingController(text: user?.middleName ?? '');
    _lastNameCtrl = TextEditingController(text: user?.lastName ?? '');
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    _addressCtrl = TextEditingController(text: user?.homeAddress ?? '');
    _wastePrefCtrl = TextEditingController(text: user?.wastePreferences ?? '');
    _scheduleCtrl = TextEditingController(text: user?.collectionSchedule ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _wastePrefCtrl.dispose();
    _scheduleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'firstName': _firstNameCtrl.text.trim(),
      'middleName': _middleNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'username': _usernameCtrl.text.trim(),
      'phoneNumber': _phoneCtrl.text.trim(),
      'homeAddress': _addressCtrl.text.trim(),
      'wastePreferences': _wastePrefCtrl.text.trim(),
      'collectionSchedule': _scheduleCtrl.text.trim(),
    };

    ref.read(profileProvider.notifier).updateProfile(
      data: data,
      imageFile: _pickedImage,
    );
  }
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final profileState = ref.watch(profileProvider);
    final authNotifier = ref.read(authProvider.notifier);

    if (userState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userState.user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Helpers.showLogoutDialog(context, () {
              authNotifier.logout();
            }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _pickedImage != null
                          ? NetworkImage(_pickedImage!.path)
                          : (userState.user!.profilePictureUrl.isNotEmpty
                          ? NetworkImage(userState.user!.profilePictureUrl)
                          : null),
                      child: userState.user!.profilePictureUrl.isEmpty && _pickedImage == null
                          ? const Icon(Icons.person, size: 70, color: Colors.grey)
                          : null,
                    ),
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Username required' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _middleNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Middle Name (Optional)',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Home Address',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _wastePrefCtrl,
                decoration: const InputDecoration(
                  labelText: 'Waste Preferences',
                  prefixIcon: Icon(Icons.recycling),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _scheduleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Preferred Collection Schedule',
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // Status Messages
              if (profileState.isLoading)
                const CircularProgressIndicator()
              else if (profileState.successMessage != null)
                Text(
                  profileState.successMessage!,
                  style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )
              else if (profileState.error != null)
                  Text(
                    profileState.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),

              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: profileState.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Update Profile', style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}