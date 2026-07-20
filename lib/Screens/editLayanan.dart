import 'package:app_laundry/Models/serviceModel.dart';
import 'package:app_laundry/Services/durasi_service.dart';
import 'package:app_laundry/Services/service_service.dart';
import 'package:app_laundry/Services/unit_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class EditLayananScreen extends StatefulWidget {
  const EditLayananScreen({
    super.key, 
    required this.store_id, 
    required this.currentTipeLayanan, 
    required this.currentUnitLayanan, 
    required this.id
  });
  
  final String? store_id;
  final String? currentTipeLayanan;
  final String? currentUnitLayanan;
  final String? id;

  @override
  _EditLayananScreenState createState() => _EditLayananScreenState();
}

class _EditLayananScreenState extends State<EditLayananScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  String? _selectedTipeLayanan;
  String? _selectedUnitLayanan; 

  final unitService = UnitService();
  final durasiService = DurasiService();
  final serviceService = ServiceService();

  late Future<List<dynamic>> _durasiFuture;
  late Future<List<dynamic>> _unitFuture;
  
  // Changed this to target a generic multi-future payload initialization
  late Future<List<dynamic>> _initialDataFuture;

  bool _isLoading = false;
  bool _isDataInitialized = false;

  @override
  void initState() {
    super.initState();

    _durasiFuture = durasiService.fetchDurasi(widget.store_id!);
    _unitFuture = unitService.fetchUnits();
    
    // We combine our layout requests so we don't build inputs before the data item returns
    _initialDataFuture = Future.wait([
      _durasiFuture,
      _unitFuture,
      serviceService.fetchServicesById(widget.id!),
    ]);
  }

  void updateService () async {
    if (_selectedTipeLayanan == null || _selectedUnitLayanan == null) return;

    setState(() {
      _isLoading = true;
    });
    
    final newService = ServiceModel(
      service_name: _namaController.text, 
      price: _hargaController.text, 
      duration_id: _selectedTipeLayanan!, 
      unit_id: _selectedUnitLayanan!, 
      store_id: widget.store_id!
    );

    try{
      await serviceService.updateService(newService, widget.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); 
      }
    }catch(e){
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data tidak berhasil diperbarui error: $e"), backgroundColor: Colors.red),
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
        child: FutureBuilder<List<dynamic>>(
          future: _initialDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.amberAccent),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Gagal memuat data layanan: ${snapshot.error}",
                  style: TextStyle(color: Colors.red[300]),
                ),
              );
            }

            // Extract values safely from Future.wait array index positions
            final listDurasi = snapshot.data![0] as List<dynamic>;
            final listUnit = snapshot.data![1] as List<dynamic>;
            final List<ServiceModel> services = List<ServiceModel>.from(snapshot.data![2]);

            if (services.isEmpty) {
              return const Center(child: Text("Data layanan tidak ditemukan", style: TextStyle(color: Colors.white)));
            }

            // Initialize fields ONCE when the backend payload is retrieved
            if (!_isDataInitialized) {
              final currentService = services.first;
              _namaController.text = currentService.service_name;
              _hargaController.text = currentService.price;
              _selectedTipeLayanan = currentService.duration_id;
              _selectedUnitLayanan = currentService.unit_id;
              _isDataInitialized = true;
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  UpperBar2(title: "EDIT LAYANAN"),

                  // ================= DROPDOWN TIPE (DURASI) LAYANAN =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
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
                            items: listDurasi.map<DropdownMenuItem<String>>((item) {
                              final String id = item.id.toString(); 
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
                          child: DropdownButtonFormField<String>(
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
                            items: listUnit.map<DropdownMenuItem<String>>((item) {
                              final String id = item.id.toString(); 
                              final String name = item.unit_name.toString(); 
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

                  // ================= TOMBOL ACTION: SIMPAN PERUBAHAN =================
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity, 
                      height: 48, 
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          if (_namaController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Nama layanan tidak boleh kosong!")),
                            );
                            return;
                          } else if (_hargaController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Harga tidak boleh kosong!")),
                            );
                            return;
                          } else if (_selectedTipeLayanan == null || _selectedTipeLayanan!.trim().isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Jenis layanan harus dipilih!")),
                            );
                            return;
                          } else if (_selectedUnitLayanan == null || _selectedUnitLayanan!.trim().isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Unit layanan harus dipilih!")),
                            );
                            return;
                          }
                          updateService();
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amberAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), 
                          ),
                        ),
                        child: _isLoading ? 
                        const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(
                            strokeWidth: 2, 
                            color: Colors.black87,
                          ),
                        ) 
                        : const Text(
                          "Simpan Perubahan",
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}