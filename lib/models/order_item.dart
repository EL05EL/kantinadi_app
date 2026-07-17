class OrderItem {
  final String id;
  final String menuId;
  final String namaMenu;
  final int quantity;
  final double hargaSatuan;
  final double subtotal;
  final String statusItem; // Baru, Sedang Disiapkan, Siap Antar, Selesai

  OrderItem({
    required this.id,
    required this.menuId,
    required this.namaMenu,
    required this.quantity,
    required this.hargaSatuan,
    required this.subtotal,
    required this.statusItem,
  });
}
