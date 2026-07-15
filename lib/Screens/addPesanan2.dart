import 'package:app_laundry/Screens/rincianPesanan.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class AddPesanan2Screen extends StatefulWidget {
  final String nama;
  final String nomor;
  final String alamat;
  
  // Jika Anda juga mempassing jenis paket (misal: "Reguler 72 Jam") dari card sebelumnya,
  // Anda bisa mengaktifkan parameter di bawah ini:
  // final String selectedPackage;

  const AddPesanan2Screen({
    super.key, 
    required this.nama, 
    required this.nomor, 
    required this.alamat,
    // this.selectedPackage = "Reguler 72 Jam",
  });

  @override
  _AddPesanan2ScreenState createState() => _AddPesanan2ScreenState();
}

class _AddPesanan2ScreenState extends State<AddPesanan2Screen> {
  // State untuk menyimpan jumlah item laundry
  int _itemCount = 0;
  
  // Harga per kemeja
  final int _hargaPerItem = 15000;
  
  // Controller untuk menangani input teks angka secara langsung
  final TextEditingController _countController = TextEditingController();

  // --- State untuk Modal Bottom Sheet (Atur Pesanan) ---
  String _selectedParfum = 'Lavender';
  String _selectedAntarJemput = 'Tidak';
  String _selectedDiskon = 'Tidak';
  final TextEditingController _catatanController = TextEditingController();

  // List data untuk Dropdown
  final List<String> _parfumList = ['Lavender', 'Moly Fresh', ' Sakura', 'Lemon'];
  final List<String> _antarJemputList = ['Tidak', 'Gratis - Rp. 0', 'Dekat - Rp. 5.000', 'Jauh - Rp. 15.000'];
  final List<String> _diskonList = ['Tidak', '5%', '10%', '15%'];

  @override
  void initState() {
    super.initState();
    _countController.text = _itemCount.toString();
  }

  @override
  void dispose() {
    _countController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // Fungsi untuk memperbarui jumlah item dan menyelaraskan TextField
  void _updateCount(int newCount) {
    if (newCount >= 0) {
      setState(() {
        _itemCount = newCount;
        _countController.text = _itemCount.toString();
      });
    }
  }

  // --- MODAL BOTTOM SHEET: ATUR PESANAN ---
  void _showPesananMenu(BuildContext context) {
    // Hitung total harga saat menu dibuka untuk di-pass ke screen berikutnya
    int totalHarga = _itemCount * _hargaPerItem;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Membuat bottom sheet bisa menyesuaikan tinggi keyboard
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20.0,
                left: 20.0,
                right: 20.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.0, // Hindari keyboard overlap
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar Pemanis UI
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title: Atur Pesanan (Center)
                  const Center(
                    child: Text(
                      "Atur Pesanan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // 1. Dropdown Parfum
                  _buildLabel("Parfum"),
                  _buildDropdownField(
                    value: _selectedParfum,
                    items: _parfumList,
                    onChanged: (value) {
                      setModalState(() => _selectedParfum = value!);
                    },
                  ),
                  const SizedBox(height: 14.0),

                  // 2. Dropdown Antar-Jemput
                  _buildLabel("Antar-Jemput"),
                  _buildDropdownField(
                    value: _selectedAntarJemput,
                    items: _antarJemputList,
                    onChanged: (value) {
                      setModalState(() => _selectedAntarJemput = value!);
                    },
                  ),
                  const SizedBox(height: 14.0),

                  // 3. Dropdown Diskon
                  _buildLabel("Diskon"),
                  _buildDropdownField(
                    value: _selectedDiskon,
                    items: _diskonList,
                    onChanged: (value) {
                      setModalState(() => _selectedDiskon = value!);
                    },
                  ),
                  const SizedBox(height: 14.0),

                  // 4. Input Catatan (Dengan Ikon)
                  _buildLabel("Catatan"),
                  TextField(
                    controller: _catatanController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Masukkan catatan pesanan...",
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                      prefixIcon: const Icon(Icons.note_alt_outlined, color: Colors.amber),
                      filled: true,
                      fillColor: Colors.grey[850],
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // 5. Tombol Aksi: Buat Pesanan
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Membuka RincianPesananScreen dengan mempassing seluruh data data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RincianPesananScreen(
                              nama: widget.nama,
                              nomor: widget.nomor,
                              alamat: widget.alamat,
                              jumlahItem: _itemCount,
                              namaItem: "Baju Kemeja",
                              parfum: _selectedParfum,
                              antarJemput: _selectedAntarJemput,
                              diskon: _selectedDiskon,
                              catatan: _catatanController.text,
                              totalHarga: totalHarga,
                            ),
                          ),
                        );
                        
                        print("Pesanan Dibuat & Data Dikirim!");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text(
                        "Buat Pesanan",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper: Widget Label Form
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Helper: Widget Dropdown Kustomisasi
  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.grey[850],
          icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalHarga = _itemCount * _hargaPerItem;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            UpperBar2(title: "TAMBAHKAN LAYANAN"),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // --- BAR PENCARIAN ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: const [
                          Expanded(
                            child: SearchBar(
                              hintText: "Cari nama layanan",
                              leading: Icon(Icons.search),
                              elevation: WidgetStatePropertyAll(1),
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                      ),
                    ),
                    
                    // --- KARTU LAYANAN (Baju Kemeja) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Reguler - Satuan",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 13,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic),
                                    ),
                                    const Text(
                                      "Baju Kemeja",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Rp. $_hargaPerItem",
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              
                              _itemCount == 0
                                  ? IconButton(
                                      onPressed: () => _updateCount(1),
                                      icon: const Icon(Icons.add_circle, color: Colors.amber, size: 32),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () => _updateCount(_itemCount - 1),
                                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 26),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                        Container(
                                          width: 50,
                                          height: 35,
                                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: TextField(
                                            controller: _countController,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 15, 
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.zero,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(6),
                                                borderSide: const BorderSide(color: Colors.grey),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(6),
                                                borderSide: const BorderSide(color: Colors.amber),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                int? parsed = int.tryParse(value);
                                                if (parsed != null) {
                                                  _itemCount = parsed;
                                                } else if (value.isEmpty) {
                                                  _itemCount = 0;
                                                }
                                              });
                                            },
                                            onSubmitted: (value) {
                                              if (value.isEmpty || int.tryParse(value) == 0) {
                                                _updateCount(0);
                                              }
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _updateCount(_itemCount + 1),
                                          icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 26),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
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
          ],
        ),
      ),
      
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.black54, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.nama,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        widget.nomor,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text("0 Kg  •  ", style: TextStyle(color: Colors.black54, fontSize: 13)),
                  Text("$_itemCount pcs  •  ", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                  const Text("0 m", style: TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            ),
            
            // TOMBOL AKSI: Klik di sini untuk memunculkan Atur Pesanan Sheet
            InkWell(
              onTap: () => _showPesananMenu(context),
              child: Container(
                color: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Rp. ${totalHarga.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}", 
                          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Total Layanan",
                          style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text(
                      "Lanjut",
                      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}