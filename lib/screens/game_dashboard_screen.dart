import 'package:flutter/material.dart';

import '../services/supabase_service.dart';

class GameDashboardScreen extends StatefulWidget {
  const GameDashboardScreen({super.key});

  @override
  State<GameDashboardScreen> createState() => _GameDashboardScreenState();
}

class _GameDashboardScreenState extends State<GameDashboardScreen> {
  final formKey = GlobalKey<FormState>();
  final rankController = TextEditingController();
  final roleController = TextEditingController();
  final gamesPlayedController = TextEditingController(text: '0');
  final winRateController = TextEditingController(text: '0');
  final favoriteController = TextEditingController();

  List<Map<String, dynamic>> games = [];
  List<Map<String, dynamic>> userGames = [];
  String? gameId;
  bool loading = true;
  bool saving = false;

  @override
  void dispose() {
    rankController.dispose();
    roleController.dispose();
    gamesPlayedController.dispose();
    winRateController.dispose();
    favoriteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final g = await SupabaseService.getGames();
      final ug = await SupabaseService.getUserGames();
      if (mounted) {
        setState(() {
          games = g;
          userGames = ug;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat game: $e')),
        );
      }
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate() || gameId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih game dan lengkapi data.')),
      );
      return;
    }

    setState(() => saving = true);
    try {
      await SupabaseService.addUserGame(
        gameId: gameId!,
        rank: rankController.text.trim(),
        role: roleController.text.trim(),
        gamesPlayed: int.parse(gamesPlayedController.text.trim()),
        winRate: double.parse(winRateController.text.trim()),
        favoriteCharacter: favoriteController.text.trim(),
      );
      await load();
      if (!mounted) return;
      rankController.clear();
      roleController.clear();
      gamesPlayedController.text = '0';
      winRateController.text = '0';
      favoriteController.clear();
      setState(() => gameId = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game dashboard tersimpan.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Dashboard')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Tambahkan Game',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: gameId,
                        decoration: const InputDecoration(labelText: 'Game'),
                        items: games
                            .map(
                              (game) => DropdownMenuItem(
                                value: game['id'].toString(),
                                child: Text(game['name'].toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => gameId = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: rankController,
                        decoration: const InputDecoration(labelText: 'Rank'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: roleController,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          hintText: 'Contoh: Duelist / Tank',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: gamesPlayedController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Games Played'),
                        validator: (v) =>
                            int.tryParse(v ?? '') == null ? 'Angka saja' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: winRateController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Win Rate (%)'),
                        validator: (v) {
                          final x = double.tryParse(v ?? '');
                          if (x == null || x < 0 || x > 100) return '0-100';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: favoriteController,
                        decoration: const InputDecoration(
                          labelText: 'Favorite Character',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: saving ? null : save,
                          child: Text(saving ? 'Menyimpan...' : 'Simpan'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Dashboard Saya',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...userGames.map((item) {
                  final game = item['games'];
                  return Card(
                    child: ListTile(
                      title: Text(
                        game is Map ? game['name'].toString() : 'Game',
                      ),
                      subtitle: Text(
                        'Rank ${item['rank']} • ${item['role']}\n'
                        '${item['games_played']} games • ${item['win_rate']}% WR',
                      ),
                      isThreeLine: true,
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
