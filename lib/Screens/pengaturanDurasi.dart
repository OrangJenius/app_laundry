import 'package:app_laundry/Screens/addDurasi.dart';
import 'package:app_laundry/Screens/editDurasi.dart';
import 'package:app_laundry/Services/durasi_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class PengaturanDurasiScreen extends StatefulWidget {
  const PengaturanDurasiScreen({super.key, required this.store_id});
  final String? store_id;

  @override
  _PengaturanDurasiScreenState createState() => _PengaturanDurasiScreenState();
}

class _PengaturanDurasiScreenState extends State<PengaturanDurasiScreen> {
  final durasiService = DurasiService();

    void _deleteDurasi(String durasiId) async {
    try {
      await durasiService.deleteDurasi(durasiId);
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

    // Fungsi untuk memunculkan Dialog Konfirmasi (Pop-up) sebelum hapus
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
            "Apakah Anda yakin ingin menghapus durasi $name?",
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
                _deleteDurasi(id); // Menjalankan fungsi hapus data
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar2(title: "DURASI"),
              
              // BUTTON: Tambah Durasi
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, // PERBAIKAN: Mengganti Expanded dengan width full agar aman di SingleChildScrollView
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddDurasiScreen(store_id: widget.store_id,)));
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "+ Tambah Durasi",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),

              // CARD: LIST DATA Durasi
              FutureBuilder <List<dynamic>>(
                future: durasiService.fetchDurasi(widget.store_id as String), 
                builder: (context, snapshot) {
                   if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    );
                  }
                  
                  // 2. Kondisi jika terjadi error saat fetch data
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Gagal memuat data: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  // 3. Kondisi jika data kosong
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Tidak ada data durasi",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  // 4. Jika data berhasil didapatkan
                  final durasi = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: durasi.length,
                    itemBuilder: (context, index) {
                      final duration = durasi[index];

                      return Padding(
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
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            duration.hours,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const Text(
                                            " jam",
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        duration.duration_name,
                                        style: TextStyle(color: Colors.black, fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
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
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditDurasiScreen(durasiId: duration.id, nama: duration.duration_name, jam: duration.hours,)));
                                      }, 
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showDeleteConfirmation(context, duration.id, duration.duration_name);
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
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}