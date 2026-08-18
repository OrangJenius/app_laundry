import 'package:app_laundry/Models/storeModel.dart';
import 'package:app_laundry/Services/store_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class EditOutletScreen extends StatefulWidget {
  final String id;
  final String owner_id;

  const EditOutletScreen({super.key, required this.id, required this.owner_id});
  @override
  _EditOutletScreenState createState() => _EditOutletScreenState();
}

class _EditOutletScreenState extends State<EditOutletScreen> {
  // Controller untuk mengambil data input (Opsional, tapi sangat disarankan)
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final store_service = StoreService();

  void editStore() async{
    try{
      final newStore = StoreModel(owner_id: widget.owner_id, store_name: _namaController.text, address: _alamatController.text, phone_number: _phoneController.text);
      await store_service.editStore(widget.id, newStore);
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diubah!"), backgroundColor: Colors.green,)
        );
        Navigator.pop(context);
      }
    }catch(e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data gagal diubah, error $e"), backgroundColor: Colors.red,)
        );
      }
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
              UpperBar2(title: "EDIT OUTLET"),
              
              // FIELD 1: Nama Outlet
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.store_outlined, color: Colors.amberAccent),
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
                          labelText: 'Nama Outlet',
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
                    Icon(Icons.location_city, color: Colors.amberAccent),
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
                          labelText: 'Alamat Lengkap',
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
                    Icon(Icons.phone_android_outlined, color: Colors.amberAccent),
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
                          labelText: 'No. Telepon',
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
                     editStore();
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