import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/colors.dart';
import '../../utils/typography.dart';

class ManajemenSewa extends StatefulWidget {
  const ManajemenSewa({super.key});

  @override
  State<ManajemenSewa> createState() => _ManajemenSewaState();
}

class _ManajemenSewaState extends State<ManajemenSewa> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadSewa();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Manajemen Sewa',
          style: AppTypography.heading3.copyWith(color: AppColors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.black),
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false).loadSewa();
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final sewaList = provider.sewaData;

          if (sewaList.isEmpty) {
            return const Center(
              child: Text('Tidak ada data sewa'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sewaList.length,
            itemBuilder: (ctx, index) {
              final sewa = sewaList[index];
              final isLunas = sewa['status_bayar'] == 'Lunas';

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
                          sewa['nama'] ?? 'Unknown',
                          style: AppTypography.heading4,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isLunas ? AppColors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isLunas ? 'Lunas' : 'Belum Lunas',
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
                      'Periode: ${sewa['periode'] ?? '-'}',
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      'Jatuh Tempo: ${sewa['jatuh_tempo'] ?? '-'}',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${(sewa['jumlah'] ?? 0).toStringAsFixed(0)}',
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        if (!isLunas)
                          ElevatedButton(
                            onPressed: () => _updateStatus(sewa['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Tandai Lunas'),
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

  Future<void> _updateStatus(String sewaId) async {
    try {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      await provider.updateSewaStatus(sewaId, 'Lunas');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Status pembayaran berhasil diupdate'),
            backgroundColor: AppColors.green,
          ),
        );
        await provider.loadSewa();
      }
    } catch (e) {
      if (mounted) {
        String message = e.toString();
        if (message.contains('row-level security policy')) {
          message =
              'Error RLS: Nonaktifkan RLS pada tabel sewa di Supabase atau tambahkan policy.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal update: $message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
