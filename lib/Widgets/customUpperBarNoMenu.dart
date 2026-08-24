import 'package:app_laundry/Screens/navigationBar.dart';
import 'package:flutter/material.dart';

class UpperBar2 extends StatelessWidget {
  final String title;

  const UpperBar2({
    super.key, // Good practice to include the key parameter
    required this.title, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0), // Padding disesuaikan agar tinggi bar pas
        child: Row(
          children: [
            IconButton(
              // PERBAIKAN: Dibungkus dengan anonymous function () {}
              onPressed: () {
                Navigator.pop(context);
              }, 
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
            const SizedBox(width: 8), // Memberi jarak antara tombol back dan teks judul
            Text(
              title, 
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperBar3 extends StatelessWidget {
  final String title;
  final String owner_id;

  const UpperBar3({
    super.key, // Good practice to include the key parameter
    required this.title, required this.owner_id, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0), // Padding disesuaikan agar tinggi bar pas
        child: Row(
          children: [
            IconButton(
              // PERBAIKAN: Dibungkus dengan anonymous function () {}
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MainNavigationScreen(currentPageIndex: 1, owner_id: owner_id)));
              }, 
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
            const SizedBox(width: 8), // Memberi jarak antara tombol back dan teks judul
            Text(
              title, 
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}