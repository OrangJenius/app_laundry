import 'package:flutter/material.dart';
// Sesuaikan dengan nama package asli Anda jika diperlukan
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class DetailLaporanPesananScreen extends StatefulWidget {
  final DateTimeRange date;
  const DetailLaporanPesananScreen({super.key, required this.date});

  @override
  State<DetailLaporanPesananScreen> createState() => _DetailLaporanPesananScreenState();
}

class _DetailLaporanPesananScreenState extends State<DetailLaporanPesananScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Judul Halaman
              UpperBar2(title: "LAPORAN PESANAN"),
              
              // CARD 1: RINGKASAN DATA PESANAN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  color: Colors.white, // Kontras dengan background gelap
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildRowInfo("Outlet", "N2Jewel"),
                        _buildRowInfo("Periode", "xx xxx xxxx - xx xxx xxx"),
                        const Divider(color: Colors.grey, height: 24),
                        
                        _buildRowInfo("Jumlah Pesanan", "x Pesanan", isBold: true),
                        _buildRowInfo("Nilai Pesanan", "Rp. xxx.xxx", isBold: true),
                        _buildRowSubInfo("Sudah Bayar", "Rp. xxx.xxx"),
                        _buildRowSubInfo("Belum Bayar", "Rp. xxx.xxx"),
                        const SizedBox(height: 12),

                        _buildRowInfo("Pesanan Batal", "x Pesanan", isBold: true),
                        _buildRowInfo("Nilai Pesanan Batal", "Rp. xxx.xxx"),
                        const SizedBox(height: 12),

                        _buildRowInfo("Total Antar-Jemput", "Rp. xxx.xxx", isBold: true),
                        _buildRowInfo("Total Diskon", "Rp. xxx.xxx", isBold: true),
                        _buildRowInfo("Total Kiloan", "xx Kg", isBold: true),
                        _buildRowInfo("Total Satuan", "xx pcs", isBold: true),
                        _buildRowInfo("Total Meteran", "x.xx m", isBold: true),
                      ],
                    ),
                  ),
                ),
              ),

              // CARD 2: LIST TRANSAKSI / LOG PESANAN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Atas sejajar
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
                            children: [
                              // Menghapus const dari parent karena Card ini menggunakan warna dinamis
                              Card(
                                color: Colors.amberAccent,
                                margin: EdgeInsets.zero,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  child: Text(
                                    "Status Pesanan", 
                                    style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "xx/xx/xxxx - xx:xx", 
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              const Text("Gladys : NOTA-xxxxx.x.xxxxx.xxx", style: TextStyle(color: Colors.black)),
                              const Text("Sinta", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end, // Rata kanan
                          children: const [
                            Text("Rp. xx.xxx", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
                            SizedBox(height: 4),
                            Text(
                              "Lunas - Non-Tunai", // Contoh teks statis yang disingkat agar rapi
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildRowInfo(String label, String value, {bool isBold = false}) {
    final style = TextStyle(
      color: Colors.black,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Dorong kiri-kanan
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildRowSubInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0), // Menjorok ke dalam
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}