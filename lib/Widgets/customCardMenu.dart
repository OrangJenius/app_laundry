import 'package:flutter/material.dart';

// --- REUSABLE CUSTOM CARD MENU WIDGET ---
class CustomCardMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap; // PERBAIKAN 1: Tambahkan properti fungsi callback klik

  const CustomCardMenu({
    super.key, // Ditambahkan key untuk mengikuti standar Flutter terbaru
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap, // PERBAIKAN 2: Masukkan ke constructor
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.black38, fontSize: 12, fontStyle: FontStyle.italic),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap, // PERBAIKAN 3: Pasang fungsi ke onTap milik ListTile
        ),
      ),
    );
  }
}