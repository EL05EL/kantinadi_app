// lib/models/transaksi.dart
import 'cart_item.dart';

class Transaksi {
  final String id;
  final String mejaId;
  final List<CartItem> items;
  final double totalBayar;
  final String metodeBayar;
  final String status;
  final DateTime waktuTransaksi;
  final String? userId;
  final String? verifiedBy;
  final DateTime? verifiedAt;

  Transaksi({
    required this.id,
    required this.mejaId,
    required this.items,
    required this.totalBayar,
    required this.metodeBayar,
    required this.status,
    required this.waktuTransaksi,
    this.userId,
    this.verifiedBy,
    this.verifiedAt,
  });

  Transaksi copyWith({
    String? id,
    String? mejaId,
    List<CartItem>? items,
    double? totalBayar,
    String? metodeBayar,
    String? status,
    DateTime? waktuTransaksi,
    String? userId,
    String? verifiedBy,
    DateTime? verifiedAt,
  }) {
    return Transaksi(
      id: id ?? this.id,
      mejaId: mejaId ?? this.mejaId,
      items: items ?? this.items,
      totalBayar: totalBayar ?? this.totalBayar,
      metodeBayar: metodeBayar ?? this.metodeBayar,
      status: status ?? this.status,
      waktuTransaksi: waktuTransaksi ?? this.waktuTransaksi,
      userId: userId ?? this.userId,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}
