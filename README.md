# 🍽️ KantinADI

### Sistem Digitalisasi Kantin ADI Kampus 4 Universitas Ahmad Dahlan

> Transformasi alur transaksi manual (nota kertas, stempel fisik, antrean panjang) menjadi pengalaman digital yang cepat, terintegrasi, dan akurat.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.0+-green.svg)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-orange.svg)](LICENSE)

---

## 📋 Daftar Isi

- [Tentang Aplikasi](#-tentang-aplikasi)
- [Ideasi & Latar Belakang](#-ideasi--latar-belakang)
- [Fitur Utama](#-fitur-utama)
- [Keunikan Aplikasi](#-keunikan-aplikasi)
- [Teknologi](#-teknologi)
- [Struktur Proyek](#-struktur-proyek)
- [Instalasi & Setup](#-instalasi--setup)
- [Arsitektur Aplikasi](#-arsitektur-aplikasi)
- [Alur Pengguna](#-alur-pengguna)
- [API & Integrasi](#-api--integrasi)
- [Database Schema](#-database-schema)
- [Screenshots](#-screenshots)
- [Tim Pengembang](#-tim-pengembang)
- [Lisensi](#-lisensi)

---

## 🎯 Tentang Aplikasi

**KantinADI** adalah aplikasi mobile berbasis Flutter yang mengdigitalisasi seluruh proses transaksi di Kantin ADI Kampus 4 UAD. Aplikasi ini mengubah alur pemesanan manual menjadi pengalaman digital yang **cepat, terintegrasi, dan akurat**.

### 🚀 Perbandingan: Manual vs Digital

| Aspek | Manual Sebelumnya | Digital (KantinADI) |
|-------|-------------------|---------------------|
| **Pemesanan** | Antre di stan, bawa nota ke kasir | Scan QR di meja, pesan dari HP |
| **Pembayaran** | Antre di kasir, stempel fisik | QRIS langsung dari HP, otomatis terverifikasi |
| **Notifikasi Tenant** | Tidak ada, harus cek manual | Notifikasi real-time pesanan baru |
| **Rekapitulasi** | Manual, rawan error | Otomatis, akurat, real-time |
| **Status Meja** | Tidak terpantau | Live status 8 meja (KOSONG/TERISI) |
| **Struk** | Kertas fisik | PDF digital via email/WhatsApp |

---

## 💡 Ideasi & Latar Belakang

### 🔍 Masalah yang Ditemukan

Berdasarkan observasi dan wawancara langsung di Kantin ADI (April–Mei 2026):

| No | Masalah | Detail | Sumber |
|----|---------|--------|--------|
| 1 | **Alur Terfragmentasi** | Pelanggan bolak‑balik antara stan dan kasir → antrean panjang | Observasi, Wawancara Inayah |
| 2 | **Nota Manual** | Dua rangkap (biru kasir, putih stan) → rawan hilang dan salah identifikasi | Observasi, Wawancara Bu Ninin |
| 3 | **Risiko Human Error** | Kasir menghafal tulisan tangan 11 tenant → kesalahan input | Wawancara Bu Ninin |
| 4 | **Verifikasi Lambat** | Stempel fisik → proses lambat, tidak terdokumentasi | Observasi, Wawancara Bu Ninin |
| 5 | **Administrasi Manual** | Bagi hasil 10% harian dan sewa Rp500.000/bulan manual | Wawancara Ibu Indah |
| 6 | **Sinyal Tidak Stabil** | Sinyal kampus menghambat transaksi non‑tunai | Wawancara Konsumen 2, Inayah |
| 7 | **Menu Monoton** | Keluhan menu "serba ayam" → kurang variasi | Wawancara Konsumen 3 |
| 8 | **Lingkungan Tidak Nyaman** | Kantin panas dan padat → mengurangi minat beli | Observasi, Wawancara Konsumen |

### 💡 Solusi yang Ditawarkan

KantinADI menjawab seluruh masalah tersebut dengan pendekatan **digital‑first**:

- ✅ **QR Code di setiap meja** → pemesanan mandiri tanpa antre
- ✅ **Pembayaran QRIS terintegrasi** → otomatis terverifikasi
- ✅ **Dashboard & notifikasi real‑time** → tenant mendapat pesanan instan
- ✅ **Verifikasi kasir satu klik** → tanpa stempel, dengan audit trail
- ✅ **Rekapitulasi otomatis** → bagi hasil 10% dan sewa bulanan terhitung
- ✅ **Sinkronisasi offline** → transaksi tetap terekam meskipun sinyal terganggu
- ✅ **Pemantauan variasi menu** → pengelola dapat melihat keberagaman menu
- ✅ **Live Status Meja** → pelanggan bisa cek ketersediaan meja

---

## ✨ Fitur Utama

### 👤 Alur Pelanggan

| No | Halaman | Fungsi |
|----|---------|--------|
| 1 | **Dashboard** | Entry point: Pilihan "Scan QR di Meja" atau "Pesan Antar" |
| 2 | **Scan QR Meja** | Scan QR → status meja otomatis **TERISI** di live report |
| 3 | **Live Status Meja** | Status real‑time 8 meja (KOSONG/TERISI) |
| 4 | **Pilih Tenant** | 9 tenant tersedia, pilih untuk mulai memesan |
| 5 | **Menu Tenant** | Daftar menu dengan tab Makanan/Minuman |
| 6 | **Keranjang** | Multi-tenant, ubah qty, hapus item, subtotal & total |
| 7 | **Form Pemesanan** | Data pelanggan (nama, email @webmail.uad.ac.id, no HP) |
| 8 | **Pembayaran** | Rincian pesanan, QRIS/Cash, struk PDF via email/WA |
| 9 | **Exit & Kosongkan Meja** | Status meja kembali **KOSONG** di live report |

### 🔧 Alur Penjual (Tenant)

- Notifikasi real-time pesanan baru
- Dasbor pesanan dengan status: Baru → Sedang Disiapkan → Siap Antar → Selesai
- Manajemen menu (tambah, ubah, hapus, update ketersediaan)

### 💳 Alur Kasir

- Verifikasi pembayaran satu klik
- Audit trail lengkap (ID kasir, timestamp)
- Integrasi transaksi stand + produk kemasan

### 📊 Alur Pengelola

- Rekapitulasi transaksi harian per tenant
- Perhitungan bagi hasil 10% otomatis
- Manajemen sewa bulanan Rp500.000/tenant
- Ekspor laporan (PDF/Excel) - *future enhancement*

---

## 🌟 Keunikan Aplikasi

| Fitur | Deskripsi |
|-------|-----------|
| **Pesan Antar (Delivery)** | Pelanggan bisa memesan tanpa scan meja, cukup isi data diri |
| **Keranjang Multi-Tenant** | Pesan dari beberapa tenant sekaligus dalam satu transaksi |
| **Floating Cart** | Selalu terlihat saat scrolling, akses cepat ke keranjang |
| **Live Status Meja** | Status meja otomatis TERISI saat scan, KOSONG saat keluar |
| **Struk Digital (PDF)** | Struk dikirim via Email dan WhatsApp |
| **Mode Offline** | Transaksi tetap aman, sinkronisasi otomatis saat koneksi pulih |
| **UI Konsisten** | Design System dengan warna #FE6C33 dan #000000, font Space Grotesk |
| **Real-time Subscription** | Update status meja dan notifikasi pesanan secara langsung |

---

## 🛠️ Teknologi

### Tech Stack

| Kategori | Teknologi | Versi | Alasan |
|----------|-----------|-------|--------|
| **Platform** | Flutter | 3.0+ | Cross-platform Android & iOS, performa tinggi |
| **State Management** | Provider | 6.1+ | Ringan, mudah digunakan, sesuai skala aplikasi |
| **Backend** | Supabase | 2.0+ | PostgreSQL + real-time subscriptions + auth |
| **Database** | PostgreSQL (Supabase) | 15+ | Relasional, support 7+ entitas |
| **Authentication** | Supabase Auth (JWT) | - | Stateless, aman, terintegrasi dengan Supabase |
| **QR Scanner** | mobile_scanner | 3.5+ | Native camera integration, performa tinggi |
| **PDF Generation** | pdf | 3.10+ | Generate struk digital dari teks |
| **Email Service** | Brevo API | - | Kirim PDF struk via email |
| **Sharing** | share_plus | 7.2+ | Share PDF via WhatsApp dan platform lain |
| **Font** | Google Fonts (Space Grotesk) | 6.2+ | Konsisten dengan mockup Figma |
| **Version Control** | Git + GitHub | - | Kolaborasi tim, branching strategy |
| **Environment** | flutter_dotenv | 5.1+ | Manajemen environment variables |

### Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1                 # State management
  google_fonts: ^6.2.1             # Space Grotesk font
  supabase_flutter: ^2.0.0         # Backend & real-time
  mobile_scanner: ^3.5.0           # QR Code scanning
  pdf: ^3.10.7                     # PDF generation
  share_plus: ^7.2.1               # Share PDF via WhatsApp
  path_provider: ^2.1.1            # File system access
  http: ^1.1.0                     # API calls
  url_launcher: ^6.2.5             # Launch WhatsApp/email
  flutter_dotenv: ^5.1.0           # Environment variables
  shared_preferences: ^2.2.2       # Local storage
  cupertino_icons: ^1.0.6          # iOS icons

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  flutter_launcher_icons: ^0.13.1