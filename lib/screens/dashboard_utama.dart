import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../widgets/custom_button.dart';
import 'pilih_tenant.dart';

const String deliveryMejaId = 'ffffffff-ffff-ffff-ffff-ffffffffffff';

class DashboardUtama extends StatelessWidget {
  const DashboardUtama({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Kantin ADI'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.black, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/logokantinadiapp.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.restaurant,
                          size: 60, color: Colors.white);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Kantin ADI',
                  style: AppTypography.display1.copyWith(fontSize: 32)),
              const SizedBox(height: 8),
              Text('SCAN • ORDER • EAT',
                  style: AppTypography.caption.copyWith(letterSpacing: 2)),
              const SizedBox(height: 40),
              CustomButton(
                label: 'Scan QR di Meja',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/scan'),
                isFullWidth: true,
                textColor: AppColors.black,
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Pesan Antar',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PilihTenant(
                        mejaId: deliveryMejaId,
                        mejaNomor: 'PESAN ANTAR',
                      ),
                    ),
                  );
                },
                isFullWidth: true,
                textColor: AppColors.black,
              ),
              const SizedBox(height: 40),
              const Text(
                'Pilih metode pemesanan yang sesuai dengan kebutuhan Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
