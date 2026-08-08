import 'package:app_laundry/Models/notaModel.dart';
import 'package:app_laundry/Services/nota_service.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:flutter/material.dart';

class PengaturanNotaScreen extends StatefulWidget {
  final String store_id;
  const PengaturanNotaScreen({super.key, required this.store_id});

  @override
  _PengaturanNotaScreenState createState() => _PengaturanNotaScreenState();
}

class _PengaturanNotaScreenState extends State<PengaturanNotaScreen> {
  final ExpansionTileController _dropdownController1 = ExpansionTileController();
  final ExpansionTileController _dropdownController2 = ExpansionTileController();

  final TextEditingController _ketentuanController = TextEditingController();

  final notaService = NotaService();

  NotaModel? nota;
  bool _isLoading = true;
  bool _isSaving = false;

  // State untuk menyimpan nilai switch fitur kasir
  bool _logoOutlet = false;
  bool _noHandphonePelanggan = false;
  bool _alamatPelanggan = false;
  bool _logoOutlet2 = false;
  bool _noHandphonePelanggan2 = false;
  bool _alamatPelanggan2 = false;

  @override
  void initState() {
    super.initState();
    fetchNota();
  }

  void fetchNota() async {
    try {
      final result = await notaService.fetchNotaStore(widget.store_id);
      if (mounted) {
        setState(() {
          nota = result;
          _ketentuanController.text = result?.ketentuan ?? '';
          _logoOutlet = result?.logo_pelanggan ?? false;
          _noHandphonePelanggan = result?.no_handphone_pelanggan ?? false;
          _alamatPelanggan = result?.alamat_pelanggan ?? false;
          _logoOutlet2 = result?.logo_produksi ?? false;
          _noHandphonePelanggan2 = result?.No_handphone_produksi ?? false;
          _alamatPelanggan2 = result?.alamat_produksi ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Data gagal dimuat, error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void addNota() async {
    final newNota = NotaModel(
      ketentuan: _ketentuanController.text,
      store_id: widget.store_id,
      logo_pelanggan: _logoOutlet,
      no_handphone_pelanggan: _noHandphonePelanggan,
      alamat_pelanggan: _alamatPelanggan,
      logo_produksi: _logoOutlet2,
      No_handphone_produksi: _noHandphonePelanggan2,
      alamat_produksi: _alamatPelanggan2,
    );

    setState(() => _isSaving = true);
    try {
      if (nota == null) {
        await notaService.addNota(newNota);
      } else {
        await notaService.editNota(nota!.id!, newNota);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil disimpan"),
            backgroundColor: Colors.green,
          ),
        );
      }
      // Refresh so `nota` (and its id) stays in sync after an insert.
      fetchNota();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Data gagal disimpan, error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _ketentuanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    UpperBar2(title: "PENGATURAN NOTA"),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "PENGATURAN NOTA",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.image, color: Colors.white, size: 40),
                        ),
                        FloatingActionButton(
                          onPressed: () {},
                          backgroundColor: Colors.amber,
                          child: const Icon(Icons.camera, color: Colors.black),
                        )
                      ],
                    ),

                    // EXPANSION TILE 1 — Nota Pelanggan
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            controller: _dropdownController1,
                            title: const Text(
                              "Nota Pelanggan",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            iconColor: Colors.amber,
                            collapsedIconColor: Colors.amber,
                            childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            children: [
                              const Divider(color: Colors.grey, height: 1),
                              const SizedBox(height: 8),
                              _buildSwitchRow("Logo Outlet", _logoOutlet, (val) {
                                setState(() => _logoOutlet = val);
                              }),
                              const Divider(color: Colors.grey),
                              _buildSwitchRow("No Handphone Pelanggan", _noHandphonePelanggan, (val) {
                                setState(() => _noHandphonePelanggan = val);
                              }),
                              const Divider(color: Colors.grey),
                              _buildSwitchRow("Alamat Pelanggan", _alamatPelanggan, (val) {
                                setState(() => _alamatPelanggan = val);
                              }),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 36,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _dropdownController1.collapse();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.amber),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  icon: const Icon(Icons.keyboard_arrow_up, color: Colors.amber, size: 18),
                                  label: const Text(
                                    "Tutup Pengaturan",
                                    style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // EXPANSION TILE 2 — Nota Produksi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            controller: _dropdownController2,
                            title: const Text(
                              "Nota Produksi",
                              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            iconColor: Colors.amber,
                            collapsedIconColor: Colors.amber,
                            childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            children: [
                              const Divider(color: Colors.grey, height: 1),
                              const SizedBox(height: 8),
                              _buildSwitchRow("Logo Outlet", _logoOutlet2, (val) {
                                setState(() => _logoOutlet2 = val);
                              }),
                              const Divider(color: Colors.grey),
                              _buildSwitchRow("No Handphone Pelanggan", _noHandphonePelanggan2, (val) {
                                setState(() => _noHandphonePelanggan2 = val);
                              }),
                              const Divider(color: Colors.grey),
                              _buildSwitchRow("Alamat Pelanggan", _alamatPelanggan2, (val) {
                                setState(() => _alamatPelanggan2 = val);
                              }),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 36,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _dropdownController2.collapse();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.amber),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  icon: const Icon(Icons.keyboard_arrow_up, color: Colors.amber, size: 18),
                                  label: const Text(
                                    "Tutup Pengaturan",
                                    style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_city, color: Colors.amberAccent),
                          const SizedBox(width: 12, height: 64),
                          Expanded(
                            child: TextField(
                              controller: _ketentuanController,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 2,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.amberAccent),
                                ),
                                labelText: 'Ketentuan',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : addNota,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                            disabledBackgroundColor: Colors.amberAccent.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black87,
                                  ),
                                )
                              : const Text(
                                  "Simpan",
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

  Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ),
        Transform.scale(
          scale: 0.85,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.amber,
          ),
        ),
      ],
    );
  }
}