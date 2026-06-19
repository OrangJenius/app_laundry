import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_laundry/Screens/loginScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start a timer to navigate after 3 seconds
    Timer(Duration(seconds: 3), () {
      // Replace 'HomeScreen()' with your actual landing page widget
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        // MaterialPageRoute(builder: (context) => Scaffold(body: Center(child: Text("Bypassed Login!")))),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your Logo or App Icon
            Image.asset('assets/images/logo.jpeg')
            // Icon(Icons.home, size: 100, color: Colors.white),
          ],
        ),
      ),
    );
  }
}