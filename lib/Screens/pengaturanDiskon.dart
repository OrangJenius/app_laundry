import 'package:app_laundry/Screens/addDiskon.dart';
import 'package:app_laundry/Screens/editDiskon.dart';
import 'package:app_laundry/Services/diskon_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class PengaturanDiskonScreen extends StatefulWidget {
  const PengaturanDiskonScreen({super.key, required this.store_id});
  final String store_id;

  @override
  _PengaturanDiskonScreenState createState() => _PengaturanDiskonScreenState();
}

class _PengaturanDiskonScreenState extends State<PengaturanDiskonScreen> {
  final diskonService = DiskonService();
  late Future<List<dynamic>> _diskonFuture; // Optimization: Store future reference

  @override
  void initState() {
    super.initState();
    _diskonFuture = diskonService.fetchdiskon(widget.store_id);
  }

  // Helper method to reload data after changes
  void _refreshData() {
    setState(() {
      _diskonFuture = diskonService.fetchdiskon(widget.store_id);
    });
  }

  void _deleteDiskon(String id) async {
    try{
      await diskonService.deletediskon(id);
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
            "Apakah Anda yakin ingin menghapus diskon $name?",
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
                _deleteDiskon(id);
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
              UpperBar2(title: "DISKON"),
              
              // BUTTON: Tambah Diskon
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, 
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Await the push, and refresh when returning back
                      await Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => AddDiskonScreen(store_id: widget.store_id)),
                      );
                      _refreshData();
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "+ Tambah Diskon",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),

              // CARD: LIST DATA Diskon
              FutureBuilder<List<dynamic>>(
                future: _diskonFuture, 
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
                        "Tidak ada data diskon",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final diskonList = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Safe list inside SingleChildScrollView
                    itemCount: diskonList.length,
                    itemBuilder: (context, index){
                      final discount = diskonList[index];

                      // ================= FORMATTING LOGIC =================
                      String formattedValue = "";
                      if (discount.tipe_diskon == "Persentase") {
                        formattedValue = "${discount.jumlah_diskon}%";
                      } else if (discount.tipe_diskon == "Nominal") {
                        formattedValue = "Rp. ${discount.jumlah_diskon}";
                      } else {
                        formattedValue = discount.jumlah_diskon.toString(); // Fallback
                      }

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
                                      Text(
                                        formattedValue, // 👈 Displays conditional format here
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15, // Bumped size slightly for prominence
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        discount.tipe_diskon,
                                        style: const TextStyle(
                                          color: Colors.grey, 
                                          fontSize: 12, 
                                          fontStyle: FontStyle.italic, 
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Tombol Aksi (Edit & Delete)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        // Pass specific object/id to your edit screen if needed
                                        await Navigator.push(
                                          context, 
                                          MaterialPageRoute(builder: (context) => EditDiskonScreen(store_id: discount.store_id, jumlah: discount.jumlah_diskon, id: discount.id, jenis: discount.tipe_diskon,)),
                                        );
                                        _refreshData();
                                      }, 
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showDeleteConfirmation(context, discount.id, discount.jumlah_diskon);
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