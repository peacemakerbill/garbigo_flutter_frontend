import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/social/providers/social_provider.dart';
import 'package:garbigo_frontend/features/social/models/social_action_request.dart';
import 'package:garbigo_frontend/features/social/models/review_response_dto.dart';
import 'package:garbigo_frontend/features/social/models/review_update_request.dart';
import 'package:garbigo_frontend/features/social/models/user_summary_dto.dart';

class OtherUserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<OtherUserProfileScreen> createState() =>
      _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState
    extends ConsumerState<OtherUserProfileScreen> {
  // Scoped provider for THIS profile only
  late final _provider = socialProvider(widget.userId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(_provider.notifier).refreshAll(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final socialState = ref.watch(_provider);
    final socialNotifier = ref.read(_provider.notifier);
    final currentUser = ref.watch(userProvider).user;

    final bool isOwnProfile = currentUser?.id == widget.userId;

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: socialState.isLoading && socialState.stats == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(_provider.notifier).refreshAll(widget.userId),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ── Profile Header ──────────────────────────────────
              CircleAvatar(
                radius: 50,
                backgroundImage: socialState.stats != null
                    ? null // TODO: replace with NetworkImage when avatar URL is available
                    : null,
                child: const Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 12),
              Text(
                _resolveDisplayName(currentUser, widget.userId),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Text(
                widget.userId,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 24),

              // ── Social Stats ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(
                    'Followers',
                    socialState.stats?.followersCount ?? 0,
                        () => _showUserList(context, 'Followers'),
                  ),
                  _buildStatColumn(
                    'Following',
                    socialState.stats?.followingCount ?? 0,
                        () => _showUserList(context, 'Following'),
                  ),
                  _buildStatColumn(
                      'Likes', socialState.stats?.likesCount ?? 0, null),
                  _buildStatColumn(
                    'Rating',
                    socialState.stats?.averageRating.toStringAsFixed(1) ??
                        '0.0',
                    null,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Action Buttons ──────────────────────────────────
              if (!isOwnProfile)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: socialState.isLoading
                            ? null
                            : () async {
                          if (socialState.isFollowing) {
                            await socialNotifier
                                .unfollow(widget.userId);
                          } else {
                            await socialNotifier
                                .follow(widget.userId);
                          }
                        },
                        icon: Icon(
                          socialState.isFollowing
                              ? Icons.person_remove
                              : Icons.person_add,
                        ),
                        label: Text(socialState.isFollowing
                            ? 'Unfollow'
                            : 'Follow'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: socialState.isLoading
                          ? null
                          : () async {
                        if (socialState.isLiked) {
                          await socialNotifier
                              .unlike(widget.userId);
                        } else {
                          await socialNotifier.like(widget.userId);
                        }
                      },
                      icon: Icon(
                        socialState.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: socialState.isLiked ? Colors.red : null,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // ── Reviews Section (About tab removed) ─────────────────────
              _buildReviewsHeader(isOwnProfile),
              const Divider(height: 1),
              _buildReviewsTab(
                socialState,
                socialNotifier,
                isOwnProfile,
                currentUser?.id,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsHeader(bool isOwnProfile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (!isOwnProfile)
          TextButton.icon(
            onPressed: () => _showReviewDialog(context, null),
            icon: const Icon(Icons.add),
            label: const Text('Write a Review'),
          ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _resolveDisplayName(dynamic currentUser, String userId) {
    if (currentUser?.id == userId) {
      final name =
      '${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}'
          .trim();
      return name.isNotEmpty ? name : 'My Profile';
    }

    final allKnown = [
      ...ref.read(_provider).followersList,
      ...ref.read(_provider).followingList,
    ];
    final match = allKnown.cast<UserSummaryDto?>().firstWhere(
          (u) => u?.id == userId,
      orElse: () => null,
    );
    if (match != null) {
      final name =
      '${match.firstName ?? ''} ${match.lastName ?? ''}'.trim();
      return name.isNotEmpty ? name : '@${match.username ?? userId}';
    }
    return 'User Profile';
  }

  Widget _buildStatColumn(String label, dynamic value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            Text('$value',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab(
      SocialState state,
      SocialNotifier notifier,
      bool isOwnProfile,
      String? currentUserId,
      ) {
    return Column(
      children: [
        if (state.reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Text('No reviews yet.'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.reviews.length,
            itemBuilder: (context, index) {
              final review = state.reviews[index];
              final isMyReview =
                  currentUserId != null && review.reviewerId == currentUserId;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: review.reviewerProfilePictureUrl != null
                      ? CircleAvatar(
                      backgroundImage: NetworkImage(
                          review.reviewerProfilePictureUrl!))
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    review.reviewerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                              (i) => Icon(
                            Icons.star,
                            size: 16,
                            color: i < review.rating
                                ? Colors.amber
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      if (review.comment != null &&
                          review.comment!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(review.comment!,
                            style: const TextStyle(fontSize: 14)),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(review.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  // Three dots menu (Edit / Delete) for own reviews
                  trailing: isMyReview
                      ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showReviewDialog(context, review);
                      } else if (value == 'delete') {
                        _confirmDelete(context, notifier, review.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                          value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                          value: 'delete', child: Text('Delete')),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(
      BuildContext context, SocialNotifier notifier, String reviewId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              notifier.deleteReview(reviewId, widget.userId);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUserList(BuildContext context, String title) {
    final notifier = ref.read(_provider.notifier);
    if (title == 'Followers') {
      notifier.getFollowers(widget.userId);
    } else {
      notifier.getFollowing(widget.userId);
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(_provider);
          final users = title == 'Followers'
              ? state.followersList
              : state.followingList;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : users.isEmpty
                    ? const Center(child: Text('No users found.'))
                    : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, i) {
                    final user = users[i];
                    return ListTile(
                      leading: user.profilePictureUrl != null
                          ? CircleAvatar(
                          backgroundImage: NetworkImage(
                              user.profilePictureUrl!))
                          : const CircleAvatar(
                          child: Icon(Icons.person)),
                      title: Text(
                          '${user.firstName ?? ''} ${user.lastName ?? ''}'
                              .trim()),
                      subtitle: Text('@${user.username ?? 'user'}'),
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

  void _showReviewDialog(BuildContext context, ReviewResponseDto? existing) {
    int rating = existing?.rating ?? 5;
    final commentController =
    TextEditingController(text: existing?.comment);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: Text(
              existing == null ? 'Write a Review' : 'Update Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (i) => IconButton(
                    icon: Icon(
                      Icons.star,
                      color: i < rating ? Colors.amber : Colors.grey,
                      size: 32,
                    ),
                    onPressed: () =>
                        setInnerState(() => rating = i + 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Your thoughts...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final notifier = ref.read(_provider.notifier);
                if (existing == null) {
                  await notifier.addReview(SocialActionRequest(
                    targetId: widget.userId,
                    targetType: 'USER',
                    rating: rating,
                    comment: commentController.text.trim(),
                  ));
                } else {
                  await notifier.updateReview(
                    existing.id,
                    widget.userId,
                    ReviewUpdateRequest(
                      rating: rating,
                      comment: commentController.text.trim(),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}