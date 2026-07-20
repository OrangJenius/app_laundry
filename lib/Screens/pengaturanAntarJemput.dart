import 'package:app_laundry/Screens/addAntarJemput.dart';
import 'package:app_laundry/Screens/editAntarJemput.dart';
import 'package:app_laundry/Services/antarJemput_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class PengaturanAntarJemputScreen extends StatefulWidget {
  final String store_id;
  const PengaturanAntarJemputScreen({super.key, required this.store_id});

  @override
  _PengaturanAntarJemputScreenState createState() => _PengaturanAntarJemputScreenState();
}

class _PengaturanAntarJemputScreenState extends State<PengaturanAntarJemputScreen> {
  final antarJemputService = AntarJemputService();

  void _deleteAntarJemput(String id) async {
    try{
      await antarJemputService.deleteantarjemput(id);
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil dihapus!"), backgroundColor: Colors.green,)
        );
      }
    }catch (e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data gagal dihapus, error: $e"), backgroundColor: Colors.red,)
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
            "Apakah Anda yakin ingin menghapus antar jemput $name?",
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
              onPressed: () async {
                Navigator.pop(dialogContext); // Menutup dialog
                _deleteAntarJemput(id);
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
              UpperBar2(title: "ANTAR JEMPUT"),
              
              // BUTTON: Tambah AntarJemput
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, // PERBAIKAN: Mengganti Expanded dengan width full agar aman di SingleChildScrollView
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddAntarJemputScreen(store_id: widget.store_id,)));
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "+ Tambah Antar-Jemput",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),

              // CARD: LIST DATA AntarJemput
              FutureBuilder(
                future: antarJemputService.fetchantarjemput(widget.store_id), 
                builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Gagal memuat data: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Tidak ada data antar jemput",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final antarJemput = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: antarJemput.length,
                    itemBuilder: (context, index) {
                      final aj = antarJemput[index];
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
                                      Text(
                                        aj.jarak,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Rp. ${aj.harga}",
                                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal),
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
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditAntarJemputScreen(id: aj.id!, store_id: aj.store_id, jarak: aj.jarak, harga: aj.harga,)));
                                      }, 
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showDeleteConfirmation(context, aj.id!, aj.jarak);
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