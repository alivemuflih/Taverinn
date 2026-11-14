import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/party_room_logic.dart';
import '../widgets/guild_motif.dart';
import 'main_screen.dart';
import 'profile_screen.dart';

class PartyRoomScreen extends StatefulWidget {
  const PartyRoomScreen({super.key, required this.postId});

  final String postId;

  @override
  State<PartyRoomScreen> createState() => _PartyRoomScreenState();
}

class _PartyRoomScreenState extends State<PartyRoomScreen> {
  final messageController = TextEditingController();
  Map<String, dynamic>? party;
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> messages = [];
  RealtimeChannel? channel;
  bool loading = true;
  bool sending = false;
  bool changingState = false;
  bool handlingEnd = false;

  String get userId => SupabaseService.currentUser!.id;
  bool get isHost => PartyRoomLogic.isPartyHost(
        userId: userId,
        hostId: party?['user_id']?.toString(),
      );
  bool get isReady => PartyRoomLogic.isReady(userId: userId, members: members);

  @override
  void initState() {
    super.initState();
    channel = SupabaseService.subscribeToParty(
      postId: widget.postId,
      onMembersChanged: () => unawaited(loadMembers()),
      onMessagesChanged: () => unawaited(loadMessages()),
      onPartyChanged: () {
        unawaited(loadParty());
        unawaited(loadMembers());
      },
      onPartyDeleted: handlePartyEnded,
    );
    unawaited(loadRoom());
  }

  Future<void> loadRoom() async {
    await Future.wait([loadParty(), loadMembers(), loadMessages()]);
    if (mounted) setState(() => loading = false);
  }

  Future<void> loadParty() async {
    try {
      final result = await SupabaseService.getParty(widget.postId);
      if (!mounted) return;
      if (result == null) {
        handlePartyEnded();
        return;
      }
      setState(() => party = result);
    } catch (_) {
      if (mounted) showSnack(AppLocalizations.of(context).errorLoading);
    }
  }

  Future<void> loadMembers() async {
    try {
      final result = await SupabaseService.getPartyMembers(widget.postId);
      if (mounted) setState(() => members = result);
    } catch (_) {
      if (mounted) showSnack(AppLocalizations.of(context).errorLoading);
    }
  }

  Future<void> loadMessages() async {
    try {
      final result = await SupabaseService.getPartyMessages(widget.postId);
      if (mounted) setState(() => messages = result);
    } catch (_) {
      if (mounted) showSnack(AppLocalizations.of(context).errorLoading);
    }
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void handlePartyEnded() {
    if (!mounted || handlingEnd) return;
    handlingEnd = true;
    showSnack(AppLocalizations.of(context).partyEnded);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (_) => false,
    );
  }

