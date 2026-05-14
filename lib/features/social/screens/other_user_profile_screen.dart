import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/social/providers/social_provider.dart';
import 'package:garbigo_frontend/features/social/models/social_action_request.dart';
import 'package:garbigo_frontend/features/social/models/review_response_dto.dart';
import 'package:go_router/go_router.dart';

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
    final socialNotifier = ref.read(socialProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 70),
                    const SizedBox(height: 12),
                    Text("User Profile", style: Theme.of(context).textTheme.headlineMedium),
                    Text(widget.userId, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Social Actions
              if (!isOwnProfile)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final check = await socialNotifier.isFollowing(widget.userId);
                        if (check.isFollowing) {
                          await socialNotifier.unfollow(widget.userId);
                          Helpers.showToast('Unfollowed successfully');
                        } else {
                          await socialNotifier.follow(widget.userId);
                          Helpers.showToast('Followed successfully');
                        }
                        await _loadData();
                      } catch (e) {
                        Helpers.showToast('Action failed', isError: true);
                      }
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Follow / Unfollow'),
                  ),
                ),

              const SizedBox(height: 24),

              // Social Stats
              _buildSocialStats(),

              const SizedBox(height: 32),

              // Tabs
              _buildTabBar(),

              const SizedBox(height: 20),

              // Tab Content
              if (_selectedTab == 0) _buildAboutTab(),
              if (_selectedTab == 1) _buildReviewsTab(socialNotifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialStats() {
    return Consumer(
      builder: (context, ref, child) {
        return FutureBuilder(
          future: ref.read(socialProvider.notifier).getUserStats(widget.userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final stats = snapshot.data!;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Followers', stats.followersCount),
                _buildStat('Following', stats.followingCount),
                _buildStat('Rating', stats.averageRating.toStringAsFixed(1)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStat(String label, dynamic value) {
    return Column(
      children: [
        Text('$value', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabButton(0, 'About'),
        const SizedBox(width: 40),
        _tabButton(1, 'Reviews'),
      ],
    );
  }

  Widget _tabButton(int index, String text) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Text(
        text,
        style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  Widget _buildAboutTab() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('More information about this user will appear here.'),
      ),
    );
  }

  Widget _buildReviewsTab(SocialNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Write Review'),
              onPressed: () => _showReviewDialog(notifier),
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
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const Text('No reviews yet.');
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(review.reviewerName),
                    subtitle: Text(review.comment ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                            (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
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
        content: StatefulBuilder(
          builder: (context, setInnerState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => IconButton(
                    icon: Icon(
                      Icons.star,
                      color: i < rating ? Colors.amber : Colors.grey,
                      size: 36,
                    ),
                    onPressed: () => setInnerState(() => rating = i + 1),
                  )),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Write your review here...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await notifier.addReview(
                  SocialActionRequest(
                    targetId: widget.userId,
                    targetType: "USER",
                    rating: rating,
                    comment: commentCtrl.text.trim(),
                  ),
                );
                ctx.pop();
                await _loadData();
                Helpers.showToast('Review posted successfully');
              } catch (e) {
                Helpers.showToast('Failed to post review', isError: true);
              }
            },
            child: const Text('Post Review'),
          ),
        ],
      ),
    );
  }
}