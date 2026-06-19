import 'dart:async';
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
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
    String selectedOutlet = "N2Jewel"; 

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
                selectedOutlet: selectedOutlet,
                onOutletChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedOutlet = newValue;
                    });
                  }
                },
              ),
              CustomCardMenu(icon: Icons.person, title: "Pengaturan Akun", subtitle: "Ubah password akun anda", onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanAkunScreen()));
              },),
              CustomCardMenu(icon: Icons.store, title: "Pengaturan Outlet", subtitle: "Tambah, ubah, hapus outlet laundry", onTap: () { 
                Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanOutletScreen()));
               },),
              CustomCardMenu(icon: Icons.timer, title: "Pengaturan Durasi Layanan", subtitle: "Tambah, ubah, hapus durasi layanan", onTap: () {  
                Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanDurasiScreen()));
              },),
              CustomCardMenu(icon: Icons.dry_cleaning, title: "Pengaturan Layanan", subtitle: "Tambah, ubah, hapus layanan", onTap: () {                 
                Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanLayananScreen()));
               },),
              CustomCardMenu(icon: Icons.spa, title: "Pengaturan Parfum", subtitle: "Tambah, ubah, hapus parfum", onTap: () {  
                Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanParfumScreen()));
              },),
              CustomCardMenu(icon: Icons.discount, title: "Pengaturan Diskon", subtitle: "Tambah, ubah, hapus diskon", onTap: () { 
                Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanDiskonScreen()));
               },),
              CustomCardMenu(icon: Icons.delivery_dining, title: "Pengaturan Antar-Jemput", subtitle: "Tambah, ubah, hapus antar-jemput", onTap: () { 
                Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanAntarJemputScreen()));
               },),
              CustomCardMenu(icon: Icons.badge, title: "Pengaturan Kasir", subtitle: "Tambah, ubah, hapus Kasir", onTap: () { 
                Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanKasirScreen()));
               },),
              CustomCardMenu(icon: Icons.people, title: "Pengaturan Pelanggan", subtitle: "Tambah, ubah, hapus pelanggan", onTap: () { 
                Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerScreen()));
               },),
              CustomCardMenu(icon: Icons.receipt, title: "Pengaturan Nota", subtitle: "Atur tampilan nota", onTap: () { 
                Navigator.push(context, MaterialPageRoute(builder: (context) => PengaturanNotaScreen()));
               },),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () {}, 
                    label: Text("Keluar Akun"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                    ),
                    icon: Icon(Icons.power_settings_new,),
                    iconAlignment: IconAlignment.end,
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}