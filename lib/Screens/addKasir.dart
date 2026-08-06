import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:app_laundry/Services/kasir_service.dart';

class AddKasirScreen extends StatefulWidget {
  final String? currentStoreId; // store_id (uuid)
  final String? ownerId;        // owner_id (uuid)

  const AddKasirScreen({
    super.key, 
    required this.currentStoreId,
    required this.ownerId,
  });

  @override
  State<AddKasirScreen> createState() => _AddKasirScreenState();
}

class _AddKasirScreenState extends State<AddKasirScreen> {
  final TextEditingController _namaController = TextEditingController();
  final _kasirService = KasirService();

  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _saveKasir() async {
    final nama = _namaController.text.trim();

    if (nama.isEmpty) {
      _showSnackBar("Nama Kasir wajib diisi!");
      return;
    }

    if (widget.currentStoreId == null) {
      _showSnackBar("Store ID tidak ditemukan!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newCashier = await _kasirService.addCashier(
        cashierName: nama,
        storeId: widget.currentStoreId!,
        ownerId: widget.ownerId,
      );

      if (mounted) {
        final String generatedId = newCashier['id'] ?? '';
        _showSuccessDialog(nama, generatedId);
      }
    } catch (e) {
      _showSnackBar("Gagal menyimpan kasir: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessDialog(String nama, String generatedId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text("Kasir Berhasil Ditambahkan", style: TextStyle(color: Colors.amberAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama Kasir: $nama", style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 12),
            const Text("ID Kasir (Supabase Generated):", style: TextStyle(color: Colors.grey, fontSize: 12)),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                generatedId,
                style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke screen sebelumnya
            },
            child: const Text("Selesai", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UpperBar2(title: "TAMBAH KASIR"),
              const SizedBox(height: 20),

              // FIELD: Nama Kasir
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _namaController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.amberAccent),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amberAccent),
                    ),
                    labelText: 'Nama Kasir',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ACTION BUTTON
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
                      : ElevatedButton(
                          onPressed: _saveKasir,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Tambahkan Kasir",
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
}