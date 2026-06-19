import 'package:flutter/material.dart';

// --- REUSABLE CUSTOM OUTLINED BUTTON WIDGET ---
class MenuActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75, // Gives enough horizontal space for the text labels to wrap cleanly
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Colors.black38, width: 1.5),
              ),
              child: Icon(icon, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 8),
          Text( 
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 1.2, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}