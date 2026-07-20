import 'package:app_laundry/Models/antarJemputModel.dart';
import 'package:app_laundry/Services/antarJemput_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class EditAntarJemputScreen extends StatefulWidget {
  final String id;
  final String store_id;
  final String jarak;
  final String harga;

  const EditAntarJemputScreen({super.key, required this.id, required this.store_id, required this.jarak, required this.harga});
  @override
  _EditAntarJemputScreenState createState() => _EditAntarJemputScreenState();
}

class _EditAntarJemputScreenState extends State<EditAntarJemputScreen> {
  @override
  void initState() {
    super.initState();
    _namaController.text = widget.jarak;
    _lamaController.text = widget.harga;
  }
  // Controller untuk mengambil data input (Opsional, tapi sangat disarankan)
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _lamaController = TextEditingController();
  bool _isLoading = false;
  final antarJemputService = AntarJemputService();

  void updateAntarJemput() async{
    setState(() {
      _isLoading = true;
    });
    final newAJ = AntarJemputModel(jarak: _namaController.text, harga: _lamaController.text, store_id: widget.store_id);

    try{
      await antarJemputService.editantarjemput(widget.id, newAJ);
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diubah!"), backgroundColor: Colors.green,)
        );
        Navigator.pop(context);
      }
    }catch (e) {
      if(mounted) {
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
              UpperBar2(title: "TAMBAH ANTAR-JEMPUT"),
              
              // FIELD 1: Nama AntarJemput
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
                          labelText: 'Nama Antar-Jemput',
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
                    Icon(Icons.arrow_forward_ios, color: Colors.amberAccent),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _lamaController,
                        style: TextStyle(color: Colors.white),
                        maxLines: 2, // Alamat biasanya panjang, diberi 2 baris agar rapi
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'Harga',
                          prefixText: "Rp",
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
                    onPressed: _isLoading? null: () {
                      if(_namaController.text.trim().isEmpty || _lamaController.text.trim().isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Jarak dan harga tidak boleh kosong!"))
                        );
                      }
                      updateAntarJemput();
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Sudut tombol agak melengkung
                      ),
                    ),
                    child: _isLoading?
                    const SizedBox(
                      width: 20,
                      height: 20,
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