import 'package:flutter/material.dart';
// Sesuaikan dengan nama package asli Anda jika diperlukan
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class DetailLaporanKasScreen extends StatefulWidget {
  const DetailLaporanKasScreen({super.key});

  @override
  State<DetailLaporanKasScreen> createState() => _DetailLaporanKasScreenState();
}

class _DetailLaporanKasScreenState extends State<DetailLaporanKasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Pastikan nama widget kustom Anda sesuai (UpperBar2 atau nama class-nya)
              UpperBar2(title: "LAPORAN KAS"),
              // CARD 1: RINGKASAN SALDO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  color: Colors.white, // Disesuaikan agar kontras dengan background gelap
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildRowInfo("Outlet", "N2Jewel"),
                        _buildRowInfo("Periode", "xx xxx xxxx - xx xxx xxx"),
                        const Divider(color: Colors.grey, height: 24), // Divider ditaruh di Column (Valid)
                        
                        _buildRowInfo("Saldo Awal", "Rp. xxx.xxx", isBold: true),
                        _buildRowSubInfo("Tunai", "Rp. xxx.xxx"),
                        _buildRowSubInfo("Non-Tunai", "Rp. xxx.xxx"),
                        const SizedBox(height: 12),

                        _buildRowInfo("Pendapatan", "Rp. xxx.xxx", isBold: true),
                        _buildRowSubInfo("Tunai", "Rp. xxx.xxx"),
                        _buildRowSubInfo("Non-Tunai", "Rp. xxx.xxx"),
                        const SizedBox(height: 12),

                        _buildRowInfo("Penambahan Kas", "Rp. xxx.xxx", isBold: true),
                        _buildRowSubInfo("Tunai", "Rp. xxx.xxx"),
                        _buildRowSubInfo("Non-Tunai", "Rp. xxx.xxx"),
                        const SizedBox(height: 12),

                        _buildRowInfo("Pengurangan Kas", "Rp. xxx.xxx", isBold: true),
                        _buildRowSubInfo("Tunai", "Rp. xxx.xxx"),
                        _buildRowSubInfo("Non-Tunai", "Rp. xxx.xxx"),
                        const SizedBox(height: 12),

                        const Divider(color: Colors.grey),
                        _buildRowInfo("Saldo Akhir", "Rp. xxx.xxx", isBold: true),
                        _buildRowSubInfo("Tunai", "Rp. xxx.xxx"),
                        _buildRowSubInfo("Non-Tunai", "Rp. xxx.xxx"),
                      ],
                    ),
                  ),
                ),
              ),

              // CARD 2: LIST TRANSAKSI / LOG KAS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Agar konten atasnya sejajar
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
                            children: const [
                              Text("xx/xx/xxxx - xx:xx", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              SizedBox(height: 4),
                              Text("Pendapatan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              SizedBox(height: 4),
                              Text("Gladys : NOTA-xxxxx.x.xxxxx.xxx", style: TextStyle(color: Colors.black)),
                              Text("Sinta", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end, // Rata kanan
                          children: const [
                            Text("Rp. xx.xxx", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            SizedBox(height: 4),
                            Text("Non-Tunai", style: TextStyle(color: Colors.grey)),
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
  // Membuat fungsi helper agar kode di atas tidak berulang-ulang (Clean Code)
  Widget _buildRowInfo(String label, String value, {bool isBold = false}) {
    final style = TextStyle(
      color: Colors.black,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Dorong teks ke kiri dan kanan
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