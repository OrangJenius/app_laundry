import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/storeModel.dart';

class StoreService {
  final _supabase = Supabase.instance.client;
  
  Future<List<StoreModel>> fetchStoreWithOwnerId(String owner_id) async {
     try {
      final List<dynamic> data = await _supabase
          .from('store') // Your table name
          .select()
          .eq('owner_id', owner_id);
          
      return data.map((json) => StoreModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching Store: $e');
      rethrow; 
    }
  }
  Future<StoreModel?> fetchStoreWithId(String id) async {
    try {
      final data = await _supabase
          .from('store')
          .select()
          .eq('id', id)
          .maybeSingle(); // <--- KUNCINYA DI SINI

      if (data == null) return null;

      // Langsung ubah satu Map tunggal menjadi satu objek StoreModel
      return StoreModel.fromMap(data); 
    } catch (e) {
      print('Error fetching Store: $e');
      rethrow;
    }
  }
  Future<void> addStore(StoreModel Store) async {
    try {
      await _supabase
          .from('store')
          .insert(Store.toMap());
    } catch (e) {
      print('Error adding Store: $e');
      rethrow;
    }
  }
  Future<void> editStore(String id, StoreModel Store) async {
    try {
      await _supabase
          .from('store')
          .update(Store.toMap())
          .eq('id', id);
    } catch (e) {
      print('Error updating Store: $e');
      rethrow;
    }
  }
    Future<void> deleteStore(String id, StoreModel Store) async {
    try {
      await _supabase
          .from('store')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error updating Store: $e');
      rethrow;
    }
  }
}