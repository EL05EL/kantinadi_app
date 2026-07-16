import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

class ConnectivityBanner extends StatelessWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;

    return Column(
      children: [
        if (!isOnline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.red,
            child: const Text(
              'Tidak ada koneksi internet',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}
