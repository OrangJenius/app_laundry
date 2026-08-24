import 'package:app_laundry/Models/cashFlowModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CashFlowService {
  final _supabase = Supabase.instance.client;

  /// Helper: Convert UTC datetime to local timezone
  DateTime _convertToLocal(dynamic dateTimeValue) {
    if (dateTimeValue is String) {
      return DateTime.parse(dateTimeValue).toLocal();
    } else if (dateTimeValue is DateTime) {
      return dateTimeValue.toLocal();
    }
    return DateTime.now();
  }

  /// Helper: Format datetime for display
  String formatDateTime(dynamic dateTimeValue) {
    final localDateTime = _convertToLocal(dateTimeValue);
    return DateFormat('dd MMM yyyy, HH:mm').format(localDateTime);
  }

  /// 1. Tambah Record Mutasi Kas Baru
  Future<CashFlowModel> createCashFlow(CashFlowModel cashFlow) async {
    final dataMap = cashFlow.toMap();

    if (cashFlow.id == null) dataMap.remove('id');
    if (cashFlow.created_at == null) dataMap.remove('created_at');
    if (cashFlow.order_id == null) dataMap.remove('order_id');

    final response = await _supabase
        .from('cash_flow')
        .insert(dataMap)
        .select()
        .single();

    return CashFlowModel.fromMap(response);
  }

  /// 2. Helper Khusus: Tambah Modal
  Future<CashFlowModel> addModal({
    required String jumlah,
    required String caraTransaksi,
    required String profileId,
    required String store_id,
    required String keterangan,
  }) async {
    final model = CashFlowModel(
      jumlah: jumlah,
      keterangan: keterangan,
      tipe: 'MASUK',
      cara_transaksi: caraTransaksi,
      profile_id: profileId,
      store_id: store_id
    );
    return await createCashFlow(model);
  }

  /// 3. Helper Khusus: Catat Pengeluaran Operasional
  Future<CashFlowModel> addPengeluaran({
    required String jumlah,
    required String keterangan,
    required String caraTransaksi,
    required String profileId,
    required String store_id
  }) async {
    final model = CashFlowModel(
      jumlah: jumlah,
      keterangan: keterangan,
      tipe: 'KELUAR',
      cara_transaksi: caraTransaksi,
      profile_id: profileId,
      store_id: store_id
    );
    return await createCashFlow(model);
  }

  /// 4. Helper Khusus: Pembayaran Order Laundry
  Future<CashFlowModel> addOrderPayment({
    required String orderId,
    required String jumlah,
    required String caraTransaksi,
    required String profileId,
    String? keterangan = "Pendapatan",
    required String store_id,
  }) async {
    final model = CashFlowModel(
      order_id: orderId,
      jumlah: jumlah,
      keterangan: keterangan ?? 'Pembayaran Order #$orderId',
      tipe: 'MASUK',
      cara_transaksi: caraTransaksi,
      profile_id: profileId,
      store_id: store_id,
    );
    return await createCashFlow(model);
  }

  /// 5. Fetch Semua Mutasi Kas (Filter Store ID & Date Range)
  /// NOW RETURNS DATETIMES IN LOCAL TIMEZONE
  Future<List<CashFlowModel>> getCashFlows({
    required String storeId,
    DateTime? startDate,
    DateTime? endDate,
    String? tipe,
    String? caraTransaksi,
  }) async {
    var query = _supabase.from('cash_flow').select().eq('store_id', storeId);

    if (startDate != null) {
      query = query.gte('created_at', startDate.toUtc().toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('created_at', endDate.toUtc().toIso8601String());
    }
    if (tipe != null) {
      query = query.eq('tipe', tipe);
    }
    if (caraTransaksi != null) {
      query = query.eq('cara_transaksi', caraTransaksi);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List).map((e) {
      var model = CashFlowModel.fromMap(e as Map<String, dynamic>);
      // Convert created_at to local timezone
      if (model.created_at != null) {
        model.created_at = _convertToLocal(model.created_at).toString();
      }
      return model;
    }).toList();
  }

  /// 6. Hitung Laporan Saldo Kas & Rincian per Cara Transaksi
  Future<Map<String, dynamic>> getCashFlowReport({
    DateTime? startDate,
    DateTime? endDate,
    String? store_id,
  }) async {
    final data = await getCashFlows(
      startDate: startDate,
      endDate: endDate,
      storeId: store_id!,
    );

    double totalMasuk = 0;
    double totalKeluar = 0;
    Map<String, double> saldoPerMetode = {};

    for (var item in data) {
      final nominal = double.tryParse(item.jumlah) ?? 0.0;
      final cara = item.cara_transaksi;

      saldoPerMetode.putIfAbsent(cara, () => 0.0);

      if (item.tipe.toUpperCase() == 'MASUK') {
        totalMasuk += nominal;
        saldoPerMetode[cara] = saldoPerMetode[cara]! + nominal;
      } else if (item.tipe.toUpperCase() == 'KELUAR') {
        totalKeluar += nominal;
        saldoPerMetode[cara] = saldoPerMetode[cara]! - nominal;
      }
    }

    return {
      'total_masuk': totalMasuk,
      'total_keluar': totalKeluar,
      'saldo_akhir': totalMasuk - totalKeluar,
      'saldo_per_metode': saldoPerMetode,
    };
  }
}