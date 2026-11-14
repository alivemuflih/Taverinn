# Taverinn Social Profile — Manual Test Checklist

Gunakan dua atau tiga akun asli pada project Supabase yang sama, dengan Phase 2 sudah diterapkan. Jangan memakai mock data. Statistik lama sebelum Phase 2 tidak dapat direkonstruksi jika party yang menjadi sumbernya sudah dihapus; hitungan mulai akurat sejak RPC Phase 2 aktif.

## Follow and profile navigation

### Test 1 — Follow

- [ ] Account A membuka profile Account B.
- [ ] Tombol **Follow** muncul dan tidak muncul pada profile diri sendiri.
- [ ] A menekan Follow.
- [ ] Relationship A → B tersimpan.
- [ ] Followers B bertambah satu dan Following A bertambah satu setelah profile refresh.

### Test 2 — Unfollow

- [ ] A menekan **Following** pada profile B untuk unfollow.
- [ ] Relationship A → B hilang.
- [ ] Counts kembali berkurang satu.
- [ ] Unfollow relationship yang sudah tidak ada tidak merusak data.

### Test 3 — Profile dari Party Room

- [ ] A dan B berada di Party Room yang sama.
- [ ] A mengetuk nama/avatar B.
- [ ] Profile B terbuka, data profile/games/statistics tampil, dan tombol Follow tersedia.
- [ ] A kembali ke Party Room; chat, Ready, daftar anggota, dan Realtime tetap aktif.

### Test 4 — Followers/Following lists

- [ ] Ketuk angka Followers dan Following dari profile.
- [ ] Daftar menampilkan username/avatar dari Supabase.
- [ ] Mengetuk item membuka profile user terkait.
- [ ] Follow state pada daftar konsisten setelah refresh.

## Activity statistics

### Test 5 — Party created

- [ ] Catat Parties Created Account A.
- [ ] A membuat party yang berhasil.
- [ ] Parties Created A bertambah tepat satu.

### Test 6 — Party joined dan first interaction

- [ ] A membuat party dan B berhasil join.
- [ ] Parties Joined B bertambah satu.
- [ ] Players Met A bertambah satu; host A tidak dihitung sebagai pemain yang ditemui.

### Test 7 — Additional unique player

- [ ] C join party milik A.
- [ ] Players Met A bertambah satu lagi.

### Test 8 — Rejoin/repeated interaction

- [ ] B leave lalu join kembali, atau join party A yang berbeda.
- [ ] Parties Joined B bertambah untuk join yang berhasil.
- [ ] Players Met A tidak bertambah lagi untuk B yang sama.
- [ ] A tidak pernah menghitung dirinya sendiri pada Players Met.

### Test 9 — End Party permanence

- [ ] A mengakhiri party.
- [ ] `lfg_posts`, `party_members`, dan `party_messages` terhapus.
- [ ] Follow A → B tetap ada.
- [ ] `user_stats` A dan B serta interaksi permanen tetap ada.
- [ ] Refresh app; counts dan activity statistics tetap sama.

### Test 10 — Self-follow and permissions

- [ ] User mencoba follow diri sendiri melalui UI; tombol tidak tersedia.
- [ ] Pemanggilan RPC `follow_user` ke diri sendiri ditolak.
- [ ] User tidak dapat insert/delete follow sebagai akun lain.
- [ ] User tidak dapat membuat atau mengubah `user_stats` secara langsung.
- [ ] User hanya dapat melihat `user_games` melalui policy authenticated yang telah disetujui.

## Automated tests

```bash
flutter test
```

Unit test menguji aturan murni UI (self-follow/relationship state). Atomic counters, RLS, dedup interaction, dan persistensi tetap harus diuji terhadap Supabase dengan skenario di atas.
