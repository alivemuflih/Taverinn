import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final schema = File('supabase/schema.sql').readAsStringSync();

  String functionDefinition(String name) {
    final start = schema.indexOf('create or replace function public.$name');
    expect(start, isNonNegative, reason: '$name must exist in schema.sql');
    final end = schema.indexOf('\n\$\$;', start);
    expect(end, isNonNegative, reason: '$name must have a closing delimiter');
    return schema.substring(start, end);
  }

  String tableDefinition(String name) {
    final match = RegExp(
      'create table if not exists public\\.$name \\(([\\s\\S]*?)\\n\\);',
    ).firstMatch(schema);
    expect(match, isNotNull, reason: '$name must exist in schema.sql');
    return match!.group(1)!;
  }

  group('Phase 2 database contract', () {
    test('self-follow is rejected and duplicate follow is idempotent', () {
      final follows = tableDefinition('follows');
      final followRpc = functionDefinition('follow_user');

      expect(follows, contains('follower_id <> following_id'));
      expect(follows, contains('primary key (follower_id, following_id)'));
      expect(followRpc, contains('if target_user_id = uid'));
      expect(
        followRpc,
        contains('on conflict (follower_id, following_id) do nothing'),
      );
    });

    test('successful create increments parties_created in its RPC', () {
      final createRpc = functionDefinition('create_lfg_party');
      expect(createRpc, contains('insert into public.user_stats'));
      expect(createRpc, contains('parties_created'));
      expect(createRpc, contains('public.user_stats.parties_created + 1'));
    });

    test('successful join increments parties_joined atomically', () {
      final joinRpc = functionDefinition('join_lfg_party');
      expect(joinRpc, contains('insert into public.party_members'));
      expect(joinRpc, contains('public.user_stats.parties_joined + 1'));
      expect(joinRpc, contains('for update'));
    });

    test('players_met excludes host and counts each player only once', () {
      final joinRpc = functionDefinition('join_lfg_party');
      final interactions = tableDefinition('user_player_interactions');

      expect(joinRpc, contains('if uid <> post_row.user_id'));
      expect(joinRpc, contains('on conflict (user_id, other_user_id) do nothing'));
      expect(joinRpc, contains('public.user_stats.players_met + 1'));
      expect(interactions, contains('primary key (user_id, other_user_id)'));
      expect(interactions, contains('user_id <> other_user_id'));
    });

    test('permanent statistics and interactions do not reference party rows', () {
      final stats = tableDefinition('user_stats');
      final interactions = tableDefinition('user_player_interactions');

      expect(stats, contains('references public.profiles(id)'));
      expect(stats, isNot(contains('references public.lfg_posts')));
      expect(interactions, contains('references public.profiles(id)'));
      expect(interactions, isNot(contains('references public.lfg_posts')));
    });
  });
}
