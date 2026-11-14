# Taverinn Supabase Setup

Repository ini tidak berisi credential Supabase aktif. Database pengembangan Taverinn sudah memiliki Phase 1 dan Phase 2. Tidak ada SQL yang dijalankan oleh langkah readiness ini.

## Menerapkan schema

`supabase/schema.sql` adalah bootstrap schema untuk project baru/kosong. Jangan menjalankan ulang file itu pada database yang sudah memiliki data Phase 1/2 karena file ini juga mendefinisikan ulang RPC dan policy.

Jika database hanya memiliki Phase 1 dan Phase 2 belum diterapkan, tinjau lalu jalankan `supabase/PHASE_2_MIGRATION.sql` satu kali di SQL Editor. Migration ini mempertahankan sebagian besar Phase 1; ia mengganti body RPC create/join dengan signature yang sama untuk counter atomik, serta mengganti policy SELECT `user_games` agar game dashboard terlihat oleh semua pengguna login.

Jangan menjalankan migration Phase 2 berulang kali pada database yang sudah berisi Phase 2, walaupun bagian-bagian migration dibuat idempotent. Jangan menjalankan `schema.sql` sebagai pengganti migration pada database existing. Migration tidak menjatuhkan tabel atau menghapus akun/profile/party/chat; statistik party historis yang party-nya sudah dihapus tidak bisa dihitung kembali.

Untuk profile yang sudah ada saat Phase 2 diterapkan, `user_stats` dibuat dengan nilai awal 0. Interaksi pemain pada party yang masih aktif saat migration dijalankan di-backfill secara idempotent untuk `Players Met`. `Parties Created` dan `Parties Joined` dihitung mulai saat RPC Phase 2 aktif.

Status yang diketahui untuk project pengembangan: Phase 1 dan Phase 2 sudah diterapkan. Verifikasi status database target lain melalui Supabase Dashboard sebelum memilih file SQL; repository ini tidak dapat memastikan status project Supabase tanpa akses database.

## Credential aplikasi

1. Buka **Project Settings → API**.
2. Salin Project URL dan anon/public key.
3. Berikan nilai tersebut saat menjalankan Flutter melalui `--dart-define`.

`lib/main.dart` membaca `SUPABASE_URL` dan `SUPABASE_ANON_KEY` menggunakan `String.fromEnvironment`. Jangan hardcode credential, commit `.env`, atau menggunakan `service_role`/secret key di client Web maupun Android.

PowerShell:

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Untuk Android, gunakan command yang sama dan ganti `-d chrome` dengan `-d <device-id>` dari `flutter devices`.
