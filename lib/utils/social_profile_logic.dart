class SocialProfileLogic {
  const SocialProfileLogic._();

  static bool canFollowUser({
    required String? viewerId,
    required String? targetUserId,
  }) {
    return viewerId != null &&
        targetUserId != null &&
        targetUserId.isNotEmpty &&
        viewerId != targetUserId;
  }

  static bool isFollowing({
    required Set<String> followingIds,
    required String targetUserId,
  }) {
    return followingIds.contains(targetUserId);
  }
}
