import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/diskonModel.dart';

class DiskonService {
  final _supabase = Supabase.instance.client;

  // FETCH diskon
  Future<List<DiskonModel>> fetchdiskon(String? store_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('diskon') // Your table name
          .select()
          .eq('store_id', store_id!);
          
      return data.map((json) => DiskonModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching diskons: $e');
      rethrow; 
    }
  }

  // ADD diskon
  Future<void> adddiskon(DiskonModel diskon) async {
    try {
      await _supabase
          .from('diskon')
          .insert(diskon.toMap());
    } catch (e) {
      print('Error adding diskon: $e');
      rethrow;
    }
  }

// Delete diskon
  Future<void> deletediskon(String id) async { // You only need the id to delete
    try {
      await _supabase
          .from('diskon')
          .delete()
          .eq('id', id); // <--- Tell Supabase WHICH row to delete
    } catch (e) {
      print('Error deleting diskon: $e');
      rethrow;
    }
  }
  
  // Edit diskon
  Future<void> editdiskon(String id, DiskonModel diskon) async {
    try {
      await _supabase
          .from('diskon')
          .update(diskon.toMap()) // <--- Pass the updated data map here
          .eq('id', id);             // <--- Target the specific diskon ID
    } catch (e) {
      print('Error updating diskon: $e'); // Fixed the print message too!
      rethrow;
    }
  }
}