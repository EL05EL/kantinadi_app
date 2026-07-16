import 'cart_item.dart';

class Transaksi {
  final String id;
  final String mejaId;
  final List<CartItem> items;
  final double totalBayar;
  final String metodeBayar;
  final String status;
  final DateTime waktuTransaksi;

  Transaksi({
    required this.id,
    required this.mejaId,
    required this.items,
    required this.totalBayar,
    required this.metodeBayar,
    required this.status,
    required this.waktuTransaksi,
  });
}
