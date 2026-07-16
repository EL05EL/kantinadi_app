import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../providers/meja_provider.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import 'menu_tenant.dart';
import 'live_status_meja.dart';
import '../widgets/logo_header.dart';

const String deliveryMejaId = 'ffffffff-ffff-ffff-ffff-ffffffffffff';

class PilihTenant extends StatelessWidget {
  final String mejaId;
  final String mejaNomor;

  const PilihTenant({
    super.key,
    required this.mejaId,
    required this.mejaNomor,
  });

  @override
  Widget build(BuildContext context) {
    final tenantProvider = Provider.of<TenantProvider>(context);
    final tenantList = tenantProvider.tenants;
    final mejaProvider = Provider.of<MejaProvider>(context);
    final terisi = mejaProvider.jumlahTerisi;
    final total = mejaProvider.totalMeja;
    final isDelivery = mejaId == deliveryMejaId;

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
                        onPressed: () {
                          if (isDelivery) {
                            Navigator.pushReplacementNamed(context, '/');
                          } else {
                            Navigator.pop(context);
                          }
                        },
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
                      if (!isDelivery)
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
                              border: Border.all(
                                  color: AppColors.black, width: 1.5),
                            ),
                            child: Text(
                              '$terisi/$total',
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PILIH TENANT', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                        '${tenantList.length} tenant tersedia. Pesanan dari tenant berbeda otomatis digabung di satu keranjang',
                        style: AppTypography.bodySmall),
                    const SizedBox(height: 16),
                    Expanded(
                      child: tenantList.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: tenantList.length,
                              itemBuilder: (ctx, index) {
                                final tenant = tenantList[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MenuTenant(
                                          tenant: tenant,
                                          mejaId: mejaId,
                                          mejaNomor: mejaNomor,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 18),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.black, width: 1.5),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(tenant.nama,
                                            style: AppTypography.bodyLarge
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                        const Icon(Icons.chevron_right,
                                            color: AppColors.black),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Silahkan tap salah satu tenant untuk melihat daftar menu.',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center),
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
