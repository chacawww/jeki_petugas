import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';

/// MODE TAMPILAN: semua data disimpan di memori (hilang saat aplikasi
/// ditutup). Nama class dan method sengaja dibuat sama seperti versi
/// backend, jadi nanti tinggal diganti isinya dengan API/database.

/// Login/registrasi contoh. ID dan kata sandi apa saja diterima asal tidak kosong.
class AuthService {
  static final ValueNotifier<bool> loggedIn = ValueNotifier(false);
  static String _kode = 'PTG-0071';
  static String _nama = 'Sari Pratama';
  static String _hp = '+62 812-3456-7890';

  static bool get isLoggedIn => loggedIn.value;

  static Future<void> signIn(String idPetugas, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _kode = idPetugas.trim().toUpperCase();
    TugasService._reset();
    loggedIn.value = true;
  }

  static Future<void> register({
    required String nama,
    required String idPetugas,
    required String noHp,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _nama = nama.trim();
    _kode = idPetugas.trim().toUpperCase();
    _hp = noHp.trim();
    TugasService._reset();
    loggedIn.value = true;
  }

  static Future<void> signOut() async {
    loggedIn.value = false;
  }

  static Future<Petugas> profile() async => Petugas(
        id: 'demo-user',
        kode: _kode,
        nama: _nama,
        noHp: _hp,
        wilayah: 'Jember, Jawa Timur',
        email: '${_kode.toLowerCase()}@petugas.jeki.app',
      );
}

/// Data tugas contoh + simulasi semua aksi Petugas.
class TugasService {
  static List<Tugas> _data = _seed();
  static final Map<String, List<Progres>> _progres = {};

  static void _reset() {
    _data = _seed();
    _progres.clear();
  }

  static Future<void> _delay() =>
      Future<void>.delayed(const Duration(milliseconds: 350));

