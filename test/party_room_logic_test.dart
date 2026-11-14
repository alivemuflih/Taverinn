import 'package:flutter_test/flutter_test.dart';
import 'package:taverinn/utils/party_room_logic.dart';
import 'package:taverinn/utils/social_profile_logic.dart';

void main() {
  group('PartyRoomLogic', () {
    test('distinguishes the host from another member', () {
      expect(
        PartyRoomLogic.isPartyHost(userId: 'user-a', hostId: 'user-a'),
        isTrue,
      );
      expect(
        PartyRoomLogic.isPartyHost(userId: 'user-b', hostId: 'user-a'),
        isFalse,
      );
      expect(
        PartyRoomLogic.isPartyHost(userId: null, hostId: 'user-a'),
        isFalse,
      );
    });

    test('reads ready state for the requested member only', () {
      final members = [
        {'user_id': 'user-a', 'is_ready': true},
        {'user_id': 'user-b', 'is_ready': false},
      ];

      expect(PartyRoomLogic.isReady(userId: 'user-a', members: members), isTrue);
      expect(PartyRoomLogic.isReady(userId: 'user-b', members: members), isFalse);
      expect(PartyRoomLogic.isReady(userId: 'user-c', members: members), isFalse);
    });

    test('reports whether capacity remains', () {
      expect(
        PartyRoomLogic.hasAvailableSlot(currentPlayers: 2, maxPlayers: 5),
        isTrue,
      );
      expect(
        PartyRoomLogic.hasAvailableSlot(currentPlayers: 5, maxPlayers: 5),
        isFalse,
      );
    });

    test('formats a message header with a local time when available', () {
      expect(
        PartyRoomLogic.formatMessageHeader('Gamer', DateTime(2026, 1, 2, 9, 5)),
        'Gamer 09:05',
      );
      expect(PartyRoomLogic.formatMessageHeader('Gamer', null), 'Gamer');
    });
  });

  group('SocialProfileLogic', () {
    test('does not allow following the current user', () {
      expect(
        SocialProfileLogic.canFollowUser(
          viewerId: 'user-a',
          targetUserId: 'user-a',
        ),
        isFalse,
      );
      expect(
        SocialProfileLogic.canFollowUser(
          viewerId: 'user-a',
          targetUserId: 'user-b',
        ),
        isTrue,
      );
    });

    test('uses relationship membership to render follow state idempotently', () {
      final followingIds = {'user-b'};
      expect(
        SocialProfileLogic.isFollowing(
          followingIds: followingIds,
          targetUserId: 'user-b',
        ),
        isTrue,
      );
      expect(
        SocialProfileLogic.isFollowing(
          followingIds: followingIds,
          targetUserId: 'user-c',
        ),
        isFalse,
      );
    });
  });
}
