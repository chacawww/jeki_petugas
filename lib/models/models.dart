enum StatusTugas {
  menunggu('menunggu', 'Menunggu'),
  survei('survei', 'Survei'),
  bahan('bahan', 'Bahan'),
  dikerjakan('dikerjakan', 'Dikerjakan'),
  diperiksa('diperiksa', 'Diperiksa'),
  revisi('revisi', 'Revisi'),
  selesai('selesai', 'Selesai');

  final String db;
  final String label;
  const StatusTugas(this.db, this.label);

  static StatusTugas parse(String? v) => StatusTugas.values.firstWhere(
        (e) => e.db == v,
        orElse: () => StatusTugas.menunggu,
      );
}

enum Prioritas {
  tinggi('tinggi', 'Tinggi'),
  sedang('sedang', 'Sedang'),
  rendah('rendah', 'Rendah');

  final String db;
  final String label;
  const Prioritas(this.db, this.label);

  static Prioritas parse(String? v) => Prioritas.values.firstWhere(
        (e) => e.db == v,
        orElse: () => Prioritas.sedang,
      );
}

enum Tingkat {
  ringan('ringan', 'Ringan'),
  sedang('sedang', 'Sedang'),
  berat('berat', 'Berat');

  final String db;
  final String label;
  const Tingkat(this.db, this.label);

  static Tingkat? parse(String? v) {
    for (final e in Tingkat.values) {
      if (e.db == v) return e;
    }
    return null;
  }
}

class Petugas {
  final String id;
  final String kode;
  final String nama;
  final String? noHp;
  final String? wilayah;
  final String? email;
  final String? avatarUrl;

  Petugas({
    required this.id,
    required this.kode,
    required this.nama,
    this.noHp,
    this.wilayah,
    this.email,
    this.avatarUrl,
  });

  factory Petugas.fromMap(Map<String, dynamic> m) => Petugas(
        id: m['id'] as String,
        kode: m['kode'] as String,
        nama: m['nama'] as String,
        noHp: m['no_hp'] as String?,
        wilayah: m['wilayah'] as String?,
        email: m['email'] as String?,
        avatarUrl: m['avatar_url'] as String?,
      );
}

class Tugas {
  final String id;
  final String kode;
  final String judul;
  final String? kategori;
  final String? alamat;
  final String? deskripsi;
  final double? lat;
  final double? lng;
  final StatusTugas status;
  final Prioritas prioritas;
  final String? fotoUrl;

  // survei
  final String? kondisiAktual;
  final Tingkat? tingkat;
  final String? catatanSurvei;
  final String? fotoSurveiUrl;

  // bahan (PDF dari Admin)
  final String? dokumenBahanUrl;
  final String? dokumenBahanNama;

  // hasil pekerjaan
  final String? fotoSebelumUrl;
  final String? fotoSesudahUrl;
  final String? fotoPendukungUrl;
  final String? catatanHasil;
  final DateTime? tanggalPengerjaan;

  // pemeriksaan Admin
  final String? catatanAdmin;
  final DateTime? selesaiAt;
  final DateTime createdAt;

  Tugas({
    required this.id,
    required this.kode,
    required this.judul,
    this.kategori,
    this.alamat,
    this.deskripsi,
    this.lat,
    this.lng,
    required this.status,
    required this.prioritas,
    this.fotoUrl,
    this.kondisiAktual,
    this.tingkat,
    this.catatanSurvei,
    this.fotoSurveiUrl,
    this.dokumenBahanUrl,
    this.dokumenBahanNama,
    this.fotoSebelumUrl,
    this.fotoSesudahUrl,
    this.fotoPendukungUrl,
    this.catatanHasil,
    this.tanggalPengerjaan,
    this.catatanAdmin,
    this.selesaiAt,
    required this.createdAt,
  });

  factory Tugas.fromMap(Map<String, dynamic> m) => Tugas(
        id: m['id'] as String,
        kode: m['kode'] as String,
        judul: m['judul'] as String,
        kategori: m['kategori'] as String?,
        alamat: m['alamat'] as String?,
        deskripsi: m['deskripsi'] as String?,
        lat: (m['lat'] as num?)?.toDouble(),
        lng: (m['lng'] as num?)?.toDouble(),
        status: StatusTugas.parse(m['status'] as String?),
        prioritas: Prioritas.parse(m['prioritas'] as String?),
        fotoUrl: m['foto_url'] as String?,
        kondisiAktual: m['kondisi_aktual'] as String?,
        tingkat: Tingkat.parse(m['tingkat'] as String?),
        catatanSurvei: m['catatan_survei'] as String?,
        fotoSurveiUrl: m['foto_survei_url'] as String?,
        dokumenBahanUrl: m['dokumen_bahan_url'] as String?,
        dokumenBahanNama: m['dokumen_bahan_nama'] as String?,
        fotoSebelumUrl: m['foto_sebelum_url'] as String?,
        fotoSesudahUrl: m['foto_sesudah_url'] as String?,
        fotoPendukungUrl: m['foto_pendukung_url'] as String?,
        catatanHasil: m['catatan_hasil'] as String?,
        tanggalPengerjaan: m['tanggal_pengerjaan'] == null
            ? null
            : DateTime.parse(m['tanggal_pengerjaan'] as String),
        catatanAdmin: m['catatan_admin'] as String?,
        selesaiAt: m['selesai_at'] == null
            ? null
            : DateTime.parse(m['selesai_at'] as String).toLocal(),
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      );

  bool get punyaKoordinat => lat != null && lng != null;

  /// Admin sudah mengunggah dokumen kebutuhan bahan.
  bool get bahanTersedia =>
      dokumenBahanUrl != null && dokumenBahanUrl!.isNotEmpty;
}

/// Catatan progres/kendala selama pengerjaan.
class Progres {
  final String id;
  final String tugasId;
  final String catatan;
  final String? fotoUrl;
  final bool kendala;
  final DateTime createdAt;

  Progres({
    required this.id,
    required this.tugasId,
    required this.catatan,
    this.fotoUrl,
    required this.kendala,
    required this.createdAt,
  });

  factory Progres.fromMap(Map<String, dynamic> m) => Progres(
        id: m['id'] as String,
        tugasId: m['tugas_id'] as String,
        catatan: m['catatan'] as String,
        fotoUrl: m['foto_url'] as String?,
        kendala: (m['kendala'] as bool?) ?? false,
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      );
}

class StatistikPetugas {
  final int menunggu;
  final int diproses;
  final int selesai;

  StatistikPetugas({
    required this.menunggu,
    required this.diproses,
    required this.selesai,
  });

  int get total => menunggu + diproses + selesai;

  /// Persentase tugas selesai dari seluruh tugas.
  double get persenSelesai => total == 0 ? 0 : selesai / total * 100;
}
