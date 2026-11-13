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
        .select('*, profiles!lfg_posts_user_id_fkey(username), games(name, icon_url)')
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

  static Future<Map<String, dynamic>> createLfg({
    required String gameId,
    required String mode,
    required String rank,
    required String language,
    required int maxPlayers,
    required String playTime,
    required String description,
  }) async {
    final result = await client.from('lfg_posts').insert({
      'user_id': currentUser!.id,
      'game_id': gameId,
      'mode': mode,
      'rank': rank,
      'language': language,
      'current_players': 1,
      'max_players': maxPlayers,
      'play_time': playTime,
      'description': description,
      'status': 'open',
    }).select().single();

    await client.from('party_members').insert({
      'post_id': result['id'],
      'user_id': currentUser!.id,
    });

    return Map<String, dynamic>.from(result);
  }

  static Future<void> joinParty(String postId) async {
    await client.rpc('join_lfg_party', params: {'target_post_id': postId});
  }

  static Future<List<Map<String, dynamic>>> getMyParties() async {
    final result = await client
        .from('party_members')
        .select('post_id, joined_at, lfg_posts(*, games(name, icon_url))')
        .eq('user_id', currentUser!.id)
        .order('joined_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  static Future<List<Map<String, dynamic>>> getUserGames() async {
    final result = await client
        .from('user_games')
        .select('*, games(name, icon_url)')
        .eq('user_id', currentUser!.id)
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

  static Future<Map<String, dynamic>?> getProfile() async {
    final result = await client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();

    return result == null ? null : Map<String, dynamic>.from(result);
  }
}
