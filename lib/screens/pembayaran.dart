import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/meja_provider.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../widgets/custom_button.dart';
import '../widgets/logo_header.dart';
import 'exit_kosongkan_meja.dart';
import '../models/app_user.dart';
import '../models/meja.dart';
import '../services/supabase_service.dart';
import '../services/email_service.dart' as email_service;
import 'live_status_meja.dart';
import 'pilih_tenant.dart';

class Pembayaran extends StatefulWidget {
  final String mejaId;
  final String mejaNomor;
  final double totalHarga;

  const Pembayaran({
    super.key,
    required this.mejaId,
    required this.mejaNomor,
    required this.totalHarga,
  });

  @override
  State<Pembayaran> createState() => _PembayaranState();
}

class _PembayaranState extends State<Pembayaran> {
  bool _isPaid = false;
  bool _isCash = false;
  bool _isProcessing = false;
  bool get isDelivery =>
      widget.mejaId == 'ffffffff-ffff-ffff-ffff-ffffffffffff';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final user = Provider.of<UserProvider>(context).user;
    final mejaProvider = Provider.of<MejaProvider>(context);
    final terisi = mejaProvider.jumlahTerisi;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                        onPressed: () => Navigator.pop(context),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LiveStatusMeja()),
                            );
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
            // Bar pembayaran
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                isDelivery
                    ? 'PESAN ANTAR — PEMBAYARAN'
                    : '${widget.mejaNomor} — PEMBAYARAN',
                style: AppTypography.heading4.copyWith(color: AppColors.black),
              ),
            ),
            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PESANAN DITERIMA
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.primary,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: AppColors.black),
                              const SizedBox(width: 8),
                              Text('PESANAN DITERIMA',
                                  style: AppTypography.heading3),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isDelivery
                                ? 'Pesanan Anda sedang disiapkan. Harap menunggu & selamat menikmati!'
                                : 'Pesanan untuk ${widget.mejaNomor} sedang disiapkan oleh masing-masing tenant. Harap menunggu & selamat menikmati!',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('RINCIAN', style: AppTypography.heading2),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (ctx, index) {
                          final item = cart.items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.offWhite,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.black, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${item.namaMenu} x ${item.quantity}',
                                          style: AppTypography.bodyMedium),
                                      Text(item.tenantNama,
                                          style: AppTypography.bodySmall),
                                    ],
                                  ),
                                ),
                                Text('Rp ${item.subtotal.toStringAsFixed(0)}',
                                    style: AppTypography.bodyMedium),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL BAYAR', style: AppTypography.heading3),
                        Text('Rp ${widget.totalHarga.toStringAsFixed(0)}',
                            style: AppTypography.heading3),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_isPaid) ...[
                      if (isDelivery)
                        CustomButton(
                          label: 'Bayar QRIS',
                          onPressed: () {
                            setState(() {
                              _isPaid = true;
                              _isCash = false;
                            });
                            _showStrukDialog(context, cart, user, 'QRIS');
                          },
                          isFullWidth: true,
                          textColor: AppColors.black,
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                label: 'QRIS',
                                onPressed: () {
                                  setState(() {
                                    _isPaid = true;
                                    _isCash = false;
                                  });
                                  _showStrukDialog(context, cart, user, 'QRIS');
                                },
                                isPrimary: true,
                                textColor: AppColors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomButton(
                                label: 'Cash',
                                onPressed: () {
                                  setState(() {
                                    _isPaid = true;
                                    _isCash = true;
                                  });
                                  _showStrukDialog(context, cart, user,
                                      'Cash (Bayar di Kasir)');
                                },
                                isPrimary: true,
                                textColor: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ] else ...[
                      if (_isCash)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: AppColors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.offWhite,
                          ),
                          child: const Text(
                            'Silakan datang ke kasir untuk melakukan pembayaran tunai dan tunjukkan struk ini.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      const SizedBox(height: 8),
                      const Icon(Icons.check_circle_outline,
                          size: 48, color: AppColors.green),
                      const Text('Pembayaran Berhasil',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      CustomButton(
                        label: 'Pesan Lagi?',
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PilihTenant(
                                  mejaId: widget.mejaId,
                                  mejaNomor: widget.mejaNomor),
                            ),
                          );
                        },
                        isPrimary: false,
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 8),
                      if (!isDelivery) ...[
                        CustomButton(
                          label: _isProcessing
                              ? 'Memproses...'
                              : 'Selesai & Keluar Meja',
                          onPressed: _isProcessing
                              ? null
                              : () async {
                                  if (cart.items.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Keranjang kosong.')),
                                    );
                                    return;
                                  }
                                  setState(() => _isProcessing = true);
                                  try {
                                    final userData = Provider.of<UserProvider>(
                                            context,
                                            listen: false)
                                        .user;
                                    if (userData == null) {
                                      throw Exception(
                                          'Data pemesan tidak ditemukan');
                                    }
                                    final userId =
                                        await SupabaseService.getUserIdByEmail(
                                            userData.email,
                                            userData.nama,
                                            userData.noHp);
                                    final items = cart.items
                                        .map((item) => {
                                              'menuId': item.menuId,
                                              'tenantId': item.tenantId,
                                              'quantity': item.quantity,
                                              'hargaSatuan': item.harga,
                                            })
                                        .toList();
                                    await SupabaseService.createTransaksi(
                                      mejaId: widget.mejaId,
                                      totalBayar: widget.totalHarga,
                                      metodeBayar: _isCash ? 'Tunai' : 'QRIS',
                                      items: items,
                                      userId: userId,
                                    );
                                    if (!mounted) return;
                                    final mejaProv = Provider.of<MejaProvider>(
                                        context,
                                        listen: false);
                                    mejaProv.updateStatusMeja(
                                        widget.mejaId, StatusMeja.kosong);
                                    cart.clearCart();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ExitKosongkanMeja(
                                            mejaNomor: widget.mejaNomor),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    setState(() => _isProcessing = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Gagal menyimpan transaksi: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          isFullWidth: true,
                        ),
                      ] else ...[
                        CustomButton(
                          label: _isProcessing
                              ? 'Memproses...'
                              : 'Simpan & Selesai',
                          onPressed: _isProcessing
                              ? null
                              : () async {
                                  if (cart.items.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Keranjang kosong.')),
                                    );
                                    return;
                                  }
                                  setState(() => _isProcessing = true);
                                  try {
                                    final userData = Provider.of<UserProvider>(
                                            context,
                                            listen: false)
                                        .user;
                                    if (userData == null) {
                                      throw Exception(
                                          'Data pemesan tidak ditemukan');
                                    }
                                    final userId =
                                        await SupabaseService.getUserIdByEmail(
                                            userData.email,
                                            userData.nama,
                                            userData.noHp);
                                    final items = cart.items
                                        .map((item) => {
                                              'menuId': item.menuId,
                                              'tenantId': item.tenantId,
                                              'quantity': item.quantity,
                                              'hargaSatuan': item.harga,
                                            })
                                        .toList();
                                    await SupabaseService.createTransaksi(
                                      mejaId: widget.mejaId,
                                      totalBayar: widget.totalHarga,
                                      metodeBayar: _isCash ? 'Tunai' : 'QRIS',
                                      items: items,
                                      userId: userId,
                                    );
                                    if (!mounted) return;
                                    cart.clearCart();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ExitKosongkanMeja(
                                            mejaNomor: widget.mejaNomor),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    setState(() => _isProcessing = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Gagal menyimpan transaksi: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          isFullWidth: true,
                        ),
                      ],
                      const SizedBox(height: 8),
                      CustomButton(
                        label: 'Nanti Saja',
                        onPressed: () => Navigator.pop(context),
                        isPrimary: false,
                        isFullWidth: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== FUNGSI STRUK ==================
  void _showStrukDialog(
      BuildContext context, CartProvider cart, AppUser? user, String metode) {
    final itemsText = cart.items.map((item) {
      return '${item.namaMenu} x ${item.quantity} = Rp ${item.subtotal.toStringAsFixed(0)} (${item.tenantNama})';
    }).join('\n');

    final strukText = '''
================================
       KANTIN ADI
    SCAN • ORDER • EAT
================================
${isDelivery ? 'Pesan Antar' : 'Meja      : ${widget.mejaNomor}'}
Tanggal   : ${DateTime.now().toString().substring(0, 16)}
--------------------------------
RINCIAN PESANAN:
$itemsText
--------------------------------
TOTAL     : Rp ${widget.totalHarga.toStringAsFixed(0)}
--------------------------------
Metode    : $metode
--------------------------------
Terima kasih telah berbelanja!
================================
    ''';

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head><style>body { font-family: monospace; }</style></head>
<body>
<pre>$strukText</pre>
</body>
</html>
    ''';

    final subject =
        'Struk Pembayaran Kantin ADI - ${isDelivery ? 'Pesan Antar' : widget.mejaNomor}';
    strukText.replaceAll('\n', '%0A');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Struk Pembayaran'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(strukText,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ),
              const SizedBox(height: 16),
              if (user != null)
                Text('Email: ${user.email}', style: AppTypography.bodySmall),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: strukText));
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Struk disalin ke clipboard!')),
                );
              }
            },
            child: const Text('Salin Struk'),
          ),
          // TOMBOL KIRIM EMAIL OTOMATIS DENGAN PDF
          TextButton(
            onPressed: () async {
              if (user == null || user.email.isEmpty) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Email tidak ditemukan.')),
                  );
                }
                return;
              }
              // Kirim email dengan PDF attachment
              await _sendEmailWithPdf(
                  strukText, user.email, subject, htmlContent, ctx);
            },
            child: const Text('Kirim Email (PDF)'),
          ),
          // TOMBOL KIRIM WHATSAPP (PDF)
          TextButton(
            onPressed: () async {
              if (user == null || user.noHp.isEmpty) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Nomor HP tidak ditemukan.')),
                  );
                }
                return;
              }
              await _shareStrukPdf(strukText, user.noHp);
            },
            child: const Text('Kirim WhatsApp (PDF)'),
          ),
        ],
      ),
    );
  }

  // ================== KIRIM EMAIL DENGAN PDF ==================
  Future<void> _sendEmailWithPdf(
    String strukText,
    String toEmail,
    String subject,
    String htmlContent,
    BuildContext ctx,
  ) async {
    try {
      // Buat PDF dari teks struk
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Text(
                strukText,
                style: pw.TextStyle(fontSize: 10, font: pw.Font.courier()),
              ),
            );
          },
        ),
      );
      final pdfBytes = await pdf.save();
      final base64Pdf = base64Encode(pdfBytes);
      final fileName =
          'struk_kantin_adi_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Tampilkan loading
      showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final success =
          await email_service.EmailService.sendReceiptWithAttachment(
        toEmail: toEmail,
        subject: subject,
        htmlContent: htmlContent,
        textContent: strukText,
        attachmentBase64: base64Pdf,
        attachmentFilename: fileName,
      );

      // Tutup loading
      if (ctx.mounted) Navigator.of(ctx).pop();

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Struk PDF berhasil dikirim ke email!')),
        );
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
              content:
                  Text('Gagal mengirim email. Periksa koneksi atau API key.')),
        );
      }
    } catch (e) {
      if (ctx.mounted) Navigator.of(ctx).pop();
      debugPrint('Error sending email: $e');
      if (mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Gagal mengirim email: $e')),
        );
      }
    }
  }

  // ================== SHARE PDF (WHATSAPP) ==================
  Future<void> _shareStrukPdf(String strukText, String noHp) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Text(
                strukText,
                style: pw.TextStyle(fontSize: 10, font: pw.Font.courier()),
              ),
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final fileName =
          'struk_kantin_adi_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        final base64 = base64Encode(bytes);
        final url = Uri.parse('data:application/pdf;base64,$base64');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, webOnlyWindowName: '_blank');
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Struk Kantin ADI',
        text: 'Berikut struk pembayaran Anda dari Kantin ADI.',
      );
    } catch (e) {
      debugPrint('Gagal share PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membagikan PDF: $e')),
        );
      }
      _fallbackShareText(strukText, noHp);
    }
  }

  void _fallbackShareText(String strukText, String noHp) {
    try {
      var waPhone = noHp.replaceAll(RegExp(r'\s+'), '');
      if (!waPhone.startsWith('+')) waPhone = '+62$waPhone';
      final waUrl = Uri.parse(
          'https://wa.me/$waPhone?text=${Uri.encodeComponent(strukText)}');
      launchUrl(waUrl, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}
