import 'package:app_laundry/Models/serviceModel.dart';
import 'package:app_laundry/Services/orderDetail_service.dart';
import 'package:app_laundry/Services/service_service.dart';
import 'package:app_laundry/Services/store_service.dart';
import 'package:app_laundry/Widgets/upperBarExcel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:excel/excel.dart' as excel_lib;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Model penampung untuk kalkulasi agregasi data per-layanan
class ServiceReportItem {
  final ServiceModel service;
  final double totalSubtotal;
  final double totalQty;

  ServiceReportItem({
    required this.service,
    required this.totalSubtotal,
    required this.totalQty,
  });
}

// Model penampung gabungan hasil data (Nama Outlet + Hasil Laporan)
class ReportDataHolder {
  final String storeName;
  final List<ServiceReportItem> items;

  ReportDataHolder({
    required this.storeName,
    required this.items,
  });
}

class DetailLaporanLayananScreen extends StatefulWidget {
  final DateTimeRange date;
  final String store_id;
  
  const DetailLaporanLayananScreen({
    super.key, 
    required this.date, 
    required this.store_id,
  });

  @override
  State<DetailLaporanLayananScreen> createState() => _DetailLaporanLayananScreenState();
}

class _DetailLaporanLayananScreenState extends State<DetailLaporanLayananScreen> {
  final serviceService = ServiceService();
  final orderDetailService = OrderDetailService();
  final storeService = StoreService();

  String _selectedSort = "Nilai Tertinggi";
  
  final List<String> _sortItems = [
    "Nilai Tertinggi", 
    "Nilai Terendah", 
    "Kuantitas tertinggi", 
    "Kuantitas terendah", 
    "Nama Layanan A - Z", 
    "Nama Durasi A - Z"
  ];

