import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/colors.dart';
import '../../utils/typography.dart';

class LaporanHarian extends StatefulWidget {
  const LaporanHarian({super.key});

  @override
  State<LaporanHarian> createState() => _LaporanHarianState();
}

class _LaporanHarianState extends State<LaporanHarian> {
  String _selectedDate = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().toString().substring(0, 10);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Provider.of<AdminProvider>(context, listen: false)
        .loadLaporan(_selectedDate);
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
          'Laporan Harian',
          style: AppTypography.heading3.copyWith(color: AppColors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.black),
            onPressed: () => _exportLaporan(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date picker
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.offWhite,
            child: Row(
              children: [
                const Text('Tanggal:'),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date.toString().substring(0, 10);
                        });
                        await _loadData();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.black, width: 1.5),
                      ),
                      child: Text(
                        _selectedDate,
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.black,
                  ),
                  child: const Text('Tampilkan'),
                ),
              ],
            ),
          ),
          // Summary
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Consumer<AdminProvider>(
              builder: (ctx, provider, _) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final summary = provider.laporanSummary;
                final total = summary['total'] ?? 0.0;
                final bagiHasil = summary['bagiHasil'] ?? 0.0;
                final bersih = total - bagiHasil;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Total', 'Rp ${total.toStringAsFixed(0)}',
                        AppColors.primary),
                    _buildSummaryItem('Bagi Hasil (10%)',
                        'Rp ${bagiHasil.toStringAsFixed(0)}', Colors.orange),
                    _buildSummaryItem('Bersih',
                        'Rp ${bersih.toStringAsFixed(0)}', Colors.green),
                  ],
                );
              },
            ),
          ),
          // Table
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (ctx, provider, _) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = provider.laporanData;

                if (data.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data untuk tanggal ini'),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('Tenant')),
                      DataColumn(label: Text('Pendapatan')),
                      DataColumn(label: Text('Bagi Hasil')),
                      DataColumn(label: Text('Bersih')),
                    ],
                    rows: data.map((item) {
                      return DataRow(cells: [
                        DataCell(Text(item['nama'] ?? '')),
                        DataCell(Text(
                            'Rp ${(item['pendapatan'] ?? 0).toStringAsFixed(0)}')),
                        DataCell(Text(
                            'Rp ${(item['bagiHasil'] ?? 0).toStringAsFixed(0)}')),
                        DataCell(
                          Text(
                            'Rp ${(item['bersih'] ?? 0).toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTypography.heading3.copyWith(color: color)),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }

  Future<void> _exportLaporan(BuildContext context) async {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    final data = provider.laporanData;
    final summary = provider.laporanSummary;

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diekspor')),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('LAPORAN HARIAN KANTIN ADI',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Tanggal: $_selectedDate',
                    style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                        'Total Pendapatan: Rp ${(summary['total'] ?? 0).toStringAsFixed(0)}'),
                    pw.Text(
                        'Bagi Hasil (10%): Rp ${(summary['bagiHasil'] ?? 0).toStringAsFixed(0)}'),
                    pw.Text(
                        'Bersih: Rp ${(summary['bersih'] ?? 0).toStringAsFixed(0)}'),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 16),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(2),
                    2: pw.FlexColumnWidth(2),
                    3: pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Tenant',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Pendapatan',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Bagi Hasil',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Bersih',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...data.map((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item['nama'] ?? ''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                'Rp ${(item['pendapatan'] ?? 0).toStringAsFixed(0)}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                'Rp ${(item['bagiHasil'] ?? 0).toStringAsFixed(0)}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                'Rp ${(item['bersih'] ?? 0).toStringAsFixed(0)}'),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                    'Dicetak: ${DateTime.now().toString().substring(0, 16)}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();

      // Gunakan getApplicationDocumentsDirectory sebagai fallback jika getTemporaryDirectory gagal
      Directory? dir;
      try {
        dir = await getTemporaryDirectory();
      } catch (_) {
        dir = await getApplicationDocumentsDirectory();
      }
      final file = File('${dir.path}/laporan_harian_$_selectedDate.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Laporan Harian Kantin ADI',
        text: 'Laporan harian tanggal $_selectedDate',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil di-generate')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal ekspor: $e')),
        );
      }
    }
  }
}
