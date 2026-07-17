import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Providers
import 'providers/meja_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';
import 'providers/tenant_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/order_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/admin_provider.dart';

// Screens (Pelanggan)
import 'screens/dashboard_utama.dart';
import 'screens/scan_qr_meja.dart';
import 'screens/live_status_meja.dart';
import 'screens/pilih_tenant.dart';
import 'screens/menu_tenant.dart';
import 'screens/keranjang_belanja.dart';
import 'screens/form_pemesanan.dart';
import 'screens/pembayaran.dart';
import 'screens/exit_kosongkan_meja.dart';

// Screens (Role Selection)
import 'screens/role_selection_screen.dart';

// Screens (Penjual)
import 'screens/penjual/dasbor_penjual.dart';
import 'screens/penjual/manajemen_menu_penjual.dart';

// Screens (Kasir)
import 'screens/kasir/verifikasi_kasir.dart';

// Screens (Pengelola)
import 'screens/admin/dashboard_admin.dart';
import 'screens/admin/laporan_harian.dart';
import 'screens/admin/manajemen_sewa.dart';
import 'screens/admin/manajemen_tenant.dart';

// Models
import 'models/tenant.dart';

// Utilities
import 'utils/colors.dart';
import 'widgets/connectivity_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint('✅ Supabase berhasil diinisialisasi');
  } else {
    debugPrint(
        '⚠️  Kredensial Supabase tidak ditemukan. Aplikasi akan berjalan dengan data lokal.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => MejaProvider()),
        ChangeNotifierProvider(create: (_) => TenantProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Kantin ADI',
        theme: ThemeData(
          fontFamily: 'SpaceGrotesk',
          scaffoldBackgroundColor: AppColors.white,
          primaryColor: AppColors.primary,
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.black,
          ),
        ),
        initialRoute: '/role-selection',
        routes: {
          '/': (context) => const ConnectivityBanner(child: DashboardUtama()),
          '/scan': (context) => const ConnectivityBanner(child: ScanQrMeja()),
          '/live-status': (context) =>
              const ConnectivityBanner(child: LiveStatusMeja()),
          '/role-selection': (context) => const RoleSelectionScreen(),
        },
        onGenerateRoute: (settings) {
          Widget page;

          // Pelanggan routes
          if (settings.name == '/pilih-tenant') {
            final args = settings.arguments as Map<String, String>?;
            page = PilihTenant(
              mejaId: args?['mejaId'] ?? '',
              mejaNomor: args?['mejaNomor'] ?? '',
            );
          } else if (settings.name == '/menu-tenant') {
            final args = settings.arguments as Map<String, dynamic>?;
            Tenant? tenant;
            if (args != null && args.containsKey('tenant')) {
              final data = args['tenant'];
              if (data is Tenant) tenant = data;
            }
            page = MenuTenant(
              tenant: tenant ?? Tenant(id: '', nama: '', kontak: ''),
              mejaId: args?['mejaId'] ?? '',
              mejaNomor: args?['mejaNomor'] ?? '',
            );
          } else if (settings.name == '/keranjang') {
            final args = settings.arguments as Map<String, String>?;
            page = KeranjangBelanja(
              mejaId: args?['mejaId'] ?? '',
              mejaNomor: args?['mejaNomor'] ?? '',
            );
          } else if (settings.name == '/form-pemesanan') {
            final args = settings.arguments as Map<String, dynamic>?;
            page = FormPemesanan(
              mejaId: args?['mejaId'] ?? '',
              mejaNomor: args?['mejaNomor'] ?? '',
              totalHarga: args?['totalHarga'] ?? 0.0,
            );
          } else if (settings.name == '/pembayaran') {
            final args = settings.arguments as Map<String, dynamic>?;
            page = Pembayaran(
              mejaId: args?['mejaId'] ?? '',
              mejaNomor: args?['mejaNomor'] ?? '',
              totalHarga: args?['totalHarga'] ?? 0.0,
            );
          } else if (settings.name == '/exit-meja') {
            final args = settings.arguments as Map<String, String>?;
            page = ExitKosongkanMeja(
              mejaNomor: args?['mejaNomor'] ?? '',
            );
          }
          // Penjual routes
          else if (settings.name == '/dasbor-penjual') {
            final args = settings.arguments as Map<String, String>?;
            page = DasborPenjual(
              tenantId: args?['tenantId'] ?? '',
              tenantNama: args?['tenantNama'] ?? '',
            );
          } else if (settings.name == '/manajemen-menu') {
            final args = settings.arguments as Map<String, String>?;
            page = ManajemenMenuPenjual(
              tenantId: args?['tenantId'] ?? '',
            );
          }
          // Kasir routes
          else if (settings.name == '/verifikasi-kasir') {
            final args = settings.arguments as Map<String, String>?;
            page = VerifikasiKasir(
              kasirId: args?['kasirId'] ?? '',
            );
          }
          // Pengelola routes
          else if (settings.name == '/dashboard-admin') {
            page = const DashboardAdmin();
          } else if (settings.name == '/laporan-harian') {
            page = const LaporanHarian();
          } else if (settings.name == '/manajemen-sewa') {
            page = const ManajemenSewa();
          } else if (settings.name == '/manajemen-tenant') {
            page = const ManajemenTenant();
          } else {
            return null;
          }

          return MaterialPageRoute(
            builder: (context) => ConnectivityBanner(child: page),
          );
        },
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Terjadi kesalahan:\n${details.exception.toString()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/'),
                        child: const Text('Kembali ke Dashboard'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          };
          return child!;
        },
      ),
    );
  }
}
