// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:app_laundry/Screens/addOutlet.dart';
import 'package:app_laundry/Screens/editOutlet.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class PengaturanOutletScreen extends StatefulWidget {
  const PengaturanOutletScreen({
    super.key,
    required this.owner_id,
  });
  final String owner_id;

  @override
  _PengaturanOutletScreenState createState() => _PengaturanOutletScreenState();
}

class _PengaturanOutletScreenState extends State<PengaturanOutletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar2(title: "OUTLET"),
              
              // BUTTON: Tambah Outlet
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, // PERBAIKAN: Mengganti Expanded dengan width full agar aman di SingleChildScrollView
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => AddOutletScreen(owner_id: widget.owner_id,)),
                      );
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "+ Tambah Outlet",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),

              // CARD: LIST DATA OUTLET
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Icon Toko
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // PERBAIKAN: Mengganti grey[1] menjadi grey[200] yang valid
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(Icons.store, color: Colors.black87, size: 28),
                        ),
                        const SizedBox(width: 12),
                        
                        // Detail Info Toko
                        Expanded( // Menjaga agar text tidak overflow menembus tombol aksi
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // PERBAIKAN: Rata kiri agar rapi
                            children: const [
                              Text(
                                "N2Jewel Laundry",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "alamat",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                "0812-3456-7890",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditOutletScreen()));
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
              )
            ],
          ),
        ),
      ),
    );
  }
}