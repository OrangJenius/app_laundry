import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:app_laundry/Widgets/customCustomerCard.dart';

class AddPesananScreen extends StatefulWidget {
  const AddPesananScreen({super.key}); // Ditambahkan best-practice constructor

  @override
  _AddPesananScreenState createState() => _AddPesananScreenState();
}

class _AddPesananScreenState extends State<AddPesananScreen> {
  // Contoh data dummy untuk simulasi list pelanggan
  final List<Map<String, String>> customers = List.generate(
    10,
    (index) => {
      "id": "$index",
      "name": "Pelanggan Ke-${index + 1}",
      "phone": "0812-3456-789${index}",
      "address": "Jl. Laundry Sukses No. ${index + 1}, Kota Suka",
    },
  );

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
            
            // --- SECTION LIST PELANGGAN ---
            // Menggunakan Expanded agar ListView bisa mengambil sisa ruang layar tanpa error layout
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16.0),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return CustomCustomerCard(
                    icon: Icons.person,
                    id: customer["id"]!,
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
}