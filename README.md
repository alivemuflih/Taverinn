# Taverinn

Aplikasi Flutter sederhana untuk mencari teman mabar / LFG (Looking For Group).

## Stack

- Flutter + Dart
- Supabase Auth
- Supabase PostgreSQL
- Flutter Web
- Flutter Android

## 1. Persiapan

Pastikan sudah terinstall:

- Flutter SDK
- VS Code / Android Studio
- Chrome
- Android SDK jika ingin menjalankan Android

Cek:

```bash
flutter doctor
```

## 2. Buat project Supabase

Buat project baru di Supabase.

Kemudian buka:

Supabase Dashboard -> SQL Editor

Salin seluruh isi:

```text
supabase/schema.sql
```

lalu Run.

Script tersebut membuat:

- profiles
- games
- user_games
- lfg_posts
- party_members
- RPC join_lfg_party
- RLS policies
- seed game

## 3. Supabase Auth

Buka:

Authentication -> Providers -> Email

Untuk testing lokal, kamu bisa menonaktifkan email confirmation agar register langsung bisa login.

## 4. Install dependency

Di folder project:

```bash
flutter pub get
```

## 5. Jalankan Flutter Web

Gunakan URL dan anon key dari:

Supabase Dashboard -> Project Settings -> API

Jalankan:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Windows PowerShell:

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Jangan pernah memasukkan `service_role` key ke aplikasi Flutter.

## 6. Android

Pastikan device/emulator terbaca:

```bash
flutter devices
```

Lalu:

```bash
flutter run -d <device-id> \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Contoh:

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
flutter run -d emulator-5554 --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

## 7. Fitur MVP

- Register
- Login
- Logout
- Home LFG
- Filter game
- Filter rank
- Filter bahasa
- Create LFG
- Detail LFG
- Join party
- My Party
- Profile
- Game Dashboard
- Supabase database

## 8. Skenario testing awal

### Auth
1. Register valid
2. Register email duplicate
3. Login valid
4. Login password salah
5. Login field kosong
6. Logout

### LFG
1. Create LFG valid
2. Create LFG tanpa game
3. Create LFG tanpa rank
4. Create LFG dengan jumlah pemain invalid
5. Refresh feed
6. Filter game
7. Filter rank
8. Filter bahasa
9. Kombinasi filter

### Party
1. Join party
2. Join party yang sama
3. Join party full
4. Cek current players
5. Cek status full

### Profile
1. Lihat profile
2. Tambahkan game
3. Edit/update game yang sama
4. Cek win rate validation
5. Logout

## 9. Struktur

```text
lib/
├── main.dart
├── models/
├── services/
│   └── supabase_service.dart
├── screens/
│   ├── auth_screen.dart
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── create_lfg_screen.dart
│   ├── party_screen.dart
│   ├── profile_screen.dart
│   └── game_dashboard_screen.dart
└── widgets/

supabase/
└── schema.sql
```

## Catatan

Project ini sengaja dibuat sebagai MVP untuk tugas kuliah. Belum ada:

- chat realtime
- friend system
- notification
- API statistik game
- matchmaking otomatis
- payment
