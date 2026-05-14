import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
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
    final socialState = ref.watch(socialProvider);
    final notifier = ref.read(socialProvider.notifier);

    final bool isFollowing = socialState.followingCache[targetUserId] ?? false;
    final bool isLiked = socialState.likedCache[targetUserId] ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Follow/Unfollow Button
            _buildButton(
              context,
              icon: isFollowing ? Icons.person_remove : Icons.person_add,
              label: isFollowing ? "Unfollow" : "Follow",
              color: isFollowing ? Colors.grey : Colors.green,
              onPressed: () => isFollowing
                  ? notifier.unfollow(targetUserId)
                  : notifier.follow(targetUserId),
            ),

            // Like/Unlike Button
            _buildButton(
              context,
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
              label: isLiked ? "Liked" : "Like",
              color: isLiked ? Colors.red : Colors.grey,
              onPressed: () => isLiked
                  ? notifier.unlike(targetUserId)
                  : notifier.like(targetUserId),
            ),

            if (showReviewButton)
              _buildButton(
                context,
                icon: Icons.rate_review,
                label: "Review",
                color: Colors.blue,
                onPressed: () => _showReviewSheet(context, ref),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showReviewSheet(BuildContext context, WidgetRef ref) {
    int rating = 5;
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInnerState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Rate User", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  icon: Icon(Icons.star, color: i < rating ? Colors.amber : Colors.grey, size: 40),
                  onPressed: () => setInnerState(() => rating = i + 1),
                )),
              ),
              TextField(
                controller: commentCtrl,
                decoration: const InputDecoration(hintText: "Write a review...", border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(socialProvider.notifier).addReview(SocialActionRequest(
                      targetId: targetUserId,
                      targetType: "USER",
                      rating: rating,
                      comment: commentCtrl.text,
                    ));
                    Navigator.pop(ctx);
                    Helpers.showToast("Review submitted");
                  },
                  child: const Text("Submit Review"),
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