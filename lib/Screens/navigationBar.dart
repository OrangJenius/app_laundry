import 'dart:async';
import 'package:app_laundry/Screens/home.dart';
import 'package:app_laundry/Screens/Pesanan.dart';
import 'package:app_laundry/Screens/laporan.dart';
import 'package:app_laundry/Screens/settings.dart';
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.currentPageIndex});
  
  final int currentPageIndex;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // 1. Deklarasikan variabel tanpa langsung mengisi nilainya dengan 0
  late int currentPageIndex;

  // List halaman dipindahkan ke variabel biasa agar lebih efisien
  final List<Widget> _pages = [
    HomeScreen(),
    PesananScreen(),
    LaporanScreen(),
    SettingsScreen()
  ];

  @override
  void initState() {
    super.initState();
    // 2. Tangkap nilai awal yang dikirim dari constructor di sini
    currentPageIndex = widget.currentPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dynamic body swaps the view based on the index
      body: _pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const [ // Ditambahkan const untuk optimasi performa widget statis
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}