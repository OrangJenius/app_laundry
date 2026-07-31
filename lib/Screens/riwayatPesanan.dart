import 'package:app_laundry/Models/customerModel.dart';
import 'package:app_laundry/Models/orderModel.dart';
import 'package:app_laundry/Models/transaksiModel.dart';
import 'package:app_laundry/Screens/rincianPesanan.dart';
import 'package:app_laundry/Services/customer_service.dart';
import 'package:app_laundry/Services/orderStatus_service.dart';
import 'package:app_laundry/Services/order_service.dart';
import 'package:app_laundry/Services/transaksi_service.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:flutter/material.dart';

class RiwayatPesananScreen extends StatefulWidget {
  final String store_id;
  final String customer_Id;

  const RiwayatPesananScreen({
    super.key,
    required this.store_id,
    required this.customer_Id,
  });

  @override
  State<RiwayatPesananScreen> createState() => _RiwayatPesananScreenState();
}

class _RiwayatPesananScreenState extends State<RiwayatPesananScreen> {
  final customerService = CustomerService();
  final orderService = OrderService();
  final transaksiService = TransaksiService();
  final orderStatusService = OrderStatusService();

  bool _isLoading = true;
  String? _errorMessage;

  Customer? _customer;
  List<OrderModel> _orders = [];
  Map<String, TransaksiModel?> _transaksiMap = {}; // Key: order_id
  Map<String, String> _orderStatusMap = {};       // Key: order_id -> latest status_order

  // Variable ringkasan
  int _totalHargaOrders = 0;
  int _totalLunas = 0;
  int _totalBelumBayar = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Fetch Data Customer
      final customers = await customerService.fetchCustomers(widget.store_id);
      final currentCustomer = customers.firstWhere(
        (c) => c.id == widget.customer_Id,
        orElse: () => Customer(
          id: widget.customer_Id,
          nama: 'Pelanggan Tidak Ditemukan',
          alamat: '',
          phoneNumber: '',
        ),
      );

      // 2. Fetch Orders berdasarkan store_id
      final rawOrders = await orderService.fetchOrder(widget.store_id);
      
      // Filter order khusus untuk customer_id ini
      List<OrderModel> customerOrders = rawOrders
          .map((map) => OrderModel.fromMap(map as Map<String, dynamic>))
          .where((order) => order.customer_id == widget.customer_Id)
          .toList();

      // 3. Fetch Data Transaksi & OrderStatus untuk setiap Order
      Map<String, TransaksiModel?> tempTransaksiMap = {};
      Map<String, String> tempOrderStatusMap = {};
      int tempTotalHarga = 0;
      int tempLunas = 0;
      int tempBelumBayar = 0;

      for (var order in customerOrders) {
        if (order.id != null) {
          // Fetch Transaksi
          final rawTransaksiList = await transaksiService.fetchTransaksi(order.id!);
          TransaksiModel? transaksi = rawTransaksiList.isNotEmpty ? rawTransaksiList.first : null;
          tempTransaksiMap[order.id!] = transaksi;

          // Fetch Order Status (Mengambil status paling terakhir/terbaru)
          final orderStatuses = await orderStatusService.fetchOrderStatus(order.id!);
          if (orderStatuses.isNotEmpty) {
            tempOrderStatusMap[order.id!] = orderStatuses.last.status_order;
          } else {
            tempOrderStatusMap[order.id!] = "Diproses";
          }

          // Hitung Ringkasan Pembayaran
          int harga = int.tryParse(order.total_harga) ?? 0;
          tempTotalHarga += harga;

          String statusPembayaran = (transaksi?.status_pembayaran ?? '').toLowerCase();
          if (statusPembayaran.contains('lunas') || statusPembayaran.contains('selesai')) {
            tempLunas += harga;
          } else {
            tempBelumBayar += harga;
          }
        }
      }

      setState(() {
        _customer = currentCustomer;
        _orders = customerOrders;
        _transaksiMap = tempTransaksiMap;
        _orderStatusMap = tempOrderStatusMap;
        _totalHargaOrders = tempTotalHarga;
        _totalLunas = tempLunas;
        _totalBelumBayar = tempBelumBayar;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            const UpperBar2(title: "Riwayat Pesanan"),
            
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Gagal memuat data:\n$_errorMessage",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // --- CARD RINGKASAN CUSTOMER ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildRowInfo("Pelanggan", _customer?.nama ?? "-", isBold: true),
                              _buildRowInfo("Jumlah Pesanan", "${_orders.length} Order"),
                              _buildRowInfo("Nilai Pesanan", _formatRupiah(_totalHargaOrders)),
                              _buildRowSubInfo("Lunas:", _formatRupiah(_totalLunas)),
                              _buildRowSubInfo("Belum Bayar:", _formatRupiah(_totalBelumBayar)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Center(
                      child: Text(
                        "*Diurutkan dari yang paling baru",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // --- LIST PESANAN ---
                    Expanded(
                      child: _orders.isEmpty
                          ? const Center(
                              child: Text(
                                "Belum ada riwayat pesanan",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                final transaksi = _transaksiMap[order.id];

                                // Status Pengerjaan dari OrderStatus
                                String orderStatus = _orderStatusMap[order.id] ?? "Diproses";
                                
                                // Status & Jenis Bayar dari Transaksi
                                String statusBayar = transaksi?.status_pembayaran ?? "Belum Bayar";
                                String jenisBayar = transaksi?.jenis_pembayaran ?? "-";
                                int totalHarga = int.tryParse(order.total_harga) ?? 0;

                                return InkWell(
                                  onTap: () {
                                    if (order.id != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RincianPesananScreen(
                                            store_id: widget.store_id,
                                            order_id: order.id!,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // BADGE WARNA BERDASARKAN ORDER STATUS
                                                  Card(
                                                    color: _getStatusColor(orderStatus),
                                                    margin: EdgeInsets.zero,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                      child: Text(
                                                        orderStatus,
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    order.created_at != null
                                                        ? order.created_at!.split('T').first
                                                        : "-",
                                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                  ),
                                                  Text(
                                                    "Resi: ${order.receipt ?? '-'}",
                                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                                  ),
                                                  Text(
                                                    _customer?.nama ?? "-",
                                                    style: const TextStyle(color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  _formatRupiah(totalHarga),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "$statusBayar - $jenisBayar",
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

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

  // Disesuaikan untuk Status Pesanan (OrderStatus)
  Color _getStatusColor(String status) {
    String lower = status.toLowerCase();
    if (lower.contains('selesai') || lower.contains('diambil')) {
      return Colors.greenAccent;
    } else if (lower.contains('proses') || lower.contains('cuci') || lower.contains('setrika')) {
      return Colors.lightBlueAccent;
    } else if (lower.contains('batal') || lower.contains('cancel')) {
      return Colors.redAccent.shade100;
    }
    return Colors.amberAccent; // Status awal seperti 'Baru' / 'Antrean'
  }

  String _formatRupiah(int uang) {
    return "Rp. ${uang.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}