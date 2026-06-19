import 'package:flutter/material.dart';
// Sesuaikan dengan nama package asli Anda jika diperlukan
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class DetailLaporanLayananScreen extends StatefulWidget {
  const DetailLaporanLayananScreen({super.key});

  @override
  State<DetailLaporanLayananScreen> createState() => _DetailLaporanLayananScreenState();
}

class _DetailLaporanLayananScreenState extends State<DetailLaporanLayananScreen> {
  // Variabel penampung nilai dropdown terpilih
  String _selectedSort = "Nilai Tertinggi";

  // List opsi Dropdown
  final List<String> _sortItems = [
    "Nilai Tertinggi", 
    "Nilai Terendah", 
    "Kuantitas tertinggi", 
    "Kuantitas terendah", 
    "Nama Layanan A - Z", 
    "Nama Durasi A - Z"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Judul Halaman
              UpperBar2(title: "LAPORAN LAYANAN"),
              
              // CARD 1: RINGKASAN DATA LAYANAN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  color: Colors.white, // Kontras dengan background gelap
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildRowInfo("Outlet", "N2Jewel", isBold: true),
                        _buildRowInfo("Periode", "xx xxx xxxx - xx xxx xxx", isBold: true),
                        const SizedBox(height: 12),
                        _buildRowInfo("Jenis Durasi", "x Durasi"),
                        _buildRowInfo("Jenis Layanan", "xx Layanan"),
                        const SizedBox(height: 12),
                        
                        // Baris Urutkan & Dropdown
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Urutkan", 
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSort,
                                  style: const TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.w600),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                                  items: _sortItems.map((String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item, style: const TextStyle(color: Colors.black87)),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedSort = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // CARD LIST TRANSAKSI / LOG LAYANAN (Dibuat Dinamis & Ringkas)
              _buildRowLayanan(
                rank: "#1",
                durasiKategori: "Ekspres - Kiloan",
                namaLayanan: "Cuci Lipat",
                harga: "Rp. xx.xxx",
                kuantitas: "x Kg",
              ),
              
              _buildRowLayanan(
                rank: "#2",
                durasiKategori: "Reguler - Kiloan",
                namaLayanan: "Cuci Lipat",
                harga: "Rp. xx.xxx",
                kuantitas: "x Kg",
              ),
              
              // Anda bisa menambah data #3, #4 dengan sangat mudah di sini tanpa menumpuk kode komponen
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER 1: Info Baris Ringkasan ---
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

  // --- WIDGET HELPER 2: Card List Item Layanan (Refactor untuk Clean Code) ---
  Widget _buildRowLayanan({
    required String rank,
    required String durasiKategori,
    required String namaLayanan,
    required String harga,
    required String kuantitas,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Informasi Kiri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rank, 
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      durasiKategori, 
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      namaLayanan, 
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Bagian Informasi Kanan
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Nilai & Kuantitas", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(harga, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    kuantitas, 
                    style: const TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 14),
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