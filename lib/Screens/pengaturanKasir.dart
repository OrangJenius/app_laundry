// import 'package:app_laundry/Screens/addKasir.dart';
// import 'package:app_laundry/Screens/editKasir.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class PengaturanKasirScreen extends StatefulWidget {
  const PengaturanKasirScreen({super.key});

  @override
  _PengaturanKasirScreenState createState() => _PengaturanKasirScreenState();
}

class _PengaturanKasirScreenState extends State<PengaturanKasirScreen> {
  // 1. Definisikan Controller resmi dari Flutter untuk mengontrol slide up/down
  final ExpansibleController _dropdownController = ExpansibleController();

  // State untuk menyimpan nilai switch fitur kasir
  bool _statNominalJumlah = false;
  bool _statKiloanSatuanMeteran = false;
  bool _hapusPelanggan = false;
  bool _batalPesanan = false;
  bool _lihatSaldoKas = false;
  bool _mengurangiKas = false;
  bool _lihatMutasiKas = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar2(title: "Kasir"),
              
              // BUTTON: Tambah Kasir
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, 
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => AddKasirScreen()));
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "+ Tambah Kasir",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),

              // ==================== DROPDOWN SLIDE OPEN / SLIDE CLOSE ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    // border: BorderSide(color: Colors.grey[700]!),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      controller: _dropdownController, // Pasang controllernya di sini
                      leading: const Icon(Icons.shield_outlined, color: Colors.amber, size: 22),
                      title: const Text(
                        "Pengaturan Hak Akses Kasir",
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      iconColor: Colors.amber,
                      collapsedIconColor: Colors.amber,
                      childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      children: [
                        const Divider(color: Colors.grey, height: 1),
                        const SizedBox(height: 8),
                        _buildSwitchRow("Statistik Harian (Nominal, Jumlah)", _statNominalJumlah, (val) {
                          setState(() => _statNominalJumlah = val);
                        }),
                        const Divider(color: Colors.grey),
                        _buildSwitchRow("Statistik Harian (Kiloan, Satuan, Meteran)", _statKiloanSatuanMeteran, (val) {
                          setState(() => _statKiloanSatuanMeteran = val);
                        }),
                        const Divider(color: Colors.grey),
                        _buildSwitchRow("Menghapus Pelanggan", _hapusPelanggan, (val) {
                          setState(() => _hapusPelanggan = val);
                        }),
                        const Divider(color: Colors.grey),
                        _buildSwitchRow("Membatalkan Pesanan", _batalPesanan, (val) {
                          setState(() => _batalPesanan = val);
                        }),
                        const Divider(color: Colors.grey),
                        _buildSwitchRow("Lihat Saldo Kas", _lihatSaldoKas, (val) {
                          setState(() => _lihatSaldoKas = val);
                        }),
                        const Divider(color: Colors.grey),
                        _buildSwitchRow("Mengurangi Kas", _mengurangiKas, (val) {
                          setState(() => _mengurangiKas = val);
                        }),
                        const Divider(color: Colors.grey),
                        _buildSwitchRow("Lihat Mutasi Kas", _lihatMutasiKas, (val) {
                          setState(() => _lihatMutasiKas = val);
                        }),
                        const SizedBox(height: 16),
                        
                        // TOMBOL AKSI UNTUK MERAPTIKAN / SLIDE CLOSE KE ATAS
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Fungsi bawaan Flutter untuk menutup slide secara mulus
                              _dropdownController.collapse(); 
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
              // =======================================================================================

              // CARD: LIST DATA Kasir
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Card(
                          color: Colors.grey,
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.person_2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "John Doe",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "ID Kasir",
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Row(
                              children: [
                                const Text(
                                  "XXX-XXXXXXX",
                                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 24,
                                  width: 32,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: (){}, 
                                    icon: const Icon(Icons.copy, size: 16)
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {}, 
                          icon: const Icon(Icons.edit, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () {}, 
                          icon: const Icon(Icons.delete, color: Colors.red),
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