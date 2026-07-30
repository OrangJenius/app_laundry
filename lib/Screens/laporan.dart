import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:app_laundry/Screens/addCash.dart';
import 'package:app_laundry/Screens/subCash.dart';
import 'package:app_laundry/Services/orderStatus_service.dart';
import 'package:app_laundry/Services/order_service.dart';
import 'package:app_laundry/Services/transaksi_service.dart';
import 'package:app_laundry/Widgets/customUpperBar.dart'; 
import 'package:app_laundry/Widgets/customDialog.dart';

class LaporanScreen extends StatefulWidget {
  final String? selectedStoreId;
  final ValueChanged<String?> onStoreChanged;

  const LaporanScreen({
    super.key, 
    this.selectedStoreId, 
    required this.onStoreChanged,
  });

  @override
  _LaporanScreenState createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _orderService = OrderService();
  final _transaksiService = TransaksiService();
  final _orderStatusService = OrderStatusService();

  late Future<Map<String, dynamic>> _reportDataFuture;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID', 
    symbol: 'Rp ', 
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  @override
  void didUpdateWidget(covariant LaporanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedStoreId != widget.selectedStoreId) {
      _loadReportData();
    }
  }

  void _loadReportData() {
    setState(() {
      _reportDataFuture = _fetchAllReportData();
    });
  }

  Future<Map<String, dynamic>> _fetchAllReportData() async {
    final storeId = widget.selectedStoreId;
    if (storeId == null || storeId.isEmpty) {
      return {
        'saldoTunai': 0.0,
        'saldoNonTunai': 0.0,
        'nilaiPesanan': 0.0,
        'jumlahPesanan': 0,
        'pesananBatal': 0,
        'totalBelumBayar': 0.0,
      };
    }

    final now = DateTime.now();

    // Fetch transactions & orders in parallel
    final results = await Future.wait([
      _transaksiService.fetchStoreTransaksi(storeId),
      _transaksiService.fetchTransaksiNow(storeId, now),
      _orderService.fetchOrderNow(storeId, now),
    ]);

    final List<dynamic> allStoreTransaksi = results[0];
    final List<dynamic> transaksiNow = results[1];
    final List<dynamic> orderNow = results[2];

    // Get order IDs to query their status
    final List<String> orderNowIds = orderNow
        .map((e) => e['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    List<dynamic> orderStatuses = [];
    if (orderNowIds.isNotEmpty) {
      orderStatuses = await _orderStatusService.fetchOrderStatusByOrderIds(orderNowIds);
    }

    // 1. Saldo Tunai & Non-Tunai (Calculated from all completed/paid store transactions)
    double saldoTunai = 0.0;
    double saldoNonTunai = 0.0;
    
    for (var tx in allStoreTransaksi) {
      final statusPembayaran = (tx['status_pembayaran'] ?? '').toString().toLowerCase();
      // Skip unpaid records when calculating current cash balance
      if (statusPembayaran == 'belum bayar') continue;

      final double amount = double.tryParse(tx['jumlah_transaksi']?.toString() ?? '0') ?? 0.0;
      final jenisPembayaran = (tx['jenis_pembayaran'] ?? '').toString().toLowerCase();

      if (jenisPembayaran.contains('tunai') || jenisPembayaran.contains('cash')) {
        saldoTunai += amount;
      } else if (jenisPembayaran.isNotEmpty) {
        saldoNonTunai += amount;
      }
    }

    // 2. Nilai Pesanan Hari Ini & Jumlah Pesanan
    double nilaiPesanan = 0.0;
    for (var ord in orderNow) {
      nilaiPesanan += double.tryParse(ord['total_harga']?.toString() ?? '0') ?? 0.0;
    }
    int jumlahPesanan = orderNow.length;

    // 3. Pesanan Batal Hari Ini
    int pesananBatal = 0;
    for (var st in orderStatuses) {
      final status = (st['status_order'] ?? st['status'] ?? '').toString().toLowerCase();
      if (status == 'batal' || status == 'cancelled') {
        pesananBatal++;
      }
    }

    // 4. Total Belum Bayar
    double totalBelumBayar = 0.0;
    for (var tx in transaksiNow) {
      final statusPembayaran = (tx['status_pembayaran'] ?? '').toString().toLowerCase();
      if (statusPembayaran == 'belum bayar') {
        totalBelumBayar += double.tryParse(tx['jumlah_transaksi']?.toString() ?? '0') ?? 0.0;
      }
    }

    return {
      'saldoTunai': saldoTunai,
      'saldoNonTunai': saldoNonTunai,
      'nilaiPesanan': nilaiPesanan,
      'jumlahPesanan': jumlahPesanan,
      'pesananBatal': pesananBatal,
      'totalBelumBayar': totalBelumBayar,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar(
                title: "L A P O R A N",
                selectedOutlet: widget.selectedStoreId ?? "Pilih Outlet",
                onOutletChanged: widget.onStoreChanged,
              ),

              // SECTION 1: Tombol Penambahan & Pengurangan Kas
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddCashScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                            child: const Text(
                              "Penambahan Kas",
                              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SubCashScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
                            child: const Text(
                              "Pengurangan Kas",
                              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Dynamic content powered by FutureBuilder
              FutureBuilder<Map<String, dynamic>>(
                future: _reportDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator(color: Colors.amber)),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          "Gagal memuat data: ${snapshot.error}",
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data ?? {
                    'saldoTunai': 0.0,
                    'saldoNonTunai': 0.0,
                    'nilaiPesanan': 0.0,
                    'jumlahPesanan': 0,
                    'pesananBatal': 0,
                    'totalBelumBayar': 0.0,
                  };

                  return Column(
                    children: [
                      // SECTION 2 & 3: Detail Saldo Kas
                      _buildHeaderSection("Saldo Kas"),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.attach_money, color: Colors.black87),
                                        SizedBox(width: 8),
                                        Text("Saldo Tunai", style: TextStyle(color: Colors.black87)),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.monetization_on_outlined, color: Colors.black87),
                                        SizedBox(width: 8),
                                        Text("Saldo Non-Tunai", style: TextStyle(color: Colors.black87)),
                                      ],
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currencyFormatter.format(data['saldoTunai']),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    const SizedBox(height: 22),
                                    Text(
                                      currencyFormatter.format(data['saldoNonTunai']),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // SECTION 4 & 5: Detail Data Pesanan
                      _buildHeaderSection("Pesanan Hari ini"),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.money, color: Colors.black87),
                                        SizedBox(width: 8),
                                        Text("Nilai Pesanan", style: TextStyle(color: Colors.black87)),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.list_alt_sharp, color: Colors.black87),
                                        SizedBox(width: 8),
                                        Text("Jumlah Pesanan", style: TextStyle(color: Colors.black87)),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.cancel_presentation, color: Colors.black87),
                                        SizedBox(width: 8),
                                        Text("Pesanan Batal", style: TextStyle(color: Colors.black87)),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.money_off, color: Colors.black87),
                                        SizedBox(width: 8),
                                        Text("Total Belum Bayar", style: TextStyle(color: Colors.black87)),
                                      ],
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currencyFormatter.format(data['nilaiPesanan']),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    const SizedBox(height: 22),
                                    Text(
                                      "${data['jumlahPesanan']}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    const SizedBox(height: 22),
                                    Text(
                                      "${data['pesananBatal']}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    const SizedBox(height: 22),
                                    Text(
                                      currencyFormatter.format(data['totalBelumBayar']),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // SECTION 6 & 7: Daftar Menu Laporan
              _buildHeaderSection("Lihat Laporan"),

              _buildMenuLaporan(
                icon: Icons.monetization_on_outlined,
                title: "Laporan Kas",
                subtitle: "Laporan Mutasi Kas",
                dialog: CustomDateRangeDialogKas(
                  onSubmit: (DateTimeRange periode) {
                    print("Toko Aktif: ${widget.selectedStoreId} | Periode: ${periode.start} - ${periode.end}");
                  }, store_id: widget.selectedStoreId!,
                ),
              ),
              _buildMenuLaporan(
                icon: Icons.list_alt_sharp,
                title: "Laporan Pesanan",
                subtitle: "Laporan Data Pesanan",
                dialog: CustomDateRangeDialogPesanan(
                  onSubmit: (DateTimeRange periode) {}, store_id: widget.selectedStoreId!,
                ),
              ),
              _buildMenuLaporan(
                icon: Icons.people,
                title: "Analisa Pelanggan",
                subtitle: "Analisa Data Pelanggan",
                dialog: CustomDateRangeDialogPelanggan(
                  onSubmit: (DateTimeRange periode) {}, store_id: widget.selectedStoreId!,
                ),
              ),
              _buildMenuLaporan(
                icon: Icons.dry_cleaning,
                title: "Laporan Layanan",
                subtitle: "Analisa Data Layanan",
                dialog: CustomDateRangeDialogLayanan(
                  onSubmit: (DateTimeRange periode) {}, store_id: widget.selectedStoreId!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Divider(color: Colors.grey[300], thickness: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuLaporan({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget dialog,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(6.0)),
            child: Icon(icon, color: Colors.black87),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.black38, fontSize: 12, fontStyle: FontStyle.italic)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => dialog,
            );
          },
        ),
      ),
    );
  }
}