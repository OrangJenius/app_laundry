import 'package:app_laundry/Screens/addCustomer.dart';
import 'package:app_laundry/Services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:app_laundry/Widgets/customCustomerCard.dart';

class AddPesananScreen extends StatefulWidget {
  const AddPesananScreen({super.key, required this.store_id}); // Ditambahkan best-practice constructor
  final String? store_id;

  @override
  _AddPesananScreenState createState() => _AddPesananScreenState();
}

class _AddPesananScreenState extends State<AddPesananScreen> {
  // Contoh data dummy untuk simulasi list pelanggan
  final _customerService = CustomerService();
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddCustomerScreen(store_id: "",)));
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
              child: FutureBuilder<List<dynamic>>( // Menggunakan dynamic atau tipe model 'Customer' kamu
                future: _customerService.fetchCustomers(widget.store_id),
                builder: (context, snapshot) {
                  // 1. Kondisi saat data sedang loading/fetching
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    );
                  }
                  
                  // 2. Kondisi jika terjadi error saat fetch data
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Gagal memuat data: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  // 3. Kondisi jika data kosong
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Tidak ada data pelanggan",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  // 4. Jika data berhasil didapatkan
                  final customers = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      // Penyesuaian: Karena berbentuk object model, panggil propertinya menggunakan titik (.) bukan kurung siku ([])
                      return CustomCustomerCard(
                        icon: Icons.person,
                        name: customer.nama,         // contoh: customer.name
                        phone_number: customer.phoneNumber, // contoh: customer.phone
                        address: customer.alamat, 
                        id: customer.id,
                        store_id: widget.store_id!,
                      );
                    },
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