import 'package:flutter/material.dart';

class UpperBar extends StatelessWidget {
  final String title;
  final String selectedOutlet;
  // 1. Add a callback function to notify the parent screen when a new selection happens
  final ValueChanged<String?> onOutletChanged; 

  const UpperBar({
    super.key, // Good practice to include the key parameter
    required this.title, 
    required this.selectedOutlet,
    required this.onOutletChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              title, 
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedOutlet,
                items: const [
                  DropdownMenuItem(value: "N2Jewel", child: Text("N2Jewel")),
                  DropdownMenuItem(value: "Outlet 2", child: Text("Outlet 2")),
                ],
                // 2. Trigger the callback function instead of calling setState here
                onChanged: onOutletChanged, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}