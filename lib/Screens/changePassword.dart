import 'package:app_laundry/Services/auth_service.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmPasswordController = TextEditingController();
    final TextEditingController _newPasswordController = TextEditingController();
    bool _isLoading = false;
    final _authService = AuthService(); 

    void changePassword() async {
        setState(() {
        _isLoading = true;
        });
        try{
        await _authService.changePassword(_newPasswordController.text);
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password berhasil diubah!"), backgroundColor: Colors.green),
            );
            Navigator.pop(context); // Tutup halaman edit
        }
        }catch (e) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password tidak berhasil diubah, error: $e"), backgroundColor: Colors.red),
            );
        }
        setState(() {
            _isLoading = false;
        });
        }
    }
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: SafeArea(
        // Menggunakan SingleChildScrollView agar tidak error 'Overflow' saat keyboard muncul
        child: SingleChildScrollView(
            child: Column(
            children: [
                UpperBar2(title: "GANTI PASSWORD"),
                
                // FIELD 1: Nama Customer
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                    children: [
                    Icon(Icons.person, color: Colors.amberAccent),
                    SizedBox(width: 12),
                    Expanded( // WAJIB: Agar TextField tidak menyebabkan Unbounded Width Error
                        child: TextField(
                        controller: _passwordController,
                        style: TextStyle(color: Colors.white), // Teks warna putih agar terbaca
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                            ),
                            labelText: 'Masukkan Password',
                            labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        ),
                    ),
                    ],
                ),
                ),

                // FIELD 2: Alamat Lengkap
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                    children: [
                    Icon(Icons.phone_android, color: Colors.amberAccent),
                    SizedBox(width: 12),
                    Expanded(
                        child: TextField(
                        controller: _confirmPasswordController,
                        style: TextStyle(color: Colors.white),
                        maxLines: 2, // Alamat biasanya panjang, diberi 2 baris agar rapi
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                            ),
                            labelText: 'Konfirmasi Password',
                            labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        ),
                    ),
                    ],
                ),
                ),

                // FIELD 3: No. Telepon
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                    children: [
                    Icon(Icons.gps_fixed, color: Colors.amberAccent),
                    SizedBox(width: 12),
                    Expanded(
                        child: TextField(
                        controller: _newPasswordController,
                        keyboardType: TextInputType.phone, // Memunculkan keyboard angka
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                            ),
                            labelText: 'Masukkan Password Baru',
                            labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        ),
                    ),
                    ],
                ),
                ),

                SizedBox(height: 24), // Memberi jarak sebelum tombol

                // TOMBOL ACTION: Tambahkan
                Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                    width: double.infinity, // Membuat tombol full-width agar lebih modern
                    height: 48, // Mengatur tinggi tombol agar pas di jari
                    child: ElevatedButton(
                    onPressed: _isLoading ? null: () {
                        if (_passwordController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Nama customer tidak boleh kosong!")),
                        );
                        return;
                        }else if (_confirmPasswordController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Alamat customer tidak boleh kosong!")),
                        );
                        return;
                        }else if (_newPasswordController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Nomor telepon tidak boleh kosong!")),
                        );
                        return;
                        }
                        changePassword();
                    }, 
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        ),
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
                        "Tambahkan",
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