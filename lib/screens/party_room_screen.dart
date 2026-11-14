import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../utils/party_room_logic.dart';
import 'profile_screen.dart';
import 'main_screen.dart';

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
  bool get isReady =>
      PartyRoomLogic.isReady(userId: userId, members: members);

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
    } catch (e) {
      if (mounted) showSnack('Gagal memuat party: $e');
    }
  }

  Future<void> loadMembers() async {
    try {
      final result = await SupabaseService.getPartyMembers(widget.postId);
      if (mounted) setState(() => members = result);
    } catch (e) {
      if (mounted) showSnack('Gagal memuat anggota: $e');
    }
  }

  Future<void> loadMessages() async {
    try {
      final result = await SupabaseService.getPartyMessages(widget.postId);
      if (mounted) setState(() => messages = result);
    } catch (e) {
      if (mounted) showSnack('Gagal memuat chat: $e');
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
    showSnack('Party telah berakhir.');
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
    } catch (e) {
      if (mounted) showSnack('Gagal mengubah status: $e');
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
    } catch (e) {
      if (mounted) showSnack('Pesan gagal dikirim: $e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> leaveParty() async {
    setState(() => changingState = true);
    try {
      await SupabaseService.leaveParty(widget.postId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showSnack('Gagal keluar dari party: $e');
    } finally {
      if (mounted) setState(() => changingState = false);
    }
  }

  Future<void> endParty() async {
    setState(() => changingState = true);
    try {
      await SupabaseService.endParty(widget.postId);
      if (mounted) handlePartyEnded();
    } catch (e) {
      if (mounted) showSnack('Gagal mengakhiri party: $e');
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
    final game = party?['games'];
    final title =
        game is Map ? game['name']?.toString() ?? 'Party Room' : 'Party Room';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : party == null
              ? const Center(child: Text('Party tidak ditemukan.'))
              : SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${party!['mode']} • ${party!['rank']}  ·  '
                            '${party!['current_players']}/${party!['max_players']} pemain',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 142,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            final member = members[index];
                            final profile = member['profiles'];
                            final name = profile is Map
                                ? profile['username']?.toString() ?? 'Player'
                                : 'Player';
                            final host = member['user_id'] == party!['user_id'];
                            final ready = member['is_ready'] == true;
                            final avatarUrl = profile is Map
                                ? profile['avatar_url']?.toString()
                                : null;
                            return ListTile(
                              dense: true,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProfileScreen(
                                    userId: member['user_id'].toString(),
                                  ),
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundImage:
                                    avatarUrl == null || avatarUrl.isEmpty
                                        ? null
                                        : NetworkImage(avatarUrl),
                                child: avatarUrl == null || avatarUrl.isEmpty
                                    ? Text(name.isEmpty
                                        ? '?'
                                        : name[0].toUpperCase())
                                    : null,
                              ),
                              title: Text(host ? '$name  ·  HOST' : name),
                              trailing: Text(
                                ready ? 'READY' : 'NOT READY',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: ready
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: messages.isEmpty
                            ? const Center(
                                child:
                                    Text('Belum ada pesan. Mulai chat party.'))
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final item = messages[index];
                                  final profile = item['profiles'];
                                  final name = profile is Map
                                      ? profile['username']?.toString() ??
                                          'Player'
                                      : 'Player';
                                  final createdAt = DateTime.tryParse(
                                    item['created_at']?.toString() ?? '',
                                  )?.toLocal();
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                PartyRoomLogic
                                                    .formatMessageHeader(
                                                  name,
                                                  createdAt,
                                                ),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall),
                                              const SizedBox(height: 3),
                                              Text(
                                                  item['message']?.toString() ??
                                                      ''),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: messageController,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => sendMessage(),
                                decoration: const InputDecoration(
                                  hintText: 'Tulis pesan...',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: sending ? null : sendMessage,
                              tooltip: 'Kirim pesan',
                              icon: sending
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.send),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: changingState ? null : toggleReady,
                                child: Text(isReady ? 'NOT READY' : 'READY'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: isHost
                                  ? FilledButton.tonal(
                                      onPressed:
                                          changingState ? null : endParty,
                                      child: const Text('AKHIRI PARTY'),
                                    )
                                  : OutlinedButton(
                                      onPressed:
                                          changingState ? null : leaveParty,
                                      child: const Text('LEAVE'),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
