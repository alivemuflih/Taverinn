import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../utils/party_room_logic.dart';
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
    } catch (e) {
      if (mounted) {
        setState(() => loadError = 'Gagal memuat data: $e');
        showSnack('Gagal memuat data: $e');
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
    final game = post['games'];
    return game is Map
        ? (game['name'] ?? 'Unknown Game').toString()
        : 'Unknown Game';
  }

  String username(Map<String, dynamic> post) {
    final profile = post['profiles'];
    return profile is Map ? (profile['username'] ?? 'User').toString() : 'User';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: load,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text(
              'Taverinn',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cari party',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                      'Temukan pemain berdasarkan game, rank, dan bahasa.'),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filter(
                          label: 'Game',
                          value: selectedGame == null
                              ? 'Semua'
                              : games
                                  .firstWhere(
                                    (g) => g['id'].toString() == selectedGame,
                                    orElse: () => {'name': 'Game'},
                                  )['name']
                                  .toString(),
                          onTap: () => _chooseGame(),
                        ),
                        _filter(
                          label: 'Rank',
                          value: selectedRank ?? 'Semua',
                          onTap: () => _chooseRank(),
                        ),
                        _filter(
                          label: 'Bahasa',
                          value: selectedLanguage ?? 'Semua',
                          onTap: () => _chooseLanguage(),
                        ),
                      ],
                    ),
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
                      Text(loadError!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (posts.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('Belum ada party yang sesuai filter.'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.separated(
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text('$label: $value'),
        onPressed: onTap,
      ),
    );
  }

  Widget _postCard(Map<String, dynamic> post) {
    final current = post['current_players'] ?? 1;
    final max = post['max_players'] ?? 5;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _detail(post),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(gameName(post)[0].toUpperCase()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      gameName(post),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(label: Text(post['status'] ?? 'open')),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Chip(
                    avatar: const Icon(Icons.emoji_events, size: 16),
                    label: Text((post['rank'] ?? '-').toString()),
                  ),
                  Chip(
                    avatar: const Icon(Icons.sports_esports, size: 16),
                    label: Text((post['mode'] ?? '-').toString()),
                  ),
                  Chip(
                    avatar: const Icon(Icons.translate, size: 16),
                    label: Text((post['language'] ?? '-').toString()),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post['description'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.groups_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text('$current/$max pemain'),
                  const Spacer(),
                  Text('@${username(post)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseGame() async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => ListView(
        children: [
          ListTile(
            title: const Text('Semua game'),
            onTap: () => Navigator.pop(context, '__all__'),
          ),
          ...games.map(
            (game) => ListTile(
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
    final result = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => ListView(
        children: [
          ListTile(
            title: const Text('Semua rank'),
            onTap: () => Navigator.pop(context, '__all__'),
          ),
          ...ranks.map(
            (rank) => ListTile(
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
    final result = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => ListView(
        children: [
          ListTile(
            title: const Text('Semua bahasa'),
            onTap: () => Navigator.pop(context, '__all__'),
          ),
          ...languages.map(
            (language) => ListTile(
              title: Text(language),
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
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gameName(post),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('${post['mode']} • ${post['rank']}'),
              Text('${post['language']} • ${post['play_time']}'),
              const SizedBox(height: 12),
              Text(post['description'] ?? ''),
              const SizedBox(height: 12),
              Text(
                '${post['current_players']}/${post['max_players']} pemain',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.group_add),
                  onPressed: canJoin
                      ? () async {
                    Navigator.pop(context);
                    try {
                      await SupabaseService.joinParty(post['id'].toString());
                      if (mounted) {
                        showSnack('Berhasil bergabung ke party.');
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
                    } catch (e) {
                      if (mounted) showSnack('Tidak bisa join: $e');
                    }
                  }
                      : null,
                  label: Text(canJoin ? 'Join Party' : 'Party penuh'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
