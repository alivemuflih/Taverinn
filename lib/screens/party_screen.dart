import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/party_notice.dart';
import '../widgets/guild_motif.dart';
import 'party_room_screen.dart';

class PartyScreen extends StatefulWidget {
  const PartyScreen({super.key});

  @override
  State<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  bool loading = true;
  String? loadError;
  List<Map<String, dynamic>> parties = [];

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
      final result = await SupabaseService.getMyParties();
      if (!mounted) return;
      setState(() => parties = result);
    } catch (e) {
      if (mounted) setState(() => loadError = 'Gagal memuat party: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.myParty),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
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
                          icon: const Icon(Icons.refresh),
                          label: Text(strings.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : parties.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const TaverinnSeal(size: 34),
                            const SizedBox(height: TaverinnSpace.x3),
                            Text(
                              strings.noJoinedParties,
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
                        padding: const EdgeInsets.all(16),
                        itemCount: parties.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: TaverinnSpace.x3),
                        itemBuilder: (_, index) {
                          final item = parties[index];
                          final post = item['lfg_posts'];
                          final game = post is Map ? post['games'] : null;
                          final postProfile =
                              post is Map ? post['profiles'] : null;
                          final postId = item['post_id'].toString();
                          final host = postProfile is Map
                              ? postProfile['username']?.toString() ??
                                  strings.host
                              : strings.host;
                          return PartyNotice(
                            key: ValueKey('my_party_card_${item['post_id']}'),
                            gameName: game is Map
                                ? game['name']?.toString() ?? strings.game
                                : strings.game,
                            rank: post is Map
                                ? post['rank']?.toString() ?? '-'
                                : '-',
                            mode: post is Map
                                ? post['mode']?.toString() ?? '-'
                                : '-',
                            language: post is Map
                                ? post['language']?.toString() ?? '-'
                                : '-',
                            playTime: post is Map
                                ? post['play_time']?.toString()
                                : null,
                            currentPlayers: post is Map
                                ? (post['current_players'] as num?)?.toInt() ??
                                    1
                                : 1,
                            maxPlayers: post is Map
                                ? (post['max_players'] as num?)?.toInt() ?? 5
                                : 5,
                            host: postProfile is Map ? '@$host' : null,
                            isOpen: post is Map &&
                                post['status']?.toString().toLowerCase() !=
                                    'full',
                            description: post is Map
                                ? post['description']?.toString() ?? ''
                                : '',
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PartyRoomScreen(postId: postId),
                                ),
                              );
                              if (mounted) load();
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}
