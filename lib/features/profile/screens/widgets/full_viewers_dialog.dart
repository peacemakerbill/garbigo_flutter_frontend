// features/profile/widgets/full_viewers_dialog.dart
import 'package:flutter/material.dart';
import 'package:garbigo_frontend/features/social/models/user_summary_dto.dart';

class FullViewersDialog extends StatefulWidget {
  final String title;
  final List<UserSummaryDto> users;

  const FullViewersDialog({
    super.key,
    required this.title,
    required this.users,
  });

  @override
  State<FullViewersDialog> createState() => _FullViewersDialogState();
}

class _FullViewersDialogState extends State<FullViewersDialog> {
  String _searchQuery = '';

  List<UserSummaryDto> get filteredUsers {
    if (_searchQuery.isEmpty) return widget.users;
    final query = _searchQuery.toLowerCase();
    return widget.users.where((user) {
      final fullName = (user.fullName ?? '${user.firstName ?? ''} ${user.lastName ?? ''}').toLowerCase();
      final username = (user.username ?? '').toLowerCase();
      return fullName.contains(query) || username.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420), // Narrower & better on mobile
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search by name or username...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),

            // List
            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_search, size: 60, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No users found', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: user.profilePictureUrl != null
                            ? NetworkImage(user.profilePictureUrl!)
                            : null,
                        child: user.profilePictureUrl == null
                            ? const Icon(Icons.person, size: 28)
                            : null,
                      ),
                      title: Text(
                        user.fullName ?? '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '@${user.username ?? 'user'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        user.role ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: user.role == 'ADMIN' ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}