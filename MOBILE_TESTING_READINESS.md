# Taverinn Mobile Testing Readiness

## Ringkasan status

- Implementasi utama Phase 1 dan Phase 2 dipertahankan. Phase 3 tidak termasuk ruang lingkup.
- Audit ini tidak menghubungkan atau mengubah database Supabase.
- Build Web berhasil. Build APK debug terhambat oleh instalasi NDK Android pada mesin ini.
- Belum ada Maestro flow YAML yang dapat diklaim runnable: Maestro tidak tersedia, dan APK belum berhasil dibuat untuk memeriksa accessibility hierarchy di Android.

## Android

| Item | Status |
|---|---|
| Android scaffold | Ada (`android/`) |
| Application ID | `com.example.taverinn` — ID template yang dapat dipakai untuk testing lokal; ganti ke ID unik sebelum distribusi |
| App name | `Taverinn` di AndroidManifest |
| INTERNET permission | Ada di main/debug/profile manifest |
| Java/Kotlin target | Java source/target 17 dan Kotlin JVM target 17 |
| Gradle runtime | Android Studio JBR OpenJDK 25.0.4 terdeteksi pada mesin ini |
| Gradle | Wrapper 9.3.1; Android Gradle Plugin 9.1.0; Kotlin plugin 2.4.0 |
| SDK levels | `compileSdk`, `targetSdk`, `minSdk`, dan NDK mengikuti default Flutter SDK, bukan angka yang ditetapkan repository |
| APK debug | Gagal pada environment: Android SDK Manager melaporkan package NDK `28.2.13676358` tidak ditemukan/tidak terpasang |
| Android runtime | Belum diuji pada emulator/perangkat fisik |

Perintah APK sempat mengunduh/memasang Android CLI, lalu berhenti saat SDK Manager tidak dapat memasang NDK yang diminta. Tidak ada perubahan source untuk mencoba melewati kegagalan tersebut. Periksa Android SDK Manager/NDK installation dan ulangi build setelah toolchain diperbaiki.

## Flutter checks

| Command | Hasil |
|---|---|
| `flutter pub get` | Berhasil. Lima paket memiliki versi lebih baru yang tidak cocok dengan constraint saat ini; tidak ada upgrade massal dilakukan. |
| `dart analyze lib` | Exit 0; tidak ada error. Terdapat 5 info deprecation lama pada `anonKey`, 3 dropdown di `create_lfg_screen.dart`, dan dropdown di `game_dashboard_screen.dart`. |
| `flutter test` | Lulus: 11 unit/kontrak test. Test kontrak memeriksa SQL repository, bukan database aktif. |
| `flutter build web` | Berhasil. |
| `flutter build apk --debug` | Gagal karena NDK `28.2.13676358` tidak ditemukan oleh Android SDK Manager pada environment ini. |
| `flutter analyze` | Exit 1 karena 5 info deprecation yang sama; tidak ada error atau warning baru dari perubahan readiness. |

Tidak ada manual test, realtime/two-account test, Android device test, atau Maestro test yang dijalankan. `adb.exe` tersedia di Android SDK lokal tetapi tidak ada di PATH; pemanggilan langsung gagal saat mencoba membuat `\.android` karena environment Android home mengarah ke root yang tidak dapat ditulis.

## Feature checklist

### Phase 1 — Core Party

- [ ] Login dan register melalui Supabase Auth
- [ ] Profile sendiri dan Game Dashboard
- [ ] Create Party dan host langsung membuka Party Room
- [ ] Party Feed dan filter game/rank/bahasa
- [ ] Join Party dan My Party
- [ ] Party Room menampilkan anggota dan host indicator
- [ ] Ready/Not Ready tersinkron lintas session
- [ ] Chat realtime dua arah
- [ ] Member dapat Leave; host dapat End Party
- [ ] Party, member, dan chat terhapus mengikuti cascade setelah End Party
- [ ] Akun/profile/game dashboard tetap ada
- [ ] RLS, RPC, capacity protection, dan row Realtime terverifikasi pada Supabase

### Phase 2 — Social Profile

- [ ] Buka profile user lain dari member list Party Room
- [ ] Follow dan Unfollow
- [ ] Lihat Followers dan Following
- [ ] Lihat Game Dashboard user lain
- [ ] Verifikasi Parties Created dan Parties Joined
- [ ] Verifikasi Players Met: host tidak menghitung dirinya sendiri dan pemain unik dihitung sekali
- [ ] Statistik dan relationship tetap ada setelah party berakhir

## Screen checklist

- `AuthScreen` — login/register
- `MainScreen` — navigasi tab Home, Create, Party, Profile
- `HomeScreen` — feed, filter, detail, join
- `CreateLfgScreen` — form party
- `PartyScreen` — My Party dan masuk kembali ke room
- `PartyRoomScreen` — member, ready, chat, leave/end
- `ProfileScreen` — profile sendiri/user lain, follow, stats, game list
- `FollowListScreen` — Followers/Following dan navigasi profile
- `GameDashboardScreen` — tambah dan lihat game sendiri
- `MissingConfigApp` — pesan bila Supabase URL/key tidak diberikan

