import 'package:flutter/material.dart';

class UpperBarExcel extends StatelessWidget {
  final String title;
  final VoidCallback? onExport;
  final bool isExporting;

  const UpperBarExcel({
    super.key,
    required this.title,
    this.onExport,
    this.isExporting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: isExporting ? null : onExport,
              icon: isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.table_chart, size: 18),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              label: Text(isExporting ? "..." : "Export"),
            ),
          ],
        ),
      ),
    );
  }
}