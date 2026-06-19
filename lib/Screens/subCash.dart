import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class SubCashScreen extends StatefulWidget {
  const SubCashScreen({super.key});

  @override
  _SubCashScreenState createState() => _SubCashScreenState();
}

class _SubCashScreenState extends State<SubCashScreen> {
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  // Variabel untuk menyimpan status pilihan tipe kas
  String? _selectedTipeKas; 

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
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
              UpperBar2(title: "PENGURANGAN CASH"),
              
              // ================= HEADER: SALDO KAS =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Text(
                          "Saldo Kas",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= DISPLAY SALDO TUNAI & NON-TUNAI =================
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), 
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.attach_money, color: Colors.black87),
                                SizedBox(width: 8),
                                Text("Saldo Tunai", style: TextStyle(color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 16), 
                            Row(
                              children: const [
                                Icon(Icons.monetization_on_outlined, color: Colors.black87),
                                SizedBox(width: 8),
                                Text("Saldo Non-Tunai", style: TextStyle(color: Colors.black87)),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end, // Diubah ke end agar teks rata kanan rapi
                          children: const [
                            Text(
                              "Rp. x.xxx.xxx", 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            SizedBox(height: 16), // Disamakan tinggi jedanya agar sejajar horizontal
                            Text(
                              "Rp. xx.xxx.xxx", 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= FIELD 1: TIPE CASH (DROPDOWN) =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.grey[800], // Mengubah background menu dropdown agar match bertema dark
                        style: const TextStyle(color: Colors.white),
                        value: _selectedTipeKas,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'Nama Cash / Tipe Kas',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        items: ["Tunai", "Non-Tunai"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedTipeKas = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ================= FIELD 2: JUMLAH CASH (INPUT ANGKA) =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _jumlahController,
                        keyboardType: TextInputType.number, // Menampilkan keyboard angka untuk nominal uang
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          prefixText: "Rp. ", // Memberi petunjuk rupiah di depan input
                          prefixStyle: const TextStyle(color: Colors.amberAccent),
                          labelText: 'Jumlah Nominal Cash',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= FIELD 3: KETERANGAN =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _keteranganController,
                        keyboardType: TextInputType.text,
                        maxLines: 2, // Diberi 2 baris agar muat deskripsi penambahan kas
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'Keterangan / Catatan',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= TOMBOL ACTION: TAMBAHKAN =================
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, 
                  height: 48, 
                  child: ElevatedButton(
                    onPressed: () {
                      // Mengambil data inputan saat tombol diklik
                      print("Tipe Kas: $_selectedTipeKas");
                      print("Jumlah: ${_jumlahController.text}");
                      print("Keterangan: ${_keteranganController.text}");
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), 
                      ),
                    ),
                    child: const Text(
                      "Kurangi Kas",
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
}