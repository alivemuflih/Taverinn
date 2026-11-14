import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/app_preferences.dart';
import '../utils/social_profile_logic.dart';
import '../widgets/guild_motif.dart';
import '../widgets/taverinn_icon.dart';
import 'auth_screen.dart';
import 'follow_list_screen.dart';
import 'game_dashboard_screen.dart';
import 'settings_screen.dart';

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
  String? loadError;

  String get targetUserId => widget.userId ?? SupabaseService.currentUser!.id;
  bool get isOwnProfile => targetUserId == SupabaseService.currentUser?.id;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (mounted) {
      setState(() {
        loading = true;
        loadError = null;
      });
    }
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
      if (mounted) setState(() => loadError = 'error');
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
    } catch (_) {
      if (mounted) showSnack(AppLocalizations.of(context).errorAction);
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
        key: ValueKey('profile_${label.toLowerCase()}_count'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TaverinnSpace.x3),
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
        padding: const EdgeInsets.symmetric(
          horizontal: TaverinnSpace.x1,
          vertical: TaverinnSpace.x3,
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: TaverinnSpace.x1),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final username = profile?['username']?.toString() ?? strings.userFallback;
    final avatarUrl = profile?['avatar_url']?.toString();
    final email = isOwnProfile ? SupabaseService.currentUser?.email ?? '' : '';

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isOwnProfile ? strings.profileTitle : strings.playerProfile),
        actions: [
          if (isOwnProfile)
            IconButton(
              key: const ValueKey('profile_logout_button'),
              onPressed: logout,
              tooltip: strings.logout,
              icon: TaverinnIcon(
                assetPath: 'assets/icons/logout.svg',
                semanticLabel: strings.logout,
              ),
            ),
        ],
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
              : RefreshIndicator(
                  onRefresh: load,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 38,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                backgroundImage:
                                    avatarUrl == null || avatarUrl.isEmpty
                                        ? null
                                        : NetworkImage(avatarUrl),
                                child: avatarUrl == null || avatarUrl.isEmpty
                                    ? Text(
                                        username.isEmpty
                                            ? 'U'
                                            : username[0].toUpperCase(),
                                        style: const TextStyle(fontSize: 28),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: TaverinnSpace.x4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      key: const ValueKey('profile_identity'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    if (email.isNotEmpty)
                                      Text(
                                        email,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    if (!isOwnProfile) ...[
                                      const SizedBox(height: TaverinnSpace.x2),
                                      OutlinedButton.icon(
                                        key: const ValueKey(
                                          'profile_follow_button',
                                        ),
                                        onPressed: updatingFollow
                                            ? null
                                            : toggleFollow,
                                        icon: const TaverinnIcon(
                                          assetPath: 'assets/icons/follow.svg',
                                          size: TaverinnIconSize.setting,
                                        ),
                                        label: Text(
                                          updatingFollow
                                              ? strings.updating
                                              : isFollowing
                                                  ? strings.unfollow
                                                  : strings.follow,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: TaverinnSpace.x4,
                            ),
                            child: GuildRule(),
                          ),
                          Row(
                            children: [
                              _followCount(
                                label: strings.followers,
                                count: followers,
                                onTap: () =>
                                    openFollowList(showFollowers: true),
                              ),
                              _followCount(
                                label: strings.following,
                                count: following,
                                onTap: () =>
                                    openFollowList(showFollowers: false),
                              ),
                            ],
                          ),
                          const SizedBox(height: TaverinnSpace.x6),
                          Text(
                            strings.activity,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: TaverinnSpace.x2),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              border: Border.symmetric(
                                horizontal: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                _activityStat(
                                  strings.partiesCreated,
                                  (stats['parties_created'] as num?)?.toInt() ??
                                      0,
                                ),
                                VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                _activityStat(
                                  strings.partiesJoined,
                                  (stats['parties_joined'] as num?)?.toInt() ??
                                      0,
                                ),
                                VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                _activityStat(
                                  strings.playersMet,
                                  (stats['players_met'] as num?)?.toInt() ?? 0,
                                ),
                              ],
                            ),
                          ),
                          if (isOwnProfile) ...[
                            const SizedBox(height: TaverinnSpace.x3),
                            OutlinedButton.icon(
                              key: const ValueKey('profile_game_dashboard'),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const GameDashboardScreen(),
                                  ),
                                );
                                if (mounted) await load();
                              },
                              icon: TaverinnIcon(
                                assetPath: 'assets/icons/game.svg',
                                semanticLabel: strings.game,
                              ),
                              label: Text(strings.manageGames),
                            ),
                          ],
                          const SizedBox(height: TaverinnSpace.x8),
                          Text(
                            isOwnProfile ? strings.myGames : strings.games,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: TaverinnSpace.x3),
                          if (userGames.isEmpty)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(TaverinnSpace.x4),
                                child: Text(
                                  isOwnProfile
                                      ? strings.noGamesInProfile
                                      : strings.noGamesShown,
                                ),
                              ),
                            )
                          else
                            ...userGames.map((item) {
                              final game = item['games'];
                              final gameName = game is Map
                                  ? game['name']?.toString() ?? strings.game
                                  : strings.game;
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: TaverinnSpace.x3,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      TaverinnRadius.compact,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(
                                    TaverinnSpace.x4,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        gameName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: TaverinnSpace.x2),
                                      Text(
                                        '${strings.rank} ${item['rank']} · ${item['role']}\n'
                                        '${item['games_played']} ${strings.gamesPlayed} · '
                                        '${item['win_rate']}% ${strings.winRate}',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          if (isOwnProfile) ...[
                            const SizedBox(height: TaverinnSpace.x6),
                            const GuildRule(),
                            const SizedBox(height: TaverinnSpace.x2),
                            ListTile(
                              key: const ValueKey('profile_settings'),
                              contentPadding: EdgeInsets.zero,
                              leading: TaverinnIcon(
                                assetPath: 'assets/icons/settings.svg',
                                size: TaverinnIconSize.setting,
                                semanticLabel: strings.settings,
                              ),
                              title: Text(strings.settings),
                              subtitle: Text(strings.settingsSubtitle),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SettingsScreen(
                                      preferences:
                                          AppPreferencesScope.of(context),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
