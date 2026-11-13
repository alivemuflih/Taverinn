import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import 'auth_screen.dart';
import 'game_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> userGames = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      profile = await SupabaseService.getProfile();
      userGames = await SupabaseService.getUserGames();
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

  @override
  Widget build(BuildContext context) {
    final username = profile?['username'] ?? 'User';
    final email = SupabaseService.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
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
                      child: Text(
                        username.toString().isEmpty
                            ? 'U'
                            : username.toString()[0].toUpperCase(),
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      username.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Center(child: Text(email)),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameDashboardScreen(),
                        ),
                      );
                      load();
                    },
                    icon: const Icon(Icons.sports_esports),
                    label: const Text('Game Dashboard'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'My Games',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (userGames.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Belum ada game di profile kamu.'),
                      ),
                    )
                  else
                    ...userGames.map((item) {
                      final game = item['games'];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              ((game is Map ? game['name'] : 'G')[0]).toString(),
                            ),
                          ),
                          title: Text(
                            game is Map ? game['name'].toString() : 'Game',
                          ),
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
