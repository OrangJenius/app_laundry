import 'package:app_laundry/Screens/addLayanan.dart';
import 'package:app_laundry/Screens/editLayanan.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:flutter/material.dart';

class PengaturanLayananScreen extends StatefulWidget {
  const PengaturanLayananScreen({super.key});

  @override
  _PengaturanLayananScreenState createState() => _PengaturanLayananScreenState();
}

class _PengaturanLayananScreenState extends State<PengaturanLayananScreen> {
  // 1. Tentukan state awal yang dipilih (harus berupa Set)
  Set<String> _selectedFilter = {'Semua'};

  @override
  Widget build(BuildContext context) { // PERBAIKAN: Mengganti Object menjadi BuildContext
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar2(title: "LAYANAN"),
              
              const SizedBox(height: 16),

              // 2. Penerapan SegmentedButton yang benar dan rapi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity, // Memenuhi lebar layar
                  child: SegmentedButton<String>(
                    // Konfigurasi visual agar serasi dengan tema gelap & amber aplikasi Anda
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
                    // Menyusun segmen pilihan
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'Semua',
                        label: Text('Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      ButtonSegment<String>(
                        value: 'Reguler',
                        label: Text('Reguler', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      ButtonSegment<String>(
                        value: 'Ekspres',
                        label: Text('Ekspres', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      ButtonSegment<String>(
                        value: 'Kilat',
                        label: Text('Kilat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    // Menentukan nilai yang aktif saat ini
                    selected: _selectedFilter,
                    // Mengubah state ketika user berpindah tab filter
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedFilter = newSelection;
                      });
                      
                      // Anda bisa mencetak nilainya untuk debugging backend nanti
                      print("Filter terpilih: ${newSelection.first}");
                    },
                  ),
                ),
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddLayananScreen()));
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
                        Expanded( // Menjaga agar text tidak overflow menembus tombol aksi
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // PERBAIKAN: Rata kiri agar rapi
                            children: const [
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
                        
                        // Tombol Aksi (Edit & Delete)
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