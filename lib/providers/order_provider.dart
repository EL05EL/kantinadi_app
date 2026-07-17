import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/supabase_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  List<Order> get newOrders =>
      _orders.where((o) => o.status == 'Baru').toList();
  List<Order> get preparingOrders =>
      _orders.where((o) => o.status == 'Sedang Disiapkan').toList();
  List<Order> get readyOrders =>
      _orders.where((o) => o.status == 'Siap Antar').toList();
  List<Order> get completedOrders =>
      _orders.where((o) => o.status == 'Selesai').toList();

  // Untuk tampilan tab yang terurut
  List<Order> get ordersByStatus {
    final statusOrder = ['Baru', 'Sedang Disiapkan', 'Siap Antar', 'Selesai'];
    final sorted = <Order>[];
    for (var status in statusOrder) {
      sorted.addAll(_orders.where((o) => o.status == status));
    }
    return sorted;
  }

  Future<void> loadOrders(String tenantId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await SupabaseService.getOrdersByTenant(tenantId);
    } catch (e) {
      debugPrint('Gagal memuat pesanan: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await SupabaseService.updateOrderStatus(orderId, newStatus);

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final updated = _orders[index].copyWith(
          status: newStatus,
          startedAt: newStatus == 'Sedang Disiapkan'
              ? DateTime.now()
              : _orders[index].startedAt,
          completedAt: newStatus == 'Selesai'
              ? DateTime.now()
              : _orders[index].completedAt,
        );
        _orders[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  void subscribeOrders(String tenantId) {
    SupabaseService.subscribeOrders(tenantId, (newOrder) {
      // Cek apakah order sudah ada (update) atau tambah baru
      final existingIndex = _orders.indexWhere((o) => o.id == newOrder.id);
      if (existingIndex != -1) {
        _orders[existingIndex] = newOrder;
      } else {
        _orders.insert(0, newOrder);
      }
      notifyListeners();
    });
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
