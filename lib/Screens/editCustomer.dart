import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class EditCustomerScreen extends StatefulWidget {
  @override
  _EditCustomerScreenState createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  // Controller untuk mengambil data input (Opsional, tapi sangat disarankan)
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
                        controller: _alamatController,
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
                        controller: _phoneController,
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
                    onPressed: () {
                      // Logika ketika data ditambahkan
                      print("Nama: ${_namaController.text}");
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Sudut tombol agak melengkung
                      ),
                    ),
                    child: Text(
                      "Simpan",
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