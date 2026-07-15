import 'package:app_laundry/Screens/Pesanan.dart';
import 'package:app_laundry/Screens/laporan.dart';
import 'package:app_laundry/Screens/settings.dart';
import 'package:app_laundry/Widgets/outletDropdown.dart';
import 'customers.dart';
import 'addCustomer.dart';
import 'navigationBar.dart';
import 'package:app_laundry/Widgets/customOutlinedButton.dart';
import 'addOutlet.dart';
import 'addPesanan.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  // Tambahkan parameter konstruktor baru
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
  // Hapus variabel lokal "selectedOutlet = 'N2Jewel'" karena datanya sekarang dikontrol oleh parent

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
                        // AKTIFKAN KEMBALI: Salurkan data state & callback dari parent
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
                Card(
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
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Rp. xxx.xxx",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                Text( 
                                  "x pesanan",
                                  style: TextStyle(fontSize: 14, color: Colors.black54),
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
                            _buildStatItem("xx.x kg", "Kiloan"),
                            _buildStatItem("xx.x pcs", "Satuan"),
                            _buildStatItem("xx.x m", "Meteran"),
                          ],
                        ),
                      )
                    ],
                  ),
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AddPesananScreen(store_id: widget.selectedStoreId,)));
                          },
                        ),
                        MenuActionButton(
                          icon: Icons.search,
                          label: "Cari\nPesanan",
                          onTap: () {
                            // SINKRONISASI: Pastikan parameter owner_id tetap terlempar saat berpindah halaman via pushReplacement
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => MainNavigationScreen(
                                  currentPageIndex: 1, 
                                  owner_id: '', // Masukkan owner_id yang sesuai
                                )
                              )
                            );
                          },
                        ),
                        MenuActionButton(
                          icon: Icons.person_add,
                          label: "Tambah\nPelanggan",
                          onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => AddCustomerScreen(store_id: widget.selectedStoreId,)));},
                        ),
                        MenuActionButton(
                          icon: Icons.person_search,
                          label: "Cari\nPelanggan",
                          onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerScreen(store_id: widget.selectedStoreId,)));},
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }
}