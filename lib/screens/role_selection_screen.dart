import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../widgets/custom_button.dart';
import '../providers/user_provider.dart';
import '../models/app_user.dart';
import '../services/supabase_service.dart';
import '../models/tenant.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = 'penjual';
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  bool _isLoading = false;

  // Untuk dropdown penjual
  List<Tenant> _tenants = [];
  Tenant? _selectedTenant;

  final Map<String, String> _roleLabels = {
    'penjual': 'Penjual (Tenant)',
    'kasir': 'Petugas Kasir',
    'pengelola': 'Pengelola (Admin)',
  };

  final Map<String, String> _roleRoutes = {
    'penjual': '/dasbor-penjual',
    'kasir': '/verifikasi-kasir',
    'pengelola': '/dashboard-admin',
  };

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    final tenants = await SupabaseService.getAllTenant();
    setState(() {
      _tenants = tenants;
      if (_tenants.isNotEmpty) {
        _selectedTenant = _tenants.first;
      }
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.black, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/logokantinadiapp.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.restaurant,
                          size: 50, color: Colors.white);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Kantin ADI',
                  style: AppTypography.display1.copyWith(fontSize: 32)),
              const SizedBox(height: 8),
              Text('SCAN • ORDER • EAT',
                  style: AppTypography.caption.copyWith(letterSpacing: 2)),
              const SizedBox(height: 40),

              // Tombol Pelanggan
              CustomButton(
                label: 'MASUK SEBAGAI PELANGGAN',
                onPressed: () {
                  Provider.of<UserProvider>(context, listen: false).clearUser();
                  Navigator.pushReplacementNamed(context, '/');
                },
                isFullWidth: true,
                textColor: AppColors.black,
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // Login Staff
              Text('LOGIN STAFF',
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.darkGrey,
                    fontSize: 16,
                  )),
              const SizedBox(height: 16),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Pilih Role',
                  border: OutlineInputBorder(),
                ),
                items: _roleLabels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Jika role penjual, tampilkan dropdown tenant
              if (_selectedRole == 'penjual')
                DropdownButtonFormField<Tenant>(
                  value: _selectedTenant,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Tenant',
                    border: OutlineInputBorder(),
                  ),
                  items: _tenants.map((tenant) {
                    return DropdownMenuItem(
                      value: tenant,
                      child: Text(tenant.nama),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTenant = value;
                    });
                  },
                )
              else ...[
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText:
                        _selectedRole == 'kasir' ? 'ID Kasir' : 'ID Admin',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Nama
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                label: _isLoading ? 'Memproses...' : 'Login',
                onPressed: _isLoading
                    ? null
                    : () {
                        _loginStaff(context);
                      },
                isFullWidth: true,
                textColor: AppColors.black,
              ),

              const SizedBox(height: 16),
              Text(
                'Staff: Login menggunakan ID yang diberikan.',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginStaff(BuildContext context) async {
    if (_selectedRole == 'penjual') {
      if (_selectedTenant == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih tenant terlebih dahulu')),
        );
        return;
      }
    } else {
      final id = _idController.text.trim();
      if (id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan isi ID terlebih dahulu')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    final nama = _namaController.text.trim();
    if (nama.isNotEmpty) {
      Provider.of<UserProvider>(context, listen: false).setUser(
        AppUser(nama: nama, email: 'staff@kantin.com', noHp: ''),
      );
    }

    setState(() => _isLoading = false);

    final route = _roleRoutes[_selectedRole] ?? '/';
    final arguments = <String, String>{};
    if (_selectedRole == 'penjual' && _selectedTenant != null) {
      arguments['tenantId'] = _selectedTenant!.id; // UUID
      arguments['tenantNama'] = _selectedTenant!.nama;
    } else if (_selectedRole == 'kasir') {
      arguments['kasirId'] = _idController.text.trim();
    }

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        route,
        arguments: arguments,
      );
    }
  }
}
