// lib/models/order.dart
import 'order_item.dart';

class Order {
  final String id;
  final String transaksiId;
  final String mejaId;
  final String mejaNomor;
  final String tenantId;
  String tenantNama; // non-final agar bisa diisi setelah konstruksi
  final List<OrderItem> items;
  final String status; // Baru, Sedang Disiapkan, Siap Antar, Selesai
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  Order({
    required this.id,
    required this.transaksiId,
    required this.mejaId,
    required this.mejaNomor,
    required this.tenantId,
    required this.tenantNama,
    required this.items,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  Order copyWith({
    String? id,
    String? transaksiId,
    String? mejaId,
    String? mejaNomor,
    String? tenantId,
    String? tenantNama,
    List<OrderItem>? items,
    String? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? this.id,
      transaksiId: transaksiId ?? this.transaksiId,
      mejaId: mejaId ?? this.mejaId,
      mejaNomor: mejaNomor ?? this.mejaNomor,
      tenantId: tenantId ?? this.tenantId,
      tenantNama: tenantNama ?? this.tenantNama,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
