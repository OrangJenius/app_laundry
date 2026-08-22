import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:app_laundry/Services/cashFlow_service.dart'; // adjust path if different
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';

class SubCashScreen extends StatefulWidget {
  final String storeId;

  const SubCashScreen({super.key, required this.storeId});

  @override
  _SubCashScreenState createState() => _SubCashScreenState();
}

class _SubCashScreenState extends State<SubCashScreen> {
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  final _cashFlowService = CashFlowService();
  final _supabase = Supabase.instance.client;

  // Variabel untuk menyimpan status pilihan tipe kas
  String? _selectedTipeKas;

  bool _isSubmitting = false;
  bool _isLoadingSaldo = true;
  double _saldoTunai = 0.0;
  double _saldoNonTunai = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSaldo();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _loadSaldo() async {
    setState(() => _isLoadingSaldo = true);
    try {
      final cashFlows = await _cashFlowService.getCashFlows(storeId: widget.storeId);

      double tunai = 0.0;
      double nonTunai = 0.0;

      for (var cf in cashFlows) {
        final double nominal = double.tryParse(cf.jumlah) ?? 0.0;
        final cara = cf.cara_transaksi.toLowerCase();
        final tipe = cf.tipe.toUpperCase();
        final double signed = tipe == 'MASUK' ? nominal : (tipe == 'KELUAR' ? -nominal : 0.0);

        if (cara.contains('tunai') || cara.contains('cash')) {
          tunai += signed;
        } else {
          nonTunai += signed;
        }
      }

      if (!mounted) return;
      setState(() {
        _saldoTunai = tunai;
        _saldoNonTunai = nonTunai;
        _isLoadingSaldo = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingSaldo = false);
    }
  }

  String _formatRupiah(double value) {
    final isNegative = value < 0;
    final absValue = value.abs().toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < absValue.length; i++) {
      final posFromEnd = absValue.length - i;
      buffer.write(absValue[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
    }
    return "${isNegative ? '-' : ''}Rp. $buffer";
  }

  Future<void> _submitSubCash() async {
    final jumlahText = _jumlahController.text.trim();

    if (_selectedTipeKas == null) {
      _showSnackBar("Pilih tipe kas terlebih dahulu");
      return;
    }

    final nominal = double.tryParse(jumlahText) ?? 0.0;
    if (jumlahText.isEmpty || nominal <= 0) {
      _showSnackBar("Masukkan jumlah nominal yang valid");
      return;
    }

    // Cegah saldo minus: cek ketersediaan dana sesuai tipe kas yang dipilih
    final saldoTersedia = _selectedTipeKas == "Tunai" ? _saldoTunai : _saldoNonTunai;
    if (nominal > saldoTersedia) {
      _showSnackBar("Saldo $_selectedTipeKas tidak mencukupi (${_formatRupiah(saldoTersedia)})");
      return;
    }

    final profileId = _supabase.auth.currentUser?.id;
    if (profileId == null) {
      _showSnackBar("Sesi tidak ditemukan, silakan login ulang");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _cashFlowService.addPengeluaran(
        jumlah: jumlahText,
        caraTransaksi: _selectedTipeKas!,
        profileId: profileId,
        store_id: widget.storeId,
        keterangan: _keteranganController.text.trim().isEmpty
            ? "Pengurangan Kas"
            : _keteranganController.text.trim(),
      );

      if (!mounted) return;
      _showSnackBar("Kas berhasil dikurangi");
      Navigator.pop(context, true); // signal caller to refresh
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Gagal mengurangi kas: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
              UpperBar2(title: "PENGURANGAN CASH"),

              // ================= HEADER: SALDO KAS =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Text(
                          "Saldo Kas",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= DISPLAY SALDO TUNAI & NON-TUNAI =================
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.attach_money, color: Colors.black87),
                                SizedBox(width: 8),
                                Text("Saldo Tunai", style: TextStyle(color: Colors.black87)),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.monetization_on_outlined, color: Colors.black87),
                                SizedBox(width: 8),
                                Text("Saldo Non-Tunai", style: TextStyle(color: Colors.black87)),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        _isLoadingSaldo
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatRupiah(_saldoTunai),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _formatRupiah(_saldoNonTunai),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= FIELD 1: TIPE CASH (DROPDOWN) =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white),
                        value: _selectedTipeKas,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'Nama Cash / Tipe Kas',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        items: ["Tunai", "Non-Tunai"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedTipeKas = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ================= FIELD 2: JUMLAH CASH (INPUT ANGKA) =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _jumlahController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          prefixText: "Rp. ",
                          prefixStyle: const TextStyle(color: Colors.amberAccent),
                          labelText: 'Jumlah Nominal Cash',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= FIELD 3: KETERANGAN =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _keteranganController,
                        keyboardType: TextInputType.text,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amberAccent),
                          ),
                          labelText: 'Keterangan / Catatan',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= TOMBOL ACTION: KURANGI =================
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitSubCash,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                          )
                        : const Text(
                            "Kurangi Kas",
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