-- =====================================================================
-- JEKI Petugas - skema Supabase
-- Jalankan di: Dashboard Supabase -> SQL Editor -> New query -> Run
--
-- Alur status tugas:
--   menunggu   : Admin sudah menugaskan, Petugas belum survei
--   survei     : Petugas sedang survei di lokasi
--   bahan      : survei terkirim; menunggu/melihat dokumen bahan (PDF) dari Admin
--   dikerjakan : perbaikan berlangsung (Petugas isi progres)
--   diperiksa  : laporan hasil terkirim, menunggu pemeriksaan Admin
--   revisi     : Admin meminta perbaikan/tindak lanjut (lihat catatan_admin)
--   selesai    : dikonfirmasi Admin (HANYA Admin yang boleh mengisi ini)
-- =====================================================================

-- ---------- Tipe enum ----------
do $$ begin
  create type status_tugas as enum
    ('menunggu', 'survei', 'bahan', 'dikerjakan', 'diperiksa', 'revisi', 'selesai');
exception when duplicate_object then null; end $$;

do $$ begin
  create type prioritas_tugas as enum ('tinggi', 'sedang', 'rendah');
exception when duplicate_object then null; end $$;

do $$ begin
  create type tingkat_kerusakan as enum ('ringan', 'sedang', 'berat');
exception when duplicate_object then null; end $$;

-- ---------- Profil petugas ----------
create table if not exists public.petugas (
  id          uuid primary key references auth.users (id) on delete cascade,
  kode        text unique not null,          -- contoh: PTG-0071
  nama        text not null,
  no_hp       text,
  wilayah     text,
  email       text,
  avatar_url  text,
  created_at  timestamptz not null default now()
);

-- ---------- Tugas ----------
create table if not exists public.tugas (
  id                 uuid primary key default gen_random_uuid(),
  kode               text unique not null,     -- contoh: #NY-2091
  judul              text not null,
  kategori           text,                     -- kategori dari Pelapor (mis. Jalan Berlubang)
  alamat             text,
  deskripsi          text,                     -- deskripsi dari Pelapor
  lat                double precision,
  lng                double precision,
  status             status_tugas not null default 'menunggu',
  prioritas          prioritas_tugas not null default 'sedang',
  petugas_id         uuid references public.petugas (id) on delete set null,
  foto_url           text,                     -- foto bukti dari Pelapor

  -- hasil survei (diisi Petugas)
  kondisi_aktual     text,
  tingkat            tingkat_kerusakan,
  catatan_survei     text,
  foto_survei_url    text,

  -- kebutuhan bahan (diisi Admin, berupa PDF)
  dokumen_bahan_url  text,
  dokumen_bahan_nama text,

  -- laporan hasil pekerjaan (diisi Petugas)
  foto_sebelum_url   text,
  foto_sesudah_url   text,
  foto_pendukung_url text,
  catatan_hasil      text,
  tanggal_pengerjaan date,

  -- pemeriksaan Admin
  catatan_admin      text,                     -- alasan revisi / catatan konfirmasi
  selesai_at         timestamptz,
  created_at         timestamptz not null default now()
);

create index if not exists tugas_petugas_idx on public.tugas (petugas_id, status);

-- ---------- Progres pengerjaan ----------
create table if not exists public.progres_tugas (
  id         uuid primary key default gen_random_uuid(),
  tugas_id   uuid not null references public.tugas (id) on delete cascade,
  catatan    text not null,
  foto_url   text,
  kendala    boolean not null default false,   -- true = catatan kendala di lapangan
  created_at timestamptz not null default now()
);

create index if not exists progres_tugas_idx on public.progres_tugas (tugas_id, created_at);

-- ---------- Row Level Security ----------
alter table public.petugas       enable row level security;
alter table public.tugas         enable row level security;
alter table public.progres_tugas enable row level security;

drop policy if exists "petugas_select_self" on public.petugas;
create policy "petugas_select_self" on public.petugas
  for select using (auth.uid() = id);

drop policy if exists "petugas_update_self" on public.petugas;
create policy "petugas_update_self" on public.petugas
  for update using (auth.uid() = id);

