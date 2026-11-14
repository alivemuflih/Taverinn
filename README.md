# Taverinn

Taverinn adalah aplikasi LFG untuk menemukan teman bermain dan party berdasarkan game, rank, bahasa, mode, dan waktu bermain.

## Tech stack

- Flutter dan Dart
- Supabase Auth
- Supabase PostgreSQL, Row Level Security, RPC, dan Realtime
- Target aplikasi: Web dan Android

## Persiapan

Pasang Flutter SDK, Chrome untuk Web, serta Android Studio/Android SDK untuk Android. Periksa toolchain:

```bash
flutter doctor
```

Ambil dependency project:

```bash
flutter pub get
```

Folder platform `web/` dan `android/` sudah disertakan. Jika membuat ulang scaffold, gunakan Flutter tooling dan periksa diff sebelum menerima perubahan konfigurasi.

## Supabase dan environment

1. Buat atau pilih project Supabase.
2. Ikuti [SUPABASE_SETUP.md](SUPABASE_SETUP.md) untuk menerapkan SQL dan menyiapkan Auth.
3. Ambil **Project URL** dan **anon/public key** dari Project Settings → API.
4. Berikan nilai saat menjalankan aplikasi menggunakan `--dart-define`.

Project membaca `SUPABASE_URL` dan `SUPABASE_ANON_KEY` melalui `String.fromEnvironment` di `lib/main.dart`. Credential tidak di-hardcode. Jangan pernah memasukkan `service_role` atau secret key ke aplikasi.

## Web testing

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Untuk menghasilkan build Web:

```bash
flutter build web
```

## Android testing

Aktifkan USB debugging, sambungkan Android device atau mulai emulator, lalu periksa:

```bash
flutter devices
```

Jalankan dengan ID device yang tampil:

```bash
flutter run -d <device-id> --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Debug build:

```bash
flutter build apk --debug
```

Scaffold Android yang dibuat Flutter memakai `applicationId` template `com.example.taverinn` karena repository sebelumnya belum memiliki konfigurasi Android. Tetapkan application ID milik developer sebelum distribusi/publikasi. `minSdk`, `compileSdk`, dan NDK menggunakan nilai default Flutter SDK pada `android/app/build.gradle.kts`.

## Party Room dan pengujian dua akun

Party Room menyediakan daftar anggota, host indicator, Ready status, chat realtime, Leave, dan Host End Party. Untuk menguji lintas user:

1. Terapkan `supabase/schema.sql` ke project Supabase yang sama dengan credential aplikasi.
2. Jalankan app pada dua browser profile/device terpisah.
3. Login sebagai Account A pada client pertama dan Account B pada client kedua.
4. Ikuti checklist di [TESTING_PARTY_ROOM.md](TESTING_PARTY_ROOM.md) untuk join, chat, ready, leave, dan penghapusan party.

Status Realtime aktif harus diverifikasi melalui pengujian dua akun terhadap Supabase yang sudah dikonfigurasi. Menambahkan scaffold atau SQL ke repository tidak menerapkan perubahan ke project Supabase aktif.

## Phase 2 — Social Profile dan Activity Statistics

Profile antar-user menyediakan Follow/Unfollow, daftar Followers/Following, game dashboard yang terlihat untuk pengguna login, dan activity statistics **Parties Created**, **Parties Joined**, serta **Players Met**. Ini bukan trust score atau rating.

Data party (`lfg_posts`, `party_members`, `party_messages`) bersifat sementara dan dihapus saat host mengakhiri party. Data sosial/statistik (`follows`, `user_stats`, `user_player_interactions`) disimpan terpisah sehingga tidak ikut terhapus bersama party. Statistics diperbarui oleh RPC database dalam transaksi create/join, bukan dihitung oleh Flutter client.

Phase 1 dan Phase 2 sudah diterapkan pada project Supabase yang digunakan untuk pengembangan. Jangan menjalankan ulang `supabase/schema.sql` pada database berisi data; file tersebut adalah bootstrap schema, bukan migration upgrade. Untuk database yang hanya memiliki Phase 1, lihat [SUPABASE_SETUP.md](SUPABASE_SETUP.md) dan gunakan migration Phase 2 terpisah bila memang belum diterapkan. Pengujian two-account/realtime tetap perlu dilakukan pada environment target; checklist ada di [TESTING_SOCIAL_PROFILE.md](TESTING_SOCIAL_PROFILE.md).

## Pemeriksaan lokal

```bash
dart analyze lib
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

## Fitur

- Login, register, dan logout
- Feed LFG dengan filter game, rank, dan bahasa
- Membuat party dan join melalui RPC
- Party Room, daftar anggota, dan Ready status
- Chat party realtime
- Member dapat leave; host dapat mengakhiri party
- Follow/Unfollow, Followers, dan Following
- Activity Statistics permanen pada profile
- My Party, Profile, dan Game Dashboard
