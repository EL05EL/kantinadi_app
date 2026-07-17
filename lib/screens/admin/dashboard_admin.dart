import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/colors.dart';
import '../../utils/typography.dart';
import '../../widgets/logo_header.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
          children: [
            const LogoHeader(size: 24),
            const SizedBox(width: 8),
            Text(
              'Dashboard Admin',
              style: AppTypography.heading3.copyWith(color: AppColors.black),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.black),
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false).loadSummary();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.black),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AdminProvider>(
              builder: (ctx, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSummaryCard(
                      'Total Transaksi Hari Ini',
                      '${provider.summary['totalTransaksi'] ?? 0}',
                      AppColors.primary,
                      Icons.receipt_long,
                    ),
                    _buildSummaryCard(
                      'Pendapatan Hari Ini',
                      'Rp ${(provider.summary['totalPendapatan'] ?? 0).toStringAsFixed(0)}',
                      Colors.green,
                      Icons.attach_money,
                    ),
                    _buildSummaryCard(
                      'Tenant Aktif',
                      '${provider.summary['tenantAktif'] ?? 0}',
                      Colors.blue,
                      Icons.storefront,
                    ),
                    _buildSummaryCard(
                      'Meja Terisi',
                      '${provider.summary['mejaTerisi'] ?? 0}',
                      Colors.orange,
                      Icons.table_restaurant,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Menu Administrasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              icon: Icons.assessment,
              title: 'Laporan Rekapitulasi',
              subtitle: 'Lihat laporan harian & bagi hasil',
              color: AppColors.primary,
              onTap: () => Navigator.pushNamed(context, '/laporan-harian'),
            ),
            const SizedBox(height: 8),
            _buildMenuButton(
              icon: Icons.payment,
              title: 'Manajemen Sewa',
              subtitle: 'Kelola tagihan sewa bulanan',
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/manajemen-sewa'),
            ),
            const SizedBox(height: 8),
            _buildMenuButton(
              icon: Icons.store,
              title: 'Manajemen Tenant',
              subtitle: 'Kelola data tenant',
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/manajemen-tenant'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.heading2.copyWith(color: color, fontSize: 20),
          ),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.black, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.heading4),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.darkGrey),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Yakin ingin logout dari Dashboard Admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).clearUser();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/role-selection',
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
