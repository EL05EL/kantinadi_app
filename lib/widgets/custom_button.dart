import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width ?? 200,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : AppColors.white,
          foregroundColor: isPrimary ? AppColors.white : AppColors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isPrimary ? AppColors.black : AppColors.black,
              width: 1.5,
            ),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          label,
          style: AppTypography.buttonLabel.copyWith(
            color: textColor ?? (isPrimary ? AppColors.white : AppColors.black),
          ),
        ),
      ),
    );
  }
}
