import 'package:app_laundry/Screens/addDiskon.dart';
import 'package:app_laundry/Screens/editDiskon.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class PengaturanDiskonScreen extends StatefulWidget {
  const PengaturanDiskonScreen({super.key});

  @override
  _PengaturanDiskonScreenState createState() => _PengaturanDiskonScreenState();
}

class _PengaturanDiskonScreenState extends State<PengaturanDiskonScreen> {
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
                  width: double.infinity, // PERBAIKAN: Mengganti Expanded dengan width full agar aman di SingleChildScrollView
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddDiskonScreen()));
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
                                "5%",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Diskon Persentase",
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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditDiskonScreen()));
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