import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  final double size;

  const LogoHeader({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logokantinadiapp.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.restaurant, size: 20, color: Colors.black),
        );
      },
    );
  }
}