  Future<void> toggleReady() async {
    setState(() => changingState = true);
    try {
      await SupabaseService.setPartyReady(widget.postId, !isReady);
      await loadMembers();
    } catch (_) {
      if (mounted) showSnack(AppLocalizations.of(context).statusFailure);
    } finally {
      if (mounted) setState(() => changingState = false);
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || sending) return;
    setState(() => sending = true);
    try {
      await SupabaseService.sendPartyMessage(widget.postId, text);
      if (!mounted) return;
      messageController.clear();
      await loadMessages();
    } catch (_) {
      if (mounted) showSnack(AppLocalizations.of(context).messageFailure);
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> leaveParty() async {
    setState(() => changingState = true);
    try {
      await SupabaseService.leaveParty(widget.postId);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) showSnack(AppLocalizations.of(context).leaveFailure);
    } finally {
      if (mounted) setState(() => changingState = false);
    }
  }

  Future<void> endParty() async {
    setState(() => changingState = true);
    try {
      await SupabaseService.endParty(widget.postId);
      if (mounted) handlePartyEnded();
    } catch (_) {
      if (mounted) showSnack(AppLocalizations.of(context).endFailure);
    } finally {
      if (mounted) setState(() => changingState = false);
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    final activeChannel = channel;
    if (activeChannel != null) {
      unawaited(SupabaseService.client.removeChannel(activeChannel));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final game = party?['games'];
    final title = game is Map
        ? game['name']?.toString() ?? strings.partyRoom
        : strings.partyRoom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: [
            const TaverinnSeal(size: 30),
            const SizedBox(width: TaverinnSpace.x2),
            Text(
              'TAVERINN',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'serif',
                    letterSpacing: 1,
                  ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : party == null
              ? Center(child: Text(strings.partyNotFound))
              : SafeArea(
                  top: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 880;
                      final content = wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 320,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _roomIdentity(title),
                                      const SizedBox(height: TaverinnSpace.x4),
                                      Expanded(child: _membersSection(false)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: TaverinnSpace.x8),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(child: _chatSection()),
                                      _composer(),
                                      _partyActions(),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _roomIdentity(title),
                                const SizedBox(height: TaverinnSpace.x3),
                                _membersSection(true),
                                const SizedBox(height: TaverinnSpace.x2),
                                Expanded(child: _chatSection()),
                                _composer(),
                                _partyActions(),
                              ],
                            );

                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1240),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              constraints.maxWidth < 420
                                  ? TaverinnSpace.x3
                                  : TaverinnSpace.x4,
                              TaverinnSpace.x3,
                              constraints.maxWidth < 420
                                  ? TaverinnSpace.x3
                                  : TaverinnSpace.x4,
                              TaverinnSpace.x2,
                            ),
                            child: content,
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _roomIdentity(String title) {
    final strings = AppLocalizations.of(context);
    final mode = party?['mode']?.toString() ?? '';
    final rank = party?['rank']?.toString() ?? '';
    final current = party?['current_players'] ?? members.length;
    final maximum = party?['max_players'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.partyRoom.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: TaverinnSpace.x1),
        Text(
          title,
          key: const ValueKey('party_room_game_title'),
          style: Theme.of(context).textTheme.headlineMedium,
          softWrap: true,
        ),
        const SizedBox(height: TaverinnSpace.x2),
        Wrap(
          spacing: TaverinnSpace.x2,
          runSpacing: TaverinnSpace.x1,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (mode.isNotEmpty) Text(mode),
            if (mode.isNotEmpty && rank.isNotEmpty)
              Text('·',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            if (rank.isNotEmpty) Text(rank),
            Text('·',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            Text(strings.playerCount(
                (current as num).toInt(), (maximum as num).toInt())),
          ],
        ),
        const SizedBox(height: TaverinnSpace.x3),
        const GuildRule(),
      ],
    );
  }

  Widget _membersSection(bool horizontal) {
    final strings = AppLocalizations.of(context);
    final title = Row(
      children: [
        Expanded(
          child: Text(
            strings.partyMembers,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        Text(
          strings.membersCount(members.length),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );

    if (horizontal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: TaverinnSpace.x2),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: members.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: TaverinnSpace.x2),
              itemBuilder: (context, index) => SizedBox(
                width: 136,
                child: _memberCard(members[index], compact: true),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: TaverinnSpace.x2),
        Expanded(
          child: ListView.separated(
            itemCount: members.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => _memberCard(
              members[index],
              compact: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _memberCard(Map<String, dynamic> member, {required bool compact}) {
    final strings = AppLocalizations.of(context);
    final profile = member['profiles'];
    final name = profile is Map
        ? profile['username']?.toString() ?? strings.userFallback
        : strings.userFallback;
    final host = member['user_id'] == party?['user_id'];
    final ready = member['is_ready'] == true;
    final avatarUrl = profile is Map ? profile['avatar_url']?.toString() : null;
    final userId = member['user_id'].toString();

    void openProfile() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId)),
      );
    }

    final avatar = CircleAvatar(
      radius: compact ? 16 : 18,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: avatarUrl == null || avatarUrl.isEmpty
          ? null
          : NetworkImage(avatarUrl),
      child: avatarUrl == null || avatarUrl.isEmpty
          ? Text(name.isEmpty ? '?' : name[0].toUpperCase())
          : null,
    );

    if (compact) {
      return Semantics(
        button: true,
        label:
            '$name, ${host ? '${strings.host}, ' : ''}${ready ? strings.ready : strings.notReady}',
        onTap: openProfile,
        child: ExcludeSemantics(
          child: InkWell(
            key: ValueKey('party_member_$userId'),
            onTap: openProfile,
            borderRadius: BorderRadius.circular(TaverinnRadius.compact),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: TaverinnSpace.x1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  avatar,
                  const SizedBox(height: TaverinnSpace.x1),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    host
                        ? strings.host
                        : (ready ? strings.ready : strings.notReady),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ready
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListTile(
      key: ValueKey('party_member_$userId'),
      onTap: openProfile,
      contentPadding: EdgeInsets.zero,
      leading: avatar,
      title: Semantics(
        label: name,
        child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      subtitle: Text(
          host ? strings.host : (ready ? strings.ready : strings.notReady)),
      trailing: Icon(
        ready ? Icons.check_circle_outline : Icons.schedule_outlined,
        color: ready
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _chatSection() {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.chatParty,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: TaverinnSpace.x2),
        const GuildRule(),
        const SizedBox(height: TaverinnSpace.x2),
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    strings.chatEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              : ListView.builder(
                  key: const ValueKey('party_chat_messages'),
                  padding: const EdgeInsets.only(bottom: TaverinnSpace.x2),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final item = messages[index];
                    final profile = item['profiles'];
                    final name = profile is Map
                        ? profile['username']?.toString() ??
                            strings.userFallback
                        : strings.userFallback;
                    final createdAt = DateTime.tryParse(
                      item['created_at']?.toString() ?? '',
                    )?.toLocal();
                    final isCurrentUser = item['user_id']?.toString() == userId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: TaverinnSpace.x2),
                      child: Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width < 680
                                ? MediaQuery.sizeOf(context).width * 0.72
                                : 680,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                  : Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.outline),
                              borderRadius: BorderRadius.circular(
                                TaverinnRadius.compact,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(TaverinnSpace.x3),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    PartyRoomLogic.formatMessageHeader(
                                      name,
                                      createdAt,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: TaverinnSpace.x1),
                                  Text(item['message']?.toString() ?? ''),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _composer() {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: TaverinnSpace.x2),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('party_chat_input'),
              controller: messageController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => sendMessage(),
              decoration: InputDecoration(
                labelText: strings.messageForParty,
                hintText: strings.writeMessage,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: TaverinnSpace.x2),
          IconButton.filled(
            key: const ValueKey('party_chat_send_button'),
            onPressed: sending ? null : sendMessage,
            tooltip: strings.sendMessage,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: sending
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
          ),
        ],
      ),
    );
  }

  Widget _partyActions() {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: TaverinnSpace.x2),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              toggled: isReady,
              enabled: !changingState,
              label: isReady ? strings.markNotReady : strings.markReady,
              onTap: changingState ? null : toggleReady,
              child: ExcludeSemantics(
                child: OutlinedButton(
                  key: const ValueKey('party_ready_button'),
                  onPressed: changingState ? null : toggleReady,
                  child: Text(isReady ? strings.notReady : strings.ready),
                ),
              ),
            ),
          ),
          const SizedBox(width: TaverinnSpace.x2),
          Expanded(
            child: isHost
                ? OutlinedButton(
                    key: const ValueKey('party_end_button'),
                    onPressed: changingState ? null : endParty,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                    ),
                    child: Text(strings.endParty),
                  )
                : OutlinedButton(
                    key: const ValueKey('party_leave_button'),
                    onPressed: changingState ? null : leaveParty,
                    child: Text(strings.leaveParty),
                  ),
          ),
        ],
      ),
    );
  }
}
