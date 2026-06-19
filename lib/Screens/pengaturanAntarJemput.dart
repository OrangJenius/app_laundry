import 'package:app_laundry/Screens/addAntarJemput.dart';
import 'package:app_laundry/Screens/editAntarJemput.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class PengaturanAntarJemputScreen extends StatefulWidget {
  const PengaturanAntarJemputScreen({super.key});

  @override
  _PengaturanAntarJemputScreenState createState() => _PengaturanAntarJemputScreenState();
}

class _PengaturanAntarJemputScreenState extends State<PengaturanAntarJemputScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar2(title: "AntarJemput"),
              
              // BUTTON: Tambah AntarJemput
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, // PERBAIKAN: Mengganti Expanded dengan width full agar aman di SingleChildScrollView
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddAntarJemputScreen()));
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
                                "Dekat",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Rp. xxx.xxx",
                                style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal),
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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditAntarJemputScreen()));
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