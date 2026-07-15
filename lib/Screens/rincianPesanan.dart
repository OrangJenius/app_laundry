import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:flutter/material.dart';

class RincianPesananScreen extends StatefulWidget {
  final String nama;
  final String nomor;
  final String alamat;
  final int jumlahItem;
  final String namaItem;
  final String parfum;
  final String antarJemput;
  final String diskon;
  final String catatan;
  final int totalHarga;

  const RincianPesananScreen({
    super.key,
    required this.nama,
    required this.nomor,
    required this.alamat,
    required this.jumlahItem,
    required this.parfum,
    required this.antarJemput,
    required this.diskon,
    required this.catatan,
    required this.totalHarga,
    this.namaItem = "Baju Kemeja",
  });

  @override
  _RincianPesananScreenState createState() => _RincianPesananScreenState();
}

class _RincianPesananScreenState extends State<RincianPesananScreen> {
  
  // Helper fungsi untuk parsing biaya antar jemput dari string teks pilihan dropdown
  int _hitungBiayaAntarJemput(String opsi) {
    if (opsi.contains('5.000')) return 5000;
    if (opsi.contains('15.000')) return 15000;
    return 0;
  }

  // Helper fungsi untuk kalkulasi nominal diskon persen dari total harga layanan
  int _hitungNominalDiskon(String opsi, int totalLayanan) {
    if (opsi.contains('5%')) return (totalLayanan * 0.05).round();
    if (opsi.contains('10%')) return (totalLayanan * 0.10).round();
    if (opsi.contains('15%')) return (totalLayanan * 0.15).round();
    return 0;
  }

  // Helper format integer ke format currency rupiah teks standar (Ribuan '.')
  String _formatRupiah(int uang) {
    return "Rp. ${uang.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    // Jalankan kalkulasi biaya pelengkap pesanan secara real-time berdasarkan input parameter data
    int biayaAntarJemput = _hitungBiayaAntarJemput(widget.antarJemput);
    int nominalDiskon = _hitungNominalDiskon(widget.diskon, widget.totalHarga);
    int totalBayarAkhir = widget.totalHarga + biayaAntarJemput - nominalDiskon;

    // Pastikan total bayar tidak minus
    if (totalBayarAkhir < 0) totalBayarAkhir = 0;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        "NOTA-2026.06.0001", // Bisa dibuat dinamis nantinya
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),

              // ================= DATA PELANGGAN & AKSI =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card Pelanggan (Menampilkan data lemparan data parameter)
                      Expanded(
                        flex: 3,
                        child: Card(
                          color: Colors.amberAccent,
                          margin: EdgeInsets.zero,
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
                                    children: [
                                      Text(
                                        widget.nama,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                      Text(
                                        widget.nomor,
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.alamat.isEmpty ? "Tidak ada alamat" : widget.alamat,
                                        style: const TextStyle(color: Colors.black45, fontSize: 10, fontStyle: FontStyle.italic),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Card Tombol Call & Print
                      Card(
                        color: Colors.amber,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () {}, 
                                icon: const Icon(Icons.call, color: Colors.white),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8.0),
                              ),
                              IconButton(
                                onPressed: () {}, 
                                icon: const Icon(Icons.print, color: Colors.white),
                                constraints: const BoxConstraints(),
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

              // ================= DETAIL LAYANAN (SATUAN) =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Reguler - Satuan", style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
                            Text(widget.namaItem, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                            const Text("x Rp. 15.000", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Jumlah", style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
                            Text("${widget.jumlahItem} Pcs", style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text(_formatRupiah(widget.totalHarga), style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
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
                        _buildInfoRow("Dibuat Oleh", "Kasir Utama"),
                        const Divider(),
                        _buildInfoRow("Status", "Proses Cuci"),
                        const Divider(),
                        _buildInfoRow("Tanggal Masuk", "26/06/2026 - 15:53"),
                        const Divider(),
                        _buildInfoRow("Estimasi Selesai", "29/06/2026 - 15:53"),
                        const Divider(),
                        _buildInfoRow("Catatan", widget.catatan.isEmpty ? "-" : widget.catatan),
                        const Divider(),
                        _buildInfoRow("Parfum", widget.parfum),
                        const Divider(),
                        _buildInfoRow("Antar-Jemput", widget.antarJemput),
                        const Divider(),
                        _buildInfoRow("Status Pembayaran", "Belum Bayar"),
                        const Divider(thickness: 1.5),
                        
                        // Rincian Kalkulasi Komponen Biaya Finansial Berjalan
                        _buildInfoRow("Total Layanan", _formatRupiah(widget.totalHarga)),
                        const SizedBox(height: 4),
                        _buildInfoRow("Antar-Jemput", _formatRupiah(biayaAntarJemput)),
                        const SizedBox(height: 4),
                        _buildInfoRow("Diskon (${widget.diskon})", "- ${_formatRupiah(nominalDiskon)}"),
                        
                        const Divider(thickness: 1.5),
                        Row(
                          children: [
                            const Text("Total Bayar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
                            const Spacer(),
                            Text(_formatRupiah(totalBayarAkhir), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
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
                  onPressed: () {
                    Navigator.pop(context); // Kembali ke form pemesanan sebelumnya
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700], foregroundColor: Colors.white),
                  child: const Text("Batalkan Pesanan"),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: Colors.black87, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }
}