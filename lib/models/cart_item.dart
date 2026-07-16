class CartItem {
  final String menuId;
  final String namaMenu;
  final double harga;
  final String tenantId;
  final String tenantNama;
  int quantity;

  CartItem({
    required this.menuId,
    required this.namaMenu,
    required this.harga,
    required this.tenantId,
    required this.tenantNama,
    this.quantity = 1,
  });

  double get subtotal => harga * quantity;
}
