import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @home.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get home;

  /// No description provided for @create.
  ///
  /// In id, this message translates to:
  /// **'Buat'**
  String get create;

  /// No description provided for @party.
  ///
  /// In id, this message translates to:
  /// **'Party'**
  String get party;

  /// No description provided for @profile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settings;

  /// No description provided for @settingsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Atur tampilan dan bahasa aplikasi.'**
  String get settingsSubtitle;

  /// No description provided for @appearance.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @themeDescription.
  ///
  /// In id, this message translates to:
  /// **'Pilih tampilan terang, gelap, atau ikuti perangkat.'**
  String get themeDescription;

  /// No description provided for @systemTheme.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get darkTheme;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In id, this message translates to:
  /// **'Bahasa untuk antarmuka Taverinn.'**
  String get languageDescription;

  /// No description provided for @indonesian.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesian;

  /// No description provided for @english.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @settingsSaved.
  ///
  /// In id, this message translates to:
  /// **'Preferensi diperbarui.'**
  String get settingsSaved;

  /// No description provided for @createParty.
  ///
  /// In id, this message translates to:
  /// **'Buat Party'**
  String get createParty;

  /// No description provided for @writeRecruitment.
  ///
  /// In id, this message translates to:
  /// **'Tulis pengumuman untuk pemain yang ingin bergabung.'**
  String get writeRecruitment;

  /// No description provided for @gameDetails.
  ///
  /// In id, this message translates to:
  /// **'RINCIAN GAME'**
  String get gameDetails;

  /// No description provided for @timeAndAnnouncement.
  ///
  /// In id, this message translates to:
  /// **'WAKTU & PENGUMUMAN'**
  String get timeAndAnnouncement;

  /// No description provided for @game.
  ///
  /// In id, this message translates to:
  /// **'Game'**
  String get game;

  /// No description provided for @mode.
  ///
  /// In id, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @rank.
  ///
  /// In id, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @languageField.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get languageField;

  /// No description provided for @maxPlayers.
  ///
  /// In id, this message translates to:
  /// **'Maksimal pemain'**
  String get maxPlayers;

  /// No description provided for @playTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu bermain'**
  String get playTime;

  /// No description provided for @description.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi'**
  String get description;

  /// No description provided for @publishParty.
  ///
  /// In id, this message translates to:
  /// **'Terbitkan party'**
  String get publishParty;

  /// No description provided for @creating.
  ///
  /// In id, this message translates to:
  /// **'Membuat...'**
  String get creating;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @couldNotLoadGames.
  ///
  /// In id, this message translates to:
  /// **'Daftar game tidak dapat dimuat.'**
  String get couldNotLoadGames;

  /// No description provided for @selectGameFirst.
  ///
  /// In id, this message translates to:
  /// **'Pilih game terlebih dahulu.'**
  String get selectGameFirst;

  /// No description provided for @partyCreated.
  ///
  /// In id, this message translates to:
  /// **'Party berhasil dibuat!'**
  String get partyCreated;

  /// No description provided for @rankRequired.
  ///
  /// In id, this message translates to:
  /// **'Rank wajib diisi'**
  String get rankRequired;

  /// No description provided for @playersRange.
  ///
  /// In id, this message translates to:
  /// **'Masukkan angka 2-20'**
  String get playersRange;

  /// No description provided for @timeRequired.
  ///
  /// In id, this message translates to:
  /// **'Waktu wajib diisi'**
  String get timeRequired;

  /// No description provided for @descriptionRequired.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi wajib diisi'**
  String get descriptionRequired;

  /// No description provided for @playTimeExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh: 20:00'**
  String get playTimeExample;

  /// No description provided for @descriptionExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Cari 3 orang buat push rank santai...'**
  String get descriptionExample;

  /// No description provided for @homeTitle.
  ///
  /// In id, this message translates to:
  /// **'Cari party'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Temukan pemain untuk sesi berikutnya.'**
  String get homeSubtitle;

  /// No description provided for @searchGameOrPlayer.
  ///
  /// In id, this message translates to:
  /// **'Cari game atau pemain'**
  String get searchGameOrPlayer;

  /// No description provided for @allGames.
  ///
  /// In id, this message translates to:
  /// **'Semua game'**
  String get allGames;

  /// No description provided for @allRanks.
  ///
  /// In id, this message translates to:
  /// **'Semua rank'**
  String get allRanks;

  /// No description provided for @allLanguages.
  ///
  /// In id, this message translates to:
  /// **'Semua bahasa'**
  String get allLanguages;

  /// No description provided for @clearFilters.
  ///
  /// In id, this message translates to:
  /// **'Hapus filter'**
  String get clearFilters;

  /// No description provided for @refresh.
  ///
  /// In id, this message translates to:
  /// **'Muat ulang'**
  String get refresh;

  /// No description provided for @noParties.
  ///
  /// In id, this message translates to:
  /// **'Belum ada party yang cocok.'**
  String get noParties;

  /// No description provided for @noPartiesHint.
  ///
  /// In id, this message translates to:
  /// **'Coba ubah filter atau periksa lagi nanti.'**
  String get noPartiesHint;

  /// No description provided for @joinParty.
  ///
  /// In id, this message translates to:
  /// **'Gabung party'**
  String get joinParty;

  /// No description provided for @partyFull.
  ///
  /// In id, this message translates to:
  /// **'Party penuh'**
  String get partyFull;

  /// No description provided for @open.
  ///
  /// In id, this message translates to:
  /// **'TERBUKA'**
  String get open;

  /// No description provided for @full.
  ///
  /// In id, this message translates to:
  /// **'PENUH'**
  String get full;

  /// No description provided for @playerCount.
  ///
  /// In id, this message translates to:
  /// **'{current}/{maximum} pemain'**
  String playerCount(int current, int maximum);

  /// No description provided for @myParty.
  ///
  /// In id, this message translates to:
  /// **'Party Saya'**
  String get myParty;

  /// No description provided for @noJoinedParties.
  ///
  /// In id, this message translates to:
  /// **'Kamu belum bergabung dengan party.'**
  String get noJoinedParties;

  /// No description provided for @profileTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @playerProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil pemain'**
  String get playerProfile;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logout;

  /// No description provided for @followers.
  ///
  /// In id, this message translates to:
  /// **'Pengikut'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In id, this message translates to:
  /// **'Mengikuti'**
  String get following;

  /// No description provided for @activity.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas'**
  String get activity;

  /// No description provided for @partiesCreated.
  ///
  /// In id, this message translates to:
  /// **'Party dibuat'**
  String get partiesCreated;

  /// No description provided for @partiesJoined.
  ///
  /// In id, this message translates to:
  /// **'Party diikuti'**
  String get partiesJoined;

  /// No description provided for @playersMet.
  ///
  /// In id, this message translates to:
  /// **'Pemain ditemui'**
  String get playersMet;

  /// No description provided for @manageGames.
  ///
  /// In id, this message translates to:
  /// **'Kelola game'**
  String get manageGames;

  /// No description provided for @myGames.
  ///
  /// In id, this message translates to:
  /// **'Game saya'**
  String get myGames;

  /// No description provided for @games.
  ///
  /// In id, this message translates to:
  /// **'Game'**
  String get games;

  /// No description provided for @noGamesInProfile.
  ///
  /// In id, this message translates to:
  /// **'Belum ada game di profil kamu.'**
  String get noGamesInProfile;

  /// No description provided for @noGamesShown.
  ///
  /// In id, this message translates to:
  /// **'Belum ada game yang ditampilkan.'**
  String get noGamesShown;

  /// No description provided for @follow.
  ///
  /// In id, this message translates to:
  /// **'Ikuti'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In id, this message translates to:
  /// **'Berhenti mengikuti'**
  String get unfollow;

  /// No description provided for @updating.
  ///
  /// In id, this message translates to:
  /// **'Memperbarui...'**
  String get updating;

  /// No description provided for @tryAgain.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get tryAgain;

  /// No description provided for @partyNotFound.
  ///
  /// In id, this message translates to:
  /// **'Party tidak ditemukan.'**
  String get partyNotFound;

  /// No description provided for @host.
  ///
  /// In id, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @ready.
  ///
  /// In id, this message translates to:
  /// **'Siap'**
  String get ready;

  /// No description provided for @notReady.
  ///
  /// In id, this message translates to:
  /// **'Belum siap'**
  String get notReady;

  /// No description provided for @markReady.
  ///
  /// In id, this message translates to:
  /// **'Tandai siap'**
  String get markReady;

  /// No description provided for @markNotReady.
  ///
  /// In id, this message translates to:
  /// **'Tandai belum siap'**
  String get markNotReady;

  /// No description provided for @sendMessage.
  ///
  /// In id, this message translates to:
  /// **'Kirim pesan'**
  String get sendMessage;

  /// No description provided for @endParty.
  ///
  /// In id, this message translates to:
  /// **'Akhiri party'**
  String get endParty;

  /// No description provided for @leaveParty.
  ///
  /// In id, this message translates to:
  /// **'Keluar party'**
  String get leaveParty;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @signIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get signUp;

  /// No description provided for @findPlayers.
  ///
  /// In id, this message translates to:
  /// **'Temukan teman untuk sesi berikutnya.'**
  String get findPlayers;

  /// No description provided for @noUsers.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pemain untuk ditampilkan.'**
  String get noUsers;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan'**
  String get saved;

  /// No description provided for @gameDashboard.
  ///
  /// In id, this message translates to:
  /// **'Game saya'**
  String get gameDashboard;

  /// No description provided for @followersList.
  ///
  /// In id, this message translates to:
  /// **'Pengikut'**
  String get followersList;

  /// No description provided for @followingList.
  ///
  /// In id, this message translates to:
  /// **'Mengikuti'**
  String get followingList;

  /// No description provided for @errorLoading.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat memuat data. Periksa koneksi lalu coba lagi.'**
  String get errorLoading;

  /// No description provided for @errorAction.
  ///
  /// In id, this message translates to:
  /// **'Tindakan gagal. Coba lagi.'**
  String get errorAction;

  /// No description provided for @feedDescription.
  ///
  /// In id, this message translates to:
  /// **'Temukan pemain berdasarkan game, rank, dan bahasa.'**
  String get feedDescription;

  /// No description provided for @all.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get all;

  /// No description provided for @partyDetails.
  ///
  /// In id, this message translates to:
  /// **'RINCIAN PARTY'**
  String get partyDetails;

  /// No description provided for @joinSuccess.
  ///
  /// In id, this message translates to:
  /// **'Berhasil bergabung ke party.'**
  String get joinSuccess;

  /// No description provided for @joinFailure.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat bergabung ke party. Coba lagi.'**
  String get joinFailure;

  /// No description provided for @unknownGame.
  ///
  /// In id, this message translates to:
  /// **'Game tidak diketahui'**
  String get unknownGame;

  /// No description provided for @userFallback.
  ///
  /// In id, this message translates to:
  /// **'Pemain'**
  String get userFallback;

  /// No description provided for @completeGameData.
  ///
  /// In id, this message translates to:
  /// **'Pilih game dan lengkapi data.'**
  String get completeGameData;

  /// No description provided for @dashboardSaved.
  ///
  /// In id, this message translates to:
  /// **'Data game tersimpan.'**
  String get dashboardSaved;

  /// No description provided for @role.
  ///
  /// In id, this message translates to:
  /// **'Peran'**
  String get role;

  /// No description provided for @roleExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Duelist / Tank'**
  String get roleExample;

  /// No description provided for @gamesPlayed.
  ///
  /// In id, this message translates to:
  /// **'Jumlah game'**
  String get gamesPlayed;

  /// No description provided for @winRate.
  ///
  /// In id, this message translates to:
  /// **'Win rate (%)'**
  String get winRate;

  /// No description provided for @favoriteCharacter.
  ///
  /// In id, this message translates to:
  /// **'Karakter favorit'**
  String get favoriteCharacter;

  /// No description provided for @noUsersMessage.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pemain untuk ditampilkan.'**
  String get noUsersMessage;

  /// No description provided for @completeFields.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi semua kolom.'**
  String get completeFields;

  /// No description provided for @signUpEmailNotice.
  ///
  /// In id, this message translates to:
  /// **'Pendaftaran berhasil. Jika konfirmasi email aktif, periksa email kamu.'**
  String get signUpEmailNotice;

  /// No description provided for @username.
  ///
  /// In id, this message translates to:
  /// **'Nama pengguna'**
  String get username;

  /// No description provided for @email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi'**
  String get password;

  /// No description provided for @noAccount.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun? Daftar'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun? Masuk'**
  String get haveAccount;

  /// No description provided for @partyRoom.
  ///
  /// In id, this message translates to:
  /// **'Ruang party'**
  String get partyRoom;

  /// No description provided for @partyMembers.
  ///
  /// In id, this message translates to:
  /// **'ANGGOTA PARTY'**
  String get partyMembers;

  /// No description provided for @membersCount.
  ///
  /// In id, this message translates to:
  /// **'{count} pemain'**
  String membersCount(int count);

  /// No description provided for @chatParty.
  ///
  /// In id, this message translates to:
  /// **'CHAT PARTY'**
  String get chatParty;

  /// No description provided for @chatEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pesan. Mulai obrolan party.'**
  String get chatEmpty;

  /// No description provided for @messageForParty.
  ///
  /// In id, this message translates to:
  /// **'Pesan untuk party'**
  String get messageForParty;

  /// No description provided for @writeMessage.
  ///
  /// In id, this message translates to:
  /// **'Tulis pesan...'**
  String get writeMessage;

  /// No description provided for @partyEnded.
  ///
  /// In id, this message translates to:
  /// **'Party telah berakhir.'**
  String get partyEnded;

  /// No description provided for @statusFailure.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat memperbarui status. Coba lagi.'**
  String get statusFailure;

  /// No description provided for @messageFailure.
  ///
  /// In id, this message translates to:
  /// **'Pesan gagal dikirim. Coba lagi.'**
  String get messageFailure;

  /// No description provided for @leaveFailure.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat keluar dari party. Coba lagi.'**
  String get leaveFailure;

  /// No description provided for @endFailure.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat mengakhiri party. Coba lagi.'**
  String get endFailure;

  /// No description provided for @languageIndonesia.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesia;

  /// No description provided for @languageEnglish.
  ///
  /// In id, this message translates to:
  /// **'Inggris'**
  String get languageEnglish;

  /// No description provided for @languageJapanese.
  ///
  /// In id, this message translates to:
  /// **'Jepang'**
  String get languageJapanese;

  /// No description provided for @other.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get other;

  /// No description provided for @addGame.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan game'**
  String get addGame;

  /// No description provided for @playerData.
  ///
  /// In id, this message translates to:
  /// **'DATA PEMAIN'**
  String get playerData;

  /// No description provided for @saveGame.
  ///
  /// In id, this message translates to:
  /// **'Simpan game'**
  String get saveGame;

  /// No description provided for @saving.
  ///
  /// In id, this message translates to:
  /// **'Menyimpan...'**
  String get saving;

  /// No description provided for @displayedGames.
  ///
  /// In id, this message translates to:
  /// **'Game yang ditampilkan'**
  String get displayedGames;

  /// No description provided for @addedGameHelp.
  ///
  /// In id, this message translates to:
  /// **'Game yang kamu tambahkan akan tampil di sini.'**
  String get addedGameHelp;

  /// No description provided for @requiredField.
  ///
  /// In id, this message translates to:
  /// **'Wajib diisi'**
  String get requiredField;

  /// No description provided for @numberOnly.
  ///
  /// In id, this message translates to:
  /// **'Masukkan angka saja'**
  String get numberOnly;

  /// No description provided for @rangeZeroToHundred.
  ///
  /// In id, this message translates to:
  /// **'Masukkan angka dari 0 sampai 100'**
  String get rangeZeroToHundred;

  /// No description provided for @rankExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Silver 3 / Mythic'**
  String get rankExample;

  /// No description provided for @members.
  ///
  /// In id, this message translates to:
  /// **'Pemain'**
  String get members;

  /// No description provided for @hostName.
  ///
  /// In id, this message translates to:
  /// **'Host: {name}'**
  String hostName(String name);

  /// No description provided for @missingSupabase.
  ///
  /// In id, this message translates to:
  /// **'Supabase belum dikonfigurasi. Jalankan aplikasi dengan nilai SUPABASE_URL dan SUPABASE_ANON_KEY melalui dart-define.'**
  String get missingSupabase;

  /// No description provided for @back.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get back;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
