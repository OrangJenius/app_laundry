import 'package:app_laundry/Models/orderModel.dart';
import 'package:app_laundry/Models/orderStatusModel.dart';
import 'package:app_laundry/Models/transaksiModel.dart';
import 'package:app_laundry/Screens/navigationBar.dart';
import 'package:app_laundry/Services/cashFlow_service.dart';
import 'package:app_laundry/Services/orderDetail_service.dart';
import 'package:app_laundry/Services/orderStatus_service.dart';
import 'package:app_laundry/Services/order_service.dart';
import 'package:app_laundry/Services/profile_service.dart';
import 'package:app_laundry/Services/transaksi_service.dart';
import 'package:app_laundry/Widgets/customUpperBarNoMenu.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RincianPesananScreen extends StatefulWidget {
  final String store_id;
  final String order_id;

  const RincianPesananScreen({
    super.key,
    required this.store_id,
    required this.order_id,
  });

  @override
  _RincianPesananScreenState createState() => _RincianPesananScreenState();
}

class _RincianPesananScreenState extends State<RincianPesananScreen> {
  final orderStatusService = OrderStatusService();
  final orderDetailService = OrderDetailService();
  final transaksiService = TransaksiService();
  final orderService = OrderService();
  final supabase = Supabase.instance.client;
  final cashFlowService = CashFlowService();

  String caraBayar = "Tunai";

