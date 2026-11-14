import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../utils/social_profile_logic.dart';
import 'auth_screen.dart';
import 'follow_list_screen.dart';
import 'game_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  Map<String, dynamic> stats = {};
  List<Map<String, dynamic>> userGames = [];
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool loading = true;
  bool updatingFollow = false;

  String get targetUserId => widget.userId ?? SupabaseService.currentUser!.id;
  bool get isOwnProfile => targetUserId == SupabaseService.currentUser?.id;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (mounted) setState(() => loading = true);
    try {
      final loadedProfile = await SupabaseService.getProfile(
        userId: targetUserId,
      );
      final loadedGames = await SupabaseService.getUserGames(
        userId: targetUserId,
      );
      final loadedStats = await SupabaseService.getUserStats(targetUserId);
      final followCounts = await SupabaseService.getFollowCounts(targetUserId);
      final followsTarget = isOwnProfile
          ? false
          : await SupabaseService.isFollowing(targetUserId);

      if (!mounted) return;
      setState(() {
        profile = loadedProfile;
        userGames = loadedGames;
        stats = loadedStats ?? {};
        followers = followCounts['followers'] ?? 0;
        following = followCounts['following'] ?? 0;
        isFollowing = followsTarget;
      });
    } catch (e) {
      if (mounted) showSnack('Gagal memuat profile: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> logout() async {
    await SupabaseService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  Future<void> toggleFollow() async {
    if (!SocialProfileLogic.canFollowUser(
      viewerId: SupabaseService.currentUser?.id,
      targetUserId: targetUserId,
    )) {
      return;
    }

    setState(() => updatingFollow = true);
    try {
      if (isFollowing) {
        await SupabaseService.unfollowUser(targetUserId);
      } else {
        await SupabaseService.followUser(targetUserId);
      }
      await load();
    } catch (e) {
      if (mounted) showSnack('Gagal memperbarui follow: $e');
    } finally {
      if (mounted) setState(() => updatingFollow = false);
    }
  }

  Future<void> openFollowList({required bool showFollowers}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FollowListScreen(
          userId: targetUserId,
          showFollowers: showFollowers,
        ),
      ),
    );
    if (mounted) await load();
  }

  Widget _followCount({
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                '$count',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityStat(String label, int value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Column(
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = profile?['username']?.toString() ?? 'User';
    final avatarUrl = profile?['avatar_url']?.toString();
    final email = isOwnProfile ? SupabaseService.currentUser?.email ?? '' : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? 'Profile' : 'Player Profile'),
        actions: [
          if (isOwnProfile)
            IconButton(
              onPressed: logout,
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 42,
                      backgroundImage: avatarUrl == null || avatarUrl.isEmpty
                          ? null
                          : NetworkImage(avatarUrl),
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? Text(
                              username.isEmpty ? 'U' : username[0].toUpperCase(),
                              style: const TextStyle(fontSize: 30),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      username,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (email.isNotEmpty) Center(child: Text(email)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _followCount(
                        label: 'Followers',
                        count: followers,
                        onTap: () => openFollowList(showFollowers: true),
                      ),
                      _followCount(
                        label: 'Following',
                        count: following,
                        onTap: () => openFollowList(showFollowers: false),
                      ),
                    ],
                  ),
                  if (!isOwnProfile) ...[
                    const SizedBox(height: 4),
                    OutlinedButton(
                      onPressed: updatingFollow ? null : toggleFollow,
                      child: Text(
                        updatingFollow
                            ? 'Memperbarui...'
                            : isFollowing
                                ? 'Following'
                                : 'Follow',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Activity Statistics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      _activityStat(
                        'Parties Created',
                        (stats['parties_created'] as num?)?.toInt() ?? 0,
                      ),
                      _activityStat(
                        'Parties Joined',
                        (stats['parties_joined'] as num?)?.toInt() ?? 0,
                      ),
                      _activityStat(
                        'Players Met',
                        (stats['players_met'] as num?)?.toInt() ?? 0,
                      ),
                    ],
                  ),
                  if (isOwnProfile) ...[
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GameDashboardScreen(),
                          ),
                        );
                        if (mounted) await load();
                      },
                      icon: const Icon(Icons.sports_esports),
                      label: const Text('Game Dashboard'),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    isOwnProfile ? 'My Games' : 'Games',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (userGames.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          isOwnProfile
                              ? 'Belum ada game di profile kamu.'
                              : 'Belum ada game yang ditampilkan.',
                        ),
                      ),
                    )
                  else
                    ...userGames.map((item) {
                      final game = item['games'];
                      final gameName = game is Map
                          ? game['name']?.toString() ?? 'Game'
                          : 'Game';
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(gameName[0].toUpperCase()),
                          ),
                          title: Text(gameName),
                          subtitle: Text(
                            'Rank: ${item['rank']}\n'
                            'Role: ${item['role']}\n'
                            'Win Rate: ${item['win_rate']}%',
                          ),
                          isThreeLine: true,
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
