import 'package:app_laundry/Screens/addParfum.dart';
import 'package:app_laundry/Screens/editParfum.dart';
import 'package:app_laundry/Services/parfum_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class PengaturanParfumScreen extends StatefulWidget {
  const PengaturanParfumScreen({super.key, required this.store_id});

  final String store_id;

  @override
  _PengaturanParfumScreenState createState() => _PengaturanParfumScreenState();
}

class _PengaturanParfumScreenState extends State<PengaturanParfumScreen> {
  
  final parfumService = ParfumService();
  
  Future <void> fetchParfum() async{
    try{
      await parfumService.fetchparfum(widget.store_id);
    }catch(e){
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error mengambil data $e"), backgroundColor: Colors.red,),
        );
      }
    }
  }

  void _deleteParfum(String id) async {
    try {
      await parfumService.deleteparfum(id);
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
              onPressed: () async {
                Navigator.pop(dialogContext); // Menutup dialog
                _deleteParfum(id);
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
              UpperBar2(title: "PARFUM"),
              
              // BUTTON: Tambah Parfum
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => AddParfumScreen(store_id: widget.store_id)),
                      );
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "+ Tambah Parfum",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),

              FutureBuilder(
                future: parfumService.fetchparfum(widget.store_id), 
                builder: (context, snapshot){
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
                        "Tidak ada data parfum",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  // 4. Jika data berhasil didapatkan
                  final parfum = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: parfum.length,
                    itemBuilder: (context, index){
                      final perfume = parfum[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Ikon Parfum dengan Container dekoratif
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Icon(Icons.cleaning_services, color: Colors.teal, size: 24),
                                ),
                                const SizedBox(width: 16), // Jarak horizontal antara ikon dan teks
                                
                                // Nama Parfum (Aman dari Overflow)
                                Expanded(
                                  child: Text(
                                    perfume.nama_parfum,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                
                                // Tombol Aksi (Edit & Delete)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context, 
                                          MaterialPageRoute(builder: (context) => EditParfumScreen(id: perfume.id!, nama: perfume.nama_parfum, store_id: perfume.store_id,)),
                                        );
                                      }, 
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showDeleteConfirmation(context, perfume.id!, perfume.nama_parfum);
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