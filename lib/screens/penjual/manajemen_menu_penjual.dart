import 'package:flutter/material.dart';
import '../../models/menu.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';
import '../../utils/typography.dart';

class ManajemenMenuPenjual extends StatefulWidget {
  final String tenantId;

  const ManajemenMenuPenjual({super.key, required this.tenantId});

  @override
  State<ManajemenMenuPenjual> createState() => _ManajemenMenuPenjualState();
}

class _ManajemenMenuPenjualState extends State<ManajemenMenuPenjual> {
  List<Menu> _menus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    try {
      _menus = await SupabaseService.getMenuByTenant(widget.tenantId);
    } catch (e) {
      debugPrint('Gagal load menu: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Manajemen Menu',
          style: AppTypography.heading3.copyWith(color: AppColors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.black),
            onPressed: _loadMenu,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _menus.isEmpty
              ? const Center(
                  child: Text('Belum ada menu. Tambahkan menu baru.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _menus.length,
                  itemBuilder: (ctx, index) {
                    final menu = _menus[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: menu.tersedia ? AppColors.black : Colors.red,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  menu.nama,
                                  style: AppTypography.heading4,
                                ),
                                Text(
                                  'Rp ${menu.harga.toStringAsFixed(0)}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: menu.tersedia
                                            ? AppColors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        menu.tersedia ? 'Tersedia' : 'Habis',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _kategoriLabel(menu.kategori),
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              menu.tersedia
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color:
                                  menu.tersedia ? AppColors.green : Colors.red,
                            ),
                            onPressed: () => _toggleAvailability(menu),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: AppColors.primary),
                            onPressed: () => _showMenuDialog(menu: menu),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMenu(menu),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMenuDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _kategoriLabel(KategoriMenu kategori) {
    switch (kategori) {
      case KategoriMenu.makanan:
        return 'Makanan';
      case KategoriMenu.minuman:
        return 'Minuman';
      case KategoriMenu.snack:
        return 'Snack';
    }
  }

  Future<void> _toggleAvailability(Menu menu) async {
    try {
      await SupabaseService.toggleMenuAvailability(menu.id, !menu.tersedia);
      await _loadMenu();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              menu.tersedia ? 'Menu ditandai Habis' : 'Menu ditandai Tersedia',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: $e')),
        );
      }
    }
  }

  Future<void> _deleteMenu(Menu menu) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Menu?'),
        content: Text('Yakin ingin menghapus "${menu.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await SupabaseService.deleteMenu(menu.id);
        await _loadMenu();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal hapus: $e')),
          );
        }
      }
    }
  }

  void _showMenuDialog({Menu? menu}) {
    final isEdit = menu != null;
    final namaController = TextEditingController(text: menu?.nama ?? '');
    final hargaController =
        TextEditingController(text: menu?.harga.toStringAsFixed(0) ?? '');
    String selectedKategori =
        menu != null ? _kategoriLabel(menu.kategori).toLowerCase() : 'makanan';
    bool tersedia = menu?.tersedia ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(isEdit ? 'Edit Menu' : 'Tambah Menu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hargaController,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedKategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'makanan', child: Text('Makanan')),
                  DropdownMenuItem(value: 'minuman', child: Text('Minuman')),
                  DropdownMenuItem(value: 'snack', child: Text('Snack')),
                ],
                onChanged: (value) {
                  setStateDialog(() {
                    selectedKategori = value!;
                  });
                },
              ),
              if (isEdit)
                Row(
                  children: [
                    const Text('Tersedia:'),
                    const SizedBox(width: 8),
                    Switch(
                      value: tersedia,
                      onChanged: (value) {
                        setStateDialog(() {
                          tersedia = value;
                        });
                      },
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final nama = namaController.text.trim();
                final harga = double.tryParse(hargaController.text.trim());

                if (nama.isEmpty || harga == null || harga <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Isi data dengan benar')),
                  );
                  return;
                }

                try {
                  if (isEdit) {
                    await SupabaseService.updateMenu(
                      menuId: menu.id, // ← PERBAIKAN: tanpa !
                      nama: nama,
                      harga: harga,
                      kategori: selectedKategori,
                      tersedia: tersedia,
                    );
                  } else {
                    await SupabaseService.createMenu(
                      tenantId: widget.tenantId,
                      nama: nama,
                      harga: harga,
                      kategori: selectedKategori,
                    );
                  }
                  Navigator.pop(ctx);
                  await _loadMenu();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? 'Menu berhasil diupdate'
                              : 'Menu berhasil ditambahkan',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Gagal: $e')),
                  );
                }
              },
              child: Text(isEdit ? 'Update' : 'Tambah'),
            ),
          ],
        ),
      ),
    );
  }
}
