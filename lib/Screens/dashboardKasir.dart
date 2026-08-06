import 'package:flutter/material.dart';

class DashboardKasirScreen extends StatefulWidget {
  final String store_id;
  const DashboardKasirScreen({super.key, required this.store_id});

  @override
  State<DashboardKasirScreen> createState() => _DashboardKasirScreenState();
}

class _DashboardKasirScreenState extends State<DashboardKasirScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            Center(child: Text("Hello World", style: TextStyle(color: Colors.white, fontSize: 64),)),
          ],
        ),
      ),
    );
  }
}
