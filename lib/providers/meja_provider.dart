import 'package:flutter/material.dart';
import '../models/meja.dart';
import '../services/supabase_service.dart';
import '../utils/dummy_data.dart';

class MejaProvider extends ChangeNotifier {
  List<Meja> _mejaList = [];

  List<Meja> get mejaList => _mejaList;

  // Hanya meja fisik (bukan DELIVERY)
  List<Meja> get mejaFisik =>
      _mejaList.where((m) => m.nomor != 'DELIVERY').toList();

  int get jumlahKosong =>
      mejaFisik.where((m) => m.status == StatusMeja.kosong).length;
  int get jumlahTerisi =>
      mejaFisik.where((m) => m.status == StatusMeja.terisi).length;
  int get totalMeja => mejaFisik.length;

  MejaProvider() {
    loadMeja();
    try {
      SupabaseService.subscribeMeja((data) {
        _mejaList = data;
        notifyListeners();
      });
    } catch (_) {}
  }

  Future<void> loadMeja() async {
    try {
      final data = await SupabaseService.getAllMeja();
      if (data.isNotEmpty) {
        _mejaList = data;
      } else {
        _mejaList = dummyMeja();
      }
    } catch (e) {
      debugPrint('Gagal memuat meja dari Supabase, menggunakan data lokal');
      _mejaList = dummyMeja();
    }
    notifyListeners();
  }

  Future<void> updateStatusMeja(String mejaId, StatusMeja status) async {
    final statusStr = status == StatusMeja.terisi ? 'terisi' : 'kosong';
    final idx = _mejaList.indexWhere((m) => m.id == mejaId);
    if (idx != -1) {
      _mejaList[idx].status = status;
      notifyListeners();
    }
    try {
      await SupabaseService.updateStatusMeja(mejaId, statusStr);
    } catch (_) {}
  }
}
