import 'package:app_laundry/Models/orderModel.dart';
import 'package:app_laundry/Screens/rincianPesanan.dart';
import 'package:app_laundry/Services/orderDetail_service.dart';
import 'package:app_laundry/Services/orderStatus_service.dart';
import 'package:app_laundry/Services/order_service.dart';
import 'package:app_laundry/Services/transaksi_service.dart';
import 'package:app_laundry/Widgets/upperBarExcel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:excel/excel.dart' as excel_lib;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DetailLaporanPesananScreen extends StatefulWidget {
  final DateTimeRange date;
  final String store_id;

  const DetailLaporanPesananScreen({
    super.key,
    required this.date,
    required this.store_id,
  });

  @override
  State<DetailLaporanPesananScreen> createState() =>
      _DetailLaporanPesananScreenState();
}

class _DetailLaporanPesananScreenState
    extends State<DetailLaporanPesananScreen> {
  final orderService = OrderService();
  final transaksiService = TransaksiService();
  final orderDetailService = OrderDetailService();
  final orderStatusService = OrderStatusService();

  late Future<Map<String, dynamic>> _reportDataFuture;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final DateFormat _dateFormatShort = DateFormat('dd MMM yyyy');
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy - HH:mm');

  @override
  void initState() {
    super.initState();
    _reportDataFuture = _fetchReportData();
  }

  Future<Map<String, dynamic>> _fetchReportData() async {
    final List<dynamic> rawOrders =
      await orderService.fetchOrdersByStoreAndDate(
      widget.store_id,
      widget.date.start,
      widget.date.end,
    );

    List<OrderModel> orders =
        rawOrders.map((e) => OrderModel.fromMap(e)).toList();

    if (orders.isEmpty) {
      return {
        'orders': <OrderModel>[],
        'summary': _createEmptySummary(),
        'transactions': <String, dynamic>{},
        'latestStatuses': <String, String>{},
      };
    }

    final List<String> orderIds =
        orders.map((e) => e.id!).where((id) => id.isNotEmpty).toList();

    final results = await Future.wait([
      transaksiService.fetchTransaksiByOrderIds(orderIds),
      orderDetailService.fetchOrderDetailByOrderIds(orderIds),
      orderStatusService.fetchOrderStatusByOrderIds(orderIds),
    ]);

    final List<dynamic> rawTransactions = results[0];
    final List<dynamic> rawDetails = results[1];
    final List<dynamic> rawStatuses = results[2];

    Map<String, dynamic> txMap = {};
    for (var tx in rawTransactions) {
      if (tx['order_id'] != null) {
        txMap[tx['order_id'].toString()] = tx;
      }
    }

    Map<String, String> latestStatusMap = {};
    for (var status in rawStatuses) {
      if (status['order_id'] != null) {
        latestStatusMap[status['order_id'].toString()] =
            status['status_name'] ?? status['status_order'] ?? 'Dalam Proses';
      }
    }

    int totalOrders = orders.length;
    double totalValue = 0;
    double paidValue = 0;
    double unpaidValue = 0;

    int canceledOrders = 0;
    double canceledValue = 0;

    double totalDelivery = 0;
    double totalDiscount = 0;
    double totalKiloan = 0;
    double totalSatuan = 0;
    double totalMeteran = 0;

    for (var order in orders) {
      print ("ORDERRRRR: $order");
      print ("ORDERRRRRsssssss: $orders");
      double total = double.tryParse(order.total_harga ?? '0') ?? 0;
      double delivery = double.tryParse(order.antar_jemput!.harga ?? '0') ?? 0;
      double discount = double.tryParse(order.discount_id ?? '0') ??0;

      totalDelivery += delivery;
      totalDiscount += discount;

      String status = (latestStatusMap[order.id] ?? '').toLowerCase();

      if (status.contains('batal') || status.contains('cancel')) {
        canceledOrders++;
        canceledValue += total;
      } else {
        totalValue += total;

        var tx = txMap[order.id];
        if (tx != null &&
            (tx['status_pembayaran'] ?? '').toString().toLowerCase() ==
                'lunas') {
          paidValue += total;
        } else {
          unpaidValue += total;
        }
      }
    }

    for (var detail in rawDetails) {
      String unit = (detail['service']?['unit']?['unit_name'] ?? '').toString().toLowerCase();
      double qty =
          double.tryParse((detail['quantity'])?.toString() ?? '0') ?? 0;
      print("QTY: $qty");
      print("UNIT: $unit");
      if (unit.contains('kg') || unit.contains('kilo')) {
        totalKiloan += qty;
      } else if (unit.contains('pcs') || unit.contains('satuan')) {
        totalSatuan += qty;
      } else if (unit.contains('m') || unit.contains('meter')) {
        totalMeteran += qty;
      }
    }

    print("Quantity: $totalKiloan, $totalMeteran, $totalSatuan");

    return {
      'orders': orders,
      'transactions': txMap,
      'latestStatuses': latestStatusMap,
      'summary': {
        'totalOrders': totalOrders,
        'totalValue': totalValue,
        'paidValue': paidValue,
        'unpaidValue': unpaidValue,
        'canceledOrders': canceledOrders,
        'canceledValue': canceledValue,
        'totalDelivery': totalDelivery,
        'totalDiscount': totalDiscount,
        'totalKiloan': totalKiloan,
        'totalSatuan': totalSatuan,
        'totalMeteran': totalMeteran,
      }
    };
  }

  Map<String, dynamic> _createEmptySummary() {
    return {
      'totalOrders': 0,
      'totalValue': 0.0,
      'paidValue': 0.0,
      'unpaidValue': 0.0,
      'canceledOrders': 0,
      'canceledValue': 0.0,
      'totalDelivery': 0.0,
      'totalDiscount': 0.0,
      'totalKiloan': 0.0,
      'totalSatuan': 0.0,
      'totalMeteran': 0.0,
    };
  }

  bool _isExporting = false;

  Future<void> _exportToExcel({
    required List<OrderModel> orders,
    required Map<String, dynamic> summary,
    required Map<String, dynamic> transactions,
    required Map<String, String> latestStatuses,
  }) async {
    setState(() => _isExporting = true);

    try {
      final excel_lib.Excel excelFile = excel_lib.Excel.createExcel();
      final excel_lib.Sheet sheet = excelFile['Laporan Pesanan'];
      excelFile.delete('Sheet1');

      final excel_lib.CellStyle headerStyle = excel_lib.CellStyle(
        bold: true,
        backgroundColorHex: excel_lib.ExcelColor.fromHexString('#9C27B0'),
        fontColorHex: excel_lib.ExcelColor.white,
      );
      final excel_lib.CellStyle boldStyle = excel_lib.CellStyle(bold: true);

      int row = 0;

      void writeCell(int col, int r, dynamic value, {excel_lib.CellStyle? style}) {
        final cell = sheet.cell(
          excel_lib.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: r),
        );
        if (value is num) {
          cell.value = excel_lib.DoubleCellValue(value.toDouble());
        } else {
          cell.value = excel_lib.TextCellValue(value.toString());
        }
        if (style != null) cell.cellStyle = style;
      }

      final formattedPeriod =
          "${_dateFormatShort.format(widget.date.start)} - ${_dateFormatShort.format(widget.date.end)}";

      // Title & Meta
      writeCell(0, row, 'LAPORAN PESANAN', style: headerStyle);
      row++;
      writeCell(0, row, 'Outlet');
      writeCell(1, row, widget.store_id);
      row++;
      writeCell(0, row, 'Periode');
      writeCell(1, row, formattedPeriod);
      row += 2;

      // Section: Ringkasan
      writeCell(0, row, 'RINGKASAN', style: headerStyle);
      row++;

      void writeSummaryLine(String label, dynamic value, {bool bold = false}) {
        writeCell(0, row, label, style: bold ? boldStyle : null);
        writeCell(1, row, value, style: bold ? boldStyle : null);
        row++;
      }

      writeSummaryLine('Jumlah Pesanan', summary['totalOrders'], bold: true);
      writeSummaryLine('Nilai Pesanan', summary['totalValue'], bold: true);
      writeSummaryLine('  Sudah Bayar', summary['paidValue']);
      writeSummaryLine('  Belum Bayar', summary['unpaidValue']);
      writeSummaryLine('Pesanan Batal', summary['canceledOrders'], bold: true);
      writeSummaryLine('Nilai Pesanan Batal', summary['canceledValue']);
      writeSummaryLine('Total Antar-Jemput', summary['totalDelivery'], bold: true);
      writeSummaryLine('Total Diskon', summary['totalDiscount'], bold: true);
      writeSummaryLine('Total Kiloan (Kg)', summary['totalKiloan'], bold: true);
      writeSummaryLine('Total Satuan (pcs)', summary['totalSatuan'], bold: true);
      writeSummaryLine('Total Meteran (m)', summary['totalMeteran'], bold: true);

      row += 1;

      // Section: List Pesanan
      writeCell(0, row, 'DAFTAR PESANAN', style: headerStyle);
      row++;

      final headers = [
        'Tanggal',
        'Receipt',
        'Pelanggan',
        'Kasir',
        'Status',
        'Total',
        'Status Bayar',
        'Metode Bayar',
      ];
      for (int i = 0; i < headers.length; i++) {
        writeCell(i, row, headers[i], style: boldStyle);
      }
      row++;

      for (var order in orders) {
        final tx = transactions[order.id];
        final statusName = latestStatuses[order.id] ?? 'Dalam Proses';

        final createdDate = order.created_at != null
            ? DateTime.tryParse(order.created_at!) ?? DateTime.now()
            : DateTime.now();

        final orderTotal = double.tryParse(order.total_harga ?? '0') ?? 0;

        final paymentStatus =
            tx != null ? (tx['status_pembayaran'] ?? 'Belum Bayar') : 'Belum Bayar';
        final paymentMethod = tx != null
            ? (tx['metode_pembayaran'] ?? tx['jenis_pembayaran'] ?? '-')
            : '-';

        writeCell(0, row, _dateTimeFormat.format(createdDate));
        writeCell(1, row, order.receipt ?? '-');
        writeCell(2, row, order.customer?.nama ?? 'Pelanggan');
        writeCell(3, row, order.profiles?.cashier_name ?? 'Manager');
        writeCell(4, row, statusName);
        writeCell(5, row, orderTotal);
        writeCell(6, row, paymentStatus);
        writeCell(7, row, paymentMethod);
        row++;
      }

      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20);
      }

      final directory = await getTemporaryDirectory();
      final fileName =
          'Laporan_Pesanan_${widget.store_id}_${DateFormat('yyyyMMdd').format(widget.date.start)}.xlsx'
              .replaceAll(' ', '_');
      final filePath = '${directory.path}/$fileName';
      final fileBytes = excelFile.encode();

      if (fileBytes == null) throw Exception('Gagal encode file excel');

      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Laporan Pesanan',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedPeriod =
        "${_dateFormatShort.format(widget.date.start)} - ${_dateFormatShort.format(widget.date.end)}";

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _reportDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: const [
                  UpperBarExcel(title: "LAPORAN PESANAN"),
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return Column(
                children: [
                  const UpperBarExcel(title: "LAPORAN PESANAN"),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Terjadi kesalahan: ${snapshot.error}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }

            final data = snapshot.data!;
            final List<OrderModel> orders = data['orders'];
            final Map<String, dynamic> summary = data['summary'];
            final Map<String, dynamic> transactions = data['transactions'];
            final Map<String, String> latestStatuses = data['latestStatuses'];

            return SingleChildScrollView(
              child: Column(
                children: [
                  UpperBarExcel(
                    title: "LAPORAN PESANAN",
                    isExporting: _isExporting,
                    onExport: () => _exportToExcel(
                      orders: orders,
                      summary: summary,
                      transactions: transactions,
                      latestStatuses: latestStatuses,
                    ),
                  ),

                  // CARD 1: RINGKASAN
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildRowInfo("Outlet", widget.store_id),
                            _buildRowInfo("Periode", formattedPeriod),
                            const Divider(color: Colors.grey, height: 24),

                            _buildRowInfo(
                              "Jumlah Pesanan",
                              "${summary['totalOrders']} Pesanan",
                              isBold: true,
                            ),
                            _buildRowInfo(
                              "Nilai Pesanan",
                              _currencyFormat.format(summary['totalValue']),
                              isBold: true,
                            ),
                            _buildRowSubInfo(
                              "Sudah Bayar",
                              _currencyFormat.format(summary['paidValue']),
                            ),
                            _buildRowSubInfo(
                              "Belum Bayar",
                              _currencyFormat.format(summary['unpaidValue']),
                            ),
                            const SizedBox(height: 12),

                            _buildRowInfo(
                              "Pesanan Batal",
                              "${summary['canceledOrders']} Pesanan",
                              isBold: true,
                            ),
                            _buildRowInfo(
                              "Nilai Pesanan Batal",
                              _currencyFormat.format(
                                  summary['canceledValue']),
                            ),
                            const SizedBox(height: 12),

                            _buildRowInfo(
                              "Total Antar-Jemput",
                              _currencyFormat.format(
                                  summary['totalDelivery']),
                              isBold: true,
                            ),
                            _buildRowInfo(
                              "Total Diskon",
                              _currencyFormat.format(
                                  summary['totalDiscount']),
                              isBold: true,
                            ),
                            _buildRowInfo(
                              "Total Kiloan",
                              "${(summary['totalKiloan'] as double).toStringAsFixed(1)} Kg",
                              isBold: true,
                            ),
                            _buildRowInfo(
                              "Total Satuan",
                              "${(summary['totalSatuan'] as double).toInt()} pcs",
                              isBold: true,
                            ),
                            _buildRowInfo(
                              "Total Meteran",
                              "${(summary['totalMeteran'] as double).toStringAsFixed(2)} m",
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // CARD 2: LIST TRANSAKSI
                  if (orders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        "Tidak ada pesanan pada periode ini.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final tx = transactions[order.id];
                        final statusName =
                            latestStatuses[order.id] ?? "Dalam Proses";

                        DateTime createdDate = order.created_at != null
                            ? DateTime.tryParse(order.created_at!) ?? DateTime.now()
                            : DateTime.now();

                        double orderTotal =
                            double.tryParse(order.total_harga ?? '0') ?? 0;

                        String paymentStatus = tx != null
                            ? (tx['status_pembayaran'] ?? 'Belum Bayar')
                            : 'Belum Bayar';
                        String paymentMethod = tx != null
                            ? (tx['metode_pembayaran'] ?? tx['jenis_pembayaran'] ?? '-')
                            : '-';

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RincianPesananScreen(
                                  store_id: widget.store_id,
                                  order_id: order.id!,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: Card(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Card(
                                            color: _getStatusColor(statusName),
                                            margin: EdgeInsets.zero,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              child: Text(
                                                statusName,
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _dateTimeFormat.format(createdDate),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${order.customer!.nama ?? 'Pelanggan'} : ${order.receipt ?? '-'}",
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          Text(
                                            order.profiles!.cashier_name ?? "Manager",
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _currencyFormat.format(orderTotal),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "$paymentStatus - $paymentMethod",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    String lower = status.toLowerCase();
    if (lower.contains('selesai') || lower.contains('lunas')) {
      return Colors.greenAccent;
    } else if (lower.contains('batal') || lower.contains('cancel')) {
      return Colors.redAccent.shade100;
    }
    return Colors.amberAccent;
  }

  Widget _buildRowInfo(String label, String value, {bool isBold = false}) {
    final style = TextStyle(
      color: Colors.black,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildRowSubInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}