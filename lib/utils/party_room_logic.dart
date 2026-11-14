class PartyRoomLogic {
  const PartyRoomLogic._();

  static bool isPartyHost({required String? userId, required String? hostId}) {
    return userId != null && userId == hostId;
  }

  static bool isReady({
    required String userId,
    required Iterable<Map<String, dynamic>> members,
  }) {
    return members.any(
      (member) => member['user_id'] == userId && member['is_ready'] == true,
    );
  }

  static bool hasAvailableSlot({
    required int currentPlayers,
    required int maxPlayers,
  }) {
    return currentPlayers < maxPlayers;
  }

  static String formatMessageHeader(String username, DateTime? createdAt) {
    if (createdAt == null) return username;
    final local = createdAt.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$username $hour:$minute';
  }
}
