import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/meja_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';
import 'providers/tenant_provider.dart';
import 'providers/connectivity_provider.dart';
import 'screens/dashboard_utama.dart';
import 'screens/scan_qr_meja.dart';
import 'screens/live_status_meja.dart';
import 'screens/pilih_tenant.dart';
import 'screens/menu_tenant.dart';
import 'screens/keranjang_belanja.dart';
import 'screens/form_pemesanan.dart';
import 'screens/pembayaran.dart';
import 'screens/exit_kosongkan_meja.dart';
import 'models/tenant.dart';
import 'utils/colors.dart';
import 'widgets/connectivity_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
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
        initialRoute: '/',
        routes: {
          '/': (context) => const ConnectivityBanner(child: DashboardUtama()),
          '/scan': (context) => const ConnectivityBanner(child: ScanQrMeja()),
          '/live-status': (context) =>
              const ConnectivityBanner(child: LiveStatusMeja()),
        },
        onGenerateRoute: (settings) {
          Widget page;
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
