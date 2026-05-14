import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/social/providers/social_provider.dart';
import 'package:garbigo_frontend/features/social/models/social_action_request.dart';
import 'package:go_router/go_router.dart';

class SocialActionBar extends ConsumerStatefulWidget {
  final String targetUserId;
  final bool showReviewButton;

  const SocialActionBar({
    super.key,
    required this.targetUserId,
    this.showReviewButton = true,
  });

  @override
  ConsumerState<SocialActionBar> createState() => _SocialActionBarState();
}

class _SocialActionBarState extends ConsumerState<SocialActionBar> {
  @override
  Widget build(BuildContext context) {
    final socialNotifier = ref.read(socialProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Follow Button
          _buildActionButton(
            icon: Icons.person_add,
            label: "Follow",
            onPressed: () async {
              try {
                final isFollowing = await socialNotifier.isFollowing(widget.targetUserId);
                if (isFollowing.isFollowing) {
                  await socialNotifier.unfollow(widget.targetUserId);
                  Helpers.showToast("Unfollowed");
                } else {
                  await socialNotifier.follow(widget.targetUserId);
                  Helpers.showToast("Followed successfully");
                }
              } catch (e) {
                Helpers.showToast("Action failed", isError: true);
              }
            },
          ),

          // Like Button (for the user profile)
          _buildActionButton(
            icon: Icons.favorite_border,
            label: "Like",
            onPressed: () async {
              try {
                await socialNotifier.like(widget.targetUserId, targetType: "USER");
                Helpers.showToast("Liked!");
              } catch (e) {
                Helpers.showToast("Already liked or error", isError: true);
              }
            },
          ),

          // Review Button
          if (widget.showReviewButton)
            _buildActionButton(
              icon: Icons.rate_review_outlined,
              label: "Review",
              onPressed: () => _showReviewDialog(context, socialNotifier),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context, SocialNotifier notifier) {
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
                  icon: Icon(
                    Icons.star,
                    color: i < rating ? Colors.amber : Colors.grey,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() => rating = i + 1);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "What did you think about this user?",
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
                  targetId: widget.targetUserId,
                  targetType: "USER",
                  rating: rating,
                  comment: commentCtrl.text.trim(),
                ),
              );
              ctx.pop();
              Helpers.showToast("Review submitted successfully!");
            },
            child: const Text('Post Review'),
          ),
        ],
      ),
    );
  }
}