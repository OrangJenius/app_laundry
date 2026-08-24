import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/transaksiModel.dart';
import 'package:intl/intl.dart';

class TransaksiService {
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

  /// Convert created_at in a dynamic map to local timezone
  Map<String, dynamic> _convertMapToLocal(Map<String, dynamic> data) {
    if (data.containsKey('created_at') && data['created_at'] != null) {
      final localDt = _convertToLocal(data['created_at']);
      data['created_at'] = localDt.toString();
    }
    return data;
  }

  Future<List<TransaksiModel>> fetchTransaksi(String order_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('transaction')
          .select()
          .eq('order_id', order_id);

      return data.map((json) {
        var model = TransaksiModel.fromMap(json);
        // Convert created_at to local timezone
        if (model.created_at != null) {
          model.created_at = _convertToLocal(model.created_at).toString();
        }
        return model;
      }).toList();
    } catch (e) {
      print('Error fetching Transaksi: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchTransaksi2(String order_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('transaction')
          .select()
          .eq('order_id', order_id);

      // Convert created_at to local timezone
      return data
          .map((item) => _convertMapToLocal(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching Transaksi: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchStoreTransaksi(String storeId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('transaction')
          .select('*, order!inner(store_id)')
          .eq('order.store_id', storeId);

      // Convert created_at to local timezone
      return data
          .map((item) => _convertMapToLocal(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching Store Transaksi: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchTransaksiNow(String storeId, DateTime date) async {
    try {
      // Convert to UTC for database query
      final dateUTC = date.toUtc();
      
      // Define the start and end of the target day in UTC
      final startOfDay = DateTime(dateUTC.year, dateUTC.month, dateUTC.day).toIso8601String();
      final endOfDay = DateTime(dateUTC.year, dateUTC.month, dateUTC.day, 23, 59, 59, 999).toIso8601String();

      final List<dynamic> data = await _supabase
          .from('transaction')
          .select('*, order!inner(store_id)')
          .eq('order.store_id', storeId)
          .gte('created_at', startOfDay)
          .lte('created_at', endOfDay);

      // Convert created_at to local timezone
      return data
          .map((item) => _convertMapToLocal(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching Transaksi Now: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchTransaksiByOrderIds(List<String> orderIds) async {
    if (orderIds.isEmpty) return [];

    final response = await _supabase
        .from('transaction')
        .select('*')
        .inFilter('order_id', orderIds);

    // Convert created_at to local timezone
    return (response as List)
        .map((item) => _convertMapToLocal(item as Map<String, dynamic>))
        .toList();
  }

  Future<TransaksiModel?> fetchTransaksiWithId(String id) async {
    try {
      final data = await _supabase
          .from('transaction')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;

      var model = TransaksiModel.fromMap(data);
      // Convert created_at to local timezone
      if (model.created_at != null) {
        model.created_at = _convertToLocal(model.created_at).toString();
      }
      return model;
    } catch (e) {
      print('Error fetching Transaksi: $e');
      rethrow;
    }
  }

  Future<void> addTransaksi(TransaksiModel transaksi) async {
    try {
      await _supabase
          .from('transaction')
          .insert(transaksi.toMap());
    } catch (e) {
      print('Error adding Transaksi: $e');
      rethrow;
    }
  }

  Future<String> editTransaksi(String order_id, TransaksiModel transaksi) async {
    try {
      // Convert ke Map lalu hapus key bernilai null
      final Map<String, dynamic> updateData = transaksi.toMap();

      updateData.removeWhere((key, value) => value == null);

      final response = await _supabase
          .from('transaction')
          .update(updateData)
          .eq('order_id', order_id)
          .select()
          .single();

      var updatedData = TransaksiModel.fromMap(response);
      
      // Convert created_at to local timezone
      if (updatedData.created_at != null) {
        updatedData.created_at = _convertToLocal(updatedData.created_at).toString();
      }

      // Pastikan mengembalikan nilai default "0" jika jumlah_transaksi ternyata null
      return updatedData.jumlah_transaksi ?? "0";
    } catch (e) {
      print('Error updating Transaksi: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaksi(String order_id) async {
    try {
      await _supabase
          .from('transaction')
          .delete()
          .eq('order_id', order_id);
    } catch (e) {
      print('Error deleting Transaksi: $e');
      rethrow;
    }
  }
}