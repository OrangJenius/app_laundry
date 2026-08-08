import 'dart:async';
import 'package:app_laundry/Services/auth_service.dart';
import 'package:app_laundry/Screens/customers.dart';
import 'package:app_laundry/Screens/pengaturanAkun.dart';
import 'package:app_laundry/Screens/pengaturanAntarJemput.dart';
import 'package:app_laundry/Screens/pengaturanDiskon.dart';
import 'package:app_laundry/Screens/pengaturanDurasi.dart';
import 'package:app_laundry/Screens/pengaturanKasir.dart';
import 'package:app_laundry/Screens/pengaturanLayanan.dart';
import 'package:app_laundry/Screens/pengaturanNota.dart';
import 'package:app_laundry/Screens/pengaturanOutlet.dart';
import 'package:app_laundry/Screens/pengaturanParfum.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBar.dart';
import 'package:app_laundry/Widgets/customCardMenu.dart';

class SettingsScreen extends StatefulWidget {
  final String? selectedStoreId;
  final ValueChanged<String?> onStoreChanged;
  final String owner_id;

  const SettingsScreen({super.key, this.selectedStoreId, required this.onStoreChanged, required this.owner_id});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Hapus baris 'String selectedOutlet = "N2Jewel";' agar tidak bentrok dengan data global

  final authService = AuthService();

  void logout() async {
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar(
                title: "P E N G A T U R A N",
                // 2. Gunakan nilai toko yang dikirim oleh parent widget
                selectedOutlet: widget.selectedStoreId ?? "Pilih Outlet",
                onOutletChanged: widget.onStoreChanged
              ),
              CustomCardMenu(
                icon: Icons.person,
                title: "Pengaturan Akun",
                subtitle: "Ubah password akun anda",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanAkunScreen()));
                },
              ),
              CustomCardMenu(
                icon: Icons.store,
                title: "Pengaturan Outlet",
                subtitle: "Tambah, ubah, hapus outlet laundry",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanOutletScreen(owner_id: widget.owner_id,)));
                },
              ),
              CustomCardMenu(
                icon: Icons.timer,
                title: "Pengaturan Durasi Layanan",
                subtitle: "Tambah, ubah, hapus durasi layanan",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanDurasiScreen(store_id: widget.selectedStoreId,)));
                },
              ),
              CustomCardMenu(
                icon: Icons.dry_cleaning,
                title: "Pengaturan Layanan",
                subtitle: "Tambah, ubah, hapus layanan",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanLayananScreen(store_id: widget.selectedStoreId,)));
                },
              ),
              CustomCardMenu(
                icon: Icons.cleaning_services,
                title: "Pengaturan Parfum",
                subtitle: "Tambah, ubah, hapus parfum",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanParfumScreen(store_id: widget.selectedStoreId!,)));
                },
              ),
              CustomCardMenu(
                icon: Icons.discount,
                title: "Pengaturan Diskon",
                subtitle: "Tambah, ubah, hapus diskon",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanDiskonScreen(store_id: widget.selectedStoreId!,)));
                },
              ),
              CustomCardMenu(
                icon: Icons.delivery_dining,
                title: "Pengaturan Antar-Jemput",
                subtitle: "Tambah, ubah, hapus antar-jemput",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanAntarJemputScreen(store_id: widget.selectedStoreId!,)));
                },
              ),
              CustomCardMenu(
                icon: Icons.badge,
                title: "Pengaturan Kasir",
                subtitle: "Tambah, ubah, hapus Kasir",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanKasirScreen(store_id: widget.selectedStoreId!, owner_id: widget.owner_id,)));
                },
              ),
              CustomCardMenu(
                icon: Icons.people,
                title: "Pengaturan Pelanggan",
                subtitle: "Tambah, ubah, hapus pelanggan",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerScreen(store_id:widget.selectedStoreId,)));
                },
              ),
              CustomCardMenu(
                icon: Icons.receipt,
                title: "Pengaturan Nota",
                subtitle: "Atur tampilan nota",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanNotaScreen(store_id: widget.selectedStoreId!,)));
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      logout();
                    },
                    label: const Text("Keluar Akun"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                    ),
                    icon: const Icon(Icons.power_settings_new),
                    iconAlignment: IconAlignment.end,
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