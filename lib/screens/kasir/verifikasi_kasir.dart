import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/transaksi.dart';
import '../../utils/colors.dart';
import '../../utils/typography.dart';
import '../../widgets/logo_header.dart';

class VerifikasiKasir extends StatefulWidget {
  final String kasirId;

  const VerifikasiKasir({super.key, required this.kasirId});

  @override
  State<VerifikasiKasir> createState() => _VerifikasiKasirState();
}

class _VerifikasiKasirState extends State<VerifikasiKasir> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadPendingTransactions();
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
              'Verifikasi Pembayaran',
              style: AppTypography.heading3.copyWith(color: AppColors.black),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.black),
            onPressed: () {
              Provider.of<TransactionProvider>(context, listen: false)
                  .loadPendingTransactions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.black),
            onPressed: () => _showLogoutConfirmation(context),
            tooltip: 'Ganti Role',
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pending = provider.pendingTransactions;

          if (pending.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 80, color: AppColors.green),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada transaksi menunggu verifikasi',
                    style: AppTypography.heading3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Semua transaksi telah terverifikasi',
                    style: AppTypography.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            itemBuilder: (ctx, index) {
              final transaksi = pending[index];
              return _buildTransactionCard(transaksi);
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(Transaksi transaksi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meja ${transaksi.mejaId}',
                style: AppTypography.heading4,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Menunggu',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...transaksi.items.map((item) {
            return Text(
              '${item.namaMenu} × ${item.quantity}',
              style: AppTypography.bodyMedium,
            );
          }).toList(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metode: ${transaksi.metodeBayar}',
                style: AppTypography.bodySmall,
              ),
              Text(
                'Total: Rp ${transaksi.totalBayar.toStringAsFixed(0)}',
                style: AppTypography.heading4.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _verifyTransaction(transaksi.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Verifikasi Pembayaran'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyTransaction(String transaksiId) async {
    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      await provider.verifyTransaction(transaksiId, widget.kasirId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pembayaran berhasil diverifikasi!'),
            backgroundColor: AppColors.green,
          ),
        );
        await provider.loadPendingTransactions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal verifikasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Role'),
        content: const Text('Kembali ke halaman pemilihan role?'),
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
            child: const Text('Ya, Kembali'),
          ),
        ],
      ),
    );
  }
}
