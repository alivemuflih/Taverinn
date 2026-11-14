import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import 'party_room_screen.dart';

class PartyScreen extends StatefulWidget {
  const PartyScreen({super.key});

  @override
  State<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  bool loading = true;
  List<Map<String, dynamic>> parties = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      parties = await SupabaseService.getMyParties();
    } catch (e) {
      if (mounted) showSnack('Gagal memuat party: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Party'),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : parties.isEmpty
              ? const Center(child: Text('Kamu belum bergabung dengan party.'))
              : RefreshIndicator(
                  onRefresh: load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: parties.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final item = parties[index];
                      final post = item['lfg_posts'];
                      final game = post is Map ? post['games'] : null;
                      return Card(
                        child: ListTile(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PartyRoomScreen(
                                  postId: item['post_id'].toString(),
                                ),
                              ),
                            );
                            if (mounted) load();
                          },
                          leading: CircleAvatar(
                            child: Text(
                              ((game is Map ? game['name'] : 'G')[0])
                                  .toString(),
                            ),
                          ),
                          title: Text(
                            game is Map ? game['name'].toString() : 'Game',
                          ),
                          subtitle: Text(
                            '${post['mode']} • ${post['rank']}\n'
                            '${post['current_players']}/${post['max_players']} pemain',
                          ),
                          isThreeLine: true,
                          trailing: Chip(
                            label: Text(
                              post['status'] == 'full' ? 'FULL' : 'OPEN',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
