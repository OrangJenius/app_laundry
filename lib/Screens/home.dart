import 'package:app_laundry/Screens/Pesanan.dart';
import 'package:app_laundry/Screens/laporan.dart';
import 'package:app_laundry/Screens/settings.dart';
import 'package:app_laundry/Services/orderDetail_service.dart';
import 'package:app_laundry/Services/order_service.dart';
import 'package:app_laundry/Widgets/outletDropdown.dart';
import 'customers.dart';
import 'addCustomer.dart';
import 'navigationBar.dart';
import 'package:app_laundry/Widgets/customOutlinedButton.dart';
import 'addOutlet.dart';
import 'addPesanan.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String? selectedStoreId;
  final ValueChanged<String?> onStoreChanged;

  const HomeScreen({
    super.key,
    required this.selectedStoreId,
    required this.onStoreChanged,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final orderService = OrderService();
  final orderDetailService = OrderDetailService();

  Future<List<dynamic>>? _combinedFuture;

  void fetchOrder() {
    final storeId = widget.selectedStoreId;
    if (storeId == null || storeId.isEmpty) {
      setState(() {
        _combinedFuture = null;
      });
      return;
    }

    setState(() {
      _combinedFuture = () async {
        // Step 1: Fetch Orders by Store ID for Today
        final orders = await orderService.fetchOrderNow(
          widget.selectedStoreId!,
          DateTime.now(),
        );

        if (orders.isEmpty) {
          return [<dynamic>[], <dynamic>[]];
        }

        // Step 2: Extract Order IDs cleanly as List<dynamic>
        final List<String> orderIds = orders.map((o) => o['id'].toString()).toList();

        // Step 3: Fetch related order details concurrently
        final results = await Future.wait([
          orderDetailService.fetchOrderDetailByOrderIds(orderIds),
        ]);

        return [orders, results[0]];
      }();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchOrder();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedStoreId != widget.selectedStoreId) {
      fetchOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- OUTLET SELECTOR SECTION ---
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutletDropdown(
                            selectedStoreId: widget.selectedStoreId,
                            onChanged: widget.onStoreChanged,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.black54),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddOutletScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- TODAY'S ORDERS SUMMARY CARD ---
                _combinedFuture == null
                    ? _buildSummaryCard(
                        totalRevenue: 0,
                        totalOrders: 0,
                        kiloanQty: 0.0,
                        satuanQty: 0.0,
                        meteranQty: 0.0,
                      )
                    : FutureBuilder<List<dynamic>>(
                        future: _combinedFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(color: Colors.amber),
                              ),
                            );
                          }

                          // Default fallback values if no orders exist
                          double totalRevenue = 0.0;
                          int totalOrders = 0;
                          double kiloanQty = 0.0;
                          double satuanQty = 0.0;
                          double meteranQty = 0.0;

                          if (snapshot.hasData && snapshot.data![0].isNotEmpty) {
                            final List<dynamic> orders = snapshot.data![0];
                            final List<dynamic> details = snapshot.data![1];

                            totalOrders = orders.length;

                            // 1. Calculate Total Revenue
                            for (var order in orders) {
                              final price = double.tryParse(order['total_harga']?.toString() ?? '0') ?? 0.0;
                              totalRevenue += price;
                            }

                            // 2. Aggregate quantities by unit name from order_detail
                            for (var detail in details) {
                              final qty = double.tryParse(detail['quantity']?.toString() ?? '0') ?? 0.0;
                              
                              // Check unit_name if joined, or service relationship
                              final unitName = (detail['unit']?['unit_name'] ?? 
                                                detail['service']?['unit']?['unit_name'] ?? 
                                                '').toString().toLowerCase();

                              if (unitName.contains('kg') || unitName.contains('kilo')) {
                                kiloanQty += qty;
                              } else if (unitName.contains('pcs') || unitName.contains('satuan')) {
                                satuanQty += qty;
                              } else if (unitName.contains('m') || unitName.contains('meter')) {
                                meteranQty += qty;
                              } else {
                                // Default backup fallback to pcs if unit is unmapped
                                satuanQty += qty;
                              }
                            }
                          }

                          return _buildSummaryCard(
                            totalRevenue: totalRevenue,
                            totalOrders: totalOrders,
                            kiloanQty: kiloanQty,
                            satuanQty: satuanQty,
                            meteranQty: meteranQty,
                          );
                        },
                      ),

                const SizedBox(height: 24),

                // --- QUICK ACTIONS GRID SECTION ---
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MenuActionButton(
                          icon: Icons.add,
                          label: "Tambah\nPesanan",
                          onTap: () {
                            if (widget.selectedStoreId == null || widget.selectedStoreId!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Silakan pilih outlet terlebih dahulu")),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPesananScreen(store_id: widget.selectedStoreId!),
                              ),
                            );
                          },
                        ),
                        MenuActionButton(
                          icon: Icons.search,
                          label: "Cari\nPesanan",
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainNavigationScreen(
                                  currentPageIndex: 1,
                                  owner_id: '',
                                ),
                              ),
                            );
                          },
                        ),
                        MenuActionButton(
                          icon: Icons.person_add,
                          label: "Tambah\nPelanggan",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCustomerScreen(store_id: widget.selectedStoreId),
                              ),
                            );
                          },
                        ),
                        MenuActionButton(
                          icon: Icons.person_search,
                          label: "Cari\nPelanggan",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerScreen(store_id: widget.selectedStoreId),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGET FOR SUMMARY CARD ---
  Widget _buildSummaryCard({
    required double totalRevenue,
    required int totalOrders,
    required double kiloanQty,
    required double satuanQty,
    required double meteranQty,
  }) {
    // Format numeric values cleanly
    final formattedRevenue = totalRevenue.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    return Card(
      color: Colors.amberAccent[100],
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber[700],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.list_alt_sharp, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pesanan",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      "Hari Ini",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Rp. $formattedRevenue",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      "$totalOrders pesanan",
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, color: Colors.black26, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("${kiloanQty.toStringAsFixed(1)} kg", "Kiloan"),
                _buildStatItem("${satuanQty.toStringAsFixed(0)} pcs", "Satuan"),
                _buildStatItem("${meteranQty.toStringAsFixed(1)} m", "Meteran"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }
}