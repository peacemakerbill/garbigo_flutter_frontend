import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/social/providers/social_provider.dart';
import 'package:garbigo_frontend/features/social/widgets/social_action_bar.dart';
import 'package:garbigo_frontend/features/social/models/review_response_dto.dart';
import 'package:go_router/go_router.dart';

import '../models/social_action_request.dart';

class OtherUserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends ConsumerState<OtherUserProfileScreen> {
  int _selectedTab = 0; // 0: About, 1: Reviews

  Future<void> _loadData() async {
    final notifier = ref.read(socialProvider.notifier);
    await Future.wait([
      notifier.getUserStats(widget.userId),
      notifier.isFollowing(widget.userId),
      notifier.getReviews(widget.userId),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider).user;
    final bool isOwnProfile = currentUser?.id == widget.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== PROFILE HEADER ====================
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage('https://via.placeholder.com/300'), // Replace with real user image later
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "User Name", // You can fetch and display real name later
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      widget.userId,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // ==================== SOCIAL ACTION BAR ====================
              if (!isOwnProfile)
                SocialActionBar(targetUserId: widget.userId),

              const SizedBox(height: 24),

              // ==================== SOCIAL STATS ====================
              _buildSocialStats(),

              const SizedBox(height: 32),

              // ==================== TABS ====================
              _buildTabBar(),

              const SizedBox(height: 20),

              // ==================== TAB CONTENT ====================
              if (_selectedTab == 0) _buildAboutTab(),
              if (_selectedTab == 1) _buildReviewsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialStats() {
    return Consumer(
      builder: (context, ref, child) {
        final notifier = ref.read(socialProvider.notifier);
        return FutureBuilder(
          future: notifier.getUserStats(widget.userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final stats = snapshot.data!;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Followers', stats.followersCount),
                _buildStatItem('Following', stats.followingCount),
                _buildStatItem('Likes', stats.likesCount),
                _buildStatItem('Rating', stats.averageRating.toStringAsFixed(1)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabButton(0, 'About'),
        const SizedBox(width: 48),
        _tabButton(1, 'Reviews'),
      ],
    );
  }

  Widget _tabButton(int index, String title) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 40,
              color: Theme.of(context).primaryColor,
            ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'More information about this user will appear here (Bio, Location, Member since, etc.)',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    final notifier = ref.read(socialProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showReviewDialog(notifier),
              icon: const Icon(Icons.add),
              label: const Text('Write Review'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<ReviewResponseDto>>(
          future: notifier.getReviews(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No reviews yet. Be the first to review!');
            }

            final reviews = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: review.reviewerProfilePictureUrl != null
                          ? NetworkImage(review.reviewerProfilePictureUrl!)
                          : null,
                    ),
                    title: Text(review.reviewerName),
                    subtitle: Text(review.comment ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                            (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showReviewDialog(SocialNotifier notifier) {
    int rating = 5;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Write a Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                    (i) => IconButton(
                  icon: Icon(Icons.star, color: i < rating ? Colors.amber : Colors.grey, size: 32),
                  onPressed: () => setState(() => rating = i + 1),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Share your experience...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await notifier.addReview(
                SocialActionRequest(
                  targetId: widget.userId,
                  targetType: 'USER',
                  rating: rating,
                  comment: commentCtrl.text.trim(),
                ),
              );
              ctx.pop();
              _loadData();
              Helpers.showToast('Review posted successfully!');
            },
            child: const Text('Post Review'),
          ),
        ],
      ),
    );
  }
}