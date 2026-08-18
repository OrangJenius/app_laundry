import 'package:app_laundry/Models/kasirModel.dart';
import 'package:app_laundry/Models/storeModel.dart';
import 'package:app_laundry/Screens/addPesanan.dart';
import 'package:app_laundry/Screens/customers.dart';
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

  KasirModel? kasirModel;
  StoreModel? storeModel;

  Future<List<dynamic>>? _combinedFuture;

  final authService = AuthService();

  void logout() async {
    await authService.signOut();
  }

  void fetchOrder() {
    final storeId = widget.store_id;
    if (storeId.isEmpty) {
      setState(() {
        _combinedFuture = null;
      });
      return;
    }

    setState(() {
      _combinedFuture = () async {
        final orders = await orderService.fetchOrderNow(
          widget.store_id,
          DateTime.now(),
        );

        if (orders.isEmpty) {
          return [<dynamic>[], <dynamic>[]];
        }

        final List<String> orderIds = orders.map((o) => o['id'].toString()).toList();

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
    fetchStore();
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            children: [
              // --- CARD HEADER TOKO & KASIR (SUDAH DIRAPIKAN) ---
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: (storeModel == null || kasirModel == null)
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.amber),
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon Toko dengan aksen warna
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.store, color: Colors.amber, size: 26),
                            ),
                            const SizedBox(width: 12),

                            // Detail Info Toko
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    storeModel!.store_name ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    storeModel!.address ?? '-',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        storeModel!.phone_number ?? '-',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Badge Profil Kasir Online
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.account_circle, size: 16, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Text(
                                    kasirModel!.cashier_name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.circle, size: 8, color: Colors.green),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

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

                        double totalRevenue = 0.0;
                        int totalOrders = 0;
                        double kiloanQty = 0.0;
                        double satuanQty = 0.0;
                        double meteranQty = 0.0;

                        if (snapshot.hasData && snapshot.data![0].isNotEmpty) {
                          final List<dynamic> orders = snapshot.data![0];
                          final List<dynamic> details = snapshot.data![1];

                          totalOrders = orders.length;

                          for (var order in orders) {
                            final price = double.tryParse(order['total_harga']?.toString() ?? '0') ?? 0.0;
                            totalRevenue += price;
                          }

                          for (var detail in details) {
                            final qty = double.tryParse(detail['quantity']?.toString() ?? '0') ?? 0.0;

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

              const SizedBox(height: 20),

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
                      builder: (context) => KasirNavigationScreen(currentPageIndex: 0, store_id: widget.store_id, cashier_id: widget.cashier_id,)
                    )
                  );
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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