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

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<List<dynamic>>? _customersFuture;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  @override
  void didUpdateWidget(covariant AddPesananScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store_id != widget.store_id) {
      _fetchCustomers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchCustomers() {
    setState(() {
      _customersFuture = _customerService.fetchCustomers(widget.store_id);
    });
  }

  /// Returns true if the customer matches the current search query.
  /// Matches against name and phone number.
  bool _matchesSearch(dynamic customer) {
    if (_searchQuery.isEmpty) return true;

    final query = _searchQuery.toLowerCase();

    final name = (customer.nama ?? '').toString().toLowerCase();
    final phone = (customer.phoneNumber ?? '').toString().toLowerCase();

    return name.contains(query) || phone.contains(query);
  }

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
                  Expanded(
                    child: SearchBar(
                      controller: _searchController,
                      hintText: "Cari nama/no handphone",
                      leading: const Icon(Icons.search),
                      elevation: const WidgetStatePropertyAll(1),
                      // Opsional: Sesuaikan background search bar agar masuk ke tema dark mode
                      // backgroundColor: WidgetStatePropertyAll(Colors.white10),
                      // hintStyle: WidgetStatePropertyAll(TextStyle(color: Colors.white38)),
                      // textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.white)),
                      trailing: _searchQuery.isNotEmpty
                          ? [
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              ),
                            ]
                          : null,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => AddCustomerScreen(store_id: widget.store_id,)));
                      _fetchCustomers();
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
                future: _customersFuture,
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

                  // 4. Jika data berhasil didapatkan, terapkan filter pencarian
                  final customers = snapshot.data!.where(_matchesSearch).toList();

                  if (customers.isEmpty) {
                    return Center(
                      child: Text(
                        "Tidak ditemukan pelanggan untuk \"$_searchQuery\"",
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

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