import 'package:app_laundry/Services/auth_service.dart';
import 'package:app_laundry/Screens/navigationBar.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Screens/loginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Add controllers for the text fields
  final authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void signUp() async {
      final email = _emailController.text.trim(); // Added .trim() to catch user entry spacing bugs
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password does not match")),
        );
        return;
      }

      try {
        // 1. Call auth service and await response metadata
        final response = await authService.signUpWithEmailPassword(email, password);
        
        if (!mounted) return;

        // 2. Since Brevo Custom SMTP confirmation is active, session will be null
        if (response.session == null && response.user != null) {
          showDialog(
            context: context,
            barrierDismissible: false, // User must interact with button to clear
            builder: (context) => AlertDialog(
              title: const Text('Verify Your Email'),
              content: Text(
                'A confirmation link has been sent to $email. '
                'Please open your inbox and click the link to activate your account.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Dismiss the alert dialog
                    Navigator.pop(context); // Pop back to Login screen seamlessly
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Fallback case: if email confirmation gets turned off in Supabase console later
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Changed to white to explicitly verify a screen change
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image.asset('assets/images/logo.jpeg'),
                // const SizedBox(height: 24),
                const Text(
                  "Register",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.white
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.white
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    signUp();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}