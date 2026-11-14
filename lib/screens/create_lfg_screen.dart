import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/guild_motif.dart';
import '../widgets/taverinn_icon.dart';
import 'party_room_screen.dart';

const _taverinnBannerAspectRatio = 1024 / 167;

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
  bool loadingGames = true;
  String? gameLoadError;

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
    if (!mounted) return;
    setState(() {
      loadingGames = true;
      gameLoadError = null;
    });
    try {
      final result = await SupabaseService.getGames();
      if (mounted) setState(() => games = result);
    } catch (_) {
      if (mounted) {
        setState(() => gameLoadError = 'error');
      }
    } finally {
      if (mounted) setState(() => loadingGames = false);
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (gameId == null) {
      final strings = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.selectGameFirst)),
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
        SnackBar(content: Text(AppLocalizations.of(context).partyCreated)),
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
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorAction)),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 48,
        title: Text(strings.createParty),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final horizontalInset = wide ? TaverinnSpace.x6 : TaverinnSpace.x4;
            final contentWidth =
                (math.min(constraints.maxWidth, 680.0) - horizontalInset * 2)
                    .clamp(0.0, 680.0);
            final bannerSize = math
                .min(contentWidth,
                    (constraints.maxWidth * 0.65).clamp(0.0, 320.0))
                .toDouble();
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Form(
                  key: formKey,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalInset,
                      TaverinnSpace.x1,
                      horizontalInset,
                      TaverinnSpace.x10,
                    ),
                    children: [
                      Center(
                        child: TaverinnIcon(
                          assetPath: 'assets/icons/taverinn_banner.svg',
                          width: bannerSize,
                          height: bannerSize / _taverinnBannerAspectRatio,
                        ),
                      ),
                      Text(strings.writeRecruitment),
                      const SizedBox(height: TaverinnSpace.x1),
                      if (gameLoadError != null) ...[
                        Text(
                          strings.couldNotLoadGames,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: loadGames,
                            icon: TaverinnIcon(
                              assetPath: 'assets/icons/refresh.svg',
                              semanticLabel: strings.refresh,
                            ),
                            label: Text(strings.retry),
                          ),
                        ),
                        const SizedBox(height: TaverinnSpace.x3),
                      ],
                      Text(
                        strings.gameDetails,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: TaverinnSpace.x1),
                      const GuildRule(),
                      const SizedBox(height: TaverinnSpace.x1),
                      DropdownButtonFormField<String>(
                        key: const ValueKey('create_party_game_input'),
                        initialValue: gameId,
                        decoration: InputDecoration(
                          labelText: strings.game,
                          prefixIcon: const TaverinnIcon(
                            assetPath: 'assets/icons/game.svg',
                            size: TaverinnIconSize.status,
                          ),
                          suffixIcon: loadingGames
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : null,
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
                      const SizedBox(height: TaverinnSpace.x3),
                      DropdownButtonFormField<String>(
                        key: const ValueKey('create_party_mode_input'),
                        initialValue: mode,
                        decoration: InputDecoration(labelText: strings.mode),
                        items: modes
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e == 'Other' ? strings.other : e),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => mode = value!),
                      ),
                      const SizedBox(height: TaverinnSpace.x3),
                      TextFormField(
                        key: const ValueKey('create_party_rank_input'),
                        controller: rankController,
                        decoration: InputDecoration(
                          labelText: strings.rank,
                          hintText: strings.rankExample,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? strings.rankRequired
                                : null,
                      ),
                      const SizedBox(height: TaverinnSpace.x3),
                      DropdownButtonFormField<String>(
                        key: const ValueKey('create_party_language_input'),
                        initialValue: language,
                        decoration:
                            InputDecoration(labelText: strings.languageField),
                        items: [
                          DropdownMenuItem(
                            value: 'Indonesia',
                            child: Text(strings.languageIndonesia),
                          ),
                          DropdownMenuItem(
                            value: 'English',
                            child: Text(strings.languageEnglish),
                          ),
                          DropdownMenuItem(
                            value: 'Japanese',
                            child: Text(strings.languageJapanese),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text(strings.other),
                          ),
                        ],
                        onChanged: (value) => setState(() => language = value!),
                      ),
                      const SizedBox(height: TaverinnSpace.x3),
                      TextFormField(
                        key: const ValueKey('create_party_max_players_input'),
                        controller: maxPlayersController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: strings.maxPlayers,
                          prefixIcon: const TaverinnIcon(
                            assetPath: 'assets/icons/players.svg',
                            size: TaverinnIconSize.status,
                          ),
                        ),
                        validator: (value) {
                          final number = int.tryParse(value ?? '');
                          if (number == null || number < 2 || number > 20) {
                            return strings.playersRange;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: TaverinnSpace.x6),
                      Text(
                        strings.timeAndAnnouncement,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: TaverinnSpace.x2),
                      const GuildRule(),
                      const SizedBox(height: TaverinnSpace.x3),
                      TextFormField(
                        key: const ValueKey('create_party_time_input'),
                        controller: playTimeController,
                        decoration: InputDecoration(
                          labelText: strings.playTime,
                          hintText: strings.playTimeExample,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? strings.timeRequired
                                : null,
                      ),
                      const SizedBox(height: TaverinnSpace.x3),
                      TextFormField(
                        key: const ValueKey('create_party_description_input'),
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: strings.description,
                          hintText: strings.descriptionExample,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? strings.descriptionRequired
                                : null,
                      ),
                      const SizedBox(height: TaverinnSpace.x6),
                      FilledButton.icon(
                        key: const ValueKey('create_party_submit_button'),
                        onPressed: loading ? null : submit,
                        icon: TaverinnIcon(
                          assetPath: 'assets/icons/create.svg',
                          semanticLabel: strings.createParty,
                        ),
                        label: Text(
                            loading ? strings.creating : strings.publishParty),
                      ),
                    ],
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
