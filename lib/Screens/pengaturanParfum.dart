import 'package:app_laundry/Screens/addParfum.dart';
import 'package:app_laundry/Screens/editParfum.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class PengaturanParfumScreen extends StatefulWidget {
  const PengaturanParfumScreen({super.key});

  @override
  _PengaturanParfumScreenState createState() => _PengaturanParfumScreenState();
}

class _PengaturanParfumScreenState extends State<PengaturanParfumScreen> {
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
                        MaterialPageRoute(builder: (context) => AddParfumScreen()),
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

              // CARD: LIST DATA PARFUM (Sudah Dirapikan Layout-nya)
              Padding(
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
                          child: const Icon(Icons.spa, color: Colors.teal, size: 24),
                        ),
                        const SizedBox(width: 16), // Jarak horizontal antara ikon dan teks
                        
                        // Nama Parfum (Aman dari Overflow)
                        const Expanded(
                          child: Text(
                            "Akasia",
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
                                  MaterialPageRoute(builder: (context) => EditParfumScreen()),
                                );
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