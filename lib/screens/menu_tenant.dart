import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tenant.dart';
import '../models/menu.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../providers/meja_provider.dart';
import '../services/supabase_service.dart';
import '../utils/dummy_data.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../widgets/floating_cart.dart';
import '../widgets/logo_header.dart';
import 'keranjang_belanja.dart';
import 'live_status_meja.dart';

class MenuTenant extends StatefulWidget {
  final Tenant tenant;
  final String mejaId;
  final String mejaNomor;

  const MenuTenant({
    super.key,
    required this.tenant,
    required this.mejaId,
    required this.mejaNomor,
  });

  @override
  State<MenuTenant> createState() => _MenuTenantState();
}

class _MenuTenantState extends State<MenuTenant>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Menu> _menuList = [];
  bool _isLoading = true;
  bool get isDelivery =>
      widget.mejaId == 'ffffffff-ffff-ffff-ffff-ffffffffffff';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.getMenuByTenant(widget.tenant.id);
      if (data.isNotEmpty) {
        _menuList = data;
      } else {
        _menuList =
            dummyMenu().where((m) => m.tenantId == widget.tenant.id).toList();
      }
    } catch (e) {
      _menuList =
          dummyMenu().where((m) => m.tenantId == widget.tenant.id).toList();
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final terisi = context.watch<MejaProvider>().jumlahTerisi;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.black),
                        onPressed: () {
                          if (mounted) Navigator.pop(context);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      const LogoHeader(size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kantin ADI',
                                style: AppTypography.display1
                                    .copyWith(fontSize: 24)),
                            Text('SCAN • ORDER • EAT',
                                style: AppTypography.caption
                                    .copyWith(letterSpacing: 2)),
                          ],
                        ),
                      ),
                      if (!isDelivery)
                        GestureDetector(
                          onTap: () {
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LiveStatusMeja()),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.black, width: 1.5),
                            ),
                            child: Text(
                              '$terisi/8',
                              style:
                                  AppTypography.heading2.copyWith(fontSize: 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 1.5, color: AppColors.black),
                ],
              ),
            ),
            // BAR MENU
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isDelivery
                        ? 'PESAN ANTAR — MENU'
                        : '${widget.mejaNomor} — MENU',
                    style:
                        AppTypography.heading4.copyWith(color: AppColors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.swap_horiz,
                            size: 16, color: AppColors.black),
                        SizedBox(width: 4),
                        Text('Ganti Tenant',
                            style: TextStyle(
                                color: AppColors.black, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // NAMA TENANT
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              color: AppColors.primary,
              child: Text(
                widget.tenant.nama.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTypography.heading2
                    .copyWith(fontWeight: FontWeight.w400),
              ),
            ),
            // TAB
            TabBar(
              controller: _tabController,
              labelColor: AppColors.black,
              unselectedLabelColor: AppColors.darkGrey,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Makanan'),
                Tab(text: 'Minuman'),
              ],
            ),
            // CONTENT
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _menuList.isEmpty
                      ? const Center(child: Text('Menu tidak tersedia.'))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            // Tab Makanan: tampilkan makanan + snack
                            _buildMenuGrid(
                                [KategoriMenu.makanan, KategoriMenu.snack]),
                            // Tab Minuman: hanya minuman
                            _buildMenuGrid([KategoriMenu.minuman]),
                          ],
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingCart(
        onTap: () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KeranjangBelanja(
                  mejaId: widget.mejaId,
                  mejaNomor: widget.mejaNomor,
                ),
              ),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Sekarang menerima list kategori agar bisa digabung
  Widget _buildMenuGrid(List<KategoriMenu> kategories) {
    final menus =
        _menuList.where((m) => kategories.contains(m.kategori)).toList();

    if (menus.isEmpty) {
      return const Center(child: Text('Tidak ada menu untuk kategori ini'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: menus.length,
      itemBuilder: (ctx, index) {
        final menu = menus[index];
        return GestureDetector(
          onTap: () {
            if (!menu.tersedia) return;
            if (!mounted) return;
            final cart = Provider.of<CartProvider>(context, listen: false);
            cart.addItem(
              CartItem(
                menuId: menu.id,
                namaMenu: menu.nama,
                harga: menu.harga,
                tenantId: widget.tenant.id,
                tenantNama: widget.tenant.nama,
                quantity: 1,
              ),
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Ditambahkan ke keranjang'),
                    duration: Duration(seconds: 1)),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.black, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant,
                    size: 40, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(
                  menu.nama,
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${menu.harga.toStringAsFixed(0)}',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.primary),
                ),
                if (!menu.tersedia)
                  const Text(
                    'HABIS',
                    style: TextStyle(
                        color: AppColors.red, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
