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
  Future<void> editTransaksi(String id, TransaksiModel Transaksi) async {
    try {
      await _supabase
          .from('transaction')
          .update(Transaksi.toMap())
          .eq('id', id);
    } catch (e) {
      print('Error updating Transaksi: $e');
      rethrow;
    }
  }
    Future<void> deleteTransaksi(String id, TransaksiModel Transaksi) async {
    try {
      await _supabase
          .from('transaction')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error updating Transaksi: $e');
      rethrow;
    }
  }
}