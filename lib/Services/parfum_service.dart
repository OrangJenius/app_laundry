import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/parfumModel.dart';

class ParfumService {
  final _supabase = Supabase.instance.client;

  // FETCH parfumS
  Future<List<ParfumModel>> fetchparfum(String store_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('parfum') // Your table name
          .select()
          .eq('store_id', store_id);
          
      return data.map((json) => ParfumModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching parfums: $e');
      rethrow; 
    }
  }

  // ADD parfum
  Future<void> addparfum(ParfumModel parfum) async {
    try {
      await _supabase
          .from('parfum')
          .insert(parfum.toMap());
    } catch (e) {
      print('Error adding parfum: $e');
      rethrow;
    }
  }

// Delete parfum
  Future<void> deleteparfum(String id) async { // You only need the id to delete
    try {
      await _supabase
          .from('parfum')
          .delete()
          .eq('id', id); // <--- Tell Supabase WHICH row to delete
    } catch (e) {
      print('Error deleting parfum: $e');
      rethrow;
    }
  }
  
  // Edit parfum
  Future<void> editparfum(String id, ParfumModel parfum) async {
    try {
      await _supabase
          .from('parfum')
          .update(parfum.toMap()) // <--- Pass the updated data map here
          .eq('id', id);             // <--- Target the specific parfum ID
    } catch (e) {
      print('Error updating parfum: $e'); // Fixed the print message too!
      rethrow;
    }
  }
}