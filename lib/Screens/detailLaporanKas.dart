import 'package:app_laundry/Models/cashFlowModel.dart';
import 'package:app_laundry/Models/storeModel.dart';
import 'package:app_laundry/Services/cashFlow_service.dart';
import 'package:app_laundry/Services/store_service.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                  const UpperBar2(title: "LAPORAN KAS"),

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