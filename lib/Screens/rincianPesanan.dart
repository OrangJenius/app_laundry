import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBar.dart';

class RincianPesananScreen extends StatefulWidget {
  const RincianPesananScreen({super.key});

  @override
  _RincianPesananScreenState createState() => _RincianPesananScreenState();
}

class _RincianPesananScreenState extends State<RincianPesananScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Membuat tombol bawah memenuhi lebar layar jika diinginkan
            children: [
              UpperBar2(title: "RINCIAN PESANAN"),
              
              // ================= TOKO & NOTA =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.store, color: Colors.black54),
                      const SizedBox(width: 8),
                      const Text(
                        "N2Jewel Laundry",
                        style: TextStyle(color: Colors.black54, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                      const Spacer(),
                      const Text(
                        "NOTA-xxxx.xx.xxxx.xxxxx",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),

              // ================= DATA PELANGGAN & AKSI =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                // IntrinsicHeight memaksa semua anak Row memiliki tinggi yang sama sesuai konten tertinggi
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Regangkan tinggi agar sama rata
                    children: [
                      // Card Pelanggan
                      Expanded(
                        flex: 3,
                        child: Card(
                          color: Colors.amberAccent,
                          margin: EdgeInsets.zero, // Menghilangkan margin bawaan card agar tinggi presisi
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.person, color: Colors.black87),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "Nama Pelanggan",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                      Text(
                                        "08123456789",
                                        style: TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                      Text(
                                        "Alamat Lengkap Pelanggan...",
                                        style: TextStyle(color: Colors.black45, fontSize: 10, fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // Jarak antar kedua Card
                      
                      // Card Tombol Call & Print
                      Card(
                        color: Colors.amber,
                        margin: EdgeInsets.zero, // Menghilangkan margin bawaan card agar tinggi presisi
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Membagi posisi tombol secara seimbang ke bawah
                            children: [
                              IconButton(
                                onPressed: () {}, 
                                icon: const Icon(Icons.call, color: Colors.white),
                                constraints: const BoxConstraints(), // Mengecilkan padding bawaan tombol
                                padding: const EdgeInsets.all(8.0),
                              ),
                              IconButton(
                                onPressed: () {}, 
                                icon: const Icon(Icons.print, color: Colors.white),
                                constraints: const BoxConstraints(), // Mengecilkan padding bawaan tombol
                                padding: const EdgeInsets.all(8.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ================= DETAIL LAYANAN (KILOAN) =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Reguler", style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
                            Text("Cuci Setrika", style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text("x Rp. 6.000", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text("Kiloan", style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
                            Text("X kg", style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text("Rp. xx.xxx", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= RINCIAN INFORMASI & BIAYA =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        _buildInfoRow("Dibuat Oleh", "xxxxxxx"),
                        const Divider(),
                        _buildInfoRow("Status", "xxxxxxx"),
                        const Divider(),
                        _buildInfoRow("Tanggal Masuk", "xx/xx/xxxx - xx:xx"),
                        const Divider(),
                        _buildInfoRow("Estimasi Selesai", "xx/xx/xxxx - xx:xx"),
                        const Divider(),
                        _buildInfoRow("Catatan", "-"),
                        const Divider(),
                        _buildInfoRow("Parfum", "Akasia"),
                        const Divider(),
                        _buildInfoRow("Antar-Jemput", "Tidak"),
                        const Divider(),
                        _buildInfoRow("Status Pembayaran", "xxxxxxx"),
                        const Divider(),
                        
                        // Rincian Biaya yang lebih rapi dibanding Column terpisah
                        _buildInfoRow("Total Layanan", "Rp. xx.xxx"),
                        const SizedBox(height: 4),
                        _buildInfoRow("Antar-Jemput", "Rp. 0"),
                        const SizedBox(height: 4),
                        _buildInfoRow("Diskon", "- Rp. 0"),
                        
                        const Divider(thickness: 1.5),
                        Row(
                          children: const [
                            Text("Total Bayar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            Spacer(),
                            Text("Rp. xx.xxx", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= TOMBOL AKSI ATAS PESANAN =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                  child: const Text("Pesanan Telah Siap", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent, foregroundColor: Colors.black),
                  child: const Text("Ubah Status Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700], foregroundColor: Colors.white),
                  child: const Text("Batalkan Pesanan"),
                ),
              ),
              const SizedBox(height: 16), // Jarak aman bawah scroll
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk membuat baris informasi agar kode lebih bersih/tidak berulang
  Widget _buildInfoRow(String title, String value) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: Colors.black87)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
      ],
    );
  }
}