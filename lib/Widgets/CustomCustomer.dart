import 'package:app_laundry/Screens/detailLaporanPesanan.dart';
import 'package:app_laundry/Screens/editCustomer.dart';
import 'package:app_laundry/Screens/rincianPesanan.dart';
import 'package:app_laundry/Services/customer_service.dart';
import 'package:flutter/material.dart';

// --- REUSABLE CUSTOM CUSTOMER CARD WIDGET ---
class CustomCustomer extends StatefulWidget {
  final IconData icon;
  final String id;
  final String name;
  final VoidCallback? onRefresh;
  final String phone_number;
  final String address;

  const CustomCustomer({
    super.key, 
    this.onRefresh,
    required this.id,
    required this.icon,
    required this.name,
    required this.phone_number,
    required this.address,
  });

  @override
  State<CustomCustomer> createState() => _CustomCustomerState();
}

class _CustomCustomerState extends State<CustomCustomer> {
  
  // Fungsi utama untuk menghapus data pelanggan via Service
  void _deleteCustomer() async {
    final customerService = CustomerService();
    try {
      await customerService.deleteCustomer(widget.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil dihapus!"), 
            backgroundColor: Colors.green,
          ),
        );
      widget.onRefresh?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Data tidak berhasil dihapus, error: $e"), 
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fungsi untuk memunculkan Dialog Konfirmasi (Pop-up) sebelum hapus
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900], // Menyesuaikan tema gelap aplikasi
          title: const Text(
            "Konfirmasi Hapus",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus pelanggan bernama ${widget.name}?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Menutup dialog saja
              },
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            // Tombol Konfirmasi Hapus
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Menutup dialog
                _deleteCustomer(); // Menjalankan fungsi hapus data
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi internal untuk memunculkan Lembaran Info dari Bawah (Modal Bottom Sheet)
  void _showCustomerMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900], // Menyamakan dengan tema gelap aplikasi laundry kamu
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Membuat tinggi sheet pas dengan isinya
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Garis indikator pegangan kecil di paling atas sheet (opsional, pemanis UI)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // SECTION 1: Informasi Ringkas Pelanggan
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(widget.icon, color: Colors.black87, size: 28),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          widget.phone_number,
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              
              // Alamat Pelanggan
              Text(
                "Alamat:",
                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Text(
                widget.address,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: Colors.grey),
              ),

              // SECTION 2: Tombol-Tombol Aksi (Edit, Riwayat, Hapus)
              Row(
                children: [
                  // Tombol Edit Pelanggan
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => EditCustomerScreen(
                              id: widget.id, 
                              nama: widget.name, 
                              alamat: widget.address, 
                              phone: widget.phone_number,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Edit", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  // Tombol Riwayat Pesanan
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigator.push(
                        //   context, 
                        //   MaterialPageRoute(builder: (context) => DetailLaporanPesananScreen()),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text("Riwayat", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  // Tombol Hapus Pelanggan (Memicu Pop-up Konfirmasi)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Tutup bottom sheet terlebih dahulu agar bersih
                      _showDeleteConfirmation(context); // Tampilkan pop-up dialog konfirmasi
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Icon(Icons.delete, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10.0), // Padding aman bawah untuk sistem gesture HP
            ],
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Icon(widget.icon, color: Colors.black87),
          ),
          title: Text(
            widget.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14, 
              color: Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4.0), 
              Row(
                children: [
                  const Icon(Icons.phone_android_outlined, size: 16, color: Colors.black38),
                  const SizedBox(width: 4.0),
                  Text(
                    widget.phone_number,
                    style: const TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4.0), 
              Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 16, color: Colors.black38),
                  const SizedBox(width: 4.0),
                  Expanded( 
                    child: Text(
                      widget.address,
                      style: const TextStyle(color: Colors.black38, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              _showCustomerMenu(context);
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            icon: const Icon(Icons.more_vert), 
          ),
          onTap: () {
            _showCustomerMenu(context);
          },
        ),
      ),
    );
  }
}
