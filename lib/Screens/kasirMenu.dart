import 'package:app_laundry/Models/kasirModel.dart';
import 'package:app_laundry/Models/storeModel.dart';
import 'package:app_laundry/Screens/addPesanan.dart';
import 'package:app_laundry/Screens/customers.dart';
import 'package:app_laundry/Screens/dashboardKasir.dart';
import 'package:app_laundry/Screens/kasirNavigation.dart';
import 'package:app_laundry/Services/auth_service.dart';
import 'package:app_laundry/Services/kasir_service.dart';
import 'package:app_laundry/Services/orderDetail_service.dart';
import 'package:app_laundry/Services/order_service.dart';
import 'package:app_laundry/Services/store_service.dart';
import 'package:app_laundry/Widgets/customDialog.dart';
import 'package:flutter/material.dart';

class KasirMenuScreen extends StatefulWidget {
  final String store_id;
  final String cashier_id;
  const KasirMenuScreen({super.key, required this.store_id, required this.cashier_id});

  @override
  State<KasirMenuScreen> createState() => _KasirMenuScreenState();
}

class _KasirMenuScreenState extends State<KasirMenuScreen> {
  final orderService = OrderService();
  final orderDetailService = OrderDetailService();
  final cashierService = KasirService();
  final storeService = StoreService();

  // Changed from `late final` to nullable: async fetches can't guarantee
  // these are set before the first build() call, so `late final` throws
  // LateInitializationError on first render. Nullable + setState() lets
  // build() check for null and show a loading state instead of crashing.
  KasirModel? kasirModel;
  StoreModel? storeModel;

  Future<List<dynamic>>? _combinedFuture;

  final authService = AuthService();

  void logout() async {
    await authService.signOut();
  }

  void fetchOrder() {
    final storeId = widget.store_id;
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
          widget.store_id,
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

  void fetchCashier() async {
    try {
      final result = await cashierService.fetchOneCashier(widget.cashier_id);
      if (mounted) {
        setState(() {
          kasirModel = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengambil data kasir, error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void fetchStore() async {
    try {
      final result = await storeService.fetchStoreWithId(widget.store_id);
      if (mounted) {
        setState(() {
          storeModel = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengambil data toko, error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCashier();
    fetchStore(); // was missing before — this is what caused the crash
    fetchOrder();
  }

  @override
  void didUpdateWidget(covariant KasirMenuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store_id != widget.store_id) {
      fetchOrder();
      fetchStore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: (storeModel == null || kasirModel == null)
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.amber),
                          ),
                        )
                      : Row(
                          children: [
                            const Icon(Icons.store),
                            Column(
                              children: [
                                Text(storeModel!.store_name ?? '-'),
                                Text(storeModel!.address ?? '-'),
                                Text(storeModel!.phone_number ?? '-'),
                              ],
                            ),
                            Card(
                              child: Row(
                                children: [
                                  Text(kasirModel!.cashier_name),
                                  const Icon(Icons.online_prediction),
                                ],
                              ),
                            )
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
                                    '')
                                .toString()
                                .toLowerCase();

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

              _buildMenuItem(
                icon: Icons.add_shopping_cart,
                title: "Tambah Pesanan",
                subtitle: "Buat Pesanan Baru",
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddPesananScreen(store_id: widget.store_id)));
                },
              ),
              _buildMenuItem(
                icon: Icons.search,
                title: "Cari Pesanan",
                subtitle: "Pencarian Pesanan",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => KasirNavigationScreen(currentPageIndex: 0, store_id: widget.store_id, cashier_id: widget.cashier_id,)));
                },
              ),
              _buildMenuItem(
                icon: Icons.people_alt_outlined,
                title: "Data Pelanggan",
                subtitle: "Kelola Data Pelanggan",
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => CustomerScreen(store_id: widget.store_id)));
                },
              ),
              _buildMenuItem(
                icon: Icons.monetization_on_outlined,
                title: "Laporan Kas",
                subtitle: "Laporan Mutasi Kas",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => CustomDateRangeDialogMutasi(
                      onSubmit: (DateTimeRange periode) {
                        print("Toko Aktif: ${widget.store_id} | Periode: ${periode.start} - ${periode.end}");
                      },
                      store_id: widget.store_id,
                    ),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.power_settings_new,
                title: "Keluar Akun",
                subtitle: "Keluar Dari Akun Kasir",
                onTap: () {
                  logout();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

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

  // Shared menu item style — same look used across the whole menu list
  // (icon-in-amber-box + title/subtitle + chevron), so every entry (Tambah
  // Pesanan, Cari Pesanan, Data Pelanggan, Laporan Kas, Keluar Akun) is
  // visually consistent instead of some using Card+IconButton and others
  // using ListTile.
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(6.0)),
            child: Icon(icon, color: Colors.black87),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.black38, fontSize: 12, fontStyle: FontStyle.italic)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}