import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/social/providers/social_provider.dart';
import 'package:garbigo_frontend/features/social/models/social_action_request.dart';
import 'package:garbigo_frontend/features/social/models/review_response_dto.dart';
import 'package:garbigo_frontend/features/social/models/review_update_request.dart';

class OtherUserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends ConsumerState<OtherUserProfileScreen> {
  int _selectedTab = 0; // 0: About, 1: Reviews

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final notifier = ref.read(socialProvider.notifier);
    await notifier.refreshAll(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final socialState = ref.watch(socialProvider);
    final socialNotifier = ref.read(socialProvider.notifier);
    final currentUser = ref.watch(userProvider).user;

    final bool isOwnProfile = currentUser?.id == widget.userId;
    final bool isFollowing = socialState.followingCache[widget.userId] ?? false;
    final bool isLiked = socialState.likedCache[widget.userId] ?? false;

    final String displayName = _getDisplayName();

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Header
              const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
              const SizedBox(height: 12),
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Text(
                widget.userId,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Social Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('Followers', socialState.stats?.followersCount ?? 0,
                          () => _showUserList(context, 'Followers')),
                  _buildStatColumn('Following', socialState.stats?.followingCount ?? 0,
                          () => _showUserList(context, 'Following')),
                  _buildStatColumn('Likes', socialState.stats?.likesCount ?? 0, null),
                  _buildStatColumn('Rating',
                      socialState.stats?.averageRating.toStringAsFixed(1) ?? '0.0', null),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              if (!isOwnProfile)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (isFollowing) {
                            await socialNotifier.unfollow(widget.userId);
                          } else {
                            await socialNotifier.follow(widget.userId);
                          }
                          await socialNotifier.checkFollowStatus(widget.userId);
                        },
                        icon: Icon(isFollowing ? Icons.person_remove : Icons.person_add),
                        label: Text(isFollowing ? 'Unfollow' : 'Follow'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () async {
                        if (isLiked) {
                          await socialNotifier.unlike(widget.userId);
                        } else {
                          await socialNotifier.like(widget.userId);
                        }
                        await socialNotifier.checkLikeStatus(widget.userId);
                      },
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Tabs
              Row(
                children: [
                  _buildTabButton(0, 'About'),
                  _buildTabButton(1, 'Reviews'),
                ],
              ),
              const Divider(height: 1),

              // Tab Content
              IndexedStack(
                index: _selectedTab,
                children: [
                  _buildAboutTab(),
                  _buildReviewsTab(socialState, socialNotifier, isOwnProfile),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisplayName() {
    final currentUser = ref.watch(userProvider).user;
    if (currentUser?.id == widget.userId) {
      final name = "${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}".trim();
      return name.isNotEmpty ? name : "User Profile";
    }
    return "User Profile";
  }

  Widget _buildStatColumn(String label, dynamic value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.green : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.green : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Text("No additional user information available."),
    );
  }

  Widget _buildReviewsTab(SocialState state, SocialNotifier notifier, bool isOwnProfile) {
    final currentUserId = ref.watch(userProvider).user?.id;

    return Column(
      children: [
        if (!isOwnProfile)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showReviewDialog(context, null),
                icon: const Icon(Icons.add),
                label: const Text("Write a Review"),
              ),
            ),
          ),

        if (state.reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Text("No reviews yet."),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.reviews.length,
            itemBuilder: (context, index) {
              final review = state.reviews[index];
              final isMyReview = review.reviewerId == currentUserId && currentUserId != null;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    review.reviewerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating Stars
                      Row(
                        children: List.generate(
                          5,
                              (i) => Icon(
                            Icons.star,
                            size: 18,
                            color: i < review.rating ? Colors.amber : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Comment
                      if (review.comment != null && review.comment!.trim().isNotEmpty)
                        Text(
                          review.comment!,
                          style: const TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                  trailing: isMyReview
                      ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showReviewDialog(context, review);
                      } else if (value == 'delete') {
                        notifier.deleteReview(review.id, widget.userId);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  )
                      : null,
                ),
              );
            },
          ),
      ],
    );
  }

  void _showUserList(BuildContext context, String title) {
    final notifier = ref.read(socialProvider.notifier);
    if (title == 'Followers') {
      notifier.getFollowers(widget.userId);
    } else {
      notifier.getFollowing(widget.userId);
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final users = title == 'Followers'
              ? ref.watch(socialProvider).followersList
              : ref.watch(socialProvider).followingList;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              Expanded(
                child: users.isEmpty
                    ? const Center(child: Text("No users found."))
                    : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, i) {
                    final user = users[i];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text("${user.firstName ?? ''} ${user.lastName ?? ''}".trim()),
                      subtitle: Text("@${user.username ?? 'user'}"),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReviewDialog(BuildContext context, ReviewResponseDto? existingReview) {
    int rating = existingReview?.rating ?? 5;
    final commentController = TextEditingController(text: existingReview?.comment);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: Text(existingReview == null ? "Write a Review" : "Update Review"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  icon: Icon(Icons.star, color: i < rating ? Colors.amber : Colors.grey, size: 32),
                  onPressed: () => setInnerState(() => rating = i + 1),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: "Your thoughts...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final notifier = ref.read(socialProvider.notifier);
                if (existingReview == null) {
                  await notifier.addReview(SocialActionRequest(
                    targetId: widget.userId,
                    targetType: "USER",
                    rating: rating,
                    comment: commentController.text.trim(),
                  ));
                } else {
                  await notifier.updateReview(
                    existingReview.id,
                    widget.userId,
                    ReviewUpdateRequest(
                      rating: rating,
                      comment: commentController.text.trim(),
                    ),
                  );
                }
                Navigator.pop(ctx);
                Helpers.showToast("Success");
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}