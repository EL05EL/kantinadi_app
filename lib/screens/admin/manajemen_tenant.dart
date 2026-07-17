import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/colors.dart';
import '../../utils/typography.dart';
import '../../services/supabase_service.dart';

class ManajemenTenant extends StatefulWidget {
  const ManajemenTenant({super.key});

  @override
  State<ManajemenTenant> createState() => _ManajemenTenantState();
}

class _ManajemenTenantState extends State<ManajemenTenant> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadTenants();
    });
  }

  // ==================== TOGGLE STATUS ====================
  Future<void> _toggleTenantStatus(String tenantId, bool currentStatus) async {
    try {
      final newStatus = currentStatus ? 'nonaktif' : 'aktif';
      await SupabaseService.updateTenantStatus(tenantId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Status tenant berhasil diubah menjadi ${newStatus == 'aktif' ? 'Aktif' : 'Non-Aktif'}'),
          ),
        );
        Provider.of<AdminProvider>(context, listen: false).loadTenants();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal ubah status: $e')),
        );
      }
    }
  }

  // ==================== TAMBAH TENANT ====================
  Future<void> _tambahTenant() async {
    final namaController = TextEditingController();
    final kontakController = TextEditingController();
    final sewaController = TextEditingController(text: '500000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Tenant Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Tenant'),
            ),
            TextField(
              controller: kontakController,
              decoration: const InputDecoration(labelText: 'Kontak'),
            ),
            TextField(
              controller: sewaController,
              decoration:
                  const InputDecoration(labelText: 'Biaya Sewa Bulanan'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final nama = namaController.text.trim();
              final kontak = kontakController.text.trim();
              final sewa =
                  double.tryParse(sewaController.text.trim()) ?? 500000;
              if (nama.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Nama tenant harus diisi')),
                );
                return;
              }
              try {
                await SupabaseService.createTenant(
                  nama: nama,
                  kontak: kontak,
                  biayaSewa: sewa,
                );
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Tenant berhasil ditambahkan')),
                  );
                  Provider.of<AdminProvider>(context, listen: false)
                      .loadTenants();
                }
              } catch (e) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Gagal tambah tenant: $e')),
                );
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  // ==================== EDIT TENANT ====================
  Future<void> _editTenant(Map<String, dynamic> tenant) async {
    final namaController = TextEditingController(text: tenant['nama'] ?? '');
    final kontakController =
        TextEditingController(text: tenant['kontak'] ?? '');
    final sewaController = TextEditingController(
        text: (tenant['biaya_sewa_bulanan'] ?? 500000).toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Tenant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Tenant'),
            ),
            TextField(
              controller: kontakController,
              decoration: const InputDecoration(labelText: 'Kontak'),
            ),
            TextField(
              controller: sewaController,
              decoration:
                  const InputDecoration(labelText: 'Biaya Sewa Bulanan'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final nama = namaController.text.trim();
              final kontak = kontakController.text.trim();
              final sewa =
                  double.tryParse(sewaController.text.trim()) ?? 500000;
              if (nama.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Nama tenant harus diisi')),
                );
                return;
              }
              try {
                await SupabaseService.updateTenant(
                  tenantId: tenant['id'],
                  nama: nama,
                  kontak: kontak,
                  biayaSewa: sewa,
                );
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tenant berhasil diupdate')),
                  );
                  Provider.of<AdminProvider>(context, listen: false)
                      .loadTenants();
                }
              } catch (e) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Gagal update tenant: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Manajemen Tenant',
          style: AppTypography.heading3.copyWith(color: AppColors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.black),
            onPressed: _tambahTenant,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.black),
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false).loadTenants();
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tenants = provider.tenantData;

          if (tenants.isEmpty) {
            return const Center(
              child: Text('Tidak ada tenant terdaftar'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tenants.length,
            itemBuilder: (ctx, index) {
              final tenant = tenants[index];
              final isAktif = tenant['status'] == 'aktif';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.black, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tenant['nama'] ?? 'Unknown',
                          style: AppTypography.heading4,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isAktif ? AppColors.green : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isAktif ? 'Aktif' : 'Non-Aktif',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kontak: ${tenant['kontak'] ?? '-'}',
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      'Sewa: Rp ${(tenant['biaya_sewa_bulanan'] ?? 0).toStringAsFixed(0)}/bulan',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // TOMBOL EDIT (BARU)
                        TextButton(
                          onPressed: () => _editTenant(tenant),
                          child: const Text('Edit'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () =>
                              _toggleTenantStatus(tenant['id'], isAktif),
                          child: Text(isAktif ? 'Nonaktifkan' : 'Aktifkan'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
