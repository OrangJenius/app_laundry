import 'package:app_laundry/Models/serviceModel.dart';
import 'package:app_laundry/Screens/addLayanan.dart';
import 'package:app_laundry/Screens/editLayanan.dart';
import 'package:app_laundry/Services/durasi_service.dart';
import 'package:app_laundry/Services/service_service.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:flutter/material.dart';

class PengaturanLayananScreen extends StatefulWidget {
  const PengaturanLayananScreen({super.key, required this.store_id});
  final String? store_id;

  @override
  _PengaturanLayananScreenState createState() => _PengaturanLayananScreenState();
}

class _PengaturanLayananScreenState extends State<PengaturanLayananScreen> {
  // Store the active segment ID selection (null means "Semua")
  String? _selectedDurationId; 
  
  // Set tracking for SegmentedButton. Uses 'Semua' initially.
  Set<String> _selectedFilter = {'Semua'};
  
  final durasiService = DurasiService();
  final serviceService = ServiceService();
  
  late Future<List<dynamic>> _durasiFuture;
  Future<List<ServiceModel>>? _servicesFuture;

  void _deleteService(String id) async {
    try {
      await durasiService.deleteDurasi(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil dihapus!"), 
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Data tidak berhasil dihapus, error: $e"), 
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900], // Menyesuaikan tema gelap aplikasi
          title: const Text(
            "Konfirmasi Hapus",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus layanan $name?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Menutup dialog saja
              },
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            // Tombol Konfirmasi Hapus
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Menutup dialog
                _deleteService(id); // Menjalankan fungsi hapus data
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _loadServices() {
      if (widget.store_id == null) return; // Prevent executing if store_id is missing
      
      setState(() {
        if (_selectedDurationId == null) {
          _servicesFuture = serviceService.fetchServices(widget.store_id!);
        } else {
          _servicesFuture = serviceService.fetchServicesByDuration(
            widget.store_id!, 
            _selectedDurationId!,
          );
        }
      });
    }

  @override
  void initState() {
    super.initState();
    _durasiFuture = durasiService.fetchDurasi(widget.store_id!);
    _loadServices(); // Initialize state variables
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar2(title: "LAYANAN"),
              
              const SizedBox(height: 16),

              // Segmented Button for Filtering
              FutureBuilder<List<dynamic>>(
                future: _durasiFuture,
                builder: (context, snapshot) {
                  List<dynamic> durasiList = [];
                  if (snapshot.hasData) {
                    durasiList = snapshot.data!;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        style: SegmentedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          selectedBackgroundColor: Colors.amber,
                          selectedForegroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        segments: <ButtonSegment<String>>[
                          const ButtonSegment<String>(
                            value: 'Semua',
                            label: Text('Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          ...durasiList.map((item) {
                            // value uses the unique database ID string, label shows the name string
                            return ButtonSegment<String>(
                              value: item.id.toString(), 
                              label: Text(item.duration_name.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            );
                          }),
                        ],
                        selected: _selectedFilter,
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedFilter = newSelection;
                            String selection = newSelection.first;
                            
                            if (selection == 'Semua') {
                              _selectedDurationId = null;
                            } else {
                              _selectedDurationId = selection;
                            }
                          });
                          _loadServices(); // Trigger database refetch automatically
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: SearchBar(
                        hintText: "Cari nama layanan",
                        leading: Icon(Icons.search),
                        elevation: WidgetStatePropertyAll(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        // Refresh target lists if a new item is added
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => AddLayananScreen(store_id: widget.store_id,)));
                        _loadServices();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),

              // FIX: Wired target to reactive _servicesFuture object tracker
              FutureBuilder<List<ServiceModel>>(
                future: _servicesFuture, 
                builder: (context, snapshot){
                  if (_servicesFuture == null) {
                    return const Center(child: Text("Initializing...", style: TextStyle(color: Colors.white)));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Center(child: CircularProgressIndicator(color: Colors.amber)),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          "Gagal memuat data: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text(
                          "Tidak ada data layanan",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  }

                  final services = snapshot.data!;

                  return ListView.builder(
                    itemCount: services.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Safe list inside SingleChildScrollView
                    itemBuilder: (context, index){
                      final service = services[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // FIX: Use optional properties derived from joined databases
                                      Text(
                                        "${service.duration?.duration_name ?? 'Loading...'} - ${service.unit?.unit_name ?? 'Loading...'}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 13,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic
                                        ),
                                      ),
                                      Text(
                                        service.service_name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Rp ${service.price}",
                                        style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        await Navigator.push(context, MaterialPageRoute(builder: (context) => EditLayananScreen(store_id: service.store_id, currentTipeLayanan: service.duration_id, currentUnitLayanan: service.unit_id, id: service.id,)));
                                        _loadServices(); // refresh list window on return
                                      }, 
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        if(service.id != null) {
                                           _showDeleteConfirmation(context, service.id!, service.service_name);
                                           _loadServices(); // auto-reload list
                                        }
                                      }, 
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}