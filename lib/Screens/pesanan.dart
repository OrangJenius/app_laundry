import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBar.dart';
import 'rincianPesanan.dart';
import 'addPesanan.dart';

class PesananScreen extends StatefulWidget {
  @override
  _PesananScreenState createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  String selectedOutlet = "N2Jewel"; 

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the Scaffold with DefaultTabController (3 tabs total)
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[900], 
        body: SafeArea(
          child: Column(
            children: [
              UpperBar(
                title: "P E S A N A N",
                selectedOutlet: selectedOutlet,
                onOutletChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedOutlet = newValue; 
                    });
                  }
                },
              ),
              // --- SEARCH & ADD ACTION BAR ---
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
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddPesananScreen()));
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
              
              // --- 2. THE NEW TABBAR WIDGET ---
              TabBar(
                labelColor: Colors.amber[700],
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: Colors.amber[700],
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(icon: Icon(Icons.local_shipping), text: "Ambil"),
                  Tab(icon: Icon(Icons.check_circle_outline), text: "Siap Ambil"),
                  Tab(icon: Icon(Icons.money_off), text: "Belum Bayar"),
                ],
              ),
              
              const SizedBox(height: 8),

              // --- 3. THE TABBARVIEW (Displays content per tab) ---
              Expanded(
                child: TabBarView(
                  children: [
                    // View Content for Tab 1: Ambil
                    ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [_buildLaundryItemCard("Antrian", "Lunas - Tunai")],
                    ),
                    // View Content for Tab 2: Siap Ambil
                    ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [_buildLaundryItemCard("Selesai", "Lunas - QCRIS")],
                    ),
                    // View Content for Tab 3: Belum Bayar
                    ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [_buildLaundryItemCard("Proses", "Belum Bayar")],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Refactored your laundry row item into a clean custom Card structure
  Widget _buildLaundryItemCard(String statusTag, String paymentStatus) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => RincianPesananScreen()));
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
                      "Reguler", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800], fontSize: 16),
                    ),
                    const Text(
                      "Nota-xxxxxxx.xxxx.xxx.xxx.xx",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.local_laundry_service, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("JOHN DOE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            Text("Masuk: xx/xx/xxxx - xx:xx", style: TextStyle(color: Colors.black54, fontSize: 12)),
                            Text("Est Selesai: xx jam lagi", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
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
                  const Text("Rp. xxx.xxx", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  Text(paymentStatus, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}