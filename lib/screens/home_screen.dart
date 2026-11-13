import 'package:flutter/material.dart';

import '../services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> games = [];
  bool loading = true;
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
    setState(() => loading = true);
    try {
      games = await SupabaseService.getGames();
      posts = await SupabaseService.getLfgPosts(
        gameId: selectedGame,
        rank: selectedRank,
        language: selectedLanguage,
      );
    } catch (e) {
      if (mounted) showSnack('Gagal memuat data: $e');
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
    return game is Map ? (game['name'] ?? 'Unknown Game').toString() : 'Unknown Game';
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
                  const Text('Temukan pemain berdasarkan game, rank, dan bahasa.'),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filter(
                          label: 'Game',
                          value: selectedGame == null
                              ? 'Semua'
                              : games.firstWhere(
                                  (g) => g['id'].toString() == selectedGame,
                                  orElse: () => {'name': 'Game'},
                                )['name'].toString(),
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
            onTap: () => Navigator.pop(context, null),
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
    setState(() => selectedGame = result);
    await load();
  }

  Future<void> _chooseRank() async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => ListView(
        children: [
          ListTile(
            title: const Text('Semua rank'),
            onTap: () => Navigator.pop(context, null),
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
    setState(() => selectedRank = result);
    await load();
  }

  Future<void> _chooseLanguage() async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => ListView(
        children: [
          ListTile(
            title: const Text('Semua bahasa'),
            onTap: () => Navigator.pop(context, null),
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
    setState(() => selectedLanguage = result);
    await load();
  }

  void _detail(Map<String, dynamic> post) {
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
                  label: const Text('Join Party'),
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await SupabaseService.joinParty(post['id'].toString());
                      if (mounted) {
                        showSnack('Berhasil bergabung ke party.');
                        await load();
                      }
                    } catch (e) {
                      if (mounted) showSnack('Tidak bisa join: $e');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
