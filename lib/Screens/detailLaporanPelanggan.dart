import 'package:app_laundry/Models/customerModel.dart';
import 'package:app_laundry/Services/customer_service.dart';
import 'package:app_laundry/Services/order_service.dart';
import 'package:app_laundry/Services/store_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

// Model penampung ringkasan data analisis pelanggan
class CustomerReportData {
  final String storeName;
  final int totalCustomers;
  final int newCustomersCount;
  final String topOrderCustomerName;
  final int topOrderCount;
  final String topValueCustomerName;
  final double topValueTotal;

  CustomerReportData({
    required this.storeName,
    required this.totalCustomers,
    required this.newCustomersCount,
    required this.topOrderCustomerName,
    required this.topOrderCount,
    required this.topValueCustomerName,
    required this.topValueTotal,
  });
}

class DetailLaporanPelangganScreen extends StatefulWidget {
  final DateTimeRange date;
  final String store_id;

  const DetailLaporanPelangganScreen({
    super.key,
    required this.date,
    required this.store_id,
  });

  @override
  State<DetailLaporanPelangganScreen> createState() => _DetailLaporanPelangganScreenState();
}

class _DetailLaporanPelangganScreenState extends State<DetailLaporanPelangganScreen> {
  final customerService = CustomerService();
  final orderService = OrderService();
  final storeService = StoreService();

  late Future<CustomerReportData> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _fetchAndProcessData();
  }

  /// Memuat & memproses analisis data pelanggan secara otomatis
  Future<CustomerReportData> _fetchAndProcessData() async {
    // 1. Ambil data secara paralel menggunakan Future.wait
    final results = await Future.wait([
      storeService.fetchStoreName(widget.store_id),
      customerService.fetchCustomers(widget.store_id),
      orderService.fetchOrdersByStoreAndDate(
        widget.store_id,
        widget.date.start,
        widget.date.end,
      ),
    ]);

    final String storeName = results[0] as String;
    final List<Customer> allCustomers = results[1] as List<Customer>;
    final List<Map<String, dynamic>> ordersInPeriod = results[2] as List<Map<String, dynamic>>;

    // 2. Hitung Pelanggan Baru (Pelanggan yang dibuat/didaftarkan pada rentang periode)
    final startIso = DateTime(widget.date.start.year, widget.date.start.month, widget.date.start.day, 0, 0, 0);
    final endIso = DateTime(widget.date.end.year, widget.date.end.month, widget.date.end.day, 23, 59, 59);

    int newCustomersCount = 0;
    for (var cust in allCustomers) {
      // Jika model customer memiliki created_at
      if (cust.toMap().containsKey('created_at') && cust.toMap()['created_at'] != null) {
        final createdAt = DateTime.tryParse(cust.toMap()['created_at'].toString());
        if (createdAt != null && createdAt.isAfter(startIso.subtract(const Duration(seconds: 1))) && createdAt.isBefore(endIso.add(const Duration(seconds: 1)))) {
          newCustomersCount++;
        }
      }
    }

    // 3. Akumulasi Transaksi per Pelanggan dalam Periode
    final Map<String, int> orderCountMap = {}; // customer_id -> jumlah transaksi
    final Map<String, double> orderValueMap = {}; // customer_id -> total rupiah
    final Map<String, String> customerNameMap = {}; // customer_id -> nama pelanggan

    for (var order in ordersInPeriod) {
      final custId = order['customer_id']?.toString();
      final totalHarga = double.tryParse(order['total_harga']?.toString() ?? '0') ?? 0.0;
      
      // Ambil nama dari relasi customer jika ada
      String custName = 'Tidak Diketahui';
      if (order['customer'] != null && order['customer']['nama'] != null) {
        custName = order['customer']['nama'].toString();
      }

      if (custId != null) {
        customerNameMap[custId] = custName;
        orderCountMap[custId] = (orderCountMap[custId] ?? 0) + 1;
        orderValueMap[custId] = (orderValueMap[custId] ?? 0.0) + totalHarga;
      }
    }

    // 4. Cari Pelanggan dengan Jumlah Pesanan Terbanyak
    String topOrderCustName = "-";
    int maxOrderCount = 0;

    orderCountMap.forEach((custId, count) {
      if (count > maxOrderCount) {
        maxOrderCount = count;
        topOrderCustName = customerNameMap[custId] ?? "-";
      }
    });

    // 5. Cari Pelanggan dengan Nilai Pesanan Terbanyak (Omzet Rp)
    String topValueCustName = "-";
    double maxValueTotal = 0.0;

    orderValueMap.forEach((custId, value) {
      if (value > maxValueTotal) {
        maxValueTotal = value;
        topValueCustName = customerNameMap[custId] ?? "-";
      }
    });

    return CustomerReportData(
      storeName: storeName,
      totalCustomers: allCustomers.length,
      newCustomersCount: newCustomersCount,
      topOrderCustomerName: topOrderCustName,
      topOrderCount: maxOrderCount,
      topValueCustomerName: topValueCustName,
      topValueTotal: maxValueTotal,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: FutureBuilder<CustomerReportData>(
          future: _reportFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Terjadi kesalahan saat memuat laporan: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final data = snapshot.data;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Judul Halaman
                  UpperBar2(title: "LAPORAN PELANGGAN"),

                  // CARD 1: RINGKASAN DATA OUTLET & PERIODE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildRowInfo("Outlet", data?.storeName ?? "-", isBold: true),
                            _buildRowInfo("Periode", _formatDateRange(widget.date), isBold: true),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // CARD 2: ANALISA PELANGGAN
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // 1. Pelanggan Baru
                            _buildRowAnalisa(
                              title: "Pelanggan Baru",
                              subtitle: null,
                              rightTitle: "${data?.newCustomersCount ?? 0} Orang",
                              rightSubtitle: null,
                            ),
                            const Divider(color: Colors.grey, height: 24),

                            // 2. Total Pelanggan
                            _buildRowAnalisa(
                              title: "Total Pelanggan",
                              subtitle: null,
                              rightTitle: "${data?.totalCustomers ?? 0} Orang",
                              rightSubtitle: null,
                            ),
                            const Divider(color: Colors.grey, height: 24),

                            // 3. Pelanggan Jumlah Pesanan Terbanyak
                            _buildRowAnalisa(
                              title: "Pelanggan Dengan",
                              subtitle: "Jumlah Pesanan Terbanyak",
                              rightTitle: data?.topOrderCustomerName ?? "-",
                              rightSubtitle: "${data?.topOrderCount ?? 0} pesanan",
                            ),
                            const Divider(color: Colors.grey, height: 24),

                            // 4. Pelanggan Nilai Pesanan Terbanyak
                            _buildRowAnalisa(
                              title: "Pelanggan Dengan",
                              subtitle: "Nilai Pesanan Terbanyak",
                              rightTitle: data?.topValueCustomerName ?? "-",
                              rightSubtitle: _formatRupiah(data?.topValueTotal ?? 0.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET HELPER 1: Info Baris Tunggal ---
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

  // --- WIDGET HELPER 2: Baris Analisa Ber-bullet ---
  Widget _buildRowAnalisa({
    required String title,
    String? subtitle,
    required String rightTitle,
    String? rightSubtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indikator Bullet Amber
        Container(
          margin: const EdgeInsets.only(top: 6, right: 10),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
        ),

        // Kotak Teks Kiri
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black, fontSize: 14)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),

        // Kotak Teks Kanan
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              rightTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
            ),
            if (rightSubtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                rightSubtitle,
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ],
        ),
      ],
    );
  }
}