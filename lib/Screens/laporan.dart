import 'dart:async';
import 'package:app_laundry/Screens/addCash.dart';
import 'package:app_laundry/Screens/subCash.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBar.dart'; 
import 'package:app_laundry/Widgets/customDialog.dart'; // Pastikan dialog kustom Anda diimpor dari sini

class LaporanScreen extends StatefulWidget {
  // 1. Tambahkan parameter untuk menampung state global
  final String? selectedStoreId;
  final ValueChanged<String?> onStoreChanged;


  const LaporanScreen({super.key, this.selectedStoreId, required this.onStoreChanged,});

  @override
  _LaporanScreenState createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  // Hapus variabel lokal 'String selectedOutlet = "N2Jewel";'

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
                // 2. Gunakan data dari widget parent
                selectedOutlet: widget.selectedStoreId ?? "Pilih Outlet",
                onOutletChanged: widget.onStoreChanged
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddCashScreen()));
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SubCashScreen()));
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

              // SECTION 2 & 3: Detail Saldo Kas (Gunakan widget.currentStoreId untuk fetch data dari database Anda nanti)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Text(
                          "Saldo Kas",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
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
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: const [
                            Text("Rp. x.xxx.xxx", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            SizedBox(height: 22), 
                            Text("Rp. xx.xxx.xxx", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // SECTION 4 & 5: Detail Data Pesanan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Text(
                          "Pesanan Hari ini",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
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
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: const [
                            Text("Rp. x.xxx.xxx", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            SizedBox(height: 22), 
                            Text("xx Pesanan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            SizedBox(height: 22), 
                            Text("x Pesanan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            SizedBox(height: 22), 
                            Text("Rp. xx.xxx.xxx", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // SECTION 6 & 7: Daftar Menu Laporan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Text(
                          "Lihat Laporan",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              _buildMenuLaporan(
                icon: Icons.monetization_on_outlined,
                title: "Laporan Kas",
                subtitle: "Laporan Mutasi Kas",
                dialog: CustomDateRangeDialogKas(
                  onSubmit: (DateTimeRange periode) {
                    print("Toko Aktif: ${widget.selectedStoreId} | Periode: ${periode.start} - ${periode.end}");
                  },
                ),
              ),
              _buildMenuLaporan(
                icon: Icons.list_alt_sharp,
                title: "Laporan Pesanan",
                subtitle: "Laporan Data Pesanan",
                dialog: CustomDateRangeDialogPesanan(
                  onSubmit: (DateTimeRange periode) {},
                ),
              ),
              _buildMenuLaporan(
                icon: Icons.people,
                title: "Analisa Pelanggan",
                subtitle: "Analisa Data Pelanggan",
                dialog: CustomDateRangeDialogPelanggan(
                  onSubmit: (DateTimeRange periode) {},
                ),
              ),
              _buildMenuLaporan(
                icon: Icons.dry_cleaning,
                title: "Laporan Layanan",
                subtitle: "Analisa Data Layanan",
                dialog: CustomDateRangeDialogLayanan(
                  onSubmit: (DateTimeRange periode) {},
                ),
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