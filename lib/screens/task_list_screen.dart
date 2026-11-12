import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Tugas>> _future;
  final _search = TextEditingController();
  StatusTugas? _filter; // null = Semua

  static const _filters = <StatusTugas>[
    StatusTugas.menunggu,
    StatusTugas.survei,
    StatusTugas.bahan,
    StatusTugas.dikerjakan,
    StatusTugas.diperiksa,
    StatusTugas.revisi,
  ];

  @override
  void initState() {
    super.initState();
    _future = TugasService.list(hanyaSelesai: false);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() =>
      setState(() => _future = TugasService.list(hanyaSelesai: false));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text('Daftar Tugas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Cari nama jalan atau kode tugas',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _chip('Semua', _filter == null, () {
                  setState(() => _filter = null);
                }),
                for (final s in _filters)
                  _chip(s.label, _filter == s, () {
                    setState(() => _filter = s);
                  }),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Tugas>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return ErrorState(
                      message: 'Gagal memuat tugas.\n${snap.error}',
                      onRetry: _reload);
                }
                final q = _search.text.trim().toLowerCase();
                final data = snap.data!.where((t) {
                  if (_filter != null && t.status != _filter) return false;
                  if (q.isEmpty) return true;
                  return t.judul.toLowerCase().contains(q) ||
                      t.kode.toLowerCase().contains(q) ||
                      (t.alamat ?? '').toLowerCase().contains(q);
                }).toList();
                if (data.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada tugas.',
                        style: TextStyle(color: AppColors.textMuted)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        TaskCard(tugas: data[i], onChanged: _reload),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : AppColors.text,
        ),
      ),
    );
  }
}
