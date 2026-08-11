import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class ReceiptPrintService {
  Future<List<BluetoothInfo>> getPairedPrinters() async {
    return await PrintBluetoothThermal.pairedBluetooths;
  }

  Future<bool> isConnected() async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  Future<bool> connectPrinter(String macAddress) async {
    return await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  Future<bool> printBytes(List<int> bytes) async {
    return await PrintBluetoothThermal.writeBytes(bytes);
  }

  /// Mirrors whatsappNota() content/order exactly, formatted for thermal paper.
  Future<List<int>> generateNotaPelanggan({
    required String storeName,
    required String alamatToko,
    required String pNToko,
    required String nota,
    required String customerName,
    required String customerPhone,
    required String alamat,
    required String kasir,
    required String masuk,
    required String est,
    required List<Map<String, dynamic>> orderDetailsList,
    required String parfum,
    required String total, // formatted, e.g. "Rp. 15.000" — same value used for both total lines, matching WA
    required String statusBayar,
    required String ketentuan,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text(storeName,
        styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
    bytes += generator.text(alamatToko, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(pNToko, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(1);

    bytes += generator.text(nota, styles: const PosStyles(bold: true));
    bytes += generator.text('Pelanggan: $customerName');
    bytes += generator.text('No Handphone: $customerPhone');
    bytes += generator.text('Alamat: $alamat');
    bytes += generator.text('Kasir: $kasir');
    bytes += generator.text('Masuk: $masuk');
    bytes += generator.text('Est Selesai: $est');

    bytes += generator.hr();
    bytes += generator.text('LAYANAN', styles: const PosStyles(bold: true));
    for (final detail in orderDetailsList) {
      final serviceName = detail['service']?['service_name'] ?? '-';
      final durasiName = detail['service']?['duration']?['duration_name'] ?? '-';
      final qty = detail['quantity']?.toString() ?? '-';
      final unit = detail['service']?['unit']?['unit_name'] ?? '-';
      final subtotal = _formatRupiah(detail['subtotal'] ?? 0);
      bytes += generator.text('$serviceName ($durasiName)');
      bytes += generator.text('$qty $unit = $subtotal');
    }

    bytes += generator.hr();
    bytes += generator.text('Parfum: $parfum');
    bytes += generator.hr();
    bytes += generator.text('Total Layanan: $total');

    bytes += generator.hr();
    bytes += generator.text('PEMBAYARAN', styles: const PosStyles(bold: true));
    bytes += generator.text('Total: $total', styles: const PosStyles(bold: true));
    bytes += generator.text('Status: $statusBayar');

    if (ketentuan.isNotEmpty && ketentuan != '-') {
      bytes += generator.feed(1);
      bytes += generator.text(ketentuan, styles: const PosStyles(align: PosAlign.center));
    }

    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  /// Internal ticket for production/staff — no pricing, just what to do with the order.
  /// Internal ticket for production/staff — includes full order + payment info.
  Future<List<int>> generateNotaProduksi({
    required String storeName,
    required String alamatToko,
    required String pNToko,
    required String nota,
    required String customerName,
    required String customerPhone,
    required String alamat,
    required String kasir,
    required String masuk,
    required String est,
    required List<Map<String, dynamic>> orderDetailsList,
    required String parfum,
    required String catatan,
    required String total,
    required String statusBayar,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text(storeName,
        styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
    bytes += generator.text(alamatToko, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(pNToko, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('*** NOTA PRODUKSI ***',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(1);

    bytes += generator.text(nota, styles: const PosStyles(bold: true));
    bytes += generator.text('Pelanggan: $customerName');
    bytes += generator.text('No Handphone: $customerPhone');
    bytes += generator.text('Alamat: $alamat');
    bytes += generator.text('Kasir: $kasir');
    bytes += generator.text('Masuk: $masuk');
    bytes += generator.text('Est Selesai: $est');

    bytes += generator.hr();
    bytes += generator.text('LAYANAN', styles: const PosStyles(bold: true));
    for (final detail in orderDetailsList) {
      final serviceName = detail['service']?['service_name'] ?? '-';
      final durasiName = detail['service']?['duration']?['duration_name'] ?? '-';
      final qty = detail['quantity']?.toString() ?? '-';
      final unit = detail['service']?['unit']?['unit_name'] ?? '-';
      bytes += generator.text('$serviceName ($durasiName)',
          styles: const PosStyles(bold: true, height: PosTextSize.size2));
      bytes += generator.text('Jumlah: $qty $unit');
    }

    if (parfum.isNotEmpty && parfum != '-') {
      bytes += generator.hr();
      bytes += generator.text('Parfum: $parfum');
    }

    if (catatan.isNotEmpty && catatan != '-') {
      bytes += generator.hr();
      bytes += generator.text('Catatan:', styles: const PosStyles(bold: true));
      bytes += generator.text(catatan);
    }

    bytes += generator.hr();
    bytes += generator.text('PEMBAYARAN', styles: const PosStyles(bold: true));
    bytes += generator.text('Total: $total', styles: const PosStyles(bold: true));
    bytes += generator.text('Status: $statusBayar');

    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  String _formatRupiah(int uang) {
    return "Rp. ${uang.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}