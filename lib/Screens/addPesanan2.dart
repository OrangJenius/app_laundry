import 'package:app_laundry/Models/orderModel.dart';
import 'package:app_laundry/Models/transaksiModel.dart';
import 'package:app_laundry/Models/orderDetailModel.dart';
import 'package:app_laundry/Models/orderStatusModel.dart';
import 'package:app_laundry/Screens/rincianPesanan.dart';
import 'package:app_laundry/Services/antarJemput_service.dart';
import 'package:app_laundry/Services/diskon_service.dart';
import 'package:app_laundry/Services/orderDetail_service.dart';
import 'package:app_laundry/Services/orderStatus_service.dart';
import 'package:app_laundry/Services/order_service.dart';
import 'package:app_laundry/Services/parfum_service.dart';
import 'package:app_laundry/Services/service_service.dart';
import 'package:app_laundry/Services/transaksi_service.dart';
import 'package:flutter/material.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPesanan2Screen extends StatefulWidget {
  final String nama;
  final String nomor;
  final String alamat;
  final String store_id;
  final String durasi_id;
  final String customer_id;

  const AddPesanan2Screen({
    super.key,
    required this.nama,
    required this.nomor,
    required this.alamat,
    required this.store_id,
    required this.durasi_id,
    required this.customer_id,
  });

  @override
  _AddPesanan2ScreenState createState() => _AddPesanan2ScreenState();
}

class _AddPesanan2ScreenState extends State<AddPesanan2Screen> {
  final parfumService = ParfumService();
  final antarJemputService = AntarJemputService();
  final diskonService = DiskonService();
  final serviceService = ServiceService();
  final orderService = OrderService();
  final orderDetailService = OrderDetailService();
  final orderStatusService = OrderStatusService();
  final transaksiService = TransaksiService();

  // Futures cached in State
  late Future<List<dynamic>> _serviceFuture;
  late Future<List<dynamic>> _parfumFuture;
  late Future<List<dynamic>> _antarJemputFuture;
  late Future<List<dynamic>> _diskonFuture;

  // Track quantities per item ID e.g., {'service_id_1': 2, 'service_id_2': 1}
  final Map<String, int> _itemCounts = {};
  final Map<String, TextEditingController> _controllers = {};

