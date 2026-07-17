import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/supabase_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaksi> _transactions = [];
  bool _isLoading = false;

  List<Transaksi> get transactions => _transactions;
  bool get isLoading => _isLoading;

  List<Transaksi> get pendingTransactions =>
      _transactions.where((t) => t.status == 'Menunggu Pembayaran').toList();

  List<Transaksi> get verifiedTransactions =>
      _transactions.where((t) => t.status == 'Terverifikasi').toList();

  Future<void> loadPendingTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await SupabaseService.getPendingTransactions();
    } catch (e) {
      debugPrint('Gagal memuat transaksi: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyTransaction(String transaksiId, String kasirId) async {
    try {
      await SupabaseService.verifyTransaction(transaksiId, kasirId);

      final index = _transactions.indexWhere((t) => t.id == transaksiId);
      if (index != -1) {
        // Update status di list
        final original = _transactions[index];
        _transactions[index] = Transaksi(
          id: original.id,
          mejaId: original.mejaId,
          items: original.items,
          totalBayar: original.totalBayar,
          metodeBayar: original.metodeBayar,
          status: 'Terverifikasi',
          waktuTransaksi: original.waktuTransaksi,
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  void clearTransactions() {
    _transactions.clear();
    notifyListeners();
  }
}
