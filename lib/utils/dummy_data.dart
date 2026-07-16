import '../models/meja.dart';
import '../models/tenant.dart';
import '../models/menu.dart';

List<Meja> dummyMeja() {
  // Hanya meja fisik (9 meja)
  return List.generate(9, (index) {
    final nomor = 'MEJA ${index + 1}';
    return Meja(
      id: 'M${(index + 1).toString().padLeft(2, '0')}',
      nomor: nomor,
      status: StatusMeja.kosong,
    );
  });
}

List<Tenant> dummyTenant() {
  return [
    Tenant(id: 'T01', nama: 'Penyetan & Ayam Geprek', kontak: '-'),
    Tenant(id: 'T02', nama: 'Masakan Padang', kontak: '-'),
    Tenant(id: 'T03', nama: 'Soto Ayam & Sup', kontak: '-'),
    Tenant(id: 'T04', nama: 'Bakso & Mie Ayam', kontak: '-'),
    Tenant(id: 'T05', nama: 'Nasi Rames Jawa', kontak: '-'),
    Tenant(id: 'T06', nama: 'Warung TOGA (Adiboga)', kontak: '-'),
    Tenant(id: 'T07', nama: 'Torte Coffee & Beverages', kontak: '-'),
    Tenant(id: 'T08', nama: 'Siomay & Batagor', kontak: '-'),
    Tenant(id: 'T09', nama: 'Gorengan & Camilan', kontak: '-'),
  ];
}

List<Menu> dummyMenu() {
  final tenants = dummyTenant();
  return [
    // T01
    Menu(
        id: 'M001',
        nama: 'Nasi Ayam Geprek',
        harga: 12000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[0].id),
    Menu(
        id: 'M002',
        nama: 'Nasi Lele Goreng Sambal',
        harga: 11000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[0].id),
    Menu(
        id: 'M003',
        nama: 'Nasi Telur Geprek',
        harga: 8000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[0].id),
    // T02
    Menu(
        id: 'M004',
        nama: 'Nasi Padang Telur Dadar',
        harga: 9000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[1].id),
    Menu(
        id: 'M005',
        nama: 'Nasi Padang Ayam Bakar',
        harga: 14000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[1].id),
    Menu(
        id: 'M006',
        nama: 'Nasi Padang Rendang',
        harga: 15000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[1].id),
    Menu(
        id: 'M007',
        nama: 'Nasi Padang Gulai Ayam',
        harga: 13000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[1].id),
    // T03
    Menu(
        id: 'M008',
        nama: 'Soto Ayam Campur Nasi',
        harga: 9000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[2].id),
    Menu(
        id: 'M009',
        nama: 'Soto Ayam Pisah Nasi',
        harga: 11000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[2].id),
    // T04
    Menu(
        id: 'M010',
        nama: 'Mie Ayam Biasa',
        harga: 8000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[3].id),
    Menu(
        id: 'M011',
        nama: 'Mie Ayam Bakso',
        harga: 12000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[3].id),
    Menu(
        id: 'M012',
        nama: 'Mie Ayam Ceker',
        harga: 13000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[3].id),
    Menu(
        id: 'M013',
        nama: 'Bakso Sapi Kuah',
        harga: 12000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[3].id),
    // T05
    Menu(
        id: 'M014',
        nama: 'Nasi Rames Tempe Orek',
        harga: 7000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[4].id),
    Menu(
        id: 'M015',
        nama: 'Nasi Rames Tahu Goreng',
        harga: 7000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[4].id),
    Menu(
        id: 'M016',
        nama: 'Nasi Rames Ayam Goreng',
        harga: 13000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[4].id),
    Menu(
        id: 'M017',
        nama: 'Nasi Rames Ayam Kecap',
        harga: 14000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[4].id),
    // T06
    Menu(
        id: 'M018',
        nama: 'Nasi Ayam Suwir Pedas',
        harga: 12000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[5].id),
    Menu(
        id: 'M019',
        nama: 'Nasi Daging Teriyaki',
        harga: 14000,
        kategori: KategoriMenu.makanan,
        tenantId: tenants[5].id),
    Menu(
        id: 'M020',
        nama: 'Es Teh Manis TOGA',
        harga: 3000,
        kategori: KategoriMenu.minuman,
        tenantId: tenants[5].id),
    // T07
    Menu(
        id: 'M021',
        nama: 'Es Kopi Susu',
        harga: 8000,
        kategori: KategoriMenu.minuman,
        tenantId: tenants[6].id),
    Menu(
        id: 'M022',
        nama: 'Es Kopi Hitam',
        harga: 5000,
        kategori: KategoriMenu.minuman,
        tenantId: tenants[6].id),
    Menu(
        id: 'M023',
        nama: 'Es Coklat',
        harga: 7000,
        kategori: KategoriMenu.minuman,
        tenantId: tenants[6].id),
    Menu(
        id: 'M024',
        nama: 'Jus Mangga',
        harga: 6000,
        kategori: KategoriMenu.minuman,
        tenantId: tenants[6].id),
    Menu(
        id: 'M025',
        nama: 'Jus Alpukat',
        harga: 7000,
        kategori: KategoriMenu.minuman,
        tenantId: tenants[6].id),
    // T08
    Menu(
        id: 'M026',
        nama: 'Siomay 1 Porsi',
        harga: 8000,
        kategori: KategoriMenu.snack,
        tenantId: tenants[7].id),
    Menu(
        id: 'M027',
        nama: 'Batagor 1 Porsi',
        harga: 8000,
        kategori: KategoriMenu.snack,
        tenantId: tenants[7].id),
    Menu(
        id: 'M028',
        nama: 'Siomay ½ Porsi',
        harga: 5000,
        kategori: KategoriMenu.snack,
        tenantId: tenants[7].id),
    Menu(
        id: 'M029',
        nama: 'Batagor ½ Porsi',
        harga: 5000,
        kategori: KategoriMenu.snack,
        tenantId: tenants[7].id),
    // T09
    Menu(
        id: 'M030',
        nama: 'Mendoan (per biji)',
        harga: 1500,
        kategori: KategoriMenu.snack,
        tenantId: tenants[8].id),
    Menu(
        id: 'M031',
        nama: 'Bakwan (per biji)',
        harga: 1000,
        kategori: KategoriMenu.snack,
        tenantId: tenants[8].id),
    Menu(
        id: 'M032',
        nama: 'Tahu Isi',
        harga: 1500,
        kategori: KategoriMenu.snack,
        tenantId: tenants[8].id),
  ];
}
