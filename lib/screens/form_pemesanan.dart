import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../widgets/custom_button.dart';
import '../widgets/logo_header.dart';
import 'pembayaran.dart';

class FormPemesanan extends StatefulWidget {
  final String mejaId;
  final String mejaNomor;
  final double totalHarga;

  const FormPemesanan({
    super.key,
    required this.mejaId,
    required this.mejaNomor,
    required this.totalHarga,
  });

  @override
  State<FormPemesanan> createState() => _FormPemesananState();
}

class _FormPemesananState extends State<FormPemesanan> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _hpController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _hpController.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const LogoHeader(size: 24),
            const SizedBox(width: 8),
            Text('Form Pemesanan',
                style: AppTypography.heading3.copyWith(color: AppColors.black)),
          ],
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _hpController,
                decoration: const InputDecoration(
                  labelText: 'Nomor HP',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Nomor HP harus diisi' : null,
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Lanjut ke Pembayaran',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final user = AppUser(
                      nama: _namaController.text,
                      email: _emailController.text,
                      noHp: _hpController.text,
                    );
                    Provider.of<UserProvider>(context, listen: false)
                        .setUser(user);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Pembayaran(
                          mejaId: widget.mejaId,
                          mejaNomor: widget.mejaNomor,
                          totalHarga: widget.totalHarga,
                        ),
                      ),
                    );
                  }
                },
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
