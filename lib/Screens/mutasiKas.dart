import 'package:app_laundry/Models/cashFlowModel.dart';
import 'package:app_laundry/Models/storeModel.dart';
import 'package:app_laundry/Services/cashFlow_service.dart';
import 'package:app_laundry/Services/store_service.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MutasiKasScreen extends StatefulWidget {
  final String store_id;
  final DateTimeRange date;

  const MutasiKasScreen({
    super.key,
    required this.date,
    required this.store_id,
  });

  @override
  State<MutasiKasScreen> createState() => _MutasiKasScreenState();
}

class _MutasiKasScreenState extends State<MutasiKasScreen> {
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

    // 3. Fetch Mutasi Periode Terpilih
    final List<CashFlowModel> periodFlows = await cashFlowService.getCashFlows(
      storeId: widget.store_id,
      startDate: widget.date.start,
      endDate: widget.date.end,
    );

    return {
      'store_name': store?.store_name ?? 'Outlet',
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
                  const UpperBar2(title: "MUTASI KAS"),

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
}