drop policy if exists "tugas_select_own" on public.tugas;
create policy "tugas_select_own" on public.tugas
  for select using (petugas_id = auth.uid());

drop policy if exists "tugas_update_own" on public.tugas;
create policy "tugas_update_own" on public.tugas
  for update using (petugas_id = auth.uid());

drop policy if exists "progres_all_own" on public.progres_tugas;
create policy "progres_all_own" on public.progres_tugas
  for all
  using (exists (
    select 1 from public.tugas t
    where t.id = progres_tugas.tugas_id and t.petugas_id = auth.uid()))
  with check (exists (
    select 1 from public.tugas t
    where t.id = progres_tugas.tugas_id and t.petugas_id = auth.uid()));

-- ---------- Batasi perubahan oleh Petugas ----------
-- RLS tidak bisa membatasi kolom, jadi pakai trigger: Petugas tidak boleh
-- menandai selesai, mengganti dokumen bahan, atau mengubah catatan Admin.
create or replace function public.batasi_update_petugas()
returns trigger language plpgsql as $$
begin
  if auth.uid() is not null and auth.uid() = old.petugas_id then
    if new.status = 'selesai' and old.status <> 'selesai' then
      raise exception 'Status Selesai hanya dapat diberikan oleh Admin';
    end if;
    if new.status = 'revisi' and old.status <> 'revisi' then
      raise exception 'Status Revisi hanya dapat diberikan oleh Admin';
    end if;
    if new.dokumen_bahan_url is distinct from old.dokumen_bahan_url
       or new.dokumen_bahan_nama is distinct from old.dokumen_bahan_nama
       or new.catatan_admin is distinct from old.catatan_admin
       or new.petugas_id is distinct from old.petugas_id then
      raise exception 'Kolom ini hanya dapat diubah oleh Admin';
    end if;
  end if;
  return new;
end $$;

drop trigger if exists trg_batasi_update_petugas on public.tugas;
create trigger trg_batasi_update_petugas
  before update on public.tugas
  for each row execute function public.batasi_update_petugas();

-- ---------- Realtime (notifikasi tugas baru di aplikasi) ----------
do $$ begin
  alter publication supabase_realtime add table public.tugas;
exception when duplicate_object then null; end $$;

-- ---------- Storage untuk foto & PDF ----------
-- Admin mengunggah PDF bahan ke: foto-tugas/<tugas_id>/bahan.pdf
insert into storage.buckets (id, name, public)
values ('foto-tugas', 'foto-tugas', true)
on conflict (id) do nothing;

drop policy if exists "foto_read" on storage.objects;
create policy "foto_read" on storage.objects
  for select using (bucket_id = 'foto-tugas');

drop policy if exists "foto_upload" on storage.objects;
create policy "foto_upload" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'foto-tugas');

-- =====================================================================
-- DATA CONTOH (opsional)
-- 1. Buat user di Authentication -> Users, email: ptg-0071@petugas.jeki.app
-- 2. Salin UUID user itu, ganti 'UUID-USER' di bawah, lalu jalankan.
-- =====================================================================
-- insert into public.petugas (id, kode, nama, no_hp, wilayah, email)
-- values ('UUID-USER', 'PTG-0071', 'Sari Pratama', '+62 812-3456-7890',
--         'Jember, Jawa Timur', 'ptg-0071@petugas.jeki.app');
--
-- insert into public.tugas (kode, judul, kategori, alamat, deskripsi, lat, lng, prioritas, petugas_id)
-- values
--  ('#NY-2091', 'Perbaikan Jalan Berlubang', 'Jalan Berlubang',
--   'Jl. Raya Kartini No. 12, Jember', 'Lubang besar di tengah jalan, membahayakan pengendara.',
--   -8.1724, 113.7002, 'tinggi', 'UUID-USER'),
--  ('#NY-2092', 'Lubang Aspal', 'Jalan Berlubang',
--   'Jl. Gajah Mada, Jember', 'Aspal terkelupas.', -8.1650, 113.7100, 'sedang', 'UUID-USER');
