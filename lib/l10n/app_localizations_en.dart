// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get create => 'Create';

  @override
  String get party => 'Party';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get settingsSubtitle => 'Choose how Taverinn looks and reads.';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeDescription => 'Choose light, dark, or follow your device.';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageDescription =>
      'Language used across the Taverinn interface.';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get english => 'English';

  @override
  String get settingsSaved => 'Preference updated.';

  @override
  String get createParty => 'Create Party';

  @override
  String get writeRecruitment => 'Write a notice for players who want to join.';

  @override
  String get gameDetails => 'GAME DETAILS';

  @override
  String get timeAndAnnouncement => 'TIME & DESCRIPTION';

  @override
  String get game => 'Game';

  @override
  String get mode => 'Mode';

  @override
  String get rank => 'Rank';

  @override
  String get languageField => 'Language';

  @override
  String get maxPlayers => 'Maximum players';

  @override
  String get playTime => 'Play time';

  @override
  String get description => 'Description';

  @override
  String get publishParty => 'Post party';

  @override
  String get creating => 'Creating...';

  @override
  String get retry => 'Try again';

  @override
  String get couldNotLoadGames => 'The game list could not be loaded.';

  @override
  String get selectGameFirst => 'Choose a game first.';

  @override
  String get partyCreated => 'Party created.';

  @override
  String get rankRequired => 'Rank is required';

  @override
  String get playersRange => 'Enter a number from 2 to 20';

  @override
  String get timeRequired => 'Play time is required';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get playTimeExample => 'Example: 20:00';

  @override
  String get descriptionExample =>
      'Example: Looking for 3 players for a relaxed ranked session...';

  @override
  String get homeTitle => 'Find a party';

  @override
  String get homeSubtitle => 'Find players for your next session.';

  @override
  String get searchGameOrPlayer => 'Search games or players';

  @override
  String get allGames => 'All games';

  @override
  String get allRanks => 'All ranks';

  @override
  String get allLanguages => 'All languages';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get refresh => 'Refresh';

  @override
  String get noParties => 'No matching parties yet.';

  @override
  String get noPartiesHint => 'Change your filters or check back later.';

  @override
  String get joinParty => 'Join party';

  @override
  String get partyFull => 'Party full';

  @override
  String get open => 'OPEN';

  @override
  String get full => 'FULL';

  @override
  String playerCount(int current, int maximum) {
    return '$current/$maximum players';
  }

  @override
  String get myParty => 'My Party';

  @override
  String get noJoinedParties => 'You have not joined a party yet.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get playerProfile => 'Player profile';

  @override
  String get logout => 'Log out';

  @override
  String get followers => 'Followers';

  @override
  String get following => 'Following';

  @override
  String get activity => 'Activity';

  @override
  String get partiesCreated => 'Parties created';

  @override
  String get partiesJoined => 'Parties joined';

  @override
  String get playersMet => 'Players met';

  @override
  String get manageGames => 'Manage games';

  @override
  String get myGames => 'My games';

  @override
  String get games => 'Games';

  @override
  String get noGamesInProfile =>
      'You have not added any games to your profile.';

  @override
  String get noGamesShown => 'No games to show yet.';

  @override
  String get follow => 'Follow';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get updating => 'Updating...';

  @override
  String get tryAgain => 'Try again';

  @override
  String get partyNotFound => 'Party not found.';

  @override
  String get host => 'Host';

  @override
  String get ready => 'Ready';

  @override
  String get notReady => 'Not ready';

  @override
  String get markReady => 'Mark ready';

  @override
  String get markNotReady => 'Mark not ready';

  @override
  String get sendMessage => 'Send message';

  @override
  String get endParty => 'End party';

  @override
  String get leaveParty => 'Leave party';

  @override
  String get cancel => 'Cancel';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get findPlayers => 'Find players for your next session.';

  @override
  String get noUsers => 'No players to show yet.';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get gameDashboard => 'My games';

  @override
  String get followersList => 'Followers';

  @override
  String get followingList => 'Following';

  @override
  String get errorLoading =>
      'Could not load data. Check your connection and try again.';

  @override
  String get errorAction => 'That action failed. Try again.';

  @override
  String get feedDescription => 'Find players by game, rank, and language.';

  @override
  String get all => 'All';

  @override
  String get partyDetails => 'PARTY DETAILS';

  @override
  String get joinSuccess => 'You joined the party.';

  @override
  String get joinFailure => 'Could not join the party. Try again.';

  @override
  String get unknownGame => 'Unknown game';

  @override
  String get userFallback => 'Player';

  @override
  String get completeGameData => 'Choose a game and complete the details.';

  @override
  String get dashboardSaved => 'Game details saved.';

  @override
  String get role => 'Role';

  @override
  String get roleExample => 'Example: Duelist / Tank';

  @override
  String get gamesPlayed => 'Games played';

  @override
  String get winRate => 'Win rate (%)';

  @override
  String get favoriteCharacter => 'Favorite character';

  @override
  String get noUsersMessage => 'No players to show yet.';

  @override
  String get completeFields => 'Complete all fields.';

  @override
  String get signUpEmailNotice =>
      'Sign-up succeeded. Check your email if confirmation is enabled.';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get noAccount => 'New here? Sign up';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get partyRoom => 'Party room';

  @override
  String get partyMembers => 'PARTY MEMBERS';

  @override
  String membersCount(int count) {
    return '$count players';
  }

  @override
  String get chatParty => 'PARTY CHAT';

  @override
  String get chatEmpty => 'No messages yet. Start the party conversation.';

  @override
  String get messageForParty => 'Message the party';

  @override
  String get writeMessage => 'Write a message...';

  @override
  String get partyEnded => 'The party has ended.';

  @override
  String get statusFailure => 'Could not update your status. Try again.';

  @override
  String get messageFailure => 'Message could not be sent. Try again.';

  @override
  String get leaveFailure => 'Could not leave the party. Try again.';

  @override
  String get endFailure => 'Could not end the party. Try again.';

  @override
  String get languageIndonesia => 'Indonesian';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get other => 'Other';

  @override
  String get addGame => 'Add a game';

  @override
  String get playerData => 'PLAYER DETAILS';

  @override
  String get saveGame => 'Save game';

  @override
  String get saving => 'Saving...';

  @override
  String get displayedGames => 'Games on your profile';

  @override
  String get addedGameHelp => 'Games you add will appear here.';

  @override
  String get requiredField => 'This field is required';

  @override
  String get numberOnly => 'Enter a number';

  @override
  String get rangeZeroToHundred => 'Enter a number from 0 to 100';

  @override
  String get rankExample => 'Example: Silver 3 / Mythic';

  @override
  String get members => 'Players';

  @override
  String hostName(String name) {
    return 'Host: $name';
  }

  @override
  String get missingSupabase =>
      'Supabase is not configured. Start the app with SUPABASE_URL and SUPABASE_ANON_KEY dart-define values.';
}
