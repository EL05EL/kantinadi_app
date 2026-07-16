enum KategoriMenu { makanan, minuman, snack }

class Menu {
  final String id;
  final String nama;
  final double harga;
  final KategoriMenu kategori;
  final String tenantId;
  bool tersedia;

  Menu({
    required this.id,
    required this.nama,
    required this.harga,
    required this.kategori,
    required this.tenantId,
    this.tersedia = true,
  });
}
