# JEKI Petugas

Aplikasi Flutter untuk Petugas Lapangan JEKI: menerima tugas dari Admin, survei lokasi,
melihat dokumen kebutuhan bahan (PDF), memperbarui progres, dan mengirim laporan hasil.
Backend: **Supabase**. Peta: **Google Maps**.

> Kode ini ditulis tanpa Flutter SDK di lingkungan penyusunnya, jadi **belum pernah
> dikompilasi**. Jalankan `flutter analyze` setelah langkah di bawah; bila ada error kecil,
> kirim pesannya dan akan diperbaiki.

## Alur aplikasi

| Status | Artinya | Aksi Petugas di aplikasi |
|---|---|---|
| `menunggu` | Admin sudah menugaskan | Buka detail, **Mulai Survei** |
| `survei` | Sedang survei | Isi kondisi aktual, tingkat, deskripsi, foto, **Kirim Survei** |
| `bahan` | Survei terkirim | Menunggu Admin; bila PDF bahan sudah ada: lihat/unduh, **Mulai Pengerjaan** |
| `dikerjakan` | Perbaikan berlangsung | Catat progres/kendala + foto, lalu **Kirim Laporan Hasil** |
| `diperiksa` | Laporan terkirim | Menunggu pemeriksaan Admin |
| `revisi` | Admin minta perbaikan | Lihat catatan Admin, perbaiki, kirim ulang |
| `selesai` | Dikonfirmasi Admin | Muncul di Riwayat |

`selesai` dan `revisi` hanya bisa diberikan Admin (dijaga trigger di `supabase/schema.sql`).

## Cara menjalankan

### 1. Buat proyek Flutter lalu salin kode ini

```bash
flutter create jeki_petugas --org id.jeki
```

Salin **`lib/`**, **`supabase/`**, dan **`pubspec.yaml`** dari folder ini ke proyek hasil
`flutter create` (timpa yang ada), lalu hapus `test/widget_test.dart` karena merujuk ke
kode bawaan yang sudah tidak ada.

```bash
cd jeki_petugas
flutter pub get
```

### 2. Siapkan Supabase

1. Buat proyek di https://supabase.com.
2. Buka **SQL Editor**, tempel isi `supabase/schema.sql`, lalu **Run**.
3. Buka **Project Settings → API**, salin *Project URL* dan *anon public key*
   ke `lib/config/env.dart`.
4. Buat akun petugas di **Authentication → Users → Add user**.
   Email harus berformat `<id-petugas-huruf-kecil>@petugas.jeki.app`,
   misalnya `ptg-0071@petugas.jeki.app`. Di aplikasi petugas login dengan
   **ID `PTG-0071`** dan kata sandi tadi.
5. Salin UUID user itu, lalu jalankan bagian *DATA CONTOH* di akhir `schema.sql`
   (hapus tanda komentar `--` dan ganti `UUID-USER`).

### 3. Google Maps API key

Buat key di Google Cloud Console dan aktifkan **Maps SDK for Android** (dan **iOS** bila perlu).

**Android**: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest ...>
    <uses-permission android:name="android.permission.INTERNET"/>

    <queries>
        <intent>
            <action android:name="android.intent.action.VIEW"/>
            <data android:scheme="https"/>
        </intent>
    </queries>

    <application ...>
        <meta-data android:name="com.google.android.geo.API_KEY"
                   android:value="ISI_API_KEY_KAMU"/>
        ...
    </application>
</manifest>
```

**iOS**: `ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>Kamera dipakai untuk memotret kondisi jalan.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Galeri dipakai untuk memilih foto dokumentasi.</string>
```

dan di `ios/Runner/AppDelegate.swift` tambahkan `import GoogleMaps` serta
`GMSServices.provideAPIKey("ISI_API_KEY_KAMU")` di `didFinishLaunchingWithOptions`.

### 4. Jalankan

```bash
flutter run
```

## Struktur kode

```
lib/
  main.dart                    inisialisasi Supabase + AuthGate
  config/env.dart              URL & key Supabase
  theme/app_theme.dart         warna & tema pink/magenta
  models/models.dart           Tugas, Petugas, Progres, enum status
  services/services.dart       AuthService, TugasService (semua panggilan Supabase)
  widgets/                     komponen bersama (kartu, chip, foto, tombol bawah)
  screens/                     login, beranda, daftar tugas, detail, survei,
                               bahan (PDF), progres, kirim hasil, sukses,
                               profil, riwayat, detail riwayat
supabase/schema.sql            tabel, RLS, trigger, storage, realtime
```

## Untuk sisi Admin (di luar aplikasi ini)

- Menugaskan: isi `tugas.petugas_id`. Petugas yang sedang membuka aplikasi langsung
  menerima notifikasi dalam aplikasi (Supabase Realtime).
- Menyiapkan bahan: unggah PDF ke bucket `foto-tugas` (mis. `<tugas_id>/bahan.pdf`),
  lalu isi `dokumen_bahan_url` dan `dokumen_bahan_nama`.
- Memeriksa hasil: ubah `status` menjadi `selesai` (isi `selesai_at`) atau `revisi`
  (isi `catatan_admin`).

## Belum termasuk

- **Push notification** saat aplikasi tertutup (butuh Firebase Cloud Messaging).
  Saat ini notifikasi hanya muncul selama aplikasi terbuka.
- Aplikasi Admin dan aplikasi Pelapor.
