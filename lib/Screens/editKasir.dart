import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class EditKasirScreen extends StatefulWidget {
  @override
  _EditKasirScreenState createState() => _EditKasirScreenState();
}

class _EditKasirScreenState extends State<EditKasirScreen> {
  // Controller untuk mengambil data input (Opsional, tapi sangat disarankan)
  final TextEditingController _namaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        // Menggunakan SingleChildScrollView agar tidak error 'Overflow' saat keyboard muncul
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar2(title: "TAMBAH KASIR"),
              
              // FIELD 1: Nama Kasir
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward_ios, color: Colors.amberAccent),
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
                          labelText: 'Nama Kasir',
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