import 'package:app_laundry/Screens/addLayanan.dart';
import 'package:app_laundry/Screens/editLayanan.dart';
import 'package:app_laundry/Services/durasi_service.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:flutter/material.dart';

class PengaturanLayananScreen extends StatefulWidget {
  const PengaturanLayananScreen({super.key, required this.store_id});
  final String? store_id;

  @override
  _PengaturanLayananScreenState createState() => _PengaturanLayananScreenState();
}

class _PengaturanLayananScreenState extends State<PengaturanLayananScreen> {
  Set<String> _selectedFilter = {'Semua'};
  final durasiService = DurasiService();
  
  // Tampung object Future di sini, inisialisasinya nanti di initState
  late Future<List<dynamic>> _durasiFuture;

  @override
  void initState() {
    super.initState();
    // PERBAIKAN 1: Inisialisasi Future di dalam initState agar aman mengakses 'widget'
    _durasiFuture = durasiService.fetchDurasi(widget.store_id!);
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

              // PERBAIKAN 2: Membungkus SegmentedButton dengan FutureBuilder
              FutureBuilder<List<dynamic>>(
                future: _durasiFuture,
                builder: (context, snapshot) {
                  // Berikan fallback list kosong jika data belum siap/error
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
                        // Menyusun segmen pilihan secara dinamis
                        segments: <ButtonSegment<String>>[
                          const ButtonSegment<String>(
                            value: 'Semua',
                            label: Text('Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          // Looping data durasi dari API
                          ...durasiList.map((item) {
                            final name = item.duration_name.toString();
                            return ButtonSegment<String>(
                              value: name,
                              label: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            );
                          }),
                        ],
                        selected: _selectedFilter,
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedFilter = newSelection;
                          });
                          print("Filter terpilih: ${newSelection.first}");
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
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddLayananScreen(store_id: widget.store_id,)));
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Reguler - Satuan",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic
                                ),
                              ),
                              Text(
                                "Baju Kemeja",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Rp. xx.xxx",
                                style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditLayananScreen()));
                              }, 
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () {
                                // Aksi Delete
                              }, 
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
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