import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meja.dart';
import '../models/tenant.dart';
import '../models/menu.dart';

class SupabaseService {
  static final SupabaseClient supabase = Supabase.instance.client;

  // ---------- USER ----------
  static Future<Map<String, dynamic>> getOrCreateUser({
    required String nama,
    required String email,
    required String noHp,
  }) async {
    final existing = await supabase
        .from('users')
        .select('*')
        .eq('email', email)
        .maybeSingle();

    if (existing != null) {
      // Update noHp jika kosong atau berbeda (opsional)
      if ((existing['no_hp'] == null || existing['no_hp'].isEmpty) &&
          noHp.isNotEmpty) {
        await supabase
            .from('users')
            .update({'no_hp': noHp}).eq('id', existing['id']);
      }
      return existing;
    }

    final newUser = await supabase
        .from('users')
        .insert({
          'nama': nama,
          'email': email,
          'no_hp': noHp,
          'role': 'pelanggan',
        })
        .select()
        .single();

    return newUser;
  }

  // Mengembalikan userId, membuat user baru jika belum ada
  static Future<String> getUserIdByEmail(
      String email, String nama, String noHp) async {
    final user = await getOrCreateUser(
      nama: nama,
      email: email,
      noHp: noHp,
    );
    return user['id'];
  }

  // ---------- MEJA ----------
  static Future<List<Meja>> getAllMeja() async {
    final data = await supabase.from('meja').select('*').order('nomor');
    return data
        .map<Meja>((json) => Meja(
              id: json['id'],
              nomor: json['nomor'],
              status: json['status'] == 'terisi'
                  ? StatusMeja.terisi
                  : StatusMeja.kosong,
            ))
        .toList();
  }

  static Future<void> updateStatusMeja(String mejaId, String status) async {
    await supabase.from('meja').update({'status': status}).eq('id', mejaId);
  }

  static void subscribeMeja(Function(List<Meja>) onUpdate) {
    supabase
        .channel('meja_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'meja',
          callback: (payload) async {
            final data = await getAllMeja();
            onUpdate(data);
          },
        )
        .subscribe();
  }

  // ---------- TENANT ----------
  static Future<List<Tenant>> getAllTenant() async {
    final data = await supabase.from('tenants').select('*');
    return data
        .map<Tenant>((json) => Tenant(
              id: json['id'],
              nama: json['nama'],
              kontak: json['kontak'] ?? '',
            ))
        .toList();
  }

  // ---------- MENU ----------
  static Future<List<Menu>> getMenuByTenant(String tenantId) async {
    final data = await supabase
        .from('menu')
        .select('*')
        .eq('tenant_id', tenantId)
        .order('nama');
    return data
        .map<Menu>((json) => Menu(
              id: json['id'],
              nama: json['nama'],
              harga: json['harga'].toDouble(),
              kategori: _parseKategori(json['kategori']),
              tenantId: json['tenant_id'],
              tersedia: json['tersedia'] ?? true,
            ))
        .toList();
  }

  static KategoriMenu _parseKategori(String? str) {
    if (str == 'makanan') return KategoriMenu.makanan;
    if (str == 'minuman') return KategoriMenu.minuman;
    if (str == 'snack') return KategoriMenu.snack;
    return KategoriMenu.makanan;
  }

  // ---------- TRANSAKSI ----------
  static Future<String> createTransaksi({
    required String mejaId,
    required double totalBayar,
    required String metodeBayar,
    required List<Map<String, dynamic>> items,
    required String userId,
  }) async {
    final transaksiRes = await supabase
        .from('transaksi')
        .insert({
          'meja_id': mejaId,
          'total_bayar': totalBayar,
          'metode_bayar': metodeBayar,
          'status_pembayaran': 'terverifikasi',
          'user_id': userId,
        })
        .select('id')
        .single();

    final transaksiId = transaksiRes['id'];

    for (var item in items) {
      await supabase.from('item_pesanan').insert({
        'transaksi_id': transaksiId,
        'menu_id': item['menuId'],
        'tenant_id': item['tenantId'],
        'quantity': item['quantity'],
        'harga_satuan': item['hargaSatuan'],
        'subtotal': item['hargaSatuan'] * item['quantity'],
        'status_item': 'baru',
      });
    }

    // Hanya update meja jika bukan pesan antar
    if (mejaId != 'DELIVERY') {
      await updateStatusMeja(mejaId, 'kosong');
    }
    return transaksiId;
  }

  // ---------- REALTIME NOTIFIKASI ----------
  static void subscribeOrder(String tenantId, Function(Map) onNewOrder) {
    supabase
        .channel('order_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'item_pesanan',
          callback: (payload) async {
            final newItem = payload.newRecord;
            if (newItem['tenant_id'] == tenantId) {
              final transaksi = await supabase
                  .from('transaksi')
                  .select('*, meja:meja_id(*)')
                  .eq('id', newItem['transaksi_id'])
                  .single();
              final menu = await supabase
                  .from('menu')
                  .select('nama')
                  .eq('id', newItem['menu_id'])
                  .single();
              onNewOrder({
                'item': newItem,
                'transaksi': transaksi,
                'menu': menu,
              });
            }
          },
        )
        .subscribe();
  }
}
