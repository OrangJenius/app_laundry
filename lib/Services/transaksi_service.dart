import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/transaksiModel.dart';

class TransaksiService {
  final _supabase = Supabase.instance.client;
  
  Future<List<TransaksiModel>> fetchTransaksi(String store_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('transaction') // Your table name
          .select()
          .eq('store_id', store_id);
          
      return data.map((json) => TransaksiModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching Transaksi: $e');
      rethrow; 
    }
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