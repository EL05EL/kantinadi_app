import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';

class FloatingCart extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingCart({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    if (cart.totalItem == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 16,
      right: 16,
      bottom: 80,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.black, width: 1.5),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 20, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_cart,
                      color: AppColors.black, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Keranjang (${cart.totalItem})',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.black),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.black, width: 1.5),
                ),
                child: Text(
                  'Rp ${cart.totalHarga.toStringAsFixed(0)}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
