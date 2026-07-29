import 'dart:async';
import 'package:app_laundry/Screens/home.dart';
import 'package:app_laundry/Screens/Pesanan.dart';
import 'package:app_laundry/Screens/laporan.dart';
import 'package:app_laundry/Screens/settings.dart';
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.currentPageIndex, required this.owner_id});
  
  final int currentPageIndex;
  final String owner_id;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int currentPageIndex;
  
  // KUNCINYA DI SINI: State global untuk menyimpan ID Toko yang aktif
  String? _currentSelectedStoreId;

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.currentPageIndex;
  }

  // Fungsi callback untuk mengubah ID toko dari HomeScreen
  void _handleStoreChanged(String? newStoreId) {
    setState(() {
      _currentSelectedStoreId = newStoreId;
    });
  }

  // Ubah List menjadi fungsi List agar bisa menerima data dinamis terbaru
  List<Widget> _getPages() {
    return [
      HomeScreen(
        selectedStoreId: _currentSelectedStoreId,
        onStoreChanged: _handleStoreChanged,
        owner_id: widget.owner_id,
      ),
      PesananScreen(selectedStoreId: _currentSelectedStoreId,
        onStoreChanged: _handleStoreChanged,), // Siap menerima filter toko
      LaporanScreen(selectedStoreId: _currentSelectedStoreId,
        onStoreChanged: _handleStoreChanged,), // Siap menerima filter toko
      SettingsScreen(selectedStoreId: _currentSelectedStoreId,
        onStoreChanged: _handleStoreChanged, owner_id: widget.owner_id),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ambil halaman secara dinamis lewat fungsi _getPages()
      body: IndexedStack(
          index: currentPageIndex,
          children: _getPages(),
        ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const [
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