import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/features/social/providers/social_provider.dart';
import 'package:garbigo_frontend/features/social/models/social_action_request.dart';

class SocialActionBar extends ConsumerWidget {
  final String targetUserId;
  final bool showReviewButton;

  const SocialActionBar({
    super.key,
    required this.targetUserId,
    this.showReviewButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the family provider scoped to this specific user
    final provider = socialProvider(targetUserId);
    final socialState = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Follow Button
            _buildButton(
              context,
              icon: socialState.isFollowing
                  ? Icons.person_remove
                  : Icons.person_add,
              label: socialState.isFollowing ? 'Unfollow' : 'Follow',
              color: socialState.isFollowing ? Colors.grey : Colors.green,
              isLoading: socialState.isLoading,
              onPressed: () async {
                if (socialState.isFollowing) {
                  await notifier.unfollow(targetUserId);
                } else {
                  await notifier.follow(targetUserId);
                }
              },
            ),

            // Like Button
            _buildButton(
              context,
              icon: socialState.isLiked
                  ? Icons.favorite
                  : Icons.favorite_border,
              label: socialState.isLiked ? 'Liked' : 'Like',
              color: socialState.isLiked ? Colors.red : Colors.grey,
              isLoading: socialState.isLoading,
              onPressed: () async {
                if (socialState.isLiked) {
                  await notifier.unlike(targetUserId);
                } else {
                  await notifier.like(targetUserId);
                }
              },
            ),

            if (showReviewButton)
              _buildButton(
                context,
                icon: Icons.rate_review,
                label: 'Review',
                color: Colors.blue,
                onPressed: () => _showReviewSheet(context, ref),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onPressed,
        bool isLoading = false,
      }) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: color),
            )
                : Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context, WidgetRef ref) {
    int rating = 5;
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInnerState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rate User',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (i) => IconButton(
                    icon: Icon(
                      Icons.star,
                      color: i < rating ? Colors.amber : Colors.grey,
                      size: 40,
                    ),
                    onPressed: () =>
                        setInnerState(() => rating = i + 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                decoration: const InputDecoration(
                  hintText: 'Write a review...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ref
                        .read(socialProvider(targetUserId).notifier)
                        .addReview(
                      SocialActionRequest(
                        targetId: targetUserId,
                        targetType: 'USER',
                        rating: rating,
                        comment: commentCtrl.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Submit Review'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}