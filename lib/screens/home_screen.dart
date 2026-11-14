import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/party_room_logic.dart';
import '../widgets/guild_motif.dart';
import '../widgets/party_notice.dart';
import 'party_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> games = [];
  bool loading = true;
  String? loadError;
  String? selectedGame;
  String? selectedRank;
  String? selectedLanguage;

  final ranks = [
    'Iron',
    'Bronze',
    'Silver',
    'Gold',
    'Platinum',
    'Diamond',
    'Ascendant',
    'Immortal',
    'Radiant',
    'Mythic',
    'Legend',
    'Epic',
  ];

  final languages = ['Indonesia', 'English', 'Japanese', 'Other'];

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
      final loadedGames = await SupabaseService.getGames();
      final loadedPosts = await SupabaseService.getLfgPosts(
        gameId: selectedGame,
        rank: selectedRank,
        language: selectedLanguage,
      );
      if (!mounted) return;
      games = loadedGames;
      posts = loadedPosts;
    } catch (_) {
      if (mounted) {
        setState(() => loadError = 'error');
        showSnack(AppLocalizations.of(context).errorLoading);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String gameName(Map<String, dynamic> post) {
    final fallback = AppLocalizations.of(context).unknownGame;
    final game = post['games'];
    return game is Map ? (game['name'] ?? fallback).toString() : fallback;
  }

  String username(Map<String, dynamic> post) {
    final profile = post['profiles'];
    final fallback = AppLocalizations.of(context).userFallback;
    return profile is Map
        ? (profile['username'] ?? fallback).toString()
        : fallback;
  }

  String displayLanguage(String value) {
    final strings = AppLocalizations.of(context);
    return switch (value) {
      'Indonesia' => strings.languageIndonesia,
      'English' => strings.languageEnglish,
      'Japanese' => strings.languageJapanese,
      'Other' => strings.other,
      _ => value,
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final pageInset = MediaQuery.sizeOf(context).width >= 720 ? 32.0 : 16.0;
    return RefreshIndicator(
      onRefresh: load,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Row(
              children: [
                TaverinnSeal(size: 28),
                const SizedBox(width: TaverinnSpace.x2),
                Text(
                  'Taverinn',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'serif',
                      ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: strings.refresh,
                onPressed: load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                pageInset,
                TaverinnSpace.x3,
                pageInset,
                TaverinnSpace.x1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.homeTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: TaverinnSpace.x1),
                  Text(strings.feedDescription),
                  const SizedBox(height: TaverinnSpace.x4),
                  Wrap(
                    spacing: TaverinnSpace.x2,
                    runSpacing: TaverinnSpace.x2,
                    children: [
                      _filter(
                        label: strings.game,
                        value: selectedGame == null
                            ? strings.all
                            : games
                                .firstWhere(
                                  (g) => g['id'].toString() == selectedGame,
                                  orElse: () => {'name': strings.game},
                                )['name']
                                .toString(),
                        onTap: _chooseGame,
                      ),
                      _filter(
                        label: strings.rank,
                        value: selectedRank ?? strings.all,
                        onTap: _chooseRank,
                      ),
                      _filter(
                        label: strings.languageField,
                        value: selectedLanguage == null
                            ? strings.all
                            : displayLanguage(selectedLanguage!),
                        onTap: _chooseLanguage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (loadError != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(strings.errorLoading, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: load,
                        icon: const Icon(Icons.refresh),
                        label: Text(strings.retry),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (posts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(TaverinnSpace.x6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TaverinnSeal(size: 34),
                      const SizedBox(height: TaverinnSpace.x3),
                      Text(
                        strings.noParties,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: TaverinnSpace.x3),
                      if (selectedGame != null ||
                          selectedRank != null ||
                          selectedLanguage != null)
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedGame = null;
                              selectedRank = null;
                              selectedLanguage = null;
                            });
                            load();
                          },
                          icon: const Icon(Icons.filter_alt_off_outlined),
                          label: Text(strings.clearFilters),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: load,
                          icon: const Icon(Icons.refresh),
                          label: Text(strings.refresh),
                        ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                pageInset,
                TaverinnSpace.x3,
                pageInset,
                TaverinnSpace.x6,
              ),
              sliver: SliverList.separated(
                itemCount: posts.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: TaverinnSpace.x3),
                itemBuilder: (_, i) {
                  final post = posts[i];
                  return _postCard(post);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _filter({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      key: ValueKey('feed_filter_${label.toLowerCase()}'),
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 44),
        padding: const EdgeInsets.symmetric(horizontal: TaverinnSpace.x3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label · $value', maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(width: TaverinnSpace.x1),
          const Icon(Icons.expand_more, size: 18),
        ],
      ),
    );
  }

  Widget _postCard(Map<String, dynamic> post) {
    final current = (post['current_players'] as num?)?.toInt() ?? 1;
    final max = (post['max_players'] as num?)?.toInt() ?? 5;

    return PartyNotice(
      key: ValueKey('party_card_${post['id']}'),
      gameName: gameName(post),
      rank: (post['rank'] ?? '-').toString(),
      mode: (post['mode'] ?? '-').toString(),
      language: (post['language'] ?? '-').toString(),
      playTime: post['play_time']?.toString(),
      currentPlayers: current,
      maxPlayers: max,
      host: '@${username(post)}',
      isOpen: post['status']?.toString().toLowerCase() != 'full',
      description: post['description']?.toString() ?? '',
      onTap: () => _detail(post),
    );
  }

  Future<void> _chooseGame() async {
    final strings = AppLocalizations.of(context);
    final result = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => ListView(
        children: [
          ListTile(
            key: const ValueKey('feed_game_filter_all'),
            title: Text(strings.allGames),
            onTap: () => Navigator.pop(context, '__all__'),
          ),
          ...games.map(
            (game) => ListTile(
              key: ValueKey('feed_game_filter_${game['id']}'),
              title: Text(game['name'].toString()),
              onTap: () => Navigator.pop(context, game['id'].toString()),
            ),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    setState(() => selectedGame = result == '__all__' ? null : result);
    await load();
  }

  Future<void> _chooseRank() async {
    final strings = AppLocalizations.of(context);
    final result = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => ListView(
        children: [
          ListTile(
            key: const ValueKey('feed_rank_filter_all'),
            title: Text(strings.allRanks),
            onTap: () => Navigator.pop(context, '__all__'),
          ),
          ...ranks.map(
            (rank) => ListTile(
              key: ValueKey('feed_rank_filter_$rank'),
              title: Text(rank),
              onTap: () => Navigator.pop(context, rank),
            ),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    setState(() => selectedRank = result == '__all__' ? null : result);
    await load();
  }

  Future<void> _chooseLanguage() async {
    final strings = AppLocalizations.of(context);
    final result = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => ListView(
        children: [
          ListTile(
            key: const ValueKey('feed_language_filter_all'),
            title: Text(strings.allLanguages),
            onTap: () => Navigator.pop(context, '__all__'),
          ),
          ...languages.map(
            (language) => ListTile(
              key: ValueKey('feed_language_filter_$language'),
              title: Text(displayLanguage(language)),
              onTap: () => Navigator.pop(context, language),
            ),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    setState(() => selectedLanguage = result == '__all__' ? null : result);
    await load();
  }

  void _detail(Map<String, dynamic> post) {
    final strings = AppLocalizations.of(context);
    final currentPlayers = (post['current_players'] as num?)?.toInt() ?? 1;
    final maxPlayers = (post['max_players'] as num?)?.toInt() ?? 5;
    final canJoin = PartyRoomLogic.hasAvailableSlot(
      currentPlayers: currentPlayers,
      maxPlayers: maxPlayers,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(TaverinnSpace.x4),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.partyDetails,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: TaverinnSpace.x2),
              Text(
                gameName(post),
                style: Theme.of(context).textTheme.headlineSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: TaverinnSpace.x2),
              const GuildRule(),
              const SizedBox(height: TaverinnSpace.x3),
              Wrap(
                spacing: TaverinnSpace.x2,
                runSpacing: TaverinnSpace.x1,
                children: [
                  Text('${post['mode']}'),
                  Text('·',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                  Text('${post['rank']}'),
                  Text('${post['language']}'),
                  if (post['play_time'] != null)
                    Text(post['play_time'].toString()),
                ],
              ),
              const SizedBox(height: TaverinnSpace.x3),
              Text(post['description'] ?? ''),
              const SizedBox(height: TaverinnSpace.x3),
              Text(
                strings.playerCount(currentPlayers, maxPlayers),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TaverinnSpace.x4),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const ValueKey('party_join_button'),
                  icon: const Icon(Icons.group_add_outlined),
                  onPressed: canJoin
                      ? () async {
                          Navigator.pop(context);
                          try {
                            await SupabaseService.joinParty(
                                post['id'].toString());
                            if (mounted) {
                              showSnack(strings.joinSuccess);
                              await load();
                              if (!mounted) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PartyRoomScreen(
                                    postId: post['id'].toString(),
                                  ),
                                ),
                              );
                            }
                          } catch (_) {
                            if (mounted) showSnack(strings.joinFailure);
                          }
                        }
                      : null,
                  label: Text(canJoin ? strings.joinParty : strings.partyFull),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
