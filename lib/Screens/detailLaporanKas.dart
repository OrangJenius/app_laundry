import 'package:app_laundry/Models/cashFlowModel.dart';
import 'package:app_laundry/Models/storeModel.dart';
import 'package:app_laundry/Services/cashFlow_service.dart';
import 'package:app_laundry/Services/store_service.dart';
import 'package:app_laundry/Widgets/upperBarExcel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:excel/excel.dart' as excel_lib;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DetailLaporanKasScreen extends StatefulWidget {
  final String store_id;
  final DateTimeRange date;

  const DetailLaporanKasScreen({
    super.key,
    required this.date,
    required this.store_id,
  });

  @override
  State<DetailLaporanKasScreen> createState() => _DetailLaporanKasScreenState();
}

class _DetailLaporanKasScreenState extends State<DetailLaporanKasScreen> {
  final cashFlowService = CashFlowService();
  final storeService = StoreService();

  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  bool _isExporting = false;

  Future<void> _exportToExcel(Map<String, dynamic> data) async {
    setState(() => _isExporting = true);

    try {
      final excel_lib.Excel excelFile = excel_lib.Excel.createExcel();
      final excel_lib.Sheet sheet = excelFile['Laporan Kas'];
      excelFile.delete('Sheet1'); // remove default empty sheet

      excel_lib.CellStyle headerStyle = excel_lib.CellStyle(
        bold: true,
        backgroundColorHex: excel_lib.ExcelColor.fromHexString('#4CAF50'),
        fontColorHex: excel_lib.ExcelColor.white,
      );

      excel_lib.CellStyle boldStyle = excel_lib.CellStyle(bold: true);

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

      // Title
      writeCell(0, row, 'LAPORAN KAS', style: headerStyle);
      row++;
      writeCell(0, row, 'Outlet');
      writeCell(1, row, data['store_name']);
      row++;
      writeCell(0, row, 'Periode');
      writeCell(1, row,
          "${_formatDate(widget.date.start)} - ${_formatDate(widget.date.end)}");
      row += 2;

      // Summary section
      void writeSummaryRow(String label, double total, double tunai, double nonTunai,
          {bool bold = false}) {
        writeCell(0, row, label, style: bold ? boldStyle : null);
        writeCell(1, row, total, style: bold ? boldStyle : null);
        row++;
        writeCell(0, row, '  Tunai');
        writeCell(1, row, tunai);
        row++;
        writeCell(0, row, '  Non-Tunai');
        writeCell(1, row, nonTunai);
        row++;
      }

      writeCell(0, row, 'RINGKASAN', style: headerStyle);
      row++;
      writeSummaryRow('Saldo Awal', data['saldo_awal_total'],
          data['saldo_awal_tunai'], data['saldo_awal_non_tunai'], bold: true);
      writeSummaryRow('Pendapatan', data['pendapatan_total'],
          data['pendapatan_tunai'], data['pendapatan_non_tunai'], bold: true);
      writeSummaryRow('Penambahan Kas', data['penambahan_total'],
          data['penambahan_tunai'], data['penambahan_non_tunai'], bold: true);
      writeSummaryRow('Pengurangan Kas', data['pengurangan_total'],
          data['pengurangan_tunai'], data['pengurangan_non_tunai'], bold: true);
      writeSummaryRow('Saldo Akhir', data['saldo_akhir_total'],
          data['saldo_akhir_tunai'], data['saldo_akhir_non_tunai'], bold: true);

      row += 1;

      // Transaction log section
      writeCell(0, row, 'RIWAYAT TRANSAKSI', style: headerStyle);
      row++;

      final headers = [
        'Tanggal',
        'Order ID',
        'Keterangan',
        'Tipe',
        'Cara Transaksi',
        'Nominal'
      ];
      for (int i = 0; i < headers.length; i++) {
        writeCell(i, row, headers[i], style: boldStyle);
      }
      row++;

      final List logs = data['logs'];
      for (var log in logs) {
        final nominal = double.tryParse(log.jumlah) ?? 0.0;
        writeCell(0, row, _formatDateTime(log.created_at));
        writeCell(1, row, log.order_id?.toString() ?? '-');
        writeCell(2, row, log.keterangan);
        writeCell(3, row, log.tipe);
        writeCell(4, row, log.cara_transaksi);
        writeCell(5, row, nominal);
        row++;
      }

      // Auto column widths (approximate)
      for (int i = 0; i < 6; i++) {
        sheet.setColumnWidth(i, 20);
      }

      // Save file
      final directory = await getTemporaryDirectory();
      final fileName =
          'Laporan_Kas_${data['store_name']}_${DateFormat('yyyyMMdd').format(widget.date.start)}.xlsx'
              .replaceAll(' ', '_');
      final filePath = '${directory.path}/$fileName';
      final fileBytes = excelFile.encode();

      if (fileBytes == null) throw Exception('Gagal encode file excel');

      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      // Share / open
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Laporan Kas ${data['store_name']}',
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

  /// Memuat Data Toko, Saldo Awal, Saldo Periode Ini, dan Log Mutasi
  Future<Map<String, dynamic>> _loadData() async {
    // 1. Fetch Nama Toko
    final StoreModel? store = await storeService.fetchStoreWithId(widget.store_id);

    // 2. Fetch Saldo Awal (Mutasi Sebelum Tanggal Start)
    final List<CashFlowModel> pastFlows = await cashFlowService.getCashFlows(
      storeId: widget.store_id,
      endDate: widget.date.start.subtract(const Duration(seconds: 1)),
    );

    double saldoAwalTunai = 0;
    double saldoAwalNonTunai = 0;

    for (var item in pastFlows) {
      final nominal = double.tryParse(item.jumlah) ?? 0.0;
      final isTunai = item.cara_transaksi.toUpperCase() == 'CASH' ||
          item.cara_transaksi.toUpperCase() == 'TUNAI';

      if (item.tipe.toUpperCase() == 'MASUK') {
        if (isTunai) saldoAwalTunai += nominal; else saldoAwalNonTunai += nominal;
      } else {
        if (isTunai) saldoAwalTunai -= nominal; else saldoAwalNonTunai -= nominal;
      }
    }

    // 3. Fetch Mutasi Periode Terpilih
    final List<CashFlowModel> periodFlows = await cashFlowService.getCashFlows(
      storeId: widget.store_id,
      startDate: widget.date.start,
      endDate: widget.date.end,
    );

    double pendapatanTunai = 0;
    double pendapatanNonTunai = 0;

    double penambahanTunai = 0;
    double penambahanNonTunai = 0;

    double penguranganTunai = 0;
    double penguranganNonTunai = 0;

    for (var item in periodFlows) {
      final nominal = double.tryParse(item.jumlah) ?? 0.0;
      final isTunai = item.cara_transaksi.toUpperCase() == 'CASH' ||
          item.cara_transaksi.toUpperCase() == 'TUNAI';

      if (item.tipe.toUpperCase() == 'MASUK') {
        if (item.order_id != null) {
          // Pendapatan dari Order Laundry
          if (isTunai) pendapatanTunai += nominal; else pendapatanNonTunai += nominal;
        } else {
          // Penambahan Kas (seperti Tambah Modal)
          if (isTunai) penambahanTunai += nominal; else penambahanNonTunai += nominal;
        }
      } else if (item.tipe.toUpperCase() == 'KELUAR') {
        // Pengurangan Kas Operasional
        if (isTunai) penguranganTunai += nominal; else penguranganNonTunai += nominal;
      }
    }

    // 4. Kalkulasi Saldo Akhir
    final double saldoAkhirTunai =
        saldoAwalTunai + pendapatanTunai + penambahanTunai - penguranganTunai;
    final double saldoAkhirNonTunai =
        saldoAwalNonTunai + pendapatanNonTunai + penambahanNonTunai - penguranganNonTunai;

    return {
      'store_name': store?.store_name ?? 'Outlet',
      'saldo_awal_tunai': saldoAwalTunai,
      'saldo_awal_non_tunai': saldoAwalNonTunai,
      'saldo_awal_total': saldoAwalTunai + saldoAwalNonTunai,

      'pendapatan_tunai': pendapatanTunai,
      'pendapatan_non_tunai': pendapatanNonTunai,
      'pendapatan_total': pendapatanTunai + pendapatanNonTunai,

      'penambahan_tunai': penambahanTunai,
      'penambahan_non_tunai': penambahanNonTunai,
      'penambahan_total': penambahanTunai + penambahanNonTunai,

      'pengurangan_tunai': penguranganTunai,
      'pengurangan_non_tunai': penguranganNonTunai,
      'pengurangan_total': penguranganTunai + penguranganNonTunai,

      'saldo_akhir_tunai': saldoAkhirTunai,
      'saldo_akhir_non_tunai': saldoAkhirNonTunai,
      'saldo_akhir_total': saldoAkhirTunai + saldoAkhirNonTunai,

      'logs': periodFlows,
    };
  }

  String _formatRupiah(double number) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(number);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return DateFormat('dd/MM/yyyy - HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final periodText =
        "${_formatDate(widget.date.start)} - ${_formatDate(widget.date.end)}";

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Gagal memuat data: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final data = snapshot.data!;
            final List<CashFlowModel> logs = data['logs'];

            return SingleChildScrollView(
              child: Column(
                children: [
                  UpperBarExcel(title: "LAPORAN KAS", isExporting: _isExporting, onExport: ()=>_exportToExcel(data),),

                  // CARD 1: RINGKASAN SALDO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildRowInfo("Outlet", data['store_name']),
                            _buildRowInfo("Periode", periodText),
                            const Divider(color: Colors.grey, height: 24),

                            _buildRowInfo("Saldo Awal", _formatRupiah(data['saldo_awal_total']), isBold: true),
                            _buildRowSubInfo("Tunai", _formatRupiah(data['saldo_awal_tunai'])),
                            _buildRowSubInfo("Non-Tunai", _formatRupiah(data['saldo_awal_non_tunai'])),
                            const SizedBox(height: 12),

                            _buildRowInfo("Pendapatan", _formatRupiah(data['pendapatan_total']), isBold: true),
                            _buildRowSubInfo("Tunai", _formatRupiah(data['pendapatan_tunai'])),
                            _buildRowSubInfo("Non-Tunai", _formatRupiah(data['pendapatan_non_tunai'])),
                            const SizedBox(height: 12),

                            _buildRowInfo("Penambahan Kas", _formatRupiah(data['penambahan_total']), isBold: true),
                            _buildRowSubInfo("Tunai", _formatRupiah(data['penambahan_tunai'])),
                            _buildRowSubInfo("Non-Tunai", _formatRupiah(data['penambahan_non_tunai'])),
                            const SizedBox(height: 12),

                            _buildRowInfo("Pengurangan Kas", _formatRupiah(data['pengurangan_total']), isBold: true),
                            _buildRowSubInfo("Tunai", _formatRupiah(data['pengurangan_tunai'])),
                            _buildRowSubInfo("Non-Tunai", _formatRupiah(data['pengurangan_non_tunai'])),
                            const SizedBox(height: 12),

                            const Divider(color: Colors.grey),
                            _buildRowInfo("Saldo Akhir", _formatRupiah(data['saldo_akhir_total']), isBold: true),
                            _buildRowSubInfo("Tunai", _formatRupiah(data['saldo_akhir_tunai'])),
                            _buildRowSubInfo("Non-Tunai", _formatRupiah(data['saldo_akhir_non_tunai'])),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // CARD 2: LIST LOG TRANSAKSI KAS
                  if (logs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text("Tidak ada riwayat transaksi kas pada periode ini.",
                          style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final isMasuk = log.tipe.toUpperCase() == 'MASUK';
                        final double nominal = double.tryParse(log.jumlah) ?? 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                                        Text(_formatDateTime(log.created_at),
                                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text(
                                          log.order_id != null ? "Pendapatan Order" : log.keterangan,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                        const SizedBox(height: 4),
                                        if (log.order_id != null)
                                          Text("Order ID: #${log.order_id}",
                                              style: const TextStyle(color: Colors.black)),
                                        Text("Keterangan: ${log.keterangan}",
                                            style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${isMasuk ? '+' : '-'} ${_formatRupiah(nominal)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isMasuk ? Colors.green[700] : Colors.red[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        log.cara_transaksi,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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

  // --- WIDGET HELPER ---
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

  Widget _buildRowSubInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}