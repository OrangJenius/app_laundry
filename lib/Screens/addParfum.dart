import 'package:app_laundry/Models/parfumModel.dart';
import 'package:app_laundry/Services/parfum_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class AddParfumScreen extends StatefulWidget {
  @override
  _AddParfumScreenState createState() => _AddParfumScreenState();
  final String store_id;

  const AddParfumScreen({super.key, required this.store_id});
}

class _AddParfumScreenState extends State<AddParfumScreen> {
  // Controller untuk mengambil data input (Opsional, tapi sangat disarankan)
  final TextEditingController _namaController = TextEditingController();
  final parfumService = ParfumService();
  bool _isLoading = false;

  Future<void> addParfum() async {
    setState(() {
      _isLoading = true;
    });

    final newParfum = ParfumModel(nama_parfum: _namaController.text, store_id: widget.store_id);

    try{
      await parfumService.addparfum(newParfum);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil ditambahkan!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data tidak berhasil ditambahkan, error: $e"), backgroundColor: Colors.red,)
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
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
              UpperBar2(title: "TAMBAH PARFUM"),
              
              // FIELD 1: Nama Parfum
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
                          labelText: 'Nama Parfum',
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
                    onPressed: _isLoading ? null: () {
                      // Logika ketika data ditambahkan
                     if(_namaController.text.trim().isEmpty){
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nama durasi tidak boleh kosong!")),
                        ); 
                        return; 
                     }
                     addParfum();
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Sudut tombol agak melengkung
                      ),
                    ),
                    child: _isLoading? 
                    const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(
                        strokeWidth: 2, 
                        color: 
                        Colors.black87,
                        ),
                      ) 
                    : const Text(
                      "Tambahkan",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
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