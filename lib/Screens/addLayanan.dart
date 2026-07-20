import 'package:app_laundry/Models/serviceModel.dart';
import 'package:app_laundry/Services/durasi_service.dart';
import 'package:app_laundry/Services/service_service.dart';
import 'package:app_laundry/Services/unit_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class AddLayananScreen extends StatefulWidget {
  const AddLayananScreen({super.key, required this.store_id});
  final String? store_id;

  @override
  _AddLayananScreenState createState() => _AddLayananScreenState();
}

class _AddLayananScreenState extends State<AddLayananScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  // Variabel untuk menyimpan ID atau Nilai terpilih dari dropdown
  String? _selectedTipeLayanan;
  String? _selectedUnitLayanan; 

  final unitService = UnitService();
  final durasiService = DurasiService();
  final serviceService = ServiceService();

  late Future<List<dynamic>> _durasiFuture;
  late Future<List<dynamic>> _unitFuture;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _durasiFuture = durasiService.fetchDurasi(widget.store_id!);
    _unitFuture = unitService.fetchUnits();
  }

  void addService () async {
    setState(() {
      _isLoading = true;
    });
    final newService = ServiceModel(service_name: _namaController.text, price: _hargaController.text, duration_id: _selectedTipeLayanan!, unit_id: _selectedUnitLayanan!, store_id: widget.store_id!);

    try{
      await serviceService.addService(service: newService);
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil ditambahkan!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Tutup halaman edit
      }
    }catch(e){
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data tidak berhasil ditambahkan error: $e"), backgroundColor: Colors.red),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

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
              UpperBar2(title: "PENAMBAHAN LAYANAN"),

              // ================= DROPDOWN TIPE (DURASI) LAYANAN =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FutureBuilder<List<dynamic>>(
                        future: _durasiFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: LinearProgressIndicator(color: Colors.amberAccent),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text(
                              "Gagal memuat durasi",
                              style: TextStyle(color: Colors.red[300]),
                            );
                          }

                          final listDurasi = snapshot.data ?? [];

                          return DropdownButtonFormField<String>(
                            dropdownColor: Colors.grey[800],
                            style: const TextStyle(color: Colors.white),
                            value: _selectedTipeLayanan,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.amberAccent),
                              ),
                              labelText: 'Tipe Layanan',
                              labelStyle: TextStyle(color: Colors.grey[400]),
                            ),
                            // Map data list dari API ke DropdownMenuItem
                            items: listDurasi.map<DropdownMenuItem<String>>((item) {
                              final String id = item.id.toString(); // Sesuaikan property id di modelmu
                              final String name = item.duration_name.toString();
                              return DropdownMenuItem<String>(
                                value: id,
                                child: Text(name),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedTipeLayanan = newValue;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ================= DROPDOWN UNIT LAYANAN =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FutureBuilder<List<dynamic>>(
                        future: _unitFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: LinearProgressIndicator(color: Colors.amberAccent),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text(
                              "Gagal memuat unit",
                              style: TextStyle(color: Colors.red[300]),
                            );
                          }

                          final listUnit = snapshot.data ?? [];

                          return DropdownButtonFormField<String>(
                            dropdownColor: Colors.grey[800],
                            style: const TextStyle(color: Colors.white),
                            value: _selectedUnitLayanan,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.amberAccent),
                              ),
                              labelText: 'Unit Layanan',
                              labelStyle: TextStyle(color: Colors.grey[400]),
                            ),
                            // Map data list dari API ke DropdownMenuItem
                            items: listUnit.map<DropdownMenuItem<String>>((item) {
                              final String id = item.id.toString(); // Sesuaikan property id di modelmu
                              final String name = item.unit_name.toString(); // Sesuaikan property name di modelmu
                              return DropdownMenuItem<String>(
                                value: id,
                                child: Text(name),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedUnitLayanan = newValue;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ================= INPUT NAMA LAYANAN =================
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
                        maxLines: 2,
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

              // ================= INPUT HARGA =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _hargaController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          prefixText: "Rp. ",
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
                    onPressed: _isLoading? null : () {
                      if (_namaController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Namadurasi tidak boleh kosong!")),
                      );
                      return;
                      }else if (_hargaController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Durasi waktu tidak boleh kosong!")),
                        );
                        return;
                      }else if (_selectedTipeLayanan!.trim().isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Jenis layanan harus dipilih!")),
                        );
                      }else if (_selectedUnitLayanan!.trim().isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Unit layanan harus dipilih!")),
                        );
                      }
                      addService();
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