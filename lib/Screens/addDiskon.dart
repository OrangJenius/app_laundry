import 'package:app_laundry/Models/diskonModel.dart';
import 'package:app_laundry/Services/diskon_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class AddDiskonScreen extends StatefulWidget {
  final String store_id;

  const AddDiskonScreen({super.key, required this.store_id});
  @override
  _AddDiskonScreenState createState() => _AddDiskonScreenState();
}

class _AddDiskonScreenState extends State<AddDiskonScreen> {
  // 1. Controller untuk mengambil data input
  final TextEditingController _jumlahController = TextEditingController();
  final diskonService = DiskonService();
  
  // 2. State untuk menyimpan tipe diskon yang dipilih
  String? _selectedType;

  @override
  void dispose() {
    // Disarankan untuk men-dispose controller agar tidak terjadi memory leak
    _jumlahController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  void addDiskon() async{
    setState(() {
      _isLoading = true;
    });
    final newDiskon = DiskonModel(jumlah_diskon: _jumlahController.text, store_id: widget.store_id, tipe_diskon: _selectedType!);

    try{
      await diskonService.adddiskon(newDiskon);
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil ditambahkan!"), backgroundColor: Colors.green,)
        );
        Navigator.pop(context);
      }
    }catch (e){
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data gagal ditambahkan, error: $e"), backgroundColor: Colors.red,)
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar2(title: "TAMBAH DISKON"),
              
              // FIELD 1: Tipe Diskon (Dropdown)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward_ios, color: Colors.amberAccent),
                    SizedBox(width: 12),
                    Expanded(
                      child: DropdownMenu<String>(
                        hintText: "Tipe Diskon",
                        // Mengatur agar lebar dropdown memenuhi layar
                        expandedInsets: EdgeInsets.zero, 
                        // hintText: Text("Pilih Tipe Diskon", style: TextStyle(color: Colors.grey[400])),
                        textStyle: TextStyle(color: Colors.white),
                        inputDecorationTheme: InputDecorationTheme(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                        ),
                        // Mengubah state saat tipe diskon dipilih
                        onSelected: (String? value) {
                          setState(() {
                            _selectedType = value;
                          });
                        },
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(
                            value: 'Nominal',
                            label: 'Nominal (Rp)',
                            style: ButtonStyle(textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.black))),
                          ),
                          DropdownMenuEntry(
                            value: 'Persentase',
                            label: 'Persentase (%)',
                            style: ButtonStyle(textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.black))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // FIELD 2: Jumlah Diskon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward_ios, color: Colors.amberAccent),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _jumlahController,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number, // Mengubah keyboard khusus angka
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'Jumlah Diskon',
                          // Prefix text berubah dinamis sesuai pilihan dropdown
                          prefixText: _selectedType == 'Nominal' 
                              ? "Rp. " 
                              : _selectedType == 'Persentase' 
                                  ? "% " 
                                  : "",
                          prefixStyle: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // TOMBOL ACTION: Tambahkan
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading? null: () {
                      // Validasi sederhana sebelum eksekusi data
                      if (_selectedType == null || _jumlahController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Harap isi tipe dan jumlah diskon!")),
                        );
                        return;
                      }
                      addDiskon();
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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