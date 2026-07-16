import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meja_provider.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../models/meja.dart';
import '../widgets/logo_header.dart';

class LiveStatusMeja extends StatelessWidget {
  const LiveStatusMeja({super.key});

  @override
  Widget build(BuildContext context) {
    final mejaProvider = Provider.of<MejaProvider>(context);
    final mejaList = mejaProvider.mejaFisik;
    final terisi = mejaProvider.jumlahTerisi;
    final total = mejaProvider.totalMeja;

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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: AppColors.black, width: 1.5),
                        ),
                        child: Text(
                          '$terisi/$total',
                          style: AppTypography.heading2.copyWith(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 1.5, color: AppColors.black),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LIVE STATUS MEJA KANTIN',
                        style: AppTypography.heading1),
                    const SizedBox(height: 8),
                    Text(
                        'Setelah scan, meja otomatis ditandai Terisi di live report.',
                        style: AppTypography.bodySmall),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: mejaList.length,
                        itemBuilder: (ctx, index) {
                          final meja = mejaList[index];
                          final isTerisi = meja.status == StatusMeja.terisi;
                          return Container(
                            decoration: BoxDecoration(
                              color: isTerisi
                                  ? AppColors.primary
                                  : AppColors.green,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.black, width: 1.5),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(meja.nomor,
                                      style: AppTypography.heading2
                                          .copyWith(color: Colors.white)),
                                  Text(
                                    isTerisi ? 'TERISI' : 'KOSONG',
                                    style: AppTypography.bodyLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
