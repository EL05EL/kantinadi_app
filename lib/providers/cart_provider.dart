import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItem => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalHarga => _items.fold(0, (sum, item) => sum + item.subtotal);

  List<CartItem> getItemsByTenant(String tenantId) {
    return _items.where((item) => item.tenantId == tenantId).toList();
  }

  List<String> get tenantIds {
    final ids = <String>{};
    for (var item in _items) {
      ids.add(item.tenantId);
    }
    return ids.toList();
  }

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere(
      (i) => i.menuId == item.menuId && i.tenantId == item.tenantId,
    );
    if (existingIndex != -1) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String menuId, String tenantId) {
    _items.removeWhere(
        (item) => item.menuId == menuId && item.tenantId == tenantId);
    notifyListeners();
  }

  void updateQuantity(String menuId, String tenantId, int newQuantity) {
    final index = _items.indexWhere(
      (item) => item.menuId == menuId && item.tenantId == tenantId,
    );
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
