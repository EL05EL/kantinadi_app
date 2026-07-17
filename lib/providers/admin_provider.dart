import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _laporanData = [];
  List<Map<String, dynamic>> _sewaData = [];
  List<Map<String, dynamic>> _tenantData = [];

  bool get isLoading => _isLoading;
  Map<String, dynamic> get summary => _summary;
  List<Map<String, dynamic>> get laporanData => _laporanData;
  List<Map<String, dynamic>> get sewaData => _sewaData;
  List<Map<String, dynamic>> get tenantData => _tenantData;

  // Untuk ringkasan dashboard
  Map<String, dynamic> get laporanSummary {
    double total = 0;
    double bagiHasil = 0;
    for (var item in _laporanData) {
      total += (item['pendapatan'] ?? 0.0);
      bagiHasil += (item['bagiHasil'] ?? 0.0);
    }
    return {
      'total': total,
      'bagiHasil': bagiHasil,
      'bersih': total - bagiHasil,
    };
  }

  Future<void> loadSummary() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Ambil data summary dari berbagai sumber
      final transaksiHariIni = await SupabaseService.getTodayTransactions();
      final totalPendapatan = await SupabaseService.getTodayRevenue();
      final tenantAktif = await SupabaseService.getActiveTenantCount();
      final mejaTerisi = await SupabaseService.getOccupiedMejaCount();

      _summary = {
        'totalTransaksi': transaksiHariIni,
        'totalPendapatan': totalPendapatan,
        'tenantAktif': tenantAktif,
        'mejaTerisi': mejaTerisi,
      };
    } catch (e) {
      debugPrint('Gagal memuat summary: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLaporan(String tanggal) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.getLaporanHarian(tanggal);
      _laporanData = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Gagal memuat laporan: $e');
      _laporanData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSewa() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.getAllSewa();
      _sewaData = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Gagal memuat sewa: $e');
      _sewaData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSewaStatus(String sewaId, String status) async {
    try {
      await SupabaseService.updateSewaStatus(sewaId, status);
      // Refresh data
      await loadSewa();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadTenants() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.getAllTenantWithDetails();
      _tenantData = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Gagal memuat tenant: $e');
      _tenantData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
