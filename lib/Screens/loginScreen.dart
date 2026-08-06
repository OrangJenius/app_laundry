import 'dart:math';

import 'package:app_laundry/Screens/Register.dart';
import 'package:app_laundry/Services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authService = AuthService();

  // 0 = Owner Login, 1 = Kasir Login
  int _selectedTab = 0; 
  bool _isLoading = false;

  // Controllers for Owner Login
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Controllers for Kasir Login
  final TextEditingController _kasirIdController = TextEditingController();

  void _loginOwner() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Email dan Password wajib diisi!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) _showSnackBar("Error Login Owner: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loginKasir() async {
    final rawKasirId = _kasirIdController.text.trim();

    if (rawKasirId.isEmpty) {
      _showSnackBar("ID Kasir dan PIN wajib diisi!");
      return;
    }

    // Convert Cashier ID (e.g. KSR-001) to synthetic email format (ksr001@laundry.com)
    final cleanId = rawKasirId.toLowerCase().trim();
    final id = rawKasirId.trim();
    final computedEmail = "$cleanId@mail.com";
    final pin = "Kasir_123!$id";
    setState(() => _isLoading = true);

    try {
      // Authenticate cashier via Supabase Auth
      await authService.signInWithEmailPassword(computedEmail, pin);
      print("$computedEmail, $pin");
    } catch (e) {
      if (mounted) _showSnackBar("ID Kasir atau Password/PIN salah!, error: $e, $computedEmail, $pin");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _kasirIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Log In",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- TOGGLE / TAB SEGMENT (SIDE BY SIDE) ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0
                                    ? Colors.amberAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Owner / Admin",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedTab == 0
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1
                                    ? Colors.amberAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Kasir",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedTab == 1
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- FORM DISPLAY (SWITCHES BASED ON TAB) ---
                  if (_selectedTab == 0) ...[
                    // OWNER FORM
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ] else ...[
                    // KASIR FORM
                    TextField(
                      controller: _kasirIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID Kasir (misal: KSR-001)',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 24),

                  // SUBMIT BUTTON
                  SizedBox(
                    height: 48,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Colors.amberAccent))
                        : ElevatedButton(
                            onPressed:
                                _selectedTab == 0 ? _loginOwner : _loginKasir,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amberAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _selectedTab == 0 ? "Login" : "Login Kasir",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // SHOW REGISTER OPTION ONLY FOR OWNER
                  if (_selectedTab == 0)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "Belum punya akun? Daftar disini!",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}