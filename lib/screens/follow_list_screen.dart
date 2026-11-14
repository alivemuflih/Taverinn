import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../utils/social_profile_logic.dart';
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

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat daftar: $e')),
        );
      }
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui follow: $e')),
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
    final title = widget.showFollowers ? 'Followers' : 'Following';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? Center(child: Text('Belum ada $title.'))
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
                          ? profile['username']?.toString() ?? 'User'
                          : 'User';
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
                        onTap: () => openProfile(userId),
                        leading: CircleAvatar(
                          backgroundImage: avatarUrl == null || avatarUrl.isEmpty
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
                                child: Text(
                                  updatingUserId == userId
                                      ? '...'
                                      : isFollowing
                                          ? 'Following'
                                          : 'Follow',
                                ),
                              ),
                      );
                    },
                  ),
                ),
    );
  }
}
