# Taverinn Party Room — Manual Test Checklist

Gunakan project Supabase yang sudah memiliki Phase 1 dan Phase 2. Jangan menjalankan ulang `supabase/schema.sql` pada database berisi data. Gunakan dua akun terpisah dan URL/key yang sama. Pengujian ini memerlukan Supabase aktif; checklist bukan bukti bahwa Realtime sudah diverifikasi.

## A. Browser Testing

- [ ] Jalankan `flutter devices` dan pastikan Chrome tersedia.
- [ ] Jalankan app di Chrome dengan `SUPABASE_URL` dan `SUPABASE_ANON_KEY`.
- [ ] Pastikan login dan register tetap berfungsi.
- [ ] Pastikan Home menampilkan party open dari Supabase.
- [ ] Pastikan layout Party Room dapat dipakai pada lebar desktop.
- [ ] Ulangi pada Chrome mobile/narrow viewport; pastikan chat, daftar member, dan tombol tidak overflow.
- [ ] Refresh halaman lalu login kembali; pastikan session dan data Supabase berfungsi.

## B. Android Testing

1. Aktifkan **Developer options** dan **USB debugging** pada Android.
2. Sambungkan device melalui USB dan setujui prompt debugging di device.
3. Pastikan Android SDK/toolchain tersedia melalui `flutter doctor`.
4. Jalankan:

   ```bash
   flutter devices
   ```

5. Jalankan app dengan device ID yang tampil:

   ```bash
   flutter run -d <device-id> --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
   ```

6. Login menggunakan Account A.
7. Login menggunakan Account B pada browser atau device kedua.

- [ ] App dapat terhubung ke Supabase melalui jaringan device.
- [ ] Keyboard tidak menutupi input chat dan tombol aksi.
- [ ] Party Room dapat digunakan pada ukuran layar Android.

Android device tidak diasumsikan tersedia di mesin development.

## C. Two Account Testing

- [ ] Account A membuat party; host langsung masuk Party Room.
- [ ] Account B melihat party A pada Home.
- [ ] Account B join dan masuk ke Party Room party A.
- [ ] A dan B melihat username, host indicator, dan anggota yang sama.
- [ ] B leave; host tetap berada di room dan melihat B keluar.
- [ ] B dapat join kembali selama party masih open.
- [ ] Pastikan role host/member menentukan tombol yang tersedia.

## D. Realtime Testing

- [ ] A mengirim chat; B menerima pesan tanpa refresh.
- [ ] B mengirim chat; A menerima pesan tanpa refresh.
- [ ] A mengubah status ke READY; B melihatnya tanpa refresh.
- [ ] B mengubah status ke READY lalu NOT READY; A melihat perubahan.
- [ ] B leave; A melihat roster dan hitungan pemain berubah.
- [ ] Dua user mencoba mengisi slot terakhir hampir bersamaan; kapasitas tidak terlampaui.
- [ ] User yang bukan anggota tidak dapat membaca atau mengirim `party_messages`.
- [ ] User tidak dapat membuat membership melalui insert langsung ke `party_members`.

## E. Party Deletion Testing

- [ ] Member tidak dapat mengakhiri party milik host.
- [ ] Host menekan **AKHIRI PARTY**.
- [ ] Host kembali ke Home dan melihat pesan “Party telah berakhir.”
- [ ] Member menerima penghapusan Realtime, keluar dari room, dan melihat pesan yang sama.
- [ ] Party tidak muncul lagi di Home atau My Party.
- [ ] `lfg_posts`, `party_members`, dan `party_messages` untuk party itu sudah terhapus.
- [ ] Akun, profile, `games`, dan `user_games` tetap ada.
- [ ] Chat party yang sudah dihapus tidak bisa dibaca lagi.

## Automated checks

```bash
flutter pub get
dart analyze lib
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

Build Web/Android memerlukan platform scaffold dan toolchain masing-masing. Jalankan instruksi setup di `README.md` dan `SUPABASE_SETUP.md` sebelum pengujian manual.