  late Future<ReportDataHolder> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _fetchAndProcessReport();
  }

  /// Memuat nama outlet, master service, & order detail secara paralel
  Future<ReportDataHolder> _fetchAndProcessReport() async {
    // Jalankan 3 request sekaligus secara paralel (jauh lebih cepat)
    final results = await Future.wait([
      storeService.fetchStoreName(widget.store_id),
      serviceService.fetchServices(widget.store_id),
      orderDetailService.fetchOrderDetailByStoreAndDate(
        widget.store_id,
        widget.date.start,
        widget.date.end.add(Duration(days: 1)),
      ),
    ]);

    final String storeName = results[0] as String;
    final List<ServiceModel> services = results[1] as List<ServiceModel>;
    final List<dynamic> rawDetails = results[2] as List<dynamic>;

    // Aggregasi data layanan
    final Map<String, ServiceReportItem> reportMap = {};

    for (var service in services) {
      if (service.id != null) {
        reportMap[service.id!] = ServiceReportItem(
          service: service,
          totalSubtotal: 0.0,
          totalQty: 0.0,
        );
      }
    }

    for (var detail in rawDetails) {
      final serviceId = detail['service_id']?.toString();
      final subtotal = double.tryParse(detail['subtotal']?.toString() ?? '0') ?? 0.0;
      final qty = double.tryParse((detail['quantity'] ?? detail['qty'])?.toString() ?? '0') ?? 0.0;

      if (serviceId != null && reportMap.containsKey(serviceId)) {
        final current = reportMap[serviceId]!;
        reportMap[serviceId] = ServiceReportItem(
          service: current.service,
          totalSubtotal: current.totalSubtotal + subtotal,
          totalQty: current.totalQty + qty,
        );
      }
    }

    return ReportDataHolder(
      storeName: storeName,
      items: reportMap.values.toList(),
    );
  }

  /// Mengurutkan list data laporan sesuai opsi dropdown
  List<ServiceReportItem> _sortList(List<ServiceReportItem> list) {
    List<ServiceReportItem> sorted = List.from(list);
    switch (_selectedSort) {
      case "Nilai Tertinggi":
        sorted.sort((a, b) => b.totalSubtotal.compareTo(a.totalSubtotal));
        break;
      case "Nilai Terendah":
        sorted.sort((a, b) => a.totalSubtotal.compareTo(b.totalSubtotal));
        break;
      case "Kuantitas tertinggi":
        sorted.sort((a, b) => b.totalQty.compareTo(a.totalQty));
        break;
      case "Kuantitas terendah":
        sorted.sort((a, b) => a.totalQty.compareTo(b.totalQty));
        break;
      case "Nama Layanan A - Z":
        sorted.sort((a, b) => a.service.service_name.compareTo(b.service.service_name));
        break;
      case "Nama Durasi A - Z":
        sorted.sort((a, b) {
          final durA = a.service.duration?.duration_name ?? '';
          final durB = b.service.duration?.duration_name ?? '';
          return durA.compareTo(durB);
        });
        break;
    }
    return sorted;
  }

  /// Formatter Rupiah
  String _formatRupiah(double value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(value);
  }

  /// Formatter Tanggal Periode
  String _formatDateRange(DateTimeRange range) {
    final formatter = DateFormat('dd MMM yyyy');
    return "${formatter.format(range.start)} - ${formatter.format(range.end)}";
  }

  bool _isExporting = false;

  Future<void> _exportToExcel(String storeName, List<ServiceReportItem> items) async {
    setState(() => _isExporting = true);

    try {
      final excel_lib.Excel excelFile = excel_lib.Excel.createExcel();
      final excel_lib.Sheet sheet = excelFile['Laporan Layanan'];
      excelFile.delete('Sheet1');

      final excel_lib.CellStyle headerStyle = excel_lib.CellStyle(
        bold: true,
        backgroundColorHex: excel_lib.ExcelColor.fromHexString('#2196F3'),
        fontColorHex: excel_lib.ExcelColor.white,
      );
      final excel_lib.CellStyle boldStyle = excel_lib.CellStyle(bold: true);

      int row = 0;

      void writeCell(int col, int r, dynamic value, {excel_lib.CellStyle? style}) {
        final cell = sheet.cell(
          excel_lib.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: r),
        );
        if (value is num) {
          cell.value = excel_lib.DoubleCellValue(value.toDouble());
        } else {
          cell.value = excel_lib.TextCellValue(value.toString());
        }
        if (style != null) cell.cellStyle = style;
      }

      // Title & Meta
      writeCell(0, row, 'LAPORAN LAYANAN', style: headerStyle);
      row++;
      writeCell(0, row, 'Outlet');
      writeCell(1, row, storeName);
      row++;
      writeCell(0, row, 'Periode');
      writeCell(1, row, _formatDateRange(widget.date));
      row++;

      final totalDurasiCount = items
          .map((e) => e.service.duration_id)
          .where((id) => id.isNotEmpty)
          .toSet()
          .length;
      writeCell(0, row, 'Jenis Durasi');
      writeCell(1, row, totalDurasiCount);
      row++;
      writeCell(0, row, 'Jenis Layanan');
      writeCell(1, row, items.length);
      row += 2;

      // Sorted according to whichever sort is currently selected on screen
      final sortedItems = _sortList(items);

      // Table header
      final headers = ['Rank', 'Durasi', 'Nama Layanan', 'Total Nilai', 'Total Kuantitas'];
      for (int i = 0; i < headers.length; i++) {
        writeCell(i, row, headers[i], style: boldStyle);
      }
      row++;

      for (int i = 0; i < sortedItems.length; i++) {
        final item = sortedItems[i];
        final durasiNama = item.service.duration?.duration_name ?? '-';
        final unitNama = item.service.unit?.unit_name ?? '';
        final formattedQty = item.totalQty % 1 == 0
            ? item.totalQty.toInt().toString()
            : item.totalQty.toStringAsFixed(1);

        writeCell(0, row, '#${i + 1}');
        writeCell(1, row, durasiNama);
        writeCell(2, row, item.service.service_name);
        writeCell(3, row, item.totalSubtotal);
        writeCell(4, row, "$formattedQty $unitNama".trim());
        row++;
      }

      for (int i = 0; i < 5; i++) {
        sheet.setColumnWidth(i, 20);
      }

      final directory = await getTemporaryDirectory();
      final fileName =
          'Laporan_Layanan_${storeName}_${DateFormat('yyyyMMdd').format(widget.date.start)}.xlsx'
              .replaceAll(' ', '_');
      final filePath = '${directory.path}/$fileName';
      final fileBytes = excelFile.encode();

      if (fileBytes == null) throw Exception('Gagal encode file excel');

      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Laporan Layanan $storeName',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: FutureBuilder<ReportDataHolder>(
          future: _reportFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Terjadi kesalahan: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final storeName = snapshot.data?.storeName ?? '-';
            final items = snapshot.data?.items ?? [];
            final sortedItems = _sortList(items);

            // Hitung ringkasan unik durasi dan layanan
            final totalDurasiCount = items
                .map((e) => e.service.duration_id)
                .where((id) => id.isNotEmpty)
                .toSet()
                .length;
            final totalLayananCount = items.length;

            return SingleChildScrollView(
              child: Column(
                children: [
                  UpperBarExcel(
                    title: "LAPORAN LAYANAN",
                    isExporting: _isExporting,
                    onExport: () => _exportToExcel(storeName, items),
                  ),

                  // CARD 1: RINGKASAN DATA LAYANAN
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Nama Outlet Dinamis dari Database
                            _buildRowInfo("Outlet", storeName, isBold: true),
                            _buildRowInfo("Periode", _formatDateRange(widget.date), isBold: true),
                            const SizedBox(height: 12),
                            _buildRowInfo("Jenis Durasi", "$totalDurasiCount Durasi"),
                            _buildRowInfo("Jenis Layanan", "$totalLayananCount Layanan"),
                            const SizedBox(height: 12),

                            // Baris Urutkan & Dropdown
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Urutkan",
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedSort,
                                      style: const TextStyle(
                                        color: Colors.blueAccent, 
                                        fontSize: 14, 
                                        fontWeight: FontWeight.w600,
                                      ),
                                      icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                                      items: _sortItems.map((String item) {
                                        return DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(item, style: const TextStyle(color: Colors.black87)),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _selectedSort = newValue;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // LIST CARD LAYANAN
                  if (sortedItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        "Belum ada data layanan.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedItems.length,
                      itemBuilder: (context, index) {
                        final item = sortedItems[index];
                        final durasiNama = item.service.duration?.duration_name ?? '-';
                        final unitNama = item.service.unit?.unit_name ?? '';
                        final formattedQty = item.totalQty % 1 == 0 
                            ? item.totalQty.toInt().toString() 
                            : item.totalQty.toStringAsFixed(1);

                        return _buildRowLayanan(
                          rank: "#${index + 1}",
                          durasiKategori: durasiNama,
                          namaLayanan: item.service.service_name,
                          harga: _formatRupiah(item.totalSubtotal),
                          kuantitas: "$formattedQty $unitNama".trim(),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET HELPER 1: Info Baris Ringkasan ---
  Widget _buildRowInfo(String label, String value, {bool isBold = false}) {
    final style = TextStyle(
      color: Colors.black,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  // --- WIDGET HELPER 2: Card List Item Layanan ---
  Widget _buildRowLayanan({
    required String rank,
    required String durasiKategori,
    required String namaLayanan,
    required String harga,
    required String kuantitas,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rank,
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      durasiKategori,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      namaLayanan,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Nilai & Kuantitas", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(harga, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    kuantitas,
                    style: const TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}