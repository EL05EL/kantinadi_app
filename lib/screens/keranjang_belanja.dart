import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/meja_provider.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import 'form_pemesanan.dart';
import '../models/cart_item.dart';
import 'live_status_meja.dart';
import '../widgets/logo_header.dart';

class KeranjangBelanja extends StatelessWidget {
  final String mejaId;
  final String mejaNomor;

  const KeranjangBelanja({
    super.key,
    required this.mejaId,
    required this.mejaNomor,
  });

  bool get isDelivery => mejaId == 'DELIVERY';

  @override
  Widget build(BuildContext context) {
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
                        onPressed: () => Navigator.pop(context),
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
                        Consumer<MejaProvider>(
                          builder: (ctx, mejaProvider, _) {
                            final terisi = mejaProvider.jumlahTerisi;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LiveStatusMeja(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.black,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '$terisi/8',
                                  style: AppTypography.heading2.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            );
                          },
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
                isDelivery
                    ? 'PESAN ANTAR — KERANJANG'
                    : '$mejaNomor — KERANJANG',
                style: AppTypography.heading4.copyWith(
                  color: AppColors.black,
                ),
              ),
            ),
            Expanded(
              child: Consumer<CartProvider>(
                builder: (ctx, cart, _) {
                  final tenantIds = cart.tenantIds;

                  if (cart.items.isEmpty) {
                    return const Center(
                      child: Text('Keranjang kosong. Silakan pilih menu.'),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Row(
                            children: [
                              Icon(Icons.add, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Tambah dari Tenant Lain',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView(
                            children: [
                              ...tenantIds.map((tenantId) {
                                final items = cart.getItemsByTenant(tenantId);
                                final tenantName = items.first.tenantNama;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tenantName,
                                      style: AppTypography.heading4,
                                    ),
                                    const SizedBox(height: 8),
                                    ...items.map((item) {
                                      return _buildCartItem(item, cart);
                                    }),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }).toList(),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Subtotal',
                                          style: AppTypography.bodyMedium,
                                        ),
                                        Text(
                                          'Rp ${cart.totalHarga.toStringAsFixed(0)}',
                                          style: AppTypography.bodyMedium,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Pajak & Layanan',
                                          style: AppTypography.bodyMedium,
                                        ),
                                        const Text(
                                          'Gratis',
                                          style: TextStyle(
                                            color: AppColors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'TOTAL',
                                          style: AppTypography.heading3,
                                        ),
                                        Text(
                                          'Rp ${cart.totalHarga.toStringAsFixed(0)}',
                                          style: AppTypography.heading3,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: cart.items.isNotEmpty
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => FormPemesanan(
                                                mejaId: mejaId,
                                                mejaNomor: mejaNomor,
                                                totalHarga: cart.totalHarga,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide.none,
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                  child: Text(
                                    'Pesan Sekarang — Rp ${cart.totalHarga.toStringAsFixed(0)}',
                                    style: AppTypography.buttonLabel.copyWith(
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildCartItem(CartItem item, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.black, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.black, width: 1.5),
            ),
            child: const Icon(Icons.fastfood, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaMenu,
                  style: AppTypography.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Rp ${item.harga.toStringAsFixed(0)} x ${item.quantity}',
                  style: AppTypography.bodySmall,
                ),
                Text(
                  'Rp ${item.subtotal.toStringAsFixed(0)}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: () {
                      if (item.quantity > 1) {
                        cart.updateQuantity(
                            item.menuId, item.tenantId, item.quantity - 1);
                      } else {
                        cart.removeItem(item.menuId, item.tenantId);
                      }
                    },
                  ),
                  Text('${item.quantity}', style: AppTypography.bodyMedium),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: () {
                      cart.updateQuantity(
                          item.menuId, item.tenantId, item.quantity + 1);
                    },
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => cart.removeItem(item.menuId, item.tenantId),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: AppColors.red, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
