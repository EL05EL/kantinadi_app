# README.md

---

## 1. Tentang Aplikasi

**KantinADI** adalah sistem digitalisasi transaksi di Kantin ADI Kampus 4 Universitas Ahmad Dahlan. Aplikasi ini mengubah alur pemesanan manual (nota kertas, stempel fisik, antrean panjang) menjadi pengalaman digital yang cepat, terintegrasi, dan akurat.

Pelanggan cukup memindai kode QR di meja, memilih menu, membayar lewat QRIS, dan pesanan langsung dikirim ke tenant. Semua transaksi tercatat otomatis, tanpa antre, tanpa nota kertas.

---

## 2. Ideasi

### Masalah yang Ditemukan

Berdasarkan observasi dan wawancara langsung di Kantin ADI (April–Mei 2026):

- Pelanggan harus bolak‑balik antara stan penjual dan kasir, menyebabkan antrean panjang dan inefisiensi waktu.
- Nota manual dua rangkap (biru untuk kasir, putih untuk stan) rawan hilang dan salah identifikasi.
- Kasir menghafal tulisan tangan dari 11 tenant yang berbeda, meningkatkan risiko human error.
- Verifikasi pembayaran masih menggunakan stempel fisik, sehingga proses lambat dan tidak terdokumentasi dengan baik.
- Perhitungan bagi hasil 10% harian dan tagihan sewa Rp500.000/bulan dilakukan secara manual, rawan kesalahan administrasi.
- Sinyal internet kampus yang tidak stabil sering menghambat transaksi non‑tunai.

### Solusi yang Ditawarkan

KantinADI menjawab seluruh masalah tersebut dengan pendekatan digital‑first:

- **QR Code di setiap meja** memungkinkan pemesanan mandiri tanpa harus mengantri.
- **Pembayaran QRIS terintegrasi** langsung dari perangkat pelanggan, otomatis terverifikasi.
- **Dashboard dan notifikasi real‑time** untuk tenant, menggantikan nota kertas.
- **Verifikasi kasir cukup satu klik**, tanpa stempel dan dilengkapi audit trail.
- **Rekapitulasi harian otomatis** menghitung bagi hasil 10% dan sewa bulanan.
- **Sinkronisasi offline** membuat transaksi tetap terekam meskipun sinyal terganggu.

---

## 3. Fitur Utama dan Keunikan Aplikasi

Berdasarkan 8 mockup layar yang telah dirancang, fitur utama dan keunikan KantinADI adalah:

### Alur Pelanggan (8 Halaman)

| No | Halaman | Fungsi |
|----|---------|--------|
| 1 | **Scan QR Meja** | Entry point. Scan QR di meja → status meja otomatis berubah menjadi **TERISI** di live report. |
| 2 | **Live Status Meja** | Menampilkan status 8 meja secara real‑time (KOSONG / TERISI). |
| 3 | **Pilih Tenant** | Menampilkan 8 tenant yang tersedia; pelanggan memilih salah satu untuk mulai memesan. |
| 4 | **Menu Tenant (Makanan)** | Menampilkan daftar menu makanan dari tenant yang dipilih, dengan tab Makanan/Minuman. |
| 5 | **Menu Tenant (Minuman)** | Menampilkan daftar menu minuman dari tenant yang dipilih. |
| 6 | **Keranjang Belanja** | Mengelompokkan item per tenant, mengubah jumlah (qty), menghapus item, dan menampilkan subtotal & total. |
| 7 | **Pembayaran** | Menampilkan rincian pesanan, total bayar, dan tombol **"Selesai & Keluar Meja"** untuk menyelesaikan transaksi. |
| 8 | **Exit & Kosongkan Meja** | Menampilkan ucapan terima kasih dan mengembalikan status meja menjadi **KOSONG** di live report. |

### Keunikan Aplikasi

- **Pemesanan tanpa antre** – semua dilakukan dari meja masing‑masing.
- **Keranjang multi‑tenant** – pelanggan dapat memesan dari beberapa tenant sekaligus dalam satu transaksi.
- **Floating Cart** – selalu terlihat saat pelanggan menggulir menu, memudahkan akses ke keranjang.
- **Status meja otomatis** – meja otomatis TERISI saat scan dan KOSONG setelah pelanggan keluar.
- **Notifikasi real‑time** – tenant langsung mendapat pemberitahuan pesanan baru.
- **Verifikasi kasir tanpa stempel** – cukup satu klik, disertai audit trail lengkap.
- **Mode offline** – transaksi tetap aman tersimpan dan tersinkronisasi saat koneksi pulih.

---

## 4. Tech‑Stack (Rencana Build)

Teknologi yang direncanakan untuk membangun KantinADI:

| Kategori | Teknologi | Alasan Pemilihan |
|----------|-----------|------------------|
| **Platform** | Flutter (Cross-Platform) | Membangun aplikasi native untuk Android dan iOS dari satu basis kode. Mendukung performa tinggi dan UI yang responsif. |
| **UI Framework** | Flutter Widgets + Custom Style System | Konsisten dengan desain sistem (`#FE6C33` dan `#000000`), menggunakan widget kustom dan `GoogleFonts` untuk Space Grotesk. |
| **Font** | Space Grotesk (Google Fonts) | Modern, sesuai dengan mockup yang telah dibuat dan diimplementasikan di Figma. |
| **State Management** | Provider | Ringan, mudah digunakan, dan cocok untuk aplikasi skala kecil hingga menengah dengan manajemen state yang sederhana. |
| **Backend** | Node.js + Express | Ringan, mudah dikembangkan untuk REST API, dan mendukung arsitektur microservice. |
| **Database** | PostgreSQL / MySQL | Relasional, cocok untuk 7 entitas inti (Meja, Tenant, Menu, Transaksi, ItemPesanan, BagiHasil, Sewa). |
| **ORM** | Prisma / Sequelize | Memudahkan migrasi dan query database dengan model yang terdefinisi dengan jelas. |
| **Autentikasi** | JWT (JSON Web Token) | Stateless, aman untuk manajemen sesi pengguna, dan mendukung skalabilitas. |
| **Payment Gateway** | QRIS API | Standar pembayaran digital nasional, terintegrasi dengan berbagai aplikasi pembayaran (OVO, Gopay, DANA, dll.). |
| **Notifikasi** | Web Push / Firebase Cloud Messaging | Mengirim notifikasi real‑time ke tenant tentang pesanan baru dan status pesanan. |
| **Version Control** | Git + GitHub | Kolaborasi tim dan manajemen kode sumber dengan branching strategy yang jelas. |
| **Deployment** | Firebase App Distribution (Frontend) + Railway / Heroku (Backend) | Distribusi aplikasi mobile mudah dan cepat; backend dengan skalabilitas kecil hingga menengah. |

---

## 5. Nama‑Nama Anggota Tim Pengembang

| No | Nama | NIM |
|----|------|-----|
| 1 | Muhammad Faiz Rabbany | 2300016083 |
| 2 | Vijay Anjar Pratama | 2300016163 |
| 3 | Grandy Tangguh Heldiyan | 2400016002 |
| 4 | Muhammad Zaky Hafizan | 2400016048 |
| 5 | Fadil Muhammad | 2400016049 |

**Mata Kuliah:** DPSI (Desain dan Pemrograman Sistem Informasi)
