import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart'; 

class PengaturanAkunScreen extends StatefulWidget {
  const PengaturanAkunScreen({super.key});

  @override
  _PengaturanAkunScreenState createState() => _PengaturanAkunScreenState();
}

class _PengaturanAkunScreenState extends State<PengaturanAkunScreen> {
  // Controller untuk mengambil data input password
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _cNewPasswordController = TextEditingController();

  // Variabel state untuk menyembunyikan/menampilkan password (opsional, meningkatkan UX)
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    // Praktik terbaik: Hancurkan controller saat screen tidak dipakai agar hemat memori
    _passwordController.dispose();
    _newPasswordController.dispose();
    _cNewPasswordController.dispose();
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
              UpperBar2(title: "PENGATURAN AKUN"),
              
              // SECTION 1: PROFIL USER
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.amberAccent,
                      child: const Icon(Icons.person, size: 35, color: Colors.black87),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // PERBAIKAN: Teks profil rapi rata kiri
                        children: [
                          const Text(
                            "Email Akun", 
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const Text(
                            "xxxxxxxxxxxx@gmail.com", 
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Tanggal Daftar: xx/xx/xxxx", 
                            style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.grey, thickness: 0.5),
              const SizedBox(height: 12),

              // FIELD 1: Password Lama
              _buildPasswordField(
                controller: _passwordController,
                label: "Password Lama",
                isObscured: _obscureOldPassword,
                onToggleVisibility: () {
                  setState(() => _obscureOldPassword = !_obscureOldPassword);
                },
              ),

              // FIELD 2: Password Baru
              _buildPasswordField(
                controller: _newPasswordController,
                label: "Password Baru",
                isObscured: _obscureNewPassword,
                onToggleVisibility: () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                },
              ),

              // FIELD 3: Konfirmasi Password Baru
              _buildPasswordField(
                controller: _cNewPasswordController,
                label: "Konfirmasi Password Baru",
                isObscured: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),

              const SizedBox(height: 24),

              // TOMBOL ACTION: Simpan Perubahan
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // PERBAIKAN: Memanggil variabel controller password yang benar secara aman
                      print("Password Lama: ${_passwordController.text}");
                      print("Password Baru: ${_newPasswordController.text}");
                      print("Konfirmasi: ${_cNewPasswordController.text}");
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Ubah Password",
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

  // --- WIDGET HELPER: Komponen Input Password Dinamis dengan Fitur Lihat Password ---
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.lock, color: Colors.amberAccent),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isObscured, // MENYEMBUNYIKAN KARAKTER PASSWORD
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amberAccent),
                ),
                labelText: label,
                labelStyle: TextStyle(color: Colors.grey[400]),
                // Menambahkan tombol mata di pojok kanan input field
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[400],
                  ),
                  onPressed: onToggleVisibility,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}