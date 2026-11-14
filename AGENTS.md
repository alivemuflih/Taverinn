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

## Git Rules

- Jangan melakukan `git push` tanpa persetujuan user.
- Jangan menjalankan `git reset --hard`.
- Jangan menghapus atau menimpa perubahan yang dibuat user.
- Sebelum perubahan besar, periksa `git diff` untuk memahami perubahan yang sudah ada.
- Setelah implementasi kode selesai, jalankan `flutter analyze` dan laporkan hasilnya. Untuk perubahan dokumentasi saja, gunakan penilaian apakah analisis kode relevan.
- Jelaskan file yang diubah dan alasan perubahannya dalam ringkasan akhir.

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

<!-- antislop:start -->
## antislop
For UI, copy, people, mobile layout, or code comments work, read these installed skill files directly (use these paths even if a same-named global skill exists):
- Core filter, always on: `antislop`: `.codex/skills/antislop/SKILL.md`
- UI / visual: `antislop-ui`: `.codex/skills/antislop-ui/SKILL.md`
- Copy & text: `antislop-copywriting`: `.codex/skills/antislop-copywriting/SKILL.md`
- People: `antislop-human`: `.codex/skills/antislop-human/SKILL.md`
- Mobile / responsive: `antislop-layoutmobile`: `.codex/skills/antislop-layoutmobile/SKILL.md`
Before starting, follow the core's "Two Usage Modes" section in strict order: explicit session instruction first, then global preference, then ask. A session instruction always wins. For a resolved mode, say `antislop active: <mode> (session override).` or `antislop active: <mode> (global preference).` once before presenting findings or making edits, using the actual mode and source. Acknowledging the user's request without naming the source does not replace this notice.
Only an explicit choice of antislop during or after selects a session mode. A request to review, audit, or avoid file edits does not select a mode; read the global preference in that case. Another skill's mode does not select antislop's mode.
If the mode is unresolved, ask during/after and end the response; wait for the answer before any UI review, planning, or concept. For read-only tasks, put the active-mode notice only at the start of the final answer, never in progress messages. For editing tasks, announce before the first edit and omit it from the final answer.
To update antislop later: `npx antislop-ai --update`, or run `npx antislop-ai` and pick Overwrite them.
<!-- antislop:end -->
