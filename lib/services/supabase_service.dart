import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<void> updateProfile({
    required String username,
  }) async {
    await client.from('profiles').update({
      'username': username,
    }).eq('id', currentUser!.id);
  }

  static Future<List<Map<String, dynamic>>> getGames() async {
    final result = await client.from('games').select().order('name');
    return List<Map<String, dynamic>>.from(result);
  }

  static Future<List<Map<String, dynamic>>> getLfgPosts({
    String? gameId,
    String? rank,
    String? language,
  }) async {
    var query = client
        .from('lfg_posts')
        .select(
            '*, profiles!lfg_posts_user_id_fkey(username), games(name, icon_url)')
        .eq('status', 'open');

    if (gameId != null && gameId.isNotEmpty) {
      query = query.eq('game_id', gameId);
    }
    if (rank != null && rank.isNotEmpty) {
      query = query.ilike('rank', rank);
    }
    if (language != null && language.isNotEmpty) {
      query = query.eq('language', language);
    }

    final result = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(result);
  }

  static Future<String> createLfg({
    required String gameId,
    required String mode,
    required String rank,
    required String language,
    required int maxPlayers,
    required String playTime,
    required String description,
  }) async {
    final result = await client.rpc('create_lfg_party', params: {
      'target_game_id': gameId,
      'target_mode': mode,
      'target_rank': rank,
      'target_language': language,
      'target_max_players': maxPlayers,
      'target_play_time': playTime,
      'target_description': description,
    });
    return result.toString();
  }

  static Future<void> joinParty(String postId) async {
    await client.rpc('join_lfg_party', params: {'target_post_id': postId});
  }

  static Future<void> setPartyReady(String postId, bool isReady) async {
    await client.rpc('set_party_ready', params: {
      'target_post_id': postId,
      'target_is_ready': isReady,
    });
  }

  static Future<void> leaveParty(String postId) async {
    await client.rpc('leave_lfg_party', params: {'target_post_id': postId});
  }

  static Future<void> endParty(String postId) async {
    await client.rpc('end_lfg_party', params: {'target_post_id': postId});
  }

  static Future<Map<String, dynamic>?> getParty(String postId) async {
    final result = await client
        .from('lfg_posts')
        .select('*, games(name, icon_url)')
        .eq('id', postId)
        .maybeSingle();
    return result == null ? null : Map<String, dynamic>.from(result);
  }

  static Future<List<Map<String, dynamic>>> getPartyMembers(
    String postId,
  ) async {
    final result = await client
        .from('party_members')
        .select('user_id, is_ready, joined_at, profiles(username, avatar_url)')
        .eq('post_id', postId)
        .order('joined_at');
    return List<Map<String, dynamic>>.from(result);
  }

  static Future<List<Map<String, dynamic>>> getPartyMessages(
    String postId,
  ) async {
    final result = await client
        .from('party_messages')
        .select('id, user_id, message, created_at, profiles(username)')
        .eq('post_id', postId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(result);
  }

  static Future<void> sendPartyMessage(String postId, String message) async {
    await client.from('party_messages').insert({
      'post_id': postId,
      'user_id': currentUser!.id,
      'message': message.trim(),
    });
  }

  static RealtimeChannel subscribeToParty({
    required String postId,
    required void Function() onMembersChanged,
    required void Function() onMessagesChanged,
    required void Function() onPartyChanged,
    required void Function() onPartyDeleted,
  }) {
    return client
        .channel('party-room-$postId-${DateTime.now().microsecondsSinceEpoch}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'party_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (_) => onMembersChanged(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'party_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (_) => onMessagesChanged(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'lfg_posts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: postId,
          ),
          callback: (_) => onPartyChanged(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'lfg_posts',
          callback: (_) async {
            // DELETE events cannot be filtered; verify this specific party.
            if (await getParty(postId) == null) onPartyDeleted();
          },
        )
        .subscribe();
  }

  static Future<List<Map<String, dynamic>>> getMyParties() async {
    final result = await client
        .from('party_members')
        .select('post_id, joined_at, lfg_posts(*, games(name, icon_url))')
        .eq('user_id', currentUser!.id)
        .order('joined_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  static Future<List<Map<String, dynamic>>> getUserGames({
    String? userId,
  }) async {
    final result = await client
        .from('user_games')
        .select('*, games(name, icon_url)')
        .eq('user_id', userId ?? currentUser!.id)
        .order('created_at');

    return List<Map<String, dynamic>>.from(result);
  }

  static Future<void> addUserGame({
    required String gameId,
    required String rank,
    required String role,
    required int gamesPlayed,
    required double winRate,
    required String favoriteCharacter,
  }) async {
    await client.from('user_games').upsert({
      'user_id': currentUser!.id,
      'game_id': gameId,
      'rank': rank,
      'role': role,
      'games_played': gamesPlayed,
      'win_rate': winRate,
      'favorite_character': favoriteCharacter,
    }, onConflict: 'user_id,game_id');
  }

  static Future<Map<String, dynamic>?> getProfile({String? userId}) async {
    final result = await client
        .from('profiles')
        .select()
        .eq('id', userId ?? currentUser!.id)
        .maybeSingle();

    return result == null ? null : Map<String, dynamic>.from(result);
  }

  static Future<Map<String, dynamic>?> getUserStats(String userId) async {
    final result = await client
        .from('user_stats')
        .select(
            'user_id, parties_created, parties_joined, players_met, created_at, updated_at')
        .eq('user_id', userId)
        .maybeSingle();
    return result == null ? null : Map<String, dynamic>.from(result);
  }

  static Future<Map<String, int>> getFollowCounts(String userId) async {
    final followerRows = await client
        .from('follows')
        .select('follower_id')
        .eq('following_id', userId);
    final followingRows = await client
        .from('follows')
        .select('following_id')
        .eq('follower_id', userId);
    return {
      'followers': followerRows.length,
      'following': followingRows.length,
    };
  }

  static Future<bool> isFollowing(String targetUserId) async {
    final result = await client
        .from('follows')
        .select('follower_id')
        .eq('follower_id', currentUser!.id)
        .eq('following_id', targetUserId)
        .maybeSingle();
    return result != null;
  }

  static Future<void> followUser(String targetUserId) async {
    await client.rpc(
      'follow_user',
      params: {'target_user_id': targetUserId},
    );
  }

  static Future<void> unfollowUser(String targetUserId) async {
    await client.rpc(
      'unfollow_user',
      params: {'target_user_id': targetUserId},
    );
  }

  static Future<Set<String>> getMyFollowingIds() async {
    final result = await client
        .from('follows')
        .select('following_id')
        .eq('follower_id', currentUser!.id);
    return result
        .map((row) => row['following_id'].toString())
        .toSet();
  }

  static Future<List<Map<String, dynamic>>> getFollowList({
    required String userId,
    required bool followers,
  }) async {
    final result = followers
        ? await client
            .from('follows')
            .select(
                'follower_id, created_at, profiles!follows_follower_id_fkey(id, username, avatar_url)')
            .eq('following_id', userId)
            .order('created_at', ascending: false)
        : await client
            .from('follows')
            .select(
                'following_id, created_at, profiles!follows_following_id_fkey(id, username, avatar_url)')
            .eq('follower_id', userId)
            .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(result);
  }
}
