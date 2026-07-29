import 'package:flutter/material.dart';
// Sesuaikan dengan nama package asli Anda jika diperlukan
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class DetailLaporanPelangganScreen extends StatefulWidget {
  final DateTimeRange date;
  const DetailLaporanPelangganScreen({super.key, required this.date});

  @override
  State<DetailLaporanPelangganScreen> createState() => _DetailLaporanPelangganScreenState();
}

class _DetailLaporanPelangganScreenState extends State<DetailLaporanPelangganScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Judul Halaman
              UpperBar2(title: "LAPORAN PELANGGAN"),
              
              // CARD 1: RINGKASAN DATA PELANGGAN
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
                      ],
                    ),
                  ),
                ),
              ),

              // CARD 2, 3, 4, 5: LOG / ANALISA PELANGGAN (Menggunakan Helper Ringkas)
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
                          rightTitle: "x Orang",
                          rightSubtitle: null,
                        ),
                        const Divider(color: Colors.grey, height: 24),

                        // 2. Total Pelanggan
                        _buildRowAnalisa(
                          title: "Total Pelanggan",
                          subtitle: null,
                          rightTitle: "xxx Orang",
                          rightSubtitle: null,
                        ),
                        const Divider(color: Colors.grey, height: 24),

                        // 3. Pelanggan Terbanyak
                        _buildRowAnalisa(
                          title: "Pelanggan Dengan",
                          subtitle: "Jumlah Pesanan Terbanyak",
                          rightTitle: "XXXX",
                          rightSubtitle: "x pesanan",
                        ),
                        const Divider(color: Colors.grey, height: 24),

                        // 4. Nilai Pesanan Terbanyak
                        _buildRowAnalisa(
                          title: "Pelanggan Dengan",
                          subtitle: "Nilai Pesanan Terbanyak",
                          rightTitle: "XXXX",
                          rightSubtitle: "Rp. xx.xxx",
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

  // --- WIDGET HELPER 2: Baris Analisa Ber-bullet (Memperbaiki Aligment Teks) ---
  Widget _buildRowAnalisa({
    required String title,
    String? subtitle,
    required String rightTitle,
    String? rightSubtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Memastikan peluru & teks sejajar di atas
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
            crossAxisAlignment: CrossAxisAlignment.start, // PERBAIKAN: Teks rata kiri, tidak melayang ke tengah
            children: [
              Text(title, style: const TextStyle(color: Colors.black, fontSize: 14)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
              ],
            ],
          ),
        ),
        
        // Kotak Teks Kanan
        Column(
          crossAxisAlignment: CrossAxisAlignment.end, // PERBAIKAN: Teks data rata kanan
          children: [
            Text(rightTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)),
            if (rightSubtitle != null) ...[
              const SizedBox(height: 2),
              Text(rightSubtitle, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
            ],
          ],
        ),
      ],
    );
  }
}