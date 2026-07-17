import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meja.dart';
import '../models/tenant.dart';
import '../models/menu.dart';
import '../models/cart_item.dart';
import '../models/transaksi.dart';
import '../models/order.dart';
import '../models/order_item.dart';

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
    final data =
        await supabase.from('tenants').select('*').eq('status', 'aktif');
    return data
        .map<Tenant>((json) => Tenant(
              id: json['id'],
              nama: json['nama'],
              kontak: json['kontak'] ?? '',
            ))
        .toList();
  }

  // ---------- TENANT MANAGEMENT ----------
  static Future<void> updateTenantStatus(String tenantId, String status) async {
    await supabase
        .from('tenants')
        .update({'status': status}).eq('id', tenantId);
  }

  static Future<void> createTenant({
    required String nama,
    required String kontak,
    required double biayaSewa,
  }) async {
    await supabase.from('tenants').insert({
      'nama': nama,
      'kontak': kontak,
      'biaya_sewa_bulanan': biayaSewa,
      'status': 'aktif',
    });
  }

  static Future<void> updateTenant({
    required String tenantId,
    required String nama,
    required String kontak,
    required double biayaSewa,
  }) async {
    await supabase.from('tenants').update({
      'nama': nama,
      'kontak': kontak,
      'biaya_sewa_bulanan': biayaSewa,
    }).eq('id', tenantId);
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

  // ---------- MANAJEMEN MENU (CRUD) ----------
  static Future<Map<String, dynamic>> createMenu({
    required String tenantId,
    required String nama,
    required double harga,
    required String kategori,
    bool tersedia = true,
  }) async {
    final result = await supabase
        .from('menu')
        .insert({
          'tenant_id': tenantId,
          'nama': nama,
          'harga': harga,
          'kategori': kategori,
          'tersedia': tersedia,
        })
        .select()
        .single();
    return result;
  }

  static Future<void> updateMenu({
    required String menuId,
    required String nama,
    required double harga,
    required String kategori,
    required bool tersedia,
  }) async {
    await supabase.from('menu').update({
      'nama': nama,
      'harga': harga,
      'kategori': kategori,
      'tersedia': tersedia,
    }).eq('id', menuId);
  }

  static Future<void> deleteMenu(String menuId) async {
    await supabase.from('menu').delete().eq('id', menuId);
  }

  static Future<void> toggleMenuAvailability(
      String menuId, bool tersedia) async {
    await supabase.from('menu').update({
      'tersedia': tersedia,
    }).eq('id', menuId);
  }

  // ---------- TRANSAKSI ----------
  static Future<String> createTransaksi({
    required String mejaId,
    required double totalBayar,
    required String metodeBayar,
    required List<Map<String, dynamic>> items,
    required String userId,
  }) async {
    // Status pembayaran: QRIS langsung Terverifikasi, Cash masuk antrian
    final statusPembayaran =
        metodeBayar == 'Cash' ? 'Menunggu Pembayaran' : 'Terverifikasi';

    final transaksiRes = await supabase
        .from('transaksi')
        .insert({
          'meja_id': mejaId,
          'total_bayar': totalBayar,
          'metode_bayar': metodeBayar,
          'status_pembayaran': statusPembayaran,
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

    if (mejaId != 'DELIVERY' &&
        mejaId != 'ffffffff-ffff-ffff-ffff-ffffffffffff') {
      await updateStatusMeja(mejaId, 'kosong');
    }
    return transaksiId;
  }

  // ---------- ORDER (UNTUK TENANT) ----------
  static Future<List<Order>> getOrdersByTenant(String tenantId) async {
    final items = await supabase.from('item_pesanan').select('''
          *,
          transaksi:transaksi_id (
            id,
            meja_id,
            created_at,
            meja:meja_id (*)
          ),
          menu:menu_id (nama)
        ''').eq('tenant_id', tenantId).order('created_at', ascending: false);

    final Map<String, Order> orderMap = {};

    for (var item in items) {
      final transaksiId = item['transaksi_id'];
      if (!orderMap.containsKey(transaksiId)) {
        final transaksi = item['transaksi'] as Map<String, dynamic>;
        final meja = transaksi['meja'] as Map<String, dynamic>?;
        orderMap[transaksiId] = Order(
          id: transaksiId,
          transaksiId: transaksiId,
          mejaId: meja?['id'] ?? 'DELIVERY',
          mejaNomor: meja?['nomor'] ?? 'PESAN ANTAR',
          tenantId: tenantId,
          tenantNama: '',
          items: [],
          status: item['status_item'] ?? 'Baru',
          createdAt: DateTime.parse(
              transaksi['created_at'] ?? DateTime.now().toIso8601String()),
        );
      }

      final menu = item['menu'] as Map<String, dynamic>;
      orderMap[transaksiId]!.items.add(
            OrderItem(
              id: item['id'],
              menuId: item['menu_id'],
              namaMenu: menu['nama'] ?? '',
              quantity: item['quantity'],
              hargaSatuan: (item['harga_satuan'] as num).toDouble(),
              subtotal: (item['subtotal'] as num).toDouble(),
              statusItem: item['status_item'] ?? 'Baru',
            ),
          );
    }

    try {
      final tenantData = await supabase
          .from('tenants')
          .select('nama')
          .eq('id', tenantId)
          .single();
      final tenantNama = tenantData['nama'] ?? '';
      for (var order in orderMap.values) {
        order.tenantNama = tenantNama;
      }
    } catch (_) {}

    return orderMap.values.toList();
  }

  static Future<void> updateOrderStatus(
      String orderId, String newStatus) async {
    await supabase
        .from('item_pesanan')
        .update({'status_item': newStatus}).eq('transaksi_id', orderId);
  }

  static void subscribeOrders(String tenantId, Function(Order) onNewOrder) {
    supabase
        .channel('order_changes_$tenantId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'item_pesanan',
          callback: (payload) async {
            final newItem = payload.newRecord;
            if (newItem['tenant_id'] == tenantId) {
              final orders = await getOrdersByTenant(tenantId);
              final newOrder = orders.firstWhere(
                (o) => o.transaksiId == newItem['transaksi_id'],
                orElse: () => throw Exception('Order not found'),
              );
              onNewOrder(newOrder);
            }
          },
        )
        .subscribe();
  }

  // ---------- TRANSAKSI (UNTUK KASIR) ----------
  static Future<List<Transaksi>> getPendingTransactions() async {
    final data = await supabase
        .from('transaksi')
        .select('''
          *,
          meja:meja_id(*),
          item_pesanan:item_pesanan (
            *,
            menu:menu_id (nama)
          )
        ''')
        .eq('status_pembayaran', 'Menunggu Pembayaran')
        .order('created_at', ascending: false);

    return data.map<Transaksi>((json) {
      final items = (json['item_pesanan'] as List<dynamic>).map((item) {
        final menu = item['menu'] as Map<String, dynamic>;
        return CartItem(
          menuId: item['menu_id'],
          namaMenu: menu['nama'] ?? '',
          harga: (item['harga_satuan'] as num).toDouble(),
          tenantId: item['tenant_id'],
          tenantNama: '',
          quantity: item['quantity'],
        );
      }).toList();

      final meja = json['meja'] as Map<String, dynamic>?;
      return Transaksi(
        id: json['id'],
        mejaId: meja?['id'] ?? 'DELIVERY',
        items: items,
        totalBayar: (json['total_bayar'] as num).toDouble(),
        metodeBayar: json['metode_bayar'] ?? 'QRIS',
        status: json['status_pembayaran'],
        waktuTransaksi: DateTime.parse(json['created_at']),
        userId: json['user_id'],
        verifiedBy: json['user_id_verified'],
        verifiedAt: json['verified_at'] != null
            ? DateTime.parse(json['verified_at'])
            : null,
      );
    }).toList();
  }

  static Future<void> verifyTransaction(
      String transaksiId, String kasirId) async {
    await supabase.from('transaksi').update({
      'status_pembayaran': 'Terverifikasi',
      'user_id_verified': kasirId,
      'verified_at': DateTime.now().toIso8601String(),
    }).eq('id', transaksiId);
  }

  // ---------- ADMIN / LAPORAN ----------
  // PERBAIKAN: Menggunakan rentang UTC berdasarkan waktu lokal
  static Future<int> getTodayTransactions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final startUtc = startOfDay.toUtc().toIso8601String();
    final endUtc = endOfDay.toUtc().toIso8601String();

    final result = await supabase
        .from('transaksi')
        .select('id')
        .gte('created_at', startUtc)
        .lt('created_at', endUtc);

    return result.length;
  }

  // PERBAIKAN: Menggunakan rentang UTC berdasarkan waktu lokal
  static Future<double> getTodayRevenue() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final startUtc = startOfDay.toUtc().toIso8601String();
    final endUtc = endOfDay.toUtc().toIso8601String();

    final result = await supabase
        .from('transaksi')
        .select('total_bayar')
        .eq('status_pembayaran', 'Terverifikasi')
        .gte('created_at', startUtc)
        .lt('created_at', endUtc);

    double total = 0;
    for (var row in result) {
      total += (row['total_bayar'] as num).toDouble();
    }
    return total;
  }

  static Future<int> getActiveTenantCount() async {
    final result =
        await supabase.from('tenants').select('id').eq('status', 'aktif');
    return result.length;
  }

  static Future<int> getOccupiedMejaCount() async {
    final result =
        await supabase.from('meja').select('id').eq('status', 'terisi');
    return result.length;
  }

  // PERBAIKAN: Fallback manual dengan rentang UTC
  static Future<List<dynamic>> getLaporanHarian(String tanggal) async {
    // Coba panggil RPC function
    try {
      final result = await supabase
          .rpc('get_laporan_harian', params: {'tanggal_param': tanggal});
      return result as List<dynamic>;
    } catch (e) {
      // Fallback manual
      final data = await supabase.from('tenants').select('''
            id,
            nama,
            item_pesanan:item_pesanan (
              transaksi:transaksi_id (
                total_bayar,
                created_at,
                status_pembayaran
              )
            )
          ''').eq('status', 'aktif');

      // Konversi tanggal input ke UTC start/end untuk filter
      final dateParts = tanggal.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      final startDate = DateTime(year, month, day);
      final endDate = startDate.add(const Duration(days: 1));

      List<Map<String, dynamic>> report = [];
      for (var tenant in data) {
        double pendapatan = 0;
        final itemPesananList = tenant['item_pesanan'] as List<dynamic>?;
        if (itemPesananList != null) {
          for (var ip in itemPesananList) {
            final transaksi = ip['transaksi'] as Map<String, dynamic>?;
            if (transaksi != null) {
              final trDate = DateTime.parse(transaksi['created_at']);
              // Bandingkan dengan rentang UTC
              if (trDate.isAfter(startDate.toUtc()) &&
                  trDate.isBefore(endDate.toUtc())) {
                if (transaksi['status_pembayaran'] == 'Terverifikasi') {
                  pendapatan += (transaksi['total_bayar'] as num).toDouble();
                }
              }
            }
          }
        }
        report.add({
          'nama': tenant['nama'],
          'pendapatan': pendapatan,
          'bagiHasil': pendapatan * 0.10,
          'bersih': pendapatan * 0.90,
        });
      }
      return report;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllSewa() async {
    final data = await supabase.from('tenants').select('''
          id,
          nama,
          sewa:sewa (*)
        ''').eq('status', 'aktif').order('nama');

    List<Map<String, dynamic>> result = [];
    for (var tenant in data) {
      final sewaList = tenant['sewa'] as List<dynamic>?;
      if (sewaList != null && sewaList.isNotEmpty) {
        for (var sewa in sewaList) {
          result.add({
            'id': sewa['id'],
            'tenant_id': tenant['id'],
            'nama': tenant['nama'],
            'periode': sewa['periode'],
            'jatuh_tempo': sewa['jatuh_tempo'],
            'jumlah': sewa['jumlah'],
            'status_bayar': sewa['status_bayar'],
            'tgl_bayar': sewa['tgl_bayar'],
          });
        }
      } else {
        final now = DateTime.now();
        final periode = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        final jatuhTempo = DateTime(now.year, now.month + 1, 1);
        result.add({
          'id': 'dummy_${tenant['id']}',
          'tenant_id': tenant['id'],
          'nama': tenant['nama'],
          'periode': periode,
          'jatuh_tempo': jatuhTempo.toString().substring(0, 10),
          'jumlah': 500000,
          'status_bayar': 'Belum Lunas',
          'tgl_bayar': null,
        });
      }
    }
    return result;
  }

  static Future<void> updateSewaStatus(String sewaId, String status) async {
    if (sewaId.startsWith('dummy_')) {
      final tenantId = sewaId.replaceFirst('dummy_', '');
      final now = DateTime.now();
      final periode = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final jatuhTempo = DateTime(now.year, now.month + 1, 1);
      await supabase.from('sewa').insert({
        'tenant_id': tenantId,
        'periode': periode,
        'jatuh_tempo': jatuhTempo.toString().substring(0, 10),
        'jumlah': 500000,
        'status_bayar': status,
        'tgl_bayar': status == 'Lunas'
            ? DateTime.now().toString().substring(0, 10)
            : null,
      });
    } else {
      await supabase.from('sewa').update({
        'status_bayar': status,
        'tgl_bayar': status == 'Lunas'
            ? DateTime.now().toString().substring(0, 10)
            : null,
      }).eq('id', sewaId);
    }
  }

  static Future<List<Map<String, dynamic>>> getAllTenantWithDetails() async {
    final data = await supabase.from('tenants').select('*').order('nama');
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ---------- REALTIME NOTIFIKASI (Lama) ----------
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
