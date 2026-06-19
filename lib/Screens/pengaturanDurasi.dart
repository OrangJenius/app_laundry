import 'package:app_laundry/Screens/addDurasi.dart';
import 'package:app_laundry/Screens/editDurasi.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class PengaturanDurasiScreen extends StatefulWidget {
  const PengaturanDurasiScreen({super.key});

  @override
  _PengaturanDurasiScreenState createState() => _PengaturanDurasiScreenState();
}

class _PengaturanDurasiScreenState extends State<PengaturanDurasiScreen> {
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddDurasiScreen()));
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
                              Row(
                                children: [
                                  Text(
                                    "72 ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "jam",
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Reguler",
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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditDurasiScreen()));
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