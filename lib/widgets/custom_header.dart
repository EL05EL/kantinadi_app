import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meja_provider.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../screens/live_status_meja.dart';

class CustomHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final bool showBackButton;

  const CustomHeader({
    super.key,
    this.onBack,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final mejaProvider = Provider.of<MejaProvider>(context);
    final terisi = mejaProvider.jumlahTerisi;

    return Column(
      children: [
        // Header orange
        Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button jika diperlukan
              if (showBackButton)
                GestureDetector(
                  onTap: onBack ?? () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.black, size: 24),
                ),
              if (!showBackButton) const SizedBox(width: 24),
              // Title
              Column(
                crossAxisAlignment: showBackButton
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Text('Kantin ADI',
                      style: AppTypography.display1.copyWith(fontSize: 24)),
                  Text('SCAN • ORDER • EAT',
                      style: AppTypography.caption.copyWith(letterSpacing: 2)),
                ],
              ),
              // 8/8 dengan jumlah terisi
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LiveStatusMeja()),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.black, width: 1.5),
                  ),
                  child: Text(
                    '${8 - terisi}/8',
                    style: AppTypography.heading2.copyWith(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Garis hitam pemisah
        Container(
          width: double.infinity,
          height: 1.5,
          color: AppColors.black,
        ),
      ],
    );
  }
}
