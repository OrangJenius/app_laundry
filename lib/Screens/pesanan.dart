import 'package:app_laundry/Screens/detailLaporanLayanan.dart';
import 'package:app_laundry/Screens/rincianPesanan.dart';
import 'package:app_laundry/Services/orderDetail_service.dart';
import 'package:app_laundry/Services/orderStatus_service.dart';
import 'package:app_laundry/Services/order_service.dart';
import 'package:app_laundry/Services/transaksi_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBar.dart';
import 'addPesanan.dart';

class PesananScreen extends StatefulWidget {
  final String? selectedStoreId;
  final ValueChanged<String?> onStoreChanged;

  const PesananScreen({
    super.key, 
    this.selectedStoreId, 
    required this.onStoreChanged,
  });

  @override
  _PesananScreenState createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  final orderService = OrderService();
  final orderDetailService = OrderDetailService();
  final orderStatusService = OrderStatusService();
  final transaksiService = TransaksiService();

  Future<List<dynamic>>? _combinedFuture;

  @override
  void initState() {
    super.initState();
    _fetchPesanan();
  }

  @override
  void didUpdateWidget(covariant PesananScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedStoreId != widget.selectedStoreId) {
      _fetchPesanan();
    }
  }

  void _fetchPesanan() {
    final storeId = widget.selectedStoreId;
    if (storeId == null || storeId.isEmpty) {
      setState(() {
        _combinedFuture = null;
      });
      return;
    }

    setState(() {
      _combinedFuture = () async {
        // Step 1: Fetch Orders by Store ID
        final orders = await orderService.fetchOrder(storeId);
        
        if (orders.isEmpty) {
          return [<dynamic>[], <dynamic>[], <dynamic>[], <dynamic>[]];
        }

        // Step 2: Extract Order IDs
        final List<String> orderIds = orders.map((o) => o['id'].toString()).toList();

        // Step 3: Fetch secondary data concurrently using Order IDs
        final results = await Future.wait([
          orderDetailService.fetchOrderDetailByOrderIds(orderIds),
          orderStatusService.fetchOrderStatusByOrderIds(orderIds),
          transaksiService.fetchTransaksiByOrderIds(orderIds),
        ]);

        return [orders, results[0], results[1], results[2]];
      }();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[900], 
        body: SafeArea(
          child: Column(
            children: [
              UpperBar(
                title: "P E S A N A N",
                selectedOutlet: widget.selectedStoreId ?? "Pilih Outlet",
                onOutletChanged: widget.onStoreChanged,
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: SearchBar(
                        hintText: "Cari pesanan...",
                        leading: Icon(Icons.search),
                        elevation: WidgetStatePropertyAll(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.selectedStoreId == null || widget.selectedStoreId!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Silakan pilih outlet terlebih dahulu")),
                          );
                          return;
                        }

                        await Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => AddPesananScreen(store_id: widget.selectedStoreId!),
                          ),
                        );
                        
                        _fetchPesanan();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              
              TabBar(
                labelColor: Colors.amber[700],
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: Colors.amber[700],
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(icon: Icon(Icons.local_shipping), text: "Antrian"),
                  Tab(icon: Icon(Icons.check_circle_outline), text: "Siap Ambil"),
                  Tab(icon: Icon(Icons.money_off), text: "Belum Bayar"),
                ],
              ),
              
              const SizedBox(height: 8),

              Expanded(
                child: _combinedFuture == null
                    ? const Center(
                        child: Text(
                          "Pilih outlet untuk menampilkan data",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : FutureBuilder<List<dynamic>>(
                        future: _combinedFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.amber),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                "Gagal memuat data: ${snapshot.error}",
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            );
                          }

                          final orders = List<Map<String, dynamic>>.from(snapshot.data?[0] ?? []);
                          final orderStatuses = List<Map<String, dynamic>>.from(snapshot.data?[2] ?? []);
                          final transactions = List<Map<String, dynamic>>.from(snapshot.data?[3] ?? []);

                          // Match status using order_id column name
                          String getLatestStatus(dynamic orderId) {
                            final matchedStatuses = orderStatuses.where(
                              (status) => status['order_id'].toString() == orderId.toString()
                            ).toList();

                            if (matchedStatuses.isEmpty) return 'Pending';
                            
                            matchedStatuses.sort((a, b) => 
                              (a['created_at'] ?? '').toString().compareTo((b['created_at'] ?? '').toString())
                            );
                            
                            return matchedStatuses.last['status_order'] ?? 'Pending';
                          }

                          // Match transaction using order_id column name
                          Map<String, dynamic>? getTransaction(dynamic orderId) {
                            final matched = transactions.where(
                              (trx) => trx['order_id'].toString() == orderId.toString()
                            ).toList();
                            return matched.isNotEmpty ? matched.first : null;
                          }

                          // Filtering Tabs logic
                          final antrianOrders = orders.where((order) {
                            final status = getLatestStatus(order['id']);
                            return status == 'Pending' || status == 'Proses';
                          }).toList();

                          final siapAmbilOrders = orders.where((order) {
                            final status = getLatestStatus(order['id']);
                            return status == 'Ready' || status == 'Siap Ambil';
                          }).toList();

                          final belumBayarOrders = orders.where((order) {
                            final status = getLatestStatus(order['id']);
                            final trx = getTransaction(order['id']);
                            final paymentStatus = trx?['status_transaksi'] ?? 'Belum Bayar';

                            return status == 'Selesai' && paymentStatus == 'Belum Bayar';
                          }).toList();

                          return TabBarView(
                            children: [
                              _buildOrderList(antrianOrders, getLatestStatus, getTransaction),
                              _buildOrderList(siapAmbilOrders, getLatestStatus, getTransaction),
                              _buildOrderList(belumBayarOrders, getLatestStatus, getTransaction),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(
    List<Map<String, dynamic>> orderList,
    String Function(dynamic) getLatestStatus,
    Map<String, dynamic>? Function(dynamic) getTransaction,
  ) {
    if (orderList.isEmpty) {
      return const Center(
        child: Text("Tidak ada pesanan", style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orderList.length,
      itemBuilder: (context, index) {
        final order = orderList[index];
        final orderId = order['id'];
        final statusTag = getLatestStatus(orderId);
        final transaction = getTransaction(orderId);

        final customerName = order['customer']?['nama'] ?? 'Pelanggan';
        final serviceDuration = order['duration']?['duration_name'] ?? 'Reguler';
        final totalPrice = order['total_harga']?.toString() ?? '0';
        final receipt = order['receipt']?.toString();
        
        final paymentStatus = transaction?['status_pembayaran'] ?? 'Belum Bayar';
        final paymentType = transaction?['jenis_pembayaran'] ?? '-';
        final paymentText = "$paymentStatus ${paymentType != '-' ? '• $paymentType' : ''}";

        final createdAtRaw = order['created_at']?.toString() ?? '';
        final entryTime = createdAtRaw.length >= 16 
            ? createdAtRaw.substring(0, 16).replaceAll('T', ' ') 
            : createdAtRaw;

        return _buildLaundryItemCard(
          orderId: orderId.toString(),
          serviceName: serviceDuration,
          customerName: customerName,
          entryTime: entryTime,
          statusTag: statusTag,
          totalPrice: totalPrice,
          paymentStatusText: paymentText,
          paymentType: paymentType,
          isPaid: paymentStatus == 'Lunas',
          receipt: receipt!,
        );
      },
    );
  }

  Widget _buildLaundryItemCard({
    required String orderId,
    required String serviceName,
    required String customerName,
    required String entryTime,
    required String statusTag,
    required String totalPrice,
    required String paymentStatusText,
    required String paymentType,
    required bool isPaid,
    required String receipt,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => RincianPesananScreen(store_id: widget.selectedStoreId!, order_id: orderId)),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      serviceName, 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800], fontSize: 16),
                    ),
                    Text(
                      receipt,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.local_laundry_service, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customerName, 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            Text(
                              "Masuk: $entryTime", 
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[100], 
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusTag,
                      style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Rp. $totalPrice", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  Text(
                    isPaid ? 
                    paymentStatusText: paymentStatusText, 
                    style: TextStyle(
                      color: isPaid ? Colors.green : Colors.red, 
                      fontSize: 12, 
                      fontWeight: FontWeight.w500,
                    ),
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