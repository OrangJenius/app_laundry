import 'package:app_laundry/Models/addCustomerModel.dart';
import 'package:app_laundry/Services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class AddCustomerScreen extends StatefulWidget {
  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  // Controller untuk mengambil data input (Opsional, tapi sangat disarankan)
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final _customerService = CustomerService(); 

  void addCustomer() async {
    final newCustomer = Customer(
      alamat: _alamatController.text, 
      nama: _namaController.text, 
      phoneNumber: _phoneController.text,
    );
    print("$newCustomer.nama, $newCustomer.alamat, $newCustomer.phoneNumber");
    await _customerService.addCustomer(newCustomer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        // Menggunakan SingleChildScrollView agar tidak error 'Overflow' saat keyboard muncul
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar2(title: "TAMBAH PELANGGAN"),
              
              // FIELD 1: Nama Customer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.amberAccent),
                    SizedBox(width: 12),
                    Expanded( // WAJIB: Agar TextField tidak menyebabkan Unbounded Width Error
                      child: TextField(
                        controller: _namaController,
                        style: TextStyle(color: Colors.white), // Teks warna putih agar terbaca
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'Nama Customer',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // FIELD 2: Alamat Lengkap
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.phone_android, color: Colors.amberAccent),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        style: TextStyle(color: Colors.white),
                        maxLines: 2, // Alamat biasanya panjang, diberi 2 baris agar rapi
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'No Handphone',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // FIELD 3: No. Telepon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.gps_fixed, color: Colors.amberAccent),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _alamatController,
                        keyboardType: TextInputType.phone, // Memunculkan keyboard angka
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'Alamat',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24), // Memberi jarak sebelum tombol

              // TOMBOL ACTION: Tambahkan
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, // Membuat tombol full-width agar lebih modern
                  height: 48, // Mengatur tinggi tombol agar pas di jari
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validasi sederhana: Pastikan nama tidak kosong sebelum insert
                      if (_namaController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nama customer tidak boleh kosong!")),
                        );
                        return;
                      }

                      try {
                        // 1. Panggil fungsi insert data kamu
                        addCustomer();

                        // 2. Tampilkan pesan sukses
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Pelanggan berhasil ditambahkan!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // 3. Kembali ke halaman sebelumnya (List Pelanggan)
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Gagal menambahkan data: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Tambahkan",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}