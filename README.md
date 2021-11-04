##  Cara Build
- **Development :** flutter build apk --verbose --dart-define=ENV=DEV
- **RC :** flutter build apk --verbose --dart-define=ENV=RC
- **Production :** flutter build apk --verbose --dart-define=ENV=PROD

##  Sedikit info yang mungkin bisa membantu anda

**Bagaimana cara membedakan environment development/rc/production di aplikasi ini?**
- Caranya pakai command argument. Informasi lengkpanya bisa dibaca [disini](https://itnext.io/flutter-1-17-no-more-flavors-no-more-ios-schemas-command-argument-that-solves-everything-8b145ed4285d)
- Untuk singkatnya bisa ikuti langkah dibawah ini:
  1. Buat class EnvironmentConfig (ini bisa dikasih nama apapun, cuma supaya gampang tak kasih nama tadi). Filenya bisa dilihat [lib/environment_config.dart](lib/environment_config.dart)
  2. Di class tersebut terdapat variabel untuk mendeskripsikan variabel environmentnya. Contohnya saya mendeskripsikan variabel "ENV" dengan default value "DEV" untuk menentukan environment mana yang akan pakai.
  3. Lalu selanjutnya buka file [lib\global_config.dart](lib/global_config.dart). Di file tersebut terdapat fungsi untuk mengambil url mana yang dipakai untuk setiap environment.
  4. Lalu selanjutnya buka file [android\app\build.gradle](android/app/build.gradle). Disana terdapat fungsi untuk menentukan nama aplikasi dan id aplikasi untuk setiap environment. Untuk lengkapnya bisa langsung coba baca file diatas.

**Bagaimana alur program ini?**
- Widget pertama yang ditampilkan adalah [lib\screens\splash_screen.dart](lib/screens/splash_screen.dart). Widget ini akan melakukan pengecekan apakah usernya sudah login atau belum.
- Jika belum login, widget selanjutnya yang akan terbuka adalah [lib\screens\login_screen.dart](lib/screens/login_screen.dart). Widget ini akan menghadle fungsi login dari aplikasi ini.
- Jika login sukses maka akan dilanjutkan ke halaman [lib\screens\dashboard_screen.dart](lib/screens/dashboard_screen.dart). Widget ini akan menampilkan list penjadwalan yang tersedia untuk supir yang login.
- Jika salah satu penjadwalan dipilih maka selanjutnya akan masuk ke halaman [lib\screens\form_screen.dart](lib/screens/form_screen.dart). Di halaman ini sopir dapat melakukan update status untuk penjadwalan yang sudah dipilih.
- Selanjutnya terdapat widget [lib\widgets\camera_view.dart](lib/widgets/camera_view.dart). Widget ini meruapakn widget custom untuk mengambil dari kamera. Pakai widget ini supaya data hasil jeperetan kamera bisa langsung dihapus setelah gambar diupload ke server.

**Bagaimana cara kerja background process di aplikasi ini?**
- Di halaman [lib\screens\splash_screen.dart](lib/screens/splash_screen.dart) terdapat fungsi untuk mengaktifkan dan mematikan fitur tracking lewat platform channel.
- Fitur tracking ini dinyalakan atau dimatikan lewat notifikasi yang dikirim dengan firebase