import 'package:app_laundry/Screens/dashboardKasir.dart';
import 'package:app_laundry/Screens/kasirMenu.dart';
import 'package:flutter/material.dart';

class KasirNavigationScreen extends StatefulWidget {
  final int currentPageIndex;
  final String store_id;
  final String cashier_id;
  const KasirNavigationScreen({super.key, required this.currentPageIndex, required this.store_id, required this.cashier_id});

  @override
  State<KasirNavigationScreen> createState() => _KasirNavigationScreenState();
}

class _KasirNavigationScreenState extends State<KasirNavigationScreen> {
  late int currentPageIndex;

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.currentPageIndex;
  }
  List<Widget> _getPages() {
    return [
      DashboardKasirScreen(selectedStoreId: widget.store_id),
      KasirMenuScreen(store_id: widget.store_id, cashier_id: widget.cashier_id,),
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
            selectedIcon: Icon(Icons.list_alt_outlined),
            icon: Icon(Icons.home_outlined),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.store),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}