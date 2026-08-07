import 'package:app_laundry/Screens/addCustomer.dart';
import 'package:app_laundry/Services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:app_laundry/Widgets/customCustomer.dart';
// IMPORT: Pastikan model Customer kamu diimport di sini jika dibutuhkan
// import 'package:app_laundry/Models/customer_model.dart'; 

class CustomerScreen extends StatefulWidget {
  final String? store_id;
  const CustomerScreen({super.key, required this.store_id});

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final _customerService = CustomerService();
  final ExpansionTileController _dropdownController = ExpansionTileController();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // State untuk menyimpan nilai switch fitur kasir
  bool _depositPelanggan = false;

  Future<List<dynamic>>? _customersFuture;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  @override
  void didUpdateWidget(covariant CustomerScreen oldWidget) {
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
                      backgroundColor: Colors.amber, 
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
            
            // --- SECTION SETTING DROP DOWN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    controller: _dropdownController,
                    title: const Text(
                      "Pengaturan Pelanggan",
                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text(
                      "Tekan untuk Melihat Pengaturan", 
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black45),
                    ),
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
                      
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () => _dropdownController.collapse(), 
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
            
            // --- SECTION LIST PELANGGAN (Menggunakan FutureBuilder) ---
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
                      return CustomCustomer(
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