  // Selected values for modal dropdowns
  dynamic _selectedParfum;
  dynamic _selectedAntarJemput;
  dynamic _selectedDiskon;
  final TextEditingController _catatanController = TextEditingController();

  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _serviceFuture = serviceService.fetchServicesByDuration(
        widget.store_id, widget.durasi_id);
    _parfumFuture = parfumService.fetchparfum(widget.store_id);
    _antarJemputFuture = antarJemputService.fetchantarjemput(widget.store_id);
    _diskonFuture = diskonService.fetchdiskon(widget.store_id);
  }

  @override
  void dispose() {
    _catatanController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Gets or creates a controller for a specific item quantity
  TextEditingController _getController(String id, int currentCount) {
    if (!_controllers.containsKey(id)) {
      _controllers[id] = TextEditingController(text: currentCount.toString());
    } else {
      if (_controllers[id]!.text != currentCount.toString()) {
        _controllers[id]!.text = currentCount.toString();
      }
    }
    return _controllers[id]!;
  }

  void _updateCount(String id, int newCount) {
    if (newCount >= 0) {
      setState(() {
        _itemCounts[id] = newCount;
      });
    }
  }

  int _getTotalItemCount() {
    return _itemCounts.values.fold(0, (sum, count) => sum + count);
  }

  /// Base total from selected services only (qty * price)
  int _calculateTotalHarga(List<dynamic> services) {
    int total = 0;
    for (var service in services) {
      String id = service.id.toString();
      int count = _itemCounts[id] ?? 0;
      int harga = int.tryParse(service.price.toString()) ?? 0;
      total += (count * harga);
    }
    return total;
  }

  /// Final total factoring in antar-jemput cost and diskon on top of the base service total.
  /// Called every modal rebuild so it stays live as the user changes selections.
  int _calculateFinalTotal(int baseTotal) {
    int total = baseTotal;

    // Add antar-jemput (ongkir) cost, if selected
    if (_selectedAntarJemput != null) {
      int ongkir = int.tryParse(_selectedAntarJemput.harga.toString()) ?? 0;
      total += ongkir;
    }

    // Apply diskon, if selected
    if (_selectedDiskon != null) {
      int jumlahDiskon =
          int.tryParse(_selectedDiskon.jumlah_diskon.toString()) ?? 0;
      if (_selectedDiskon.tipe_diskon == "Persentase") {
        total -= (total * jumlahDiskon ~/ 100);
      } else if (_selectedDiskon.tipe_diskon == "Nominal") {
        total -= jumlahDiskon;
      }
    }

    return total < 0 ? 0 : total;
  }

  String _formatRupiah(int value) {
    return "Rp. ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  /// Process creating the order and its associated detail, status, and transaction models
  Future<void> addPesanan(int totalHarga, List<dynamic> services) async {
    final String? uID = supabase.auth.currentUser?.id;

    if (uID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sesi login pengguna tidak ditemukan.")),
      );
      return;
    }

    if (_getTotalItemCount() == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih minimal 1 layanan terlebih dahulu.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create Main Order
      final newOrder = OrderModel(
        store_id: widget.store_id,
        duration_id: widget.durasi_id,
        customer_id: widget.customer_id,
        total_harga: totalHarga.toString(),
        parfum_id: _selectedParfum?.id != null ? _selectedParfum.id.toString() : null,
        antar_jemput_id: _selectedAntarJemput?.id != null ? _selectedAntarJemput.id.toString() : null,
        profile_id: uID,
        discount_id: _selectedDiskon?.id != null ? _selectedDiskon.id.toString() : null,
      );
      
      final createdOrder = await orderService.addOrder(newOrder);
      final String orderId = createdOrder.id.toString(); 

      // List untuk menampung nama-nama layanan yang dipilih
      List<String> selectedServiceNames = [];

      // 2. Create Order Details for each selected service
      for (var service in services) {
        String serviceId = service.id.toString();
        int count = _itemCounts[serviceId] ?? 0;

        if (count > 0) {
          int harga = int.tryParse(service.price.toString()) ?? 0;
          int subtotal = count * harga;

          selectedServiceNames.add(service.service_name ?? "Layanan");

          final newOrderDetail = OrderDetailModel(
            order_id: orderId,
            service_id: serviceId,
            qty: count.toString(),
            subtotal: subtotal.toString(),
            price: service.price.toString(),
          );

          await orderDetailService.addOrderDetail(newOrderDetail);
        }
      }

      // 3. Create Initial Order Status
      final newOrderStatus = OrderStatusModel(
        order_id: orderId,
        status_order: "Pending",
        profile_id: uID,
      );
      await orderStatusService.addOrderStatus(newOrderStatus);

      // 4. Create Initial Transaction Record
      final newTransaksi = TransaksiModel(
        order_id: orderId,
        status_pembayaran: "Belum Bayar",
        jenis_pembayaran: null,
        profile_id: uID,
        jumlah_transaksi: totalHarga.toString(),
      );
      await transaksiService.addTransaksi(newTransaksi);

      if (!mounted) return;

      // 5. Navigate to Summary or Next Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RincianPesananScreen(
            order_id: orderId,
            store_id: widget.store_id,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menambahkan pesanan: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- MODAL BOTTOM SHEET: ATUR PESANAN ---
  void _showPesananMenu(BuildContext context, int baseTotalHarga, List<dynamic> services) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Recalculated on every setModalState call, so it stays live
            // as the user changes antar-jemput / diskon selections.
            final int finalTotal = _calculateFinalTotal(baseTotalHarga);

            return Padding(
              padding: EdgeInsets.only(
                top: 20.0,
                left: 20.0,
                right: 20.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    const Center(
                      child: Text(
                        "Atur Pesanan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // 1. Dropdown Parfum
                    _buildLabel("Parfum"),
                    FutureBuilder<List<dynamic>>(
                      future: _parfumFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return _buildLoadingDropdown();
                        }
                        final rawItems = snapshot.data!;
                        final items = <dynamic>[null, ...rawItems];

                        return _buildDropdownField<dynamic>(
                          value: _selectedParfum,
                          items: items,
                          itemLabel: (item) {
                            if (item == null) {
                              return "Tidak";
                            }
                            return item.nama_parfum ?? item.toString();
                          },
                          onChanged: (val) =>
                              setModalState(() => _selectedParfum = val),
                        );
                      },
                    ),
                    const SizedBox(height: 14.0),

                    // 2. Dropdown Antar-Jemput
                    _buildLabel("Antar-Jemput"),
                    FutureBuilder<List<dynamic>>(
                      future: _antarJemputFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return _buildLoadingDropdown();
                        }
                        final rawItems = snapshot.data!;
                        final items = <dynamic>[null, ...rawItems];

                        return _buildDropdownField<dynamic>(
                          value: _selectedAntarJemput,
                          items: items,
                          itemLabel: (item) {
                            if (item == null) {
                              return "Tidak";
                            }
                            String name = item.jarak ?? '';
                            String price =
                                item.harga != null ? " - Rp. ${item.harga}" : "";
                            return "$name$price";
                          },
                          onChanged: (val) =>
                              setModalState(() => _selectedAntarJemput = val),
                        );
                      },
                    ),
                    const SizedBox(height: 14.0),

                    // 3. Dropdown Diskon
                    _buildLabel("Diskon"),
                    FutureBuilder<List<dynamic>>(
                      future: _diskonFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return _buildLoadingDropdown();
                        }

                        final rawItems = snapshot.data!;
                        final items = <dynamic>[null, ...rawItems];

                        return _buildDropdownField<dynamic>(
                          value: _selectedDiskon,
                          items: items,
                          itemLabel: (item) {
                            if (item == null) {
                              return "Tanpa Diskon";
                            }
                            if (item.tipe_diskon == "Persentase") {
                              return "${item.jumlah_diskon}%";
                            } else if (item.tipe_diskon == "Nominal") {
                              return "Rp. ${item.jumlah_diskon}";
                            }
                            return item.jumlah_diskon.toString();
                          },
                          onChanged: (val) =>
                              setModalState(() => _selectedDiskon = val),
                        );
                      },
                    ),
                    const SizedBox(height: 14.0),

                    // 4. Catatan
                    _buildLabel("Catatan"),
                    TextField(
                      controller: _catatanController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Masukkan catatan pesanan...",
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                        prefixIcon: const Icon(Icons.note_alt_outlined, color: Colors.amber),
                        filled: true,
                        fillColor: Colors.grey[850],
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Live total summary, reacts to antar-jemput / diskon changes
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            _formatRupiah(finalTotal),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 5. Tombol Buat Pesanan
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                Navigator.pop(context); // Close modal
                                await addPesanan(finalTotal, services);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : const Icon(Icons.shopping_bag_outlined),
                        label: Text(
                          _isLoading ? "Memproses..." : "Buat Pesanan",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildLoadingDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.grey[850],
          icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _serviceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.amber));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("Gagal memuat layanan: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red)),
              );
            }

            final services = snapshot.data ?? [];
            // Base total from services only. Antar-jemput cost and diskon
            // are applied live inside the "Atur Pesanan" modal via
            // _calculateFinalTotal, since those selections happen there.
            int totalHarga = _calculateTotalHarga(services);

            return Column(
              children: [
                UpperBar2(title: "TAMBAHKAN LAYANAN"),

                // --- SEARCH BAR ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: const [
                      Expanded(
                        child: SearchBar(
                          hintText: "Cari nama layanan",
                          leading: Icon(Icons.search),
                          elevation: WidgetStatePropertyAll(1),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- DYNAMIC SERVICES LIST ---
                Expanded(
                  child: services.isEmpty
                      ? const Center(
                          child: Text("Belum ada layanan tersedia", style: TextStyle(color: Colors.white70)),
                        )
                      : ListView.builder(
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            final service = services[index];
                            final String serviceId = service.id.toString();
                            final int currentCount = _itemCounts[serviceId] ?? 0;
                            final controller = _getController(serviceId, currentCount);

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service.duration.duration_name ?? "Layanan",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 13,
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            Text(
                                              service.service_name ?? "-",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Rp. ${service.price}",
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Item Counter Controls
                                      currentCount == 0
                                          ? IconButton(
                                              onPressed: () => _updateCount(serviceId, 1),
                                              icon: const Icon(Icons.add_circle, color: Colors.amber, size: 32),
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () => _updateCount(serviceId, currentCount - 1),
                                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 26),
                                                  constraints: const BoxConstraints(),
                                                  padding: EdgeInsets.zero,
                                                ),
                                                Container(
                                                  width: 50,
                                                  height: 35,
                                                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: TextField(
                                                    controller: controller,
                                                    keyboardType: TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    decoration: InputDecoration(
                                                      contentPadding: EdgeInsets.zero,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(6),
                                                        borderSide: const BorderSide(color: Colors.grey),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(6),
                                                        borderSide: const BorderSide(color: Colors.amber),
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      int? parsed = int.tryParse(value);
                                                      _updateCount(serviceId, parsed ?? 0);
                                                    },
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () => _updateCount(serviceId, currentCount + 1),
                                                  icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 26),
                                                  constraints: const BoxConstraints(),
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // --- BOTTOM NAVIGATION BAR ---
                SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Colors.black54, size: 28),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.nama,
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  widget.nomor,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              "${_getTotalItemCount()} pcs",
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                      // Action Button to Open Atur Pesanan
                      InkWell(
                        onTap: () => _showPesananMenu(context, totalHarga, services),
                        child: Container(
                          color: Colors.amber,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatRupiah(totalHarga),
                                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    "Total Layanan",
                                    style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Text(
                                "Lanjut",
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}