import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/social/providers/social_provider.dart';
import 'package:garbigo_frontend/features/social/models/social_action_request.dart';
import 'package:garbigo_frontend/features/social/models/review_response_dto.dart';
import 'package:garbigo_frontend/features/social/models/review_update_request.dart';
import 'package:garbigo_frontend/features/social/models/user_summary_dto.dart';

// ── Green palette (garbage-collection brand) ─────────────────────────────────
const _kGreen        = Color(0xFF2E7D32); // deep green – primary
const _kGreenLight   = Color(0xFF4CAF50); // mid green – gradient end
const _kGreenSurface = Color(0xFFE8F5E9); // very light green – backgrounds
const _kGreenAccent  = Color(0xFF81C784); // muted green – borders / icons

class OtherUserProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<OtherUserProfileScreen> createState() =>
      _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState
    extends ConsumerState<OtherUserProfileScreen> {
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
    final socialState    = ref.watch(_provider);
    final socialNotifier = ref.read(_provider.notifier);
    final currentUser    = ref.watch(userProvider).user;
    final isOwnProfile   = currentUser?.id == widget.userId;
    final displayName    = _resolveDisplayName(socialState, currentUser);

    return Scaffold(
      backgroundColor: _kGreenSurface,
      body: socialState.isLoading && socialState.stats == null
          ? const Center(child: CircularProgressIndicator(color: _kGreen))
          : RefreshIndicator(
        color: _kGreen,
        onRefresh: () =>
            ref.read(_provider.notifier).refreshAll(widget.userId),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Hero header ──────────────────────────────────
            SliverAppBar(
              expandedHeight: 210,
              pinned: true,
              backgroundColor: _kGreen,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_kGreen, _kGreenLight],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        _buildAvatar(socialState),
                        const SizedBox(height: 10),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '@${widget.userId}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatsCard(socialState),
                    const SizedBox(height: 16),

                    if (!isOwnProfile) ...[
                      _buildActionButtons(socialState, socialNotifier),
                      const SizedBox(height: 24),
                    ],

                    _buildReviewsHeader(isOwnProfile),
                    const SizedBox(height: 8),
                    _buildReviewsList(
                      socialState,
                      socialNotifier,
                      currentUser?.id,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar ───────────────────────────────────────────────────────────────

  Widget _buildAvatar(SocialState state) {
    final url = state.profileAvatarUrl;
    return CircleAvatar(
      radius: 46,
      backgroundColor: Colors.white24,
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null
          ? const Icon(Icons.person, size: 46, color: Colors.white)
          : null,
    );
  }

  // ── Stats Card ───────────────────────────────────────────────────────────

  Widget _buildStatsCard(SocialState state) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _kGreenAccent, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statItem('Followers', state.stats?.followersCount ?? 0,
                    () => _showUserList(context, 'Followers')),
            _vDivider(),
            _statItem('Following', state.stats?.followingCount ?? 0,
                    () => _showUserList(context, 'Following')),
            _vDivider(),
            _statItem('Likes', state.stats?.likesCount ?? 0, null,
                icon: Icons.favorite_rounded, iconColor: Colors.red),
            _vDivider(),
            _statItem(
              'Rating',
              state.stats?.averageRating.toStringAsFixed(1) ?? '—',
              null,
              icon: Icons.star_rounded,
              iconColor: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() =>
      Container(height: 36, width: 1, color: _kGreenAccent.withOpacity(0.4));

  Widget _statItem(String label, dynamic value, VoidCallback? onTap,
      {IconData? icon, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: iconColor),
                  const SizedBox(width: 3),
                ],
                Text('$value',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            if (onTap != null)
              const Icon(Icons.keyboard_arrow_down,
                  size: 13, color: _kGreenAccent),
          ],
        ),
      ),
    );
  }

  // ── Action Buttons — Facebook-style intelligent toggle ───────────────────
  //
  //  Follow state   → "Following ✓" outlined green button (long-press to unfollow)
  //  Unfollow state → "Follow" filled green button
  //  Liked state    → "♥ Liked" red-tint label button  (tap to unlike)
  //  Unliked state  → "♡ Like"  green outline           (tap to like)

  Widget _buildActionButtons(SocialState state, SocialNotifier notifier) {
    final busy = state.isLoading;

    return Row(
      children: [
        // Follow / Unfollow
        Expanded(
          child: state.isFollowing
              ? _GreenOutlinedButton(
            label: 'Following',
            icon: Icons.check_rounded,
            iconColor: _kGreen,
            onPressed: busy ? null : () => _confirmUnfollow(context, notifier),
            tooltip: 'Tap to unfollow',
          )
              : _GreenFilledButton(
            label: 'Follow',
            icon: Icons.person_add_rounded,
            onPressed: busy ? null : () => notifier.follow(widget.userId),
          ),
        ),
        const SizedBox(width: 10),

        // Like / Unlike
        _AnimatedLikeButton(
          isLiked: state.isLiked,
          isProcessing: busy,
          onTap: () async {
            if (state.isLiked) {
              await notifier.unlike(widget.userId);
            } else {
              await notifier.like(widget.userId);
            }
          },
        ),

        const SizedBox(width: 10),

        // Message (placeholder)
        _GreenIconButton(
          icon: Icons.chat_bubble_outline_rounded,
          tooltip: 'Message',
          onPressed: () {
            // TODO: navigate to chat screen
          },
        ),
      ],
    );
  }

  void _confirmUnfollow(BuildContext context, SocialNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Unfollow'),
        content: const Text('Stop following this user?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            onPressed: () {
              Navigator.pop(ctx);
              notifier.unfollow(widget.userId);
            },
            child: const Text('Unfollow'),
          ),
        ],
      ),
    );
  }

  // ── Reviews Header ───────────────────────────────────────────────────────

  Widget _buildReviewsHeader(bool isOwnProfile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Reviews',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (!isOwnProfile)
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: _kGreen),
            onPressed: () => _showReviewDialog(context, null),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Write Review'),
          ),
      ],
    );
  }

  // ── Reviews List — own reviews are tappable ──────────────────────────────

  Widget _buildReviewsList(
      SocialState state,
      SocialNotifier notifier,
      String? currentUserId,
      ) {
    if (state.reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const Icon(Icons.rate_review_outlined,
                size: 48, color: _kGreenAccent),
            const SizedBox(height: 12),
            const Text('No reviews yet',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.reviews.length,
      itemBuilder: (context, index) {
        final review     = state.reviews[index];
        final isMyReview =
            currentUserId != null && review.reviewerId == currentUserId;

        return _ReviewCard(
          review: review,
          isMyReview: isMyReview,
          onTap: isMyReview
              ? () => _showReviewActions(context, notifier, review)
              : null,
        );
      },
    );
  }

  /// Bottom sheet with Edit / Delete options for the user's own review.
  void _showReviewActions(
      BuildContext context, SocialNotifier notifier, ReviewResponseDto review) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: _kGreenSurface,
                child: Icon(Icons.edit_outlined, color: _kGreen),
              ),
              title: const Text('Edit Review'),
              subtitle: const Text('Update your rating or comment'),
              onTap: () {
                Navigator.pop(ctx);
                _showReviewDialog(context, review);
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              title: const Text('Delete Review',
                  style: TextStyle(color: Colors.red)),
              subtitle: const Text('This cannot be undone'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, notifier, review.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _resolveDisplayName(SocialState state, dynamic currentUser) {
    if (currentUser?.id == widget.userId) {
      final name =
      '${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}'
          .trim();
      return name.isNotEmpty ? name : 'My Profile';
    }
    if (state.profileDisplayName?.isNotEmpty == true) {
      return state.profileDisplayName!;
    }
    final allKnown = [...state.followersList, ...state.followingList];
    final match = allKnown.cast<UserSummaryDto?>().firstWhere(
          (u) => u?.id == widget.userId,
      orElse: () => null,
    );
    if (match != null) {
      final name =
      '${match.firstName ?? ''} ${match.lastName ?? ''}'.trim();
      return name.isNotEmpty ? name : '@${match.username ?? widget.userId}';
    }
    return 'User Profile';
  }

  void _confirmDelete(
      BuildContext context, SocialNotifier notifier, String reviewId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              notifier.deleteReview(reviewId, widget.userId);
            },
            child: const Text('Delete'),
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(_provider);
            final users = title == 'Followers'
                ? state.followersList
                : state.followingList;
            return Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1),
                Expanded(
                  child: state.isLoading
                      ? const Center(
                      child: CircularProgressIndicator(color: _kGreen))
                      : users.isEmpty
                      ? const Center(child: Text('No users found.'))
                      : ListView.builder(
                    controller: scrollController,
                    itemCount: users.length,
                    itemBuilder: (context, i) {
                      final user = users[i];
                      return ListTile(
                        leading: user.profilePictureUrl != null
                            ? CircleAvatar(
                            backgroundImage: NetworkImage(
                                user.profilePictureUrl!))
                            : const CircleAvatar(
                            backgroundColor: _kGreenSurface,
                            child: Icon(Icons.person,
                                color: _kGreen)),
                        title: Text(
                            '${user.firstName ?? ''} ${user.lastName ?? ''}'
                                .trim()),
                        subtitle:
                        Text('@${user.username ?? 'user'}'),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(
              existing == null ? 'Write a Review' : 'Update Review',
              style: const TextStyle(color: _kGreen)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (i) => IconButton(
                    icon: Icon(
                      i < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: i < rating ? Colors.amber : Colors.grey,
                      size: 34,
                    ),
                    onPressed: () => setInnerState(() => rating = i + 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: _kGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: _kGreenSurface,
                ),
                maxLines: 4,
                maxLength: 500,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.grey))),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _kGreen),
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

// ── Review Card ──────────────────────────────────────────────────────────────
// Own reviews show a green border + "You" badge + ••• hint and are tappable.
// Other reviews are display-only.

class _ReviewCard extends StatelessWidget {
  final ReviewResponseDto review;
  final bool isMyReview;
  final VoidCallback? onTap;

  const _ReviewCard({
    required this.review,
    required this.isMyReview,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isMyReview ? _kGreenAccent : const Color(0xFFE0E0E0),
          width: isMyReview ? 1.4 : 0.8,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  review.reviewerProfilePictureUrl != null
                      ? CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                          review.reviewerProfilePictureUrl!))
                      : CircleAvatar(
                    radius: 20,
                    backgroundColor: _kGreenSurface,
                    child: Text(
                      (review.reviewerName.isNotEmpty
                          ? review.reviewerName[0]
                          : '?')
                          .toUpperCase(),
                      style: const TextStyle(
                          color: _kGreen,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Name + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(review.reviewerName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                            ),
                            if (isMyReview) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _kGreenSurface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('You',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: _kGreen,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          _fmt(review.createdAt),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  // Star badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text('${review.rating}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  // Tap-to-edit hint for own reviews
                  if (isMyReview) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.more_vert,
                        size: 18, color: Colors.grey),
                  ],
                ],
              ),
              if (review.comment != null &&
                  review.comment!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(review.comment!,
                    style: const TextStyle(fontSize: 14, height: 1.45)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

// ── Button helpers ────────────────────────────────────────────────────────────

class _GreenFilledButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _GreenFilledButton(
      {required this.label, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    style: FilledButton.styleFrom(
      backgroundColor: _kGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 13),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(label,
        style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}

class _GreenOutlinedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _GreenOutlinedButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: _kGreen,
        side: const BorderSide(color: _kGreen, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: iconColor),
      label: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600)),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}

class _GreenIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _GreenIconButton(
      {required this.icon, required this.tooltip, this.onPressed});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: _kGreenSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Icon(icon, color: _kGreen, size: 22),
        ),
      ),
    ),
  );
}

// ── Animated Like / Unlike button ────────────────────────────────────────────

class _AnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final bool isProcessing;
  final VoidCallback onTap;

  const _AnimatedLikeButton({
    required this.isLiked,
    required this.isProcessing,
    required this.onTap,
  });

  @override
  State<_AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<_AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));
  late final Animation<double> _scale = Tween<double>(begin: 1, end: 1.35)
      .chain(CurveTween(curve: Curves.easeOut))
      .animate(_ctrl);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liked = widget.isLiked;
    return ScaleTransition(
      scale: _scale,
      child: Tooltip(
        message: liked ? 'Unlike' : 'Like',
        child: Material(
          color: liked ? Colors.red.shade50 : _kGreenSurface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.isProcessing
                ? null
                : () {
              _ctrl.forward(from: 0).then((_) => _ctrl.reverse());
              widget.onTap();
            },
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: liked ? Colors.red : _kGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    liked ? 'Liked' : 'Like',
                    style: TextStyle(
                      color: liked ? Colors.red : _kGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}