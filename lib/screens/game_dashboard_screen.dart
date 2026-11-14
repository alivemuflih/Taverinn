import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/guild_motif.dart';

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
  String? loadError;

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
    if (!mounted) return;
    setState(() {
      loading = true;
      loadError = null;
    });
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
        setState(() {
          loading = false;
          loadError = 'Gagal memuat game: $e';
        });
      }
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate() || gameId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).completeGameData)),
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
          SnackBar(content: Text(AppLocalizations.of(context).dashboardSaved)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorAction)),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.gameDashboard)),
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
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const TaverinnSeal(size: 34),
                        const SizedBox(height: TaverinnSpace.x3),
                        Text(
                          strings.addGame,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: TaverinnSpace.x4),
                        Text(
                          strings.playerData,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: TaverinnSpace.x2),
                        const GuildRule(),
                        const SizedBox(height: TaverinnSpace.x3),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                key: const ValueKey('dashboard_game_input'),
                                initialValue: gameId,
                                decoration:
                                    InputDecoration(labelText: strings.game),
                                items: games
                                    .map(
                                      (game) => DropdownMenuItem(
                                        value: game['id'].toString(),
                                        child: Text(game['name'].toString()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => gameId = value),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                key: const ValueKey('dashboard_rank_input'),
                                controller: rankController,
                                decoration:
                                    InputDecoration(labelText: strings.rank),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? strings.requiredField
                                    : null,
                              ),
                              const SizedBox(height: TaverinnSpace.x3),
                              TextFormField(
                                key: const ValueKey('dashboard_role_input'),
                                controller: roleController,
                                decoration: InputDecoration(
                                  labelText: strings.role,
                                  hintText: strings.roleExample,
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? strings.requiredField
                                    : null,
                              ),
                              const SizedBox(height: TaverinnSpace.x3),
                              TextFormField(
                                key: const ValueKey(
                                  'dashboard_games_played_input',
                                ),
                                controller: gamesPlayedController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: strings.gamesPlayed),
                                validator: (v) => int.tryParse(v ?? '') == null
                                    ? strings.numberOnly
                                    : null,
                              ),
                              const SizedBox(height: TaverinnSpace.x3),
                              TextFormField(
                                key: const ValueKey('dashboard_win_rate_input'),
                                controller: winRateController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration:
                                    InputDecoration(labelText: strings.winRate),
                                validator: (v) {
                                  final x = double.tryParse(v ?? '');
                                  if (x == null || x < 0 || x > 100) {
                                    return strings.rangeZeroToHundred;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: TaverinnSpace.x3),
                              TextFormField(
                                key: const ValueKey(
                                  'dashboard_favorite_character_input',
                                ),
                                controller: favoriteController,
                                decoration: InputDecoration(
                                  labelText: strings.favoriteCharacter,
                                ),
                              ),
                              const SizedBox(height: TaverinnSpace.x4),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  key: const ValueKey(
                                    'dashboard_save_button',
                                  ),
                                  onPressed: saving ? null : save,
                                  child: Text(saving
                                      ? strings.saving
                                      : strings.saveGame),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: TaverinnSpace.x8),
                        Text(
                          strings.displayedGames,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: TaverinnSpace.x3),
                        if (userGames.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: TaverinnSpace.x3,
                            ),
                            child: Text(strings.addedGameHelp),
                          ),
                        ...userGames.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final game = item['games'];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: TaverinnSpace.x3,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index > 0) const Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: TaverinnSpace.x3,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        game is Map
                                            ? game['name'].toString()
                                            : strings.game,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: TaverinnSpace.x1),
                                      Text(
                                        'Rank ${item['rank']} · ${item['role']}\n'
                                        '${item['games_played']} games · '
                                        '${item['win_rate']}% WR',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
    );
  }
}
