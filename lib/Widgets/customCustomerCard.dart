import 'package:app_laundry/Screens/addPesanan2.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Screens/editCustomer.dart';

class CustomCustomerCard extends StatelessWidget {
  final IconData icon;
  final String id;
  final String name;
  final String phone_number;
  final String address;

  const CustomCustomerCard({
    super.key,
    required this.id,
    required this.icon,
    required this.name,
    required this.phone_number,
    required this.address,
  });

  // --- MENU TINGKAT 2: PILIHAN PAKET LAUNDRY ---
  void _showPackageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar Pemanis UI
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
              const Text(
                "Pilih Durasi Paket Laundry",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),

              // 1. Paket Reguler 72 Jam
              _buildPackageTile(
                context: context,
                icon: Icons.timer_outlined,
                title: "Reguler 72 Jam",
                subtitle: "Estimasi selesai dalam 3 hari",
                color: Colors.blue,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddPesanan2Screen()));
                  print("Memilih Paket Reguler (72 Jam) untuk $name");
                  // TODO: Tambahkan logika kelanjutan transaksi Anda di sini
                },
              ),
              const Divider(color: Colors.grey, height: 1),

              // 2. Paket Ekspres 24 Jam
              _buildPackageTile(
                context: context,
                icon: Icons.flash_on,
                title: "Ekspres 24 Jam",
                subtitle: "Estimasi selesai dalam 1 hari",
                color: Colors.amber,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddPesanan2Screen()));
                  print("Memilih Paket Ekspres (24 Jam) untuk $name");
                  // TODO: Tambahkan logika kelanjutan transaksi Anda di sini
                },
              ),
              const Divider(color: Colors.grey, height: 1),

              // 3. Paket Kilat 6 Jam
              _buildPackageTile(
                context: context,
                icon: Icons.bolt,
                title: "Kilat 6 Jam",
                subtitle: "Selesai super cepat di hari yang sama",
                color: Colors.redAccent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddPesanan2Screen()));
                  print("Memilih Paket Kilat (6 Jam) untuk $name");
                  // TODO: Tambahkan logika kelanjutan transaksi Anda di sini
                },
              ),
              const SizedBox(height: 12.0),
            ],
          ),
        );
      },
    );
  }

  // Helper Widget untuk Baris Pilihan Paket Laundry
  Widget _buildPackageTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[400], fontSize: 13),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
    );
  }

  // --- MENU TINGKAT 1: EDIT ATAU PILIH CUSTOMER ---
  void _showCustomerMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar Pemanis UI
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

              // Informasi Singkat Pelanggan
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(icon, color: Colors.black87, size: 28),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          phone_number,
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
                address,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: Colors.grey),
              ),

              // Hanya 2 Tombol Aksi (Edit & Pilih)
              Row(
                children: [
                  // Tombol Edit
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Tutup bottom sheet customer menu
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditCustomerScreen(id: this.id, nama: this.name, alamat: this.address, phone: this.phone_number,)));
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
                  const SizedBox(width: 12.0),

                  // Tombol Pilih (Membuka Menu Paket)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Tutup bottom sheet customer menu terlebih dahulu
                        _showPackageMenu(context); // Buka bottom sheet pilihan paket laundry
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text("Pilih", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
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
            child: Icon(icon, color: Colors.black87),
          ),
          title: Text(
            name,
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
                    phone_number,
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
                      address,
                      style: const TextStyle(color: Colors.black38, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () {
              // Menampilkan menu dasar kustomer (Edit / Pilih)
              _showCustomerMenu(context); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black87,
            ),
            child: const Text("Pilih"),
          ),
          onTap: () {
            // Opsional: Ketukan pada area card juga bisa membuka menu kustomer
            _showCustomerMenu(context);
          },
        ),
      ),
    );
  }
}