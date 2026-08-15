import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:app_laundry/Services/customer_service.dart'; // Jangan lupa import service-mu nanti
import 'package:app_laundry/Models/customerModel.dart';   // Import model Customer kamu

class EditCustomerScreen extends StatefulWidget {
  // 1. Tambahkan parameter untuk menerima data customer yang mau diedit
  final String id; // Diperlukan untuk query WHERE id = id di Supabase nanti
  final String nama;
  final String alamat;
  final String phone;
  final String store_id;

  const EditCustomerScreen({
    super.key,
    required this.id,
    required this.nama,
    required this.alamat,
    required this.phone,
    required this.store_id,
  });

  @override
  _EditCustomerScreenState createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  // Controller diinisialisasi tanpa default text dulu
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false; 

  final _customerService = CustomerService();
  // 2. Gunakan initState untuk mengisi teks awal (Prefill) ke dalam controller
  @override
  void initState() {
    super.initState();
    _namaController.text = widget.nama;
    _alamatController.text = widget.alamat;
    _phoneController.text = widget.phone;
  }

  // Jangan lupa dispose controller demi menjaga performa memori
  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void updateCustomer() async {
    setState(() {
      _isLoading = true;
    });
    // Logika panggil fungsi editCustomer di CustomerService kamu
    final updatedData = Customer(
      nama: _namaController.text,
      alamat: _alamatController.text,
      phoneNumber: _phoneController.text,
      store_id: widget.store_id,
    );

    try {
      await _customerService.editCustomer(widget.id, updatedData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Tutup halaman edit
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memperbarui data: $e"), backgroundColor: Colors.red),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar2(title: "EDIT PELANGGAN"),
              
              // FIELD 1: Nama Customer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.amberAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _namaController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
                          labelText: 'Nama Customer',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // FIELD 2: No Handphone (Disesuaikan controllernya agar tidak tertukar label)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.phone_android, color: Colors.amberAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController, // Diubah menjadi phone controller
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
                          labelText: 'No Handphone',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // FIELD 3: Alamat (Disesuaikan controllernya agar tidak tertukar label)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed, color: Colors.amberAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _alamatController, // Diubah menjadi alamat controller
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
                          labelText: 'Alamat',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // TOMBOL ACTION: Simpan
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null: () {
                      if (_namaController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nama customer tidak boleh kosong!")),
                        );
                        return;
                      }else if (_alamatController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Alamat customer tidak boleh kosong!")),
                        );
                        return;
                      }else if (_phoneController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nomor telepon tidak boleh kosong!")),
                        );
                        return;
                      }
                      updateCustomer();
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading? 
                    const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(
                        strokeWidth: 2, 
                        color: 
                        Colors.black87,
                        ),
                      ) 
                    : const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
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