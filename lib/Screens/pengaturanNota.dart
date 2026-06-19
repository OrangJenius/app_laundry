import 'package:flutter/material.dart';
// Sesuaikan dengan lokasi file custom upper bar Anda jika diperlukan
// import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class PengaturanNotaScreen extends StatefulWidget {
  const PengaturanNotaScreen({super.key});

  @override
  _PengaturanNotaScreenState createState() => _PengaturanNotaScreenState();
}

class _PengaturanNotaScreenState extends State<PengaturanNotaScreen> {
  // Perubahan 1: Menggunakan ExpansionTileController bawaan Flutter
  // Perubahan 2: Dipisah menjadi 2 controller agar tidak konflik satu sama lain
  final ExpansionTileController _dropdownController1 = ExpansionTileController();
  final ExpansionTileController _dropdownController2 = ExpansionTileController();
  
  final TextEditingController _ketentuanController = TextEditingController();

  // State untuk menyimpan nilai switch fitur kasir
  bool _logoOutlet = false;
  bool _noHandphonePelanggan = false;
  bool _alamatPelanggan = false;

  @override
  void dispose() {
    // Selalu bersihkan controller setelah tidak digunakan untuk menghindari memory leak
    _ketentuanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Menggunakan widget placeholder jika UpperBar2 belum diimport dengan benar
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "PENGATURAN NOTA",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.image, color: Colors.white, size: 40),
                  ),
                  FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: Colors.amber,
                    child: const Icon(Icons.camera, color: Colors.black),
                  )
                ],
              ),
              
              // EXPANSION TILE 1
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      controller: _dropdownController1, // Pasang controller pertama
                      title: const Text(
                        "Nota Pelanggan",
                        style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500), // Diubah ke hitam karena background putih
                      ),
                      iconColor: Colors.amber,
                      collapsedIconColor: Colors.amber,
                      childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      children: [
                        const Divider(color: Colors.grey, height: 1),
                        const SizedBox(height: 8),
                        _buildSwitchRow("Logo Outlet", _logoOutlet, (val) {
                          setState(() => _logoOutlet = val);
                        }),
                        const Divider(color: Colors.grey),
                        _buildSwitchRow("No Handphone Pelanggan", _noHandphonePelanggan, (val) {
                          setState(() => _noHandphonePelanggan = val);
                        }),
                        const Divider(color: Colors.grey),
                        _buildSwitchRow("Alamat Pelanggan", _alamatPelanggan, (val) {
                          setState(() => _alamatPelanggan = val);
                        }),
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _dropdownController1.collapse(); // Menutup tile pertama
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.amber),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_up, color: Colors.amber, size: 18),
                            label: const Text(
                              "Tutup Pengaturan",
                              style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // EXPANSION TILE 2
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      controller: _dropdownController1, // Pasang controller pertama
                      title: const Text(
                        "Nota Produksi",
                        style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500), // Diubah ke hitam karena background putih
                      ),
                      iconColor: Colors.amber,
                      collapsedIconColor: Colors.amber,
                      childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      children: [
                        const Divider(color: Colors.grey, height: 1),
                        const SizedBox(height: 8),
                        _buildSwitchRow("Logo Outlet", _logoOutlet, (val) {
                          setState(() => _logoOutlet = val);
                        }),
                        const Divider(color: Colors.grey),
                        _buildSwitchRow("No Handphone Pelanggan", _noHandphonePelanggan, (val) {
                          setState(() => _noHandphonePelanggan = val);
                        }),
                        const Divider(color: Colors.grey),
                        _buildSwitchRow("Alamat Pelanggan", _alamatPelanggan, (val) {
                          setState(() => _alamatPelanggan = val);
                        }),
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _dropdownController1.collapse(); // Menutup tile pertama
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.amber),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_up, color: Colors.amber, size: 18),
                            label: const Text(
                              "Tutup Pengaturan",
                              style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_city, color: Colors.amberAccent),
                    const SizedBox(width: 12, height: 64,),
                    Expanded(
                      child: TextField(
                        controller: _ketentuanController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'Ketentuan',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, 
                  height: 48, 
                  child: ElevatedButton(
                    onPressed: () {
                      // Perubahan 3: Menggunakan .text untuk print isi dari TextField
                      print("Alamat: ${_ketentuanController.text}");
                      print("Logo Outlet: $_logoOutlet");
                      print("No HP: $_noHandphonePelanggan");
                      print("Alamat Pelanggan: $_alamatPelanggan");
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), 
                      ),
                    ),
                    child: const Text(
                      "Simpan",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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

  Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ),
        Transform.scale(
          scale: 0.85, 
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.amber,
          ),
        ),
      ],
    );
  }
}