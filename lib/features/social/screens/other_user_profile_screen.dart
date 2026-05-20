import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/social/providers/social_provider.dart';
import 'package:garbigo_frontend/features/social/models/social_action_request.dart';
import 'package:garbigo_frontend/features/social/models/review_response_dto.dart';
import 'package:garbigo_frontend/features/social/models/review_update_request.dart';

const _kGreen = Color(0xFF2E7D32);
const _kGreenLight = Color(0xFF4CAF50);
const _kGreenSurface = Color(0xFFE8F5E9);
const _kGreenAccent = Color(0xFF81C784);

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
  final MapController _mapController = MapController();

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
    final currentUser = ref.watch(userProvider).user;
    final isOwnProfile = currentUser?.id == widget.userId;
    final displayName = _resolveDisplayName(socialState, currentUser);

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: _kGreenSurface,
      body: socialState.isLoading && socialState.stats == null
          ? const Center(child: CircularProgressIndicator(color: _kGreen))
          : RefreshIndicator(
        color: _kGreen,
        onRefresh: () =>
            ref.read(_provider.notifier).refreshAll(widget.userId),
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(displayName, socialState),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 40 : 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCard(socialState),
                    const SizedBox(height: 20),

                    if (!isOwnProfile) ...[
                      _buildActionButtons(socialState),
                      const SizedBox(height: 24),
                    ],

                    _buildLocationCard(socialState),
                    const SizedBox(height: 24),

                    _buildReviewsHeader(isOwnProfile),
                    const SizedBox(height: 12),
                    _buildReviewsList(socialState, currentUser?.id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(String displayName, SocialState state) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: _kGreen,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_outlined, size: 28),
        tooltip: 'Go to Home',
        onPressed: () => context.go('/dashboard/client'),
      ),
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
                _buildAvatar(state),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  state.profileEmail ?? widget.userId,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(SocialState state) {
    final url = state.profileAvatarUrl;
    return CircleAvatar(
      radius: 56,
      backgroundColor: Colors.white24,
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null
          ? const Icon(Icons.person, size: 56, color: Colors.white)
          : null,
    );
  }

  Widget _buildStatsCard(SocialState state) {
    final stats = state.stats;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statItem(
              icon: Icons.people,
              value: stats?.followersCount ?? 0,
              label: 'Followers',
              onTap: () => _showUserList('Followers'),
            ),
            _statItem(
              icon: Icons.person_outline,
              value: stats?.followingCount ?? 0,
              label: 'Following',
              onTap: () => _showUserList('Following'),
            ),
            _statItem(
              icon: Icons.favorite,
              value: stats?.likesCount ?? 0,
              label: 'Likes',
              color: Colors.red,
            ),
            _statItem(
              icon: Icons.star,
              value: stats?.averageRating?.toStringAsFixed(1) ?? '—',
              label: 'Rating',
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required dynamic value,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color ?? _kGreen),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(SocialState state) {
    final busy = state.isLoading;
    final notifier = ref.read(_provider.notifier);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: state.isFollowing
                  ? _GreenOutlinedButton(
                label: 'Unfollow',
                icon: Icons.person_remove_rounded,
                iconColor: Colors.red,
                onPressed: busy ? null : () => _confirmUnfollow(notifier),
              )
                  : _GreenFilledButton(
                label: 'Follow',
                icon: Icons.person_add_rounded,
                onPressed: busy ? null : () => notifier.follow(widget.userId),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnimatedLikeButton(
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
            ),
            const SizedBox(width: 12),
            _GreenIconButton(
              icon: Icons.chat_bubble_outline_rounded,
              tooltip: 'Write Review',
              onPressed: () => _showReviewDialog(null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(SocialState state) {
    final location = state.currentLocation;

    if (location == null) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.location_off, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('Location not available',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    final position = LatLng(location.latitude, location.longitude);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Last updated: ${location.timestamp?.toLocal().toString().substring(0, 16) ?? "Recently"}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: position,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.garbigo.frontend',
                      tileProvider: CancellableNetworkTileProvider(),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: position,
                          width: 48,
                          height: 48,
                          child: const Tooltip(
                            message: 'Collector Live Location',
                            child: Icon(
                              Icons.location_pin,
                              color: _kGreen,
                              size: 48,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildReviewsHeader(bool isOwnProfile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Reviews',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        if (!isOwnProfile)
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: _kGreen),
            onPressed: () => _showReviewDialog(null),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Write Review'),
          ),
      ],
    );
  }

  Widget _buildReviewsList(SocialState state, String? currentUserId) {
    if (state.reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(Icons.rate_review_outlined, size: 60, color: _kGreenAccent),
              SizedBox(height: 16),
              Text('No reviews yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.reviews.length,
      itemBuilder: (context, index) {
        final review = state.reviews[index];
        final isMyReview =
            currentUserId != null && review.reviewerId == currentUserId;

        return _ReviewCard(
          review: review,
          isMyReview: isMyReview,
          onEdit: isMyReview ? () => _showReviewDialog(review) : null,
          onDelete: isMyReview
              ? () => _confirmDelete(review.id, widget.userId)
              : null,
        );
      },
    );
  }

  // ==================== DIALOGS ====================

  void _confirmUnfollow(SocialNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Unfollow'),
        content: const Text('Stop following this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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

  void _confirmDelete(String reviewId, String targetId) {
    final notifier = ref.read(_provider.notifier);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              notifier.deleteReview(reviewId, targetId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _resolveDisplayName(SocialState state, dynamic currentUser) {
    if (currentUser?.id == widget.userId) {
      final name =
      '${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}'
          .trim();
      return name.isNotEmpty ? name : 'My Profile';
    }
    return state.profileDisplayName ?? 'User Profile';
  }

  void _showReviewDialog(ReviewResponseDto? existing) {
    int rating = existing?.rating ?? 5;
    final commentController = TextEditingController(text: existing?.comment);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            existing == null ? 'Write a Review' : 'Update Review',
            style: const TextStyle(color: _kGreen, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (i) => IconButton(
                    icon: Icon(
                      i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: i < rating ? Colors.amber : Colors.grey,
                      size: 36,
                    ),
                    onPressed: () => setInnerState(() => rating = i + 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: _kGreenSurface,
                ),
                maxLines: 5,
                maxLength: 500,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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

  void _showUserList(String title) {
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
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(_provider);
            final users = title == 'Followers' ? state.followersList : state.followingList;
            return Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                Expanded(
                  child: users.isEmpty
                      ? const Center(child: Text('No users found'))
                      : ListView.builder(
                    controller: scrollController,
                    itemCount: users.length,
                    itemBuilder: (context, i) {
                      final user = users[i];
                      return ListTile(
                        leading: user.profilePictureUrl != null
                            ? CircleAvatar(backgroundImage: NetworkImage(user.profilePictureUrl!))
                            : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text('${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()),
                        subtitle: Text('@${user.username ?? 'user'}'),
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
}

// ====================== REUSABLE WIDGETS ======================

class _ReviewCard extends StatelessWidget {
  final ReviewResponseDto review;
  final bool isMyReview;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ReviewCard({
    required this.review,
    required this.isMyReview,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: review.reviewerProfilePictureUrl != null
                      ? NetworkImage(review.reviewerProfilePictureUrl!)
                      : null,
                  child: review.reviewerProfilePictureUrl == null
                      ? Text(
                    review.reviewerName.isNotEmpty
                        ? review.reviewerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(review.reviewerName,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          if (isMyReview)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text('You',
                                  style: TextStyle(
                                      color: _kGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      Text(
                        '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${review.rating}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.comment!, style: const TextStyle(height: 1.5)),
            ],
            if (isMyReview)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: _kGreen), onPressed: onEdit),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: onDelete),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _GreenFilledButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _GreenFilledButton({required this.label, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    style: FilledButton.styleFrom(
      backgroundColor: _kGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onPressed: onPressed,
    icon: Icon(icon, size: 20),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}

class _GreenOutlinedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;

  const _GreenOutlinedButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      foregroundColor: _kGreen,
      side: const BorderSide(color: _kGreen, width: 1.5),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onPressed: onPressed,
    icon: Icon(icon, size: 20, color: iconColor),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}

class _GreenIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _GreenIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

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
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: _kGreen, size: 24),
        ),
      ),
    ),
  );
}

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: liked ? Colors.red : _kGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    liked ? 'Unlike' : 'Like',
                    style: TextStyle(
                      color: liked ? Colors.red : _kGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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