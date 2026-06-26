import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:app_laundry/Services/customer_service.dart'; // Jangan lupa import service-mu nanti
import 'package:app_laundry/Models/addCustomerModel.dart';   // Import model Customer kamu

class EditCustomerScreen extends StatefulWidget {
  // 1. Tambahkan parameter untuk menerima data customer yang mau diedit
  final String id; // Diperlukan untuk query WHERE id = id di Supabase nanti
  final String nama;
  final String alamat;
  final String phone;

  const EditCustomerScreen({
    super.key,
    required this.id,
    required this.nama,
    required this.alamat,
    required this.phone,
  });

  @override
  _EditCustomerScreenState createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  // Controller diinisialisasi tanpa default text dulu
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  final _customerService = CustomerService();
  void editCustomer() async{
    final updateCustomer = Customer{
      alamat: _alamatController.text, 
      nama: _namaController.text, 
      phoneNumber: _phoneController.text,
    }
    await _customerService.editCustomer(this.id, updateCustomer);
  }
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
    // Logika panggil fungsi editCustomer di CustomerService kamu
    final updatedData = Customer(
      nama: _namaController.text,
      alamat: _alamatController.text,
      phoneNumber: _phoneController.text,
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
                    onPressed: () {
                      updateCustomer();
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
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