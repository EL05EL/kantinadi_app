import 'package:flutter/material.dart';
import '../models/tenant.dart';
import '../services/supabase_service.dart';
import '../utils/dummy_data.dart';

class TenantProvider extends ChangeNotifier {
  List<Tenant> _tenants = [];

  List<Tenant> get tenants => _tenants;

  TenantProvider() {
    loadTenants();
  }

  Future<void> loadTenants() async {
    try {
      final data = await SupabaseService.getAllTenant();
      if (data.isNotEmpty) {
        _tenants = data;
      } else {
        _tenants = dummyTenant();
      }
    } catch (e) {
      debugPrint('Gagal memuat tenant dari Supabase, menggunakan data lokal');
      _tenants = dummyTenant();
    }
    notifyListeners();
  }

  Tenant? getTenantById(String id) {
    try {
      return _tenants.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}
