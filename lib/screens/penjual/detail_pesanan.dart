import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../utils/colors.dart';
import '../../utils/typography.dart';

class DetailPesanan extends StatefulWidget {
  final Order order;
  final String tenantId;

  const DetailPesanan({
    super.key,
    required this.order,
    required this.tenantId,
  });

  @override
  State<DetailPesanan> createState() => _DetailPesananState();
}

class _DetailPesananState extends State<DetailPesanan> {
  String _selectedStatus = '';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Detail Pesanan - Meja ${widget.order.mejaNomor}',
          style: AppTypography.heading3.copyWith(color: AppColors.black),
        ),
        actions: [
          if (_selectedStatus != 'Selesai')
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.black),
              onPressed: _isUpdating ? null : _updateStatus,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status saat ini
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.black, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status:', style: AppTypography.heading4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_selectedStatus),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _selectedStatus,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Dropdown untuk update status
            if (_selectedStatus != 'Selesai') ...[
              const Text('Ubah Status:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                items: _getAvailableStatuses().map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            // Detail pesanan
            Text('Detail Pesanan:', style: AppTypography.heading4),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.order.items.length,
                itemBuilder: (ctx, index) {
                  final item = widget.order.items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.black, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.namaMenu,
                                style: AppTypography.bodyMedium),
                            Text(
                              '× ${item.quantity}',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                        Text(
                          'Rp ${item.subtotal.toStringAsFixed(0)}',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getAvailableStatuses() {
    final statuses = ['Baru', 'Sedang Disiapkan', 'Siap Antar', 'Selesai'];
    final currentIndex = statuses.indexOf(_selectedStatus);
    return statuses.sublist(currentIndex);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Baru':
        return AppColors.primary;
      case 'Sedang Disiapkan':
        return Colors.orange;
      case 'Siap Antar':
        return Colors.green;
      case 'Selesai':
        return AppColors.grey;
      default:
        return AppColors.darkGrey;
    }
  }

  Future<void> _updateStatus() async {
    setState(() => _isUpdating = true);

    try {
      final provider = Provider.of<OrderProvider>(context, listen: false);
      await provider.updateOrderStatus(widget.order.id, _selectedStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status berhasil diperbarui')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }
}
