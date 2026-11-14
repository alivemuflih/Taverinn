import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import 'party_room_screen.dart';

class CreateLfgScreen extends StatefulWidget {
  const CreateLfgScreen({super.key});

  @override
  State<CreateLfgScreen> createState() => _CreateLfgScreenState();
}

class _CreateLfgScreenState extends State<CreateLfgScreen> {
  final formKey = GlobalKey<FormState>();
  final rankController = TextEditingController();
  final playTimeController = TextEditingController();
  final descriptionController = TextEditingController();
  final maxPlayersController = TextEditingController(text: '5');

  List<Map<String, dynamic>> games = [];
  String? gameId;
  String mode = 'Competitive';
  String language = 'Indonesia';
  bool loading = false;

  final modes = ['Competitive', 'Ranked', 'Casual', 'Custom', 'Co-op', 'Other'];

  @override
  void dispose() {
    rankController.dispose();
    playTimeController.dispose();
    descriptionController.dispose();
    maxPlayersController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  Future<void> loadGames() async {
    try {
      final result = await SupabaseService.getGames();
      if (mounted) setState(() => games = result);
    } catch (_) {}
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (gameId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih game terlebih dahulu.')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final postId = await SupabaseService.createLfg(
        gameId: gameId!,
        mode: mode,
        rank: rankController.text.trim(),
        language: language,
        maxPlayers: int.parse(maxPlayersController.text.trim()),
        playTime: playTimeController.text.trim(),
        description: descriptionController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PartyRoomScreen(postId: postId)),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Party berhasil dibuat!')),
      );
      formKey.currentState!.reset();
      rankController.clear();
      playTimeController.clear();
      descriptionController.clear();
      maxPlayersController.text = '5';
      setState(() {
        gameId = null;
        mode = 'Competitive';
        language = 'Indonesia';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat party: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Party')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Buat LFG',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            const Text(
                'Beri detail agar pemain lain mudah menemukan party kamu.'),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: gameId,
              decoration: const InputDecoration(
                labelText: 'Game',
                prefixIcon: Icon(Icons.sports_esports),
              ),
              items: games
                  .map(
                    (game) => DropdownMenuItem<String>(
                      value: game['id'].toString(),
                      child: Text(game['name'].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => gameId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: mode,
              decoration: const InputDecoration(labelText: 'Mode'),
              items: modes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => mode = value!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: rankController,
              decoration: const InputDecoration(
                labelText: 'Rank',
                hintText: 'Contoh: Silver 3 / Mythic',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Rank wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: language,
              decoration: const InputDecoration(labelText: 'Bahasa'),
              items: ['Indonesia', 'English', 'Japanese', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => language = value!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: maxPlayersController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Maksimal pemain',
                prefixIcon: Icon(Icons.groups),
              ),
              validator: (value) {
                final number = int.tryParse(value ?? '');
                if (number == null || number < 2 || number > 20) {
                  return 'Masukkan angka 2-20';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: playTimeController,
              decoration: const InputDecoration(
                labelText: 'Waktu bermain',
                hintText: 'Contoh: 20:00',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Waktu wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Contoh: Cari 3 orang buat push rank santai...',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Deskripsi wajib diisi'
                  : null,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: loading ? null : submit,
              icon: const Icon(Icons.add),
              label: Text(loading ? 'Membuat...' : 'Create Party'),
            ),
          ],
        ),
      ),
    );
  }
}
