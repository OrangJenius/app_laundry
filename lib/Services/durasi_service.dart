import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/durasiModel.dart';

class DurasiService {
  final _supabase = Supabase.instance.client;
  Future<List<DurasiModel>> fetchDurasi(String storeId) async {
    try {
      final response = await _supabase
          .from('duration')
          .select()
          .eq('store_id', storeId); // Sort by fastest to slowest

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => DurasiModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching Durasis: $e');
      rethrow;
    }
  }

  /// Add a new Durasi service option (e.g., Express 6 Hours)
  Future<void> addDurasi(DurasiModel durasi) async {
    try {
      await _supabase
          .from('duration')
          .insert(
            durasi.toMap()
          );
    } catch (e) {
      print('Error adding Durasi: $e');
      rethrow;
    }
  }

  /// Update an existing Durasi
  Future<void> updateDurasi(DurasiModel durasi, id) async {
    try {
      await _supabase
          .from('duration')
          .update(
            durasi.toMap()
          )
          .eq('id', id);
    } catch (e) {
      print('Error updating Durasi: $e');
      rethrow;
    }
  }

  /// Delete a Durasi option
  /// Note: Thanks to 'ON DELETE CASCADE' in your schema, 
  /// deleting this will automatically delete services attached to it safely.
  Future<void> deleteDurasi(String id) async {
    try {
      await _supabase
          .from('duration')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting Durasi: $e');
      rethrow;
    }
  }
}