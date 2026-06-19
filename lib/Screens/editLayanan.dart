import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class EditLayananScreen extends StatefulWidget {
  const EditLayananScreen({super.key});

  @override
  _EditLayananScreenState createState() => _EditLayananScreenState();
}

class _EditLayananScreenState extends State<EditLayananScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  // Variabel untuk menyimpan status pilihan tipe kas
  String? _selectedTipeLayanan;
  String? _selectedDurasiLayanan; 

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar2(title: "EDIT LAYANAN"),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.grey[800], // Mengubah background menu dropdown agar match bertema dark
                        style: const TextStyle(color: Colors.white),
                        value: _selectedTipeLayanan,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'Nama Layanan',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        items: ["Kiloan", "Satuan", "Meteran"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedTipeLayanan = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.grey[800], // Mengubah background menu dropdown agar match bertema dark
                        style: const TextStyle(color: Colors.white),
                        value: _selectedDurasiLayanan,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'Nama Layanan',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        items: ["Reguler - 72 Jam", "Ekspres - 24 Jam", "Kilat - 6 Jam"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDurasiLayanan = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _namaController,
                        keyboardType: TextInputType.text,
                        maxLines: 2, // Diberi 2 baris agar muat deskripsi penambahan kas
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'Nama Layanan',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _hargaController,
                        keyboardType: TextInputType.number, // Menampilkan keyboard angka untuk nominal uang
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          prefixText: "Rp. ", // Memberi petunjuk rupiah di depan input
                          prefixStyle: const TextStyle(color: Colors.amberAccent),
                          labelText: 'Harga',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),              

              const SizedBox(height: 24),

              // ================= TOMBOL ACTION: TAMBAHKAN =================
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, 
                  height: 48, 
                  child: ElevatedButton(
                    onPressed: () {
                      // Mengambil data inputan saat tombol diklik
                      print(" $_selectedTipeLayanan");
                      print(" $_selectedDurasiLayanan");
                      print(" ${_namaController.text}");
                      print(" ${_hargaController.text}");
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), 
                      ),
                    ),
                    child: const Text(
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