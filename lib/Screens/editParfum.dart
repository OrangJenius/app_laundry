import 'package:app_laundry/Models/parfumModel.dart';
import 'package:app_laundry/Services/parfum_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class EditParfumScreen extends StatefulWidget {
  @override
  _EditParfumScreenState createState() => _EditParfumScreenState();
  final String id;
  final String nama;
  final String store_id;

  const EditParfumScreen({super.key, required this.id, required this.nama, required this.store_id});
}

class _EditParfumScreenState extends State<EditParfumScreen> {
  // Controller untuk mengambil data input (Opsional, tapi sangat disarankan)
  final TextEditingController _namaController = TextEditingController();
  bool _isLoading = false;

  final parfumService = ParfumService();

  void updateParfum () async{
    setState(() {
      _isLoading = true;
    });
    try{
      await parfumService.editparfum(widget.id, ParfumModel(nama_parfum: _namaController.text, store_id: widget.store_id));
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data gagal diperbarui, error: #e"), backgroundColor: Colors.red),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.nama;
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
              UpperBar2(title: "EDIT PARFUM"),
              
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
                    onPressed: _isLoading? null : () {
                      if(_namaController.text.trim().isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nama parfum tidak boleh kosong!"),)
                        );
                        return;
                      }
                      updateParfum();
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
                        color: Colors.black87,
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