import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/order.dart';
import '../../utils/colors.dart';
import '../../utils/typography.dart';
import '../../widgets/logo_header.dart';
import 'detail_pesanan.dart';
import 'manajemen_menu_penjual.dart';

class DasborPenjual extends StatefulWidget {
  final String tenantId;
  final String tenantNama;

  const DasborPenjual({
    super.key,
    required this.tenantId,
    required this.tenantNama,
  });

  @override
  State<DasborPenjual> createState() => _DasborPenjualState();
}

class _DasborPenjualState extends State<DasborPenjual>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OrderProvider>(context, listen: false);
      provider.loadOrders(widget.tenantId);
      provider.subscribeOrders(widget.tenantId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dasbor Penjual',
                  style:
                      AppTypography.heading3.copyWith(color: AppColors.black),
                ),
                Text(
                  widget.tenantNama,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Tombol Manajemen Menu
          IconButton(
            icon: const Icon(Icons.menu_book, color: AppColors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ManajemenMenuPenjual(tenantId: widget.tenantId),
                ),
              );
            },
          ),
          // Notifikasi
          Consumer<OrderProvider>(
            builder: (ctx, provider, _) {
              final newCount = provider.newOrders.length;
              return newCount > 0
                  ? Stack(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child:
                              Icon(Icons.notifications, color: AppColors.black),
                        ),
                        Positioned(
                          right: 10,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$newCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.notifications_none,
                          color: AppColors.black),
                    );
            },
          ),
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.black),
            onPressed: () => _showLogoutConfirmation(context),
            tooltip: 'Ganti Role',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.offWhite,
            child: Consumer<OrderProvider>(
              builder: (ctx, provider, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                        'Baru', provider.newOrders.length, AppColors.primary),
                    _buildStatItem('Disiapkan', provider.preparingOrders.length,
                        Colors.orange),
                    _buildStatItem('Siap Antar', provider.readyOrders.length,
                        Colors.green),
                    _buildStatItem('Selesai', provider.completedOrders.length,
                        AppColors.grey),
                  ],
                );
              },
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppColors.black,
            unselectedLabelColor: AppColors.darkGrey,
            indicatorColor: AppColors.primary,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Baru'),
              Tab(text: 'Disiapkan'),
              Tab(text: 'Siap Antar'),
              Tab(text: 'Selesai'),
            ],
          ),
          // Content
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (ctx, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrderList(provider.newOrders, 'Baru'),
                    _buildOrderList(
                        provider.preparingOrders, 'Sedang Disiapkan'),
                    _buildOrderList(provider.readyOrders, 'Siap Antar'),
                    _buildOrderList(provider.completedOrders, 'Selesai'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: AppTypography.heading2.copyWith(color: color),
        ),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }

  Widget _buildOrderList(List<Order> orders, String status) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada pesanan $status',
          style: AppTypography.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (ctx, index) {
        final order = orders[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailPesanan(
                  order: order,
                  tenantId: widget.tenantId,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                      'Meja ${order.mejaNomor}',
                      style: AppTypography.heading4,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) {
                  return Text(
                    '${item.namaMenu} × ${item.quantity}',
                    style: AppTypography.bodyMedium,
                  );
                }).toList(),
                const SizedBox(height: 8),
                Text(
                  'Pesan: ${order.createdAt.toString().substring(0, 16)}',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
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
