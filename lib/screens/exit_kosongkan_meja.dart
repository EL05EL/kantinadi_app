import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../widgets/custom_button.dart';
import '../widgets/logo_header.dart';
import '../providers/meja_provider.dart';
import 'scan_qr_meja.dart';
import 'live_status_meja.dart';

class ExitKosongkanMeja extends StatelessWidget {
  final String mejaNomor;

  const ExitKosongkanMeja({super.key, required this.mejaNomor});

  bool get isDelivery => mejaNomor == 'PESAN ANTAR';

  @override
  Widget build(BuildContext context) {
    final mejaProvider = Provider.of<MejaProvider>(context);
    final terisi = mejaProvider.jumlahTerisi;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.black),
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      const LogoHeader(size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kantin ADI',
                                style: AppTypography.display1
                                    .copyWith(fontSize: 24)),
                            Text('SCAN • ORDER • EAT',
                                style: AppTypography.caption
                                    .copyWith(letterSpacing: 2)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LiveStatusMeja()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: AppColors.black, width: 1.5),
                          ),
                          child: Text(
                            '$terisi/8',
                            style:
                                AppTypography.heading2.copyWith(fontSize: 20),
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
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                isDelivery ? 'PESAN ANTAR' : mejaNomor,
                style: AppTypography.heading4.copyWith(color: AppColors.black),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: AppColors.black, width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.thumb_up,
                              size: 80, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        isDelivery ? 'PESANAN BERHASIL' : mejaNomor,
                        style: AppTypography.heading2
                            .copyWith(color: AppColors.primary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text('TERIMA KASIH!',
                          style: AppTypography.display1
                              .copyWith(color: AppColors.black)),
                      const SizedBox(height: 16),
                      Text(
                        isDelivery
                            ? 'Pesanan Antar Anda telah dicatat dan sedang diproses.'
                            : 'Meja telah dikosongkan dan kembali tersedia di live report!',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge,
                      ),
                      const SizedBox(height: 48),
                      CustomButton(
                        label: isDelivery
                            ? 'Kembali ke Dashboard Utama'
                            : 'Kembali ke Halaman Scan',
                        onPressed: () {
                          if (isDelivery) {
                            Navigator.pushReplacementNamed(context, '/');
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ScanQrMeja()),
                            );
                          }
                        },
                        isFullWidth: false,
                        width: 250,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
