import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/transaksiModel.dart';

class TransaksiService {
  final _supabase = Supabase.instance.client;
  
  Future<List<TransaksiModel>> fetchTransaksi(String order_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('transaction') // Your table name
          .select()
          .eq('order_id', order_id);
          
      return data.map((json) => TransaksiModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching Transaksi: $e');
      rethrow; 
    }
  }
  Future<List<dynamic>> fetchTransaksi2(String order_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('transaction') // Your table name
          .select()
          .eq('order_id', order_id);
          
      return data;
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

      return data;
    } catch (e) {
      print('Error fetching Store Transaksi: $e');
      rethrow;
    }
  }
  Future<List<dynamic>> fetchTransaksiNow(String storeId, DateTime date) async {
    try {
      // Define the start and end of the target day
      final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toIso8601String();

      final List<dynamic> data = await _supabase
          .from('transaction')
          .select('*, order!inner(store_id)')
          .eq('order.store_id', storeId)
          .gte('created_at', startOfDay)
          .lte('created_at', endOfDay);

      return data;
    } catch (e) {
      print('Error fetching Transaksi Now: $e');
      rethrow;
    }
  }
  Future<List<dynamic>> fetchTransaksiByOrderIds(List<String> orderIds) async {
    if (orderIds.isEmpty) return [];

    return await _supabase
        .from('transaction')
        .select('*')
        .inFilter('order_id', orderIds);
  }
  Future<TransaksiModel?> fetchTransaksiWithId(String id) async {
    try {
      final data = await _supabase
          .from('transaction')
          .select()
          .eq('id', id)
          .maybeSingle(); // <--- KUNCINYA DI SINI

      if (data == null) return null;

      // Langsung ubah satu Map tunggal menjadi satu objek TransaksiModel
      return TransaksiModel.fromMap(data); 
    } catch (e) {
      print('Error fetching Transaksi: $e');
      rethrow;
    }
  }
  Future<void> addTransaksi(TransaksiModel Transaksi) async {
    try {
      await _supabase
          .from('transaction')
          .insert(Transaksi.toMap());
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

      final updatedData = TransaksiModel.fromMap(response);

      // Pastikan mengembalikan nilai default "0" jika jumlah_transaksi ternyata null
      return updatedData.jumlah_transaksi ?? "0";
    } catch (e) {
      print('Error updating Transaksi: $e');
      rethrow;
    }
  }
    Future<void> deleteTransaksi(String order_id,) async {
    try {
      await _supabase
          .from('transaction')
          .delete()
          .eq('order_id', order_id);
    } catch (e) {
      print('Error updating Transaksi: $e');
      rethrow;
    }
  }
}