Poin yang perlu dites di device: keyboard/resize, scroll dan overflow pada layar kecil, tombol Back, loading/error/empty state, serta perpindahan route saat host mengakhiri party. Audit memperbaiki pembedaan feed error dari feed kosong, pembatalan filter yang sebelumnya dianggap sebagai pilihan "Semua", dan dispose controller pada screen yang memilikinya.

Guard tambahan mencegah `PartyRoomScreen` membersihkan controller setelah room sudah ditutup saat request chat masih berjalan. Tombol kirim chat memiliki tooltip agar label aksinya tersedia untuk accessibility/selector.

## Maestro preparation

Folder `maestro/` disiapkan untuk flow. Selector teks di bawah berasal dari label/teks yang memang ada di widget, tetapi belum diverifikasi terhadap accessibility hierarchy Android. Karena APK belum terbangun dan Maestro CLI belum tersedia, belum dibuat flow YAML yang diklaim siap jalan.

Flow yang direkomendasikan setelah Android runtime tersedia:

| # | Flow | Account | Preconditions | Expected result | Perlu realtime bersamaan? |
|---:|---|---|---|---|---|
| 1 | Login | A | App signed out; akun aktif dan credential disediakan melalui environment lokal | Home menampilkan feed | Tidak |
| 2 | Logout | A | A sudah login | Kembali ke Login | Tidak |
| 3 | Create Party | A (host) | A login; game tersedia | Party dibuat dan room terbuka | Tidak |
| 4 | Join Party | B (player) | Party A masih open dan punya slot | B berhasil join; counter kapasitas berubah | Ya, A/B untuk verifikasi silang |
| 5 | Open Party Room | A/B | Akun sudah menjadi member | Room dan roster tampil | Tidak untuk membuka; ya untuk roster silang |
| 6 | Ready / Not Ready | A/B | Dua member berada di room | Status berubah dan kembali terlihat di session lain | Ya |
| 7 | Chat | A/B | Dua member berada di room | Pesan terkirim dan tampil di kedua room | Ya |
| 8 | Leave Party | B | B member; party tetap hidup | B keluar dan roster/counter host berubah | Ya |
| 9 | End Party | A | A host; B masih berada di room | Room ditutup untuk keduanya; row sementara terhapus | Ya |
| 10 | View another profile | A | A dan B member di room yang sama | Mengetuk B membuka profile B; Back kembali ke room | Ya untuk setup |
| 11 | Follow | A | A membuka profile B; A bukan B | State follow dan counts bertambah | Tidak |
| 12 | Unfollow | A | A sedang follow B | Relationship dan counts berkurang | Tidak |
| 13 | Followers / Following | A | Ada relationship yang dapat dilihat | Daftar dan profile tujuan terbuka | Tidak |
| 14 | View Game Dashboard | A | B memiliki user game; policy Phase 2 aktif | Game B terlihat di profile B | Tidak |
| 15 | Activity Statistics | A/B | Counter tersedia setelah create/join | Tiga counter cocok dengan transaksi yang dilakukan | Ya untuk verifikasi dua sisi |

## Test accounts

- **Account A — host:** membuat party, mengakhiri party, memeriksa `Parties Created` dan `Players Met`.
- **Account B — player:** join/leave, memeriksa `Parties Joined`, follow/unfollow, dan menerima realtime.
- **Account C — player opsional:** dipakai untuk membuktikan `Players Met` menghitung pemain unik.

Gunakan akun testing khusus. Jangan menaruh password, anon key, atau credential dalam file flow/dokumentasi yang di-commit; berikan credential melalui environment lokal/CI secret.

## Preconditions dan hasil yang diharapkan

1. Gunakan Supabase environment yang memang sudah memiliki Phase 1 dan Phase 2, serta seed game yang diperlukan. Jangan jalankan ulang full `supabase/schema.sql` pada database berisi data.
2. Pastikan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` disediakan melalui `--dart-define` atau konfigurasi lokal. Jangan gunakan `service_role` key di client.
3. Siapkan dua device/session terpisah untuk skenario party dan realtime. Sesi harus login ke project Supabase yang sama.
4. Pastikan party yang digunakan belum penuh, dan akun B/C bukan anggota sebelumnya.
5. Untuk statistik, catat nilai awal sebelum aksi; setiap create/join yang berhasil harus menaikkan counter yang sesuai. Join ulang pemain yang sama tidak menaikkan `Players Met` host kedua kali.
6. Setelah host End Party, room tutup dan row party/member/message hilang; profile, follows, user games, stats, dan interaksi permanen tetap ada.

## Realtime dependency

Join, roster, Ready, chat, Leave, End Party dan penghapusan room perlu dua akun/session aktif. Players Met memerlukan host dan player; deduplikasi lintas party paling jelas diuji dengan Account C dan percobaan join ulang B. Test satu akun tidak membuktikan Realtime atau capacity race.

## Readiness conclusion

Belum siap untuk menyatakan **Mobile Testing dengan Maestro** dimulai: Web dan Flutter unit checks lulus, tetapi APK belum berhasil dibangun, Maestro CLI tidak ditemukan di PATH, accessibility selectors belum diverifikasi pada Android, dan realtime Supabase belum diuji dua akun pada device. Lanjutkan setelah NDK terpasang, APK berhasil dibuat/dijalankan, Maestro tersedia, lalu jalankan checklist realtime dengan akun testing.
