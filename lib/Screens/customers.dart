import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:app_laundry/Widgets/customCustomer.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key}); // Ditambahkan best-practice constructor

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  // Contoh data dummy untuk simulasi list pelanggan
  final List<Map<String, String>> customers = List.generate(
    10,
    (index) => {
      "name": "Pelanggan Ke-${index + 1}",
      "phone": "0812-3456-789${index}",
      "address": "Jl. Laundry Sukses No. ${index + 1}, Kota Suka",
    },
  );
  final ExpansibleController _dropdownController = ExpansibleController();

  // State untuk menyimpan nilai switch fitur kasir
  bool _depositPelanggan = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        // SingleChildScrollView diganti dengan struktur Column + Expanded ListView
        child: Column(
          children: [
            UpperBar2(title: "PILIH PELANGGAN"),
            
            // --- SECTION SEARCH BAR & BUTTON ADD ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Expanded(
                    child: SearchBar(
                      hintText: "Cari nama/no handphone",
                      leading: Icon(Icons.search),
                      elevation: WidgetStatePropertyAll(1),
                      // Opsional: Sesuaikan background search bar agar masuk ke tema dark mode
                      // backgroundColor: WidgetStatePropertyAll(Colors.white10),
                      // hintStyle: WidgetStatePropertyAll(TextStyle(color: Colors.white38)),
                      // textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Aksi tambah pelanggan baru
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber, // Menyamakan aksen dengan CustomCustomerCard
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.add), 
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  // border: BorderSide(color: Colors.grey[700]!),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    controller: _dropdownController, // Pasang controllernya di sini
                    title: const Text(
                      "Pengaturan Pelanggan",
                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text("Tekan untuk Melihat Pengaturan", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black),),
                    iconColor: Colors.amber,
                    collapsedIconColor: Colors.amber,
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    children: [
                      const Divider(color: Colors.grey, height: 1),
                      const SizedBox(height: 8),
                      _buildSwitchRow("Fitur Deposit Pelanggan", _depositPelanggan, (val) {
                        setState(() => _depositPelanggan = val);
                      }),
                      const SizedBox(height: 16),
                      
                      // TOMBOL AKSI UNTUK MERAPTIKAN / SLIDE CLOSE KE ATAS
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Fungsi bawaan Flutter untuk menutup slide secara mulus
                            _dropdownController.collapse(); 
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.amber),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.amber, size: 18),
                          label: const Text(
                            "Tutup Pengaturan",
                            style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // --- SECTION LIST PELANGGAN ---
            // Menggunakan Expanded agar ListView bisa mengambil sisa ruang layar tanpa error layout
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16.0),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return CustomCustomer(
                    icon: Icons.person,
                    name: customer["name"]!,
                    phone_number: customer["phone"]!,
                    address: customer["address"]!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
    Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ),
        Transform.scale(
          scale: 0.85, 
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.amber,
          ),
        ),
      ],
    );
  }
}