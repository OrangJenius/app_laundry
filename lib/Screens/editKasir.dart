// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:app_laundry/Models/kasirModel.dart';
import 'package:app_laundry/Services/kasir_service.dart';
import 'package:flutter/material.dart';

import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class EditKasirScreen extends StatefulWidget {
  final String nama;
  final String id;
  final String store_id;
  const EditKasirScreen({
    super.key,
    required this.nama,
    required this.id,
    required this.store_id,
  });
  @override
  _EditKasirScreenState createState() => _EditKasirScreenState();
}

class _EditKasirScreenState extends State<EditKasirScreen> {
  final kasirService = KasirService();
  // Controller untuk mengambil data input (Opsional, tapi sangat disarankan)
  final TextEditingController _namaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.nama;
  }
  void editKasir() async{
    setState(() {
      _isLoading = true;
    });
    final newKasir = KasirModel(cashier_name: _namaController.text, store_id: widget.store_id);
    try{
      await kasirService.editCashier(widget.id, newKasir);
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diubah!"), backgroundColor: Colors.green,)
        );
        Navigator.pop(context);
      }
    }catch(e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data gagal diubah, error: $e"), backgroundColor: Colors.red,)
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
              UpperBar2(title: "EDIT KASIR"),
              
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
                    onPressed: _isLoading? null : () {
                      if(_namaController.text.trim().isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Nama kasir tidak boleh kosong!")),
                        );
                        return;
                      }
                      editKasir();
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