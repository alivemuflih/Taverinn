import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/social_profile_logic.dart';
import '../widgets/guild_motif.dart';
import '../widgets/taverinn_icon.dart';
import 'profile_screen.dart';

class FollowListScreen extends StatefulWidget {
  const FollowListScreen({
    super.key,
    required this.userId,
    required this.showFollowers,
  });

  final String userId;
  final bool showFollowers;

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  List<Map<String, dynamic>> users = [];
  Set<String> myFollowingIds = {};
  String? updatingUserId;
  bool loading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final result = await SupabaseService.getFollowList(
        userId: widget.userId,
        followers: widget.showFollowers,
      );
      final followingIds = await SupabaseService.getMyFollowingIds();
      if (!mounted) return;
      setState(() {
        users = result;
        myFollowingIds = followingIds;
      });
    } catch (_) {
      if (mounted) setState(() => loadError = 'error');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> toggleFollow(String targetUserId) async {
    if (!SocialProfileLogic.canFollowUser(
      viewerId: SupabaseService.currentUser?.id,
      targetUserId: targetUserId,
    )) {
      return;
    }

    setState(() => updatingUserId = targetUserId);
    try {
      final isFollowing = myFollowingIds.contains(targetUserId);
      if (isFollowing) {
        await SupabaseService.unfollowUser(targetUserId);
      } else {
        await SupabaseService.followUser(targetUserId);
      }
      if (!mounted) return;
      setState(() {
        if (isFollowing) {
          myFollowingIds.remove(targetUserId);
        } else {
          myFollowingIds.add(targetUserId);
        }
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorAction)),
        );
      }
    } finally {
      if (mounted) setState(() => updatingUserId = null);
    }
  }

  Future<void> openProfile(String targetUserId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: targetUserId),
      ),
    );
    if (mounted) await load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final title =
        widget.showFollowers ? strings.followersList : strings.followingList;
    return Scaffold(
      appBar: AppBar(
        leading: TaverinnBackButton(
          label: AppLocalizations.of(context).back,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(title),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(strings.errorLoading, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: load,
                          icon: TaverinnIcon(
                            assetPath: 'assets/icons/refresh.svg',
                            semanticLabel: strings.refresh,
                          ),
                          label: Text(strings.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : users.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const TaverinnSeal(size: 34),
                            const SizedBox(height: TaverinnSpace.x3),
                            Text(
                              strings.noUsersMessage,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: load,
                      child: ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = users[index];
                          final profile = item['profiles'];
                          final userId = (profile is Map
                                  ? profile['id']
                                  : widget.showFollowers
                                      ? item['follower_id']
                                      : item['following_id'])
                              .toString();
                          final username = profile is Map
                              ? profile['username']?.toString() ??
                                  strings.userFallback
                              : strings.userFallback;
                          final avatarUrl = profile is Map
                              ? profile['avatar_url']?.toString()
                              : null;
                          final isFollowing = SocialProfileLogic.isFollowing(
                            followingIds: myFollowingIds,
                            targetUserId: userId,
                          );
                          final isSelf =
                              userId == SupabaseService.currentUser?.id;

                          return ListTile(
                            key: ValueKey('follow_user_$userId'),
                            onTap: () => openProfile(userId),
                            leading: CircleAvatar(
                              backgroundImage:
                                  avatarUrl == null || avatarUrl.isEmpty
                                      ? null
                                      : NetworkImage(avatarUrl),
                              child: avatarUrl == null || avatarUrl.isEmpty
                                  ? Text(username.isEmpty
                                      ? 'U'
                                      : username[0].toUpperCase())
                                  : null,
                            ),
                            title: Text(username),
                            trailing: isSelf
                                ? null
                                : TextButton(
                                    onPressed: updatingUserId == userId
                                        ? null
                                        : () => toggleFollow(userId),
                                    key: ValueKey('follow_toggle_$userId'),
                                    child: Text(
                                      updatingUserId == userId
                                          ? strings.updating
                                          : isFollowing
                                              ? strings.following
                                              : strings.follow,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
    );
  }
}