  static List<Tugas> _seed() {
    final now = DateTime.now();
    return [
      Tugas(
        id: 't1',
        kode: '#NY-2091',
        judul: 'Perbaikan Jalan Berlubang',
        kategori: 'Jalan Berlubang',
        alamat: 'Jl. Raya Kartini No. 12, Jember',
        deskripsi:
            'Lubang besar di tengah jalan, membahayakan pengendara motor terutama saat malam hari.',
        lat: -8.1724,
        lng: 113.7002,
        status: StatusTugas.menunggu,
        prioritas: Prioritas.tinggi,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Tugas(
        id: 't2',
        kode: '#NY-2092',
        judul: 'Lubang Aspal',
        kategori: 'Jalan Berlubang',
        alamat: 'Jl. Gajah Mada, Jember',
        deskripsi: 'Aspal terkelupas dan membentuk beberapa lubang kecil.',
        lat: -8.1650,
        lng: 113.7100,
        status: StatusTugas.bahan,
        prioritas: Prioritas.sedang,
        kondisiAktual: 'Tiga lubang, kedalaman sekitar 10 cm, panjang 2 m.',
        tingkat: Tingkat.sedang,
        catatanSurvei: 'Perlu penambalan aspal dingin.',
        dokumenBahanUrl: 'demo:bahan',
        dokumenBahanNama: 'Kebutuhan Bahan #NY-2092.pdf',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Tugas(
        id: 't3',
        kode: '#NY-2093',
        judul: 'Aspal Amblas',
        kategori: 'Jalan Rusak',
        alamat: 'Jl. Sumatra, Jember',
        deskripsi: 'Permukaan jalan amblas setelah hujan deras.',
        lat: -8.1700,
        lng: 113.7200,
        status: StatusTugas.dikerjakan,
        prioritas: Prioritas.rendah,
        kondisiAktual: 'Amblas sepanjang 3 m, kedalaman 15 cm.',
        tingkat: Tingkat.berat,
        dokumenBahanUrl: 'demo:bahan',
        dokumenBahanNama: 'Kebutuhan Bahan #NY-2093.pdf',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Tugas(
        id: 't4',
        kode: '#NY-2085',
        judul: 'Perbaikan Gorong-gorong',
        kategori: 'Drainase',
        alamat: 'Jl. Mastrip, Jember',
        deskripsi: 'Gorong-gorong tersumbat dan jalan tergenang.',
        lat: -8.1600,
        lng: 113.7150,
        status: StatusTugas.selesai,
        prioritas: Prioritas.sedang,
        tingkat: Tingkat.sedang,
        kondisiAktual: 'Saluran tersumbat sampah dan lumpur.',
        catatanHasil: 'Saluran dibersihkan dan tutup gorong-gorong diganti.',
        catatanAdmin: 'Hasil sesuai. Terima kasih.',
        dokumenBahanUrl: 'demo:bahan',
        dokumenBahanNama: 'Kebutuhan Bahan #NY-2085.pdf',
        tanggalPengerjaan: now.subtract(const Duration(days: 6)),
        selesaiAt: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 9)),
      ),
    ];
  }

  static int _idx(String id) => _data.indexWhere((t) => t.id == id);

  /// Salin tugas dengan beberapa kolom diganti.
  static void _update(
    String id, {
    StatusTugas? status,
    String? kondisiAktual,
    Tingkat? tingkat,
    String? catatanSurvei,
    String? dokumenBahanUrl,
    String? dokumenBahanNama,
    String? catatanHasil,
    DateTime? tanggalPengerjaan,
    String? catatanAdmin,
    DateTime? selesaiAt,
  }) {
    final i = _idx(id);
    final t = _data[i];
    _data[i] = Tugas(
      id: t.id,
      kode: t.kode,
      judul: t.judul,
      kategori: t.kategori,
      alamat: t.alamat,
      deskripsi: t.deskripsi,
      lat: t.lat,
      lng: t.lng,
      status: status ?? t.status,
      prioritas: t.prioritas,
      fotoUrl: t.fotoUrl,
      kondisiAktual: kondisiAktual ?? t.kondisiAktual,
      tingkat: tingkat ?? t.tingkat,
      catatanSurvei: catatanSurvei ?? t.catatanSurvei,
      fotoSurveiUrl: t.fotoSurveiUrl,
      dokumenBahanUrl: dokumenBahanUrl ?? t.dokumenBahanUrl,
      dokumenBahanNama: dokumenBahanNama ?? t.dokumenBahanNama,
      fotoSebelumUrl: t.fotoSebelumUrl,
      fotoSesudahUrl: t.fotoSesudahUrl,
      fotoPendukungUrl: t.fotoPendukungUrl,
      catatanHasil: catatanHasil ?? t.catatanHasil,
      tanggalPengerjaan: tanggalPengerjaan ?? t.tanggalPengerjaan,
      catatanAdmin: catatanAdmin ?? t.catatanAdmin,
      selesaiAt: selesaiAt ?? t.selesaiAt,
      createdAt: t.createdAt,
    );
  }

  // ---------------- Baca data ----------------

  /// [hanyaSelesai]: true = hanya selesai, false = belum selesai.
  /// Urutan: prioritas tinggi dulu, lalu terbaru.
  static Future<List<Tugas>> list({
    List<StatusTugas>? statuses,
    bool? hanyaSelesai,
  }) async {
    await _delay();
    var list = List<Tugas>.from(_data);
    if (hanyaSelesai == true) {
      list = list.where((t) => t.status == StatusTugas.selesai).toList();
    } else if (hanyaSelesai == false) {
      list = list.where((t) => t.status != StatusTugas.selesai).toList();
    }
    if (statuses != null && statuses.isNotEmpty) {
      list = list.where((t) => statuses.contains(t.status)).toList();
    }
    const urutan = {
      Prioritas.tinggi: 0,
      Prioritas.sedang: 1,
      Prioritas.rendah: 2,
    };
    list.sort((a, b) {
      final p = urutan[a.prioritas]!.compareTo(urutan[b.prioritas]!);
      return p != 0 ? p : b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  static Future<Tugas> get(String id) async {
    await _delay();
    return _data[_idx(id)];
  }

  static Future<StatistikPetugas> statistik() async {
    await _delay();
    int menunggu = 0, diproses = 0, selesai = 0;
    for (final t in _data) {
      switch (t.status) {
        case StatusTugas.menunggu:
          menunggu++;
          break;
        case StatusTugas.selesai:
          selesai++;
          break;
        default:
          diproses++;
      }
    }
    return StatistikPetugas(
        menunggu: menunggu, diproses: diproses, selesai: selesai);
  }

  // ---------------- Survei ----------------

  static Future<void> mulaiSurvei(String id) async {
    await _delay();
    _update(id, status: StatusTugas.survei);
  }

  /// Kirim survei. Di mode tampilan, dokumen bahan dari Admin langsung
  /// dianggap tersedia supaya alur berikutnya bisa dicoba.
  static Future<void> kirimSurvei(
    String tugasId, {
    required String kondisiAktual,
    required Tingkat tingkat,
    required String catatan,
    XFile? foto,
  }) async {
    await _delay();
    final t = _data[_idx(tugasId)];
    _update(
      tugasId,
      status: StatusTugas.bahan,
      kondisiAktual: kondisiAktual,
      tingkat: tingkat,
      catatanSurvei: catatan,
      dokumenBahanUrl: 'demo:bahan',
      dokumenBahanNama: 'Kebutuhan Bahan ${t.kode}.pdf',
    );
  }

  // ---------------- Pengerjaan ----------------

  static Future<void> mulaiPengerjaan(String id) async {
    await _delay();
    _update(id, status: StatusTugas.dikerjakan);
  }

  static Future<List<Progres>> progres(String tugasId) async {
    await _delay();
    return List<Progres>.from(_progres[tugasId] ?? const []);
  }

  static Future<void> tambahProgres(
    String tugasId, {
    required String catatan,
    bool kendala = false,
    XFile? foto,
  }) async {
    await _delay();
    final list = _progres.putIfAbsent(tugasId, () => []);
    list.insert(
      0,
      Progres(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        tugasId: tugasId,
        catatan: catatan,
        kendala: kendala,
        createdAt: DateTime.now(),
      ),
    );
  }

  // ---------------- Laporan hasil ----------------

  static Future<void> kirimHasil(
    String tugasId, {
    required XFile fotoSebelum,
    required XFile fotoSesudah,
    XFile? fotoPendukung,
    required String catatan,
    required DateTime tanggal,
  }) async {
    await _delay();
    _update(
      tugasId,
      status: StatusTugas.diperiksa,
      catatanHasil: catatan,
      tanggalPengerjaan: tanggal,
    );
  }

  // ---------------- Simulasi aksi Admin (khusus mode tampilan) ----------------

  static Future<void> simulasiSelesai(String id) async {
    await _delay();
    _update(
      id,
      status: StatusTugas.selesai,
      selesaiAt: DateTime.now(),
      catatanAdmin: 'Hasil sesuai. Pekerjaan dikonfirmasi selesai.',
    );
  }

  static Future<void> simulasiRevisi(String id) async {
    await _delay();
    _update(
      id,
      status: StatusTugas.revisi,
      catatanAdmin: 'Permukaan masih kurang rata, mohon diratakan kembali.',
    );
  }
}
