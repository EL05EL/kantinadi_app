import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../widgets/custom_button.dart';
import '../widgets/logo_header.dart';
import 'pilih_tenant.dart';

class PesanAntar extends StatefulWidget {
  const PesanAntar({super.key});

  @override
  State<PesanAntar> createState() => _PesanAntarState();
}

class _PesanAntarState extends State<PesanAntar> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _hpController = TextEditingController();
  final _prodiController = TextEditingController();
  String _selectedGedung = 'Gedung 1';
  bool _isLoading = false;

  final List<String> gedungList = ['Gedung 1', 'Gedung 2'];

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _hpController.dispose();
    _prodiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
        title: Row(
          children: [
            const LogoHeader(size: 24),
            const SizedBox(width: 8),
            Text('Pesan Antar',
                style: AppTypography.heading3.copyWith(color: AppColors.black)),
          ],
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pemesan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Nama harus diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email UAD (@webmail.uad.ac.id)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return 'Email harus diisi';
                    if (!v.endsWith('@webmail.uad.ac.id')) {
                      return 'Harus menggunakan email UAD';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _hpController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor HP',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Nomor HP harus diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prodiController,
                  decoration: const InputDecoration(
                    labelText: 'Prodi (contoh: Teknik Informatika)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Prodi harus diisi' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedGedung,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Gedung',
                    border: OutlineInputBorder(),
                  ),
                  items: gedungList.map((g) {
                    return DropdownMenuItem(value: g, child: Text(g));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedGedung = val!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: _isLoading ? 'Memproses...' : 'Pesan Sekarang',
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _isLoading = true);
                          await Future.delayed(const Duration(seconds: 2));
                          final user = AppUser(
                            nama: _namaController.text,
                            email: _emailController.text,
                            noHp: _hpController.text,
                          );
                          Provider.of<UserProvider>(context, listen: false)
                              .setUser(user);
                          setState(() => _isLoading = false);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PilihTenant(
                                mejaId: 'DELIVERY',
                                mejaNomor: 'PESAN ANTAR',
                              ),
                            ),
                          );
                        },
                  isFullWidth: true,
                  textColor: AppColors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
