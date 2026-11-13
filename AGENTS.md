# Project Instructions

## Project

- Nama aplikasi: **Taverinn**
- Tujuan: aplikasi sosial LFG (Looking For Group) untuk mencari teman mabar.
- README dan kode adalah sumber kebenaran untuk fitur yang sudah berjalan. Jangan menganggap fitur yang belum ada sebagai bagian dari aplikasi.

## Tech Stack

- Flutter dan Dart (Dart SDK `>=3.4.0 <4.0.0`)
- Supabase Flutter untuk autentikasi dan akses data
- Supabase PostgreSQL untuk database, RLS, trigger, dan RPC
- Target yang didokumentasikan: Flutter Web dan Android

## Struktur Project

- `lib/main.dart` — inisialisasi Flutter/Supabase dan auth gate.
- `lib/screens/` — layar autentikasi, home/feed, create LFG, party, profil, dan dashboard game.
- `lib/services/supabase_service.dart` — akses Supabase dan operasi data.
- `supabase/schema.sql` — tabel, constraints, trigger, fungsi RPC, seed data, serta RLS policies.
- `test/` — tes Flutter (jika tersedia/ditambahkan).
- `README.md` dan `TESTING_CHECKLIST.md` — setup, fitur MVP, dan skenario uji manual.

Jangan mengasumsikan direktori atau layer lain ada. Periksa struktur terkini sebelum menambah file atau mengubah arsitektur.

## Aturan Implementasi

- Pertahankan Flutter/Dart dan pola arsitektur yang sudah digunakan; jangan menggantinya dengan stack lain.
- Jangan mengubah struktur database, constraints, kebijakan RLS, trigger, RPC, atau seed database tanpa izin eksplisit.
- Jangan menghapus atau mengubah perilaku fitur yang sudah ada tanpa konfirmasi.
- Gunakan layar, widget, service, dan pola UI yang sudah tersedia sebelum membuat duplikasi.
- Operasi asinkron menggunakan `async`/`await`; tangani loading, error, dan lifecycle widget dengan aman (`mounted` bila diperlukan setelah `await`).
- Semua akses database/API Supabase ditempatkan melalui `lib/services/supabase_service.dart` bila sesuai pola yang ada. Hindari query Supabase tersebar di layar untuk operasi data baru.
- Jangan menaruh Supabase `service_role` key atau rahasia di aplikasi. URL dan anon key dibaca dari `--dart-define` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
- Ikuti null safety, lint Flutter, gaya Dart, dan komponen Material yang telah digunakan.
- Jangan membuat file baru jika fungsi tersebut dapat ditambahkan dengan jelas ke file yang sudah ada. Buat file baru bila memang meningkatkan pemisahan tanggung jawab dan sesuai pola project.

## Workflow

Sebelum mengubah kode:

1. Baca struktur project dan instruksi `AGENTS.md` lain yang berlaku.
2. Cari file yang relevan.
3. Pahami implementasi, pola UI, service, dan dampak perubahan terhadap Supabase/schema.
4. Baru lakukan perubahan terkecil yang memenuhi kebutuhan.

Setelah mengubah kode:

1. Jalankan pemeriksaan atau tes yang relevan, misalnya `flutter analyze` dan `flutter test`.
2. Jalankan build target yang relevan, misalnya `flutter build web` atau `flutter build apk`.
3. Perbaiki error yang diperkenalkan oleh perubahan.
4. Laporkan ringkasan perubahan serta pemeriksaan yang benar-benar dijalankan dan hasilnya.

Jangan mengklaim tes/build berhasil jika perintahnya tidak dijalankan. Untuk perubahan dokumentasi saja, gunakan penilaian apakah tes/build memang relevan.

## Perintah Umum

```bash
flutter pub get
flutter analyze
flutter test
flutter build web
```

Contoh menjalankan Web dengan konfigurasi Supabase:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```