  late Future<dynamic> _orderFuture;
  late Future<dynamic> _orderDetailFuture;
  late Future<dynamic> _orderStatusFuture;
  late Future<dynamic> _transaksiFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _orderFuture = orderService.fetchOrderById(widget.order_id);
    _orderDetailFuture = orderDetailService.fetchOrderDetail2(widget.order_id);
    _orderStatusFuture = orderStatusService.fetchOrderStatus2(widget.order_id);
    _transaksiFuture = transaksiService.fetchTransaksi2(widget.order_id);
  }

  void updateStatus(String nextStatus) async {
    final String? userID = supabase.auth.currentUser?.id;
    if (userID == null) return;

    final newStatus = OrderStatusModel(
      order_id: widget.order_id,
      status_order: nextStatus,
      profile_id: userID,
    );

    try {
      await orderStatusService.addOrderStatus(newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data Berhasil ditambahkan!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _orderStatusFuture =
              orderStatusService.fetchOrderStatus2(widget.order_id);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Data gagal diupdate, error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void updateTransaksi() async {
    final String? userID = supabase.auth.currentUser?.id;
    if (userID == null) return;

    final newTransaksi = TransaksiModel(
      order_id: widget.order_id,
      status_pembayaran: "Lunas",
      jenis_pembayaran: caraBayar,
      profile_id: userID,
    );

    try {
      final jumlah = await transaksiService.editTransaksi(widget.order_id, newTransaksi);
      await cashFlowService.addOrderPayment(orderId: widget.order_id, jumlah: jumlah, caraTransaksi: caraBayar, profileId: userID, store_id: widget.store_id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data Berhasil ditambahkan!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _transaksiFuture =
              transaksiService.fetchTransaksi2(widget.order_id);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Data gagal diupdate, error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void cancelOrder() async {
    try {
      await transaksiService.deleteTransaksi(widget.order_id);
      await orderDetailService.deleteOrderDetail(widget.order_id);
      // await orderStatusService.deleteOrderStatus(widget.order_id);
      await orderService.deleteOrder(widget.order_id);

      final uid = supabase.auth.currentUser?.id;
      final profile = await ProfileService().fetchProfileWithId(uid!);
      final oID = profile?.owner_id;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil dihapus!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(
              currentPageIndex: 1,
              owner_id: oID ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Data gagal dihapus, error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void confirmationModal({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text("Konfirmasi"),
            ),
          ],
        );
      },
    );
  }

  String _formatRupiah(int uang) {
    return "Rp. ${uang.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  String _calculateEstimateFinish(String createdAt, int hours) {
    try {
      DateTime parsedDate = DateTime.parse(createdAt);
      DateTime finishDate = parsedDate.add(Duration(hours: hours));
      return "${finishDate.year}-${finishDate.month.toString().padLeft(2, '0')}-${finishDate.day.toString().padLeft(2, '0')} ${finishDate.hour.toString().padLeft(2, '0')}:${finishDate.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "-";
    }
  }

  int _calculateDiscountNominal(int totalHarga, dynamic diskon) {
    if (diskon == null || diskon is! Map) return 0;
    bool isPercent = diskon['tipe']?.toString().toLowerCase() == 'persen';
    int jumlahDiskon = diskon['jumlah_diskon'] ?? 0;
    if (isPercent) {
      return (totalHarga * (jumlahDiskon / 100)).round();
    }
    return jumlahDiskon;
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is List && data.isNotEmpty) {
      if (data.first is Map<String, dynamic>) {
        return data.first as Map<String, dynamic>;
      } else {
        try {
          return (data.first as dynamic).toJson();
        } catch (_) {}
      }
    } else if (data != null) {
      try {
        return (data as dynamic).toJson();
      } catch (_) {}
    }
    return {};
  }

  List<Map<String, dynamic>> _toListOfMaps(dynamic data) {
    if (data is List) {
      return data.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }
        try {
          return (item as dynamic).toJson() as Map<String, dynamic>;
        } catch (_) {
          return <String, dynamic>{};
        }
      }).where((map) => map.isNotEmpty).toList();
    } else if (data is Map<String, dynamic>) {
      return [data];
    } else if (data != null) {
      try {
        return [(data as dynamic).toJson() as Map<String, dynamic>];
      } catch (_) {}
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: FutureBuilder(
          future: Future.wait([
            _orderFuture,
            _orderDetailFuture,
            _orderStatusFuture,
            _transaksiFuture
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.amber));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text("Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white)));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                  child: Text("Data tidak ditemukan",
                      style: TextStyle(color: Colors.white)));
            }

            final order = _toMap(snapshot.data![0]);
            final orderDetailsList = _toListOfMaps(snapshot.data![1]);
            final orderStatus = _toMap(snapshot.data![2]);
            final transaksi = _toMap(snapshot.data![3]);

            final int totalHarga = order['total_harga'] ?? 0;
            final antarJemput = order['antar_jemput'] is Map
                ? order['antar_jemput'] as Map<String, dynamic>
                : {};
            final int antarJemputHarga = antarJemput['harga'] ?? 0;

            final diskonMap = order['diskon'] is Map
                ? order['diskon'] as Map<String, dynamic>
                : {};
            final int diskonNominal =
                _calculateDiscountNominal(totalHarga, diskonMap);
            final int totalBayar =
                totalHarga + antarJemputHarga - diskonNominal;

            int maxHours = 0;
            if (orderDetailsList.isNotEmpty) {
              for (var detail in orderDetailsList) {
                int hours = detail['service']?['duration']?['hours'] ?? 0;
                if (hours > maxHours) maxHours = hours;
              }
            }

            final String currentStatus = orderStatus['status_order'] ?? '';
            final String currentPembayaran =
                transaksi['status_pembayaran'] ?? 'Belum Lunas';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UpperBar2(title: "RINCIAN PESANAN"),

                  // ================= TOKO & NOTA =================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.store, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text(
                            order['store']?['store_name'] ?? '-',
                            style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontStyle: FontStyle.italic),
                          ),
                          const Spacer(),
                          Text(
                            order['receipt'] ?? '-',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ================= DATA PELANGGAN & AKSI =================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Card(
                              color: Colors.amberAccent,
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.person,
                                        color: Colors.black87),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order['customer']?['nama'] ?? '-',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87),
                                          ),
                                          Text(
                                            order['customer']
                                                    ?['nomor_telepon'] ??
                                                '-',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            (order['customer']?['alamat'] ?? '')
                                                    .isEmpty
                                                ? "Tidak ada alamat"
                                                : order['customer']['alamat'],
                                            style: const TextStyle(
                                                color: Colors.black45,
                                                fontSize: 10,
                                                fontStyle: FontStyle.italic),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Card(
                            color: Colors.amber,
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.call,
                                        color: Colors.white),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8.0),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.print,
                                        color: Colors.white),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ================= DETAIL LAYANAN =================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: orderDetailsList.isEmpty
                            ? const Text("Tidak ada detail layanan",
                                style: TextStyle(color: Colors.grey))
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: orderDetailsList.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 16),
                                itemBuilder: (context, index) {
                                  final orderDetail = orderDetailsList[index];
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              orderDetail['service']
                                                          ?['duration']
                                                      ?['duration_name'] ??
                                                  '-',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                  fontStyle: FontStyle.italic)),
                                          Text(
                                              orderDetail['service']
                                                      ?['service_name'] ??
                                                  '-',
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              "x ${_formatRupiah(orderDetail['price'] ?? 0)}",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontStyle: FontStyle.italic)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                              orderDetail['service']?['unit']
                                                      ?['unit_type'] ??
                                                  '-',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                  fontStyle: FontStyle.italic)),
                                          Text(
                                              "${orderDetail['quantity'] ?? 0} ${orderDetail['service']?['unit']?['unit_name'] ?? ''}",
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              _formatRupiah(
                                                  orderDetail['subtotal'] ?? 0),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontStyle: FontStyle.italic)),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ),
                  ),

                  // ================= RINCIAN INFORMASI & BIAYA =================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                                "Dibuat Oleh",
                                (order['profiles']?['cashier_name'] ?? '')
                                        .isEmpty
                                    ? "Manager"
                                    : order['profiles']['cashier_name']),
                            const Divider(),
                            _buildInfoRow("Status",
                                currentStatus.isEmpty ? '-' : currentStatus),
                            const Divider(),
                            _buildInfoRow(
                                "Tanggal Masuk", order['created_at'] ?? '-'),
                            const Divider(),
                            _buildInfoRow(
                              "Estimasi Selesai",
                              _calculateEstimateFinish(
                                  order['created_at'] ?? '', maxHours),
                            ),
                            const Divider(),
                            _buildInfoRow(
                                "Catatan",
                                (order['catatan'] ?? '').isEmpty
                                    ? "-"
                                    : order['catatan']),
                            const Divider(),
                            _buildInfoRow("Parfum",
                                order['parfum']?['nama_parfum'] ?? '-'),
                            const Divider(),
                            _buildInfoRow(
                                "Antar-Jemput",
                                (antarJemput['jarak'] ?? '').isEmpty
                                    ? "-"
                                    : antarJemput['jarak']),
                            const Divider(),
                            _buildInfoRow("Status Pembayaran", currentPembayaran),
                            const Divider(thickness: 1.5),
                            _buildInfoRow(
                                "Total Layanan", _formatRupiah(totalHarga)),
                            const SizedBox(height: 4),
                            _buildInfoRow("Antar-Jemput",
                                _formatRupiah(antarJemputHarga)),
                            const SizedBox(height: 4),
                            _buildInfoRow(
                              "Diskon",
                              "- ${_formatRupiah(diskonNominal)}",
                            ),
                            const Divider(thickness: 1.5),
                            Row(
                              children: [
                                const Text("Total Bayar",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15)),
                                const Spacer(),
                                Text(_formatRupiah(totalBayar),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ================= TOMBOL AKSI =================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        bool isReady = currentStatus.toLowerCase() == 'ready';
                        String targetStatus = isReady ? "Selesai" : "Ready";
                        
                        confirmationModal(
                          title: "Konfirmasi Status Pesanan",
                          message:
                              "Apakah Anda yakin ingin memperbarui status pesanan menjadi '$targetStatus'?",
                          onConfirm: () => updateStatus(targetStatus),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black),
                      child: Text(
                        currentStatus.toLowerCase() == 'ready'
                            ? "Selesaikan Pesanan"
                            : "Ubah Status Pesanan",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Conditionally show payment button only if NOT Lunas
                  if (currentPembayaran.toLowerCase() != 'lunas')
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          confirmationModal(
                            title: "Konfirmasi Pembayaran",
                            message:
                                "Apakah Anda yakin ingin mengubah status pembayaran menjadi 'Lunas (Tunai)'?",
                            onConfirm: updateTransaksi,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                            foregroundColor: Colors.black),
                        child: const Text("Ubah Status Pembayaran",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        confirmationModal(
                          title: "Konfirmasi Pembatalan",
                          message:
                              "Apakah Anda yakin ingin Membatalkan pesanan ini?",
                          onConfirm: cancelOrder,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white),
                      child: const Text("Batalkan Pesanan"),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(color: Colors.black87, fontSize: 13)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 13)),
      ],
    );
  }
}