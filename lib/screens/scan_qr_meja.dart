import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/meja_provider.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../widgets/logo_header.dart';
import 'live_status_meja.dart';
import 'pilih_tenant.dart';
import '../models/meja.dart';

class ScanQrMeja extends StatefulWidget {
  const ScanQrMeja({super.key});

  @override
  State<ScanQrMeja> createState() => _ScanQrMejaState();
}

class _ScanQrMejaState extends State<ScanQrMeja> {
  MobileScannerController? _controller;
  bool _hasScanned = false; // mencegah navigasi ganda

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mejaProvider = Provider.of<MejaProvider>(context);
    final terisi = mejaProvider.jumlahTerisi;

    return WillPopScope(
      onWillPop: () async {
        // Konfirmasi keluar
        final bool? confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Yakin ingin keluar?'),
            content: const Text('Yakin ingin keluar & kosongkan meja?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  final mp = Provider.of<MejaProvider>(context, listen: false);
                  for (var meja in mp.mejaFisik) {
                    mp.updateStatusMeja(meja.id, StatusMeja.kosong);
                  }
                  Navigator.pop(ctx, true);
                },
                child: const Text('Ya, keluar'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          Navigator.pushReplacementNamed(context, '/');
          return false;
        }
        return confirm ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                color: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.black),
                          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                        ),
                        const SizedBox(width: 8),
                        const LogoHeader(size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kantin ADI',
                                  style: AppTypography.display1.copyWith(fontSize: 24)),
                              Text('SCAN • ORDER • EAT',
                                  style: AppTypography.caption.copyWith(letterSpacing: 2)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LiveStatusMeja()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.black, width: 1.5),
                            ),
                            child: Text(
                              '$terisi/8',
                              style: AppTypography.heading2.copyWith(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(height: 1.5, color: AppColors.black),
                  ],
                ),
              ),
              // Area Kamera
              Expanded(
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: (capture) {
                        if (_hasScanned) return; // hindari multiple scan
                        final barcode = capture.barcodes.first;
                        if (barcode.rawValue != null) {
                          _onScan(barcode.rawValue!);
                        }
                      },
                    ),
                    // Overlay panduan
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary, width: 3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // Teks petunjuk
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Arahkan kamera ke QR Code di meja',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.white,
                          backgroundColor: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Tombol pilih meja manual (fallback)
                    Positioned(
                      bottom: 60,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _showMejaDialog(context),
                          icon: const Icon(Icons.table_restaurant),
                          label: const Text('Pilih Meja Manual'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onScan(String rawValue) {
    if (_hasScanned) return;
    _hasScanned = true;

    // Parse teks QR: harapkan format "MEJA X" atau "meja x"
    final mejaProvider = Provider.of<MejaProvider>(context, listen: false);
    final mejaList = mejaProvider.mejaFisik;

    // Cari meja berdasarkan nomor yang cocok
    Meja? targetMeja;
    final upper = rawValue.toUpperCase().trim();
    for (final meja in mejaList) {
      if (upper.contains(meja.nomor.toUpperCase())) {
        targetMeja = meja;
        break;
      }
    }

    if (targetMeja != null) {
      // Update status menjadi terisi
      mejaProvider.updateStatusMeja(targetMeja.id, StatusMeja.terisi);
      // Navigasi ke pilih tenant
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PilihTenant(mejaId: targetMeja!.id, mejaNomor: targetMeja.nomor),
        ),
      );
    } else {
      // Tidak ditemukan, tampilkan pesan dan reset scan
      _hasScanned = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Code tidak dikenali: "$rawValue"')),
      );
    }
  }

  void _showMejaDialog(BuildContext context) {
    final mejaProvider = Provider.of<MejaProvider>(context, listen: false);
    final mejaKosong = mejaProvider.mejaFisik
        .where((m) => m.status == StatusMeja.kosong)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pilih Meja'),
        content: mejaKosong.isEmpty
            ? const Text('Semua meja sedang terisi.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: mejaKosong.map((meja) {
                  return ListTile(
                    title: Text(meja.nomor),
                    onTap: () {
                      mejaProvider.updateStatusMeja(meja.id, StatusMeja.terisi);
                      Navigator.pop(ctx);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PilihTenant(mejaId: meja.id, mejaNomor: meja.nomor),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }
}