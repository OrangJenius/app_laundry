import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/antarJemputModel.dart';

class AntarJemputService {
  final _supabase = Supabase.instance.client;

  // FETCH antarjemputS
  Future<List<AntarJemputModel>> fetchantarjemput(String? store_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('antar_jemput') // Your table name
          .select()
          .eq('store_id', store_id!);
          
      return data.map((json) => AntarJemputModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching antarjemputs: $e');
      rethrow; 
    }
  }

  // ADD antarjemput
  Future<void> addantarjemput(AntarJemputModel antarjemput) async {
    try {
      await _supabase
          .from('antar_jemput')
          .insert(antarjemput.toMap());
    } catch (e) {
      print('Error adding antarjemput: $e');
      rethrow;
    }
  }

// Delete antarjemput
  Future<void> deleteantarjemput(String id) async { // You only need the id to delete
    try {
      await _supabase
          .from('antar_jemput')
          .delete()
          .eq('id', id); // <--- Tell Supabase WHICH row to delete
    } catch (e) {
      print('Error deleting antarjemput: $e');
      rethrow;
    }
  }
  
  // Edit antarjemput
  Future<void> editantarjemput(String id, AntarJemputModel antarjemput) async {
    try {
      await _supabase
          .from('antar_jemput')
          .update(antarjemput.toMap()) // <--- Pass the updated data map here
          .eq('id', id);             // <--- Target the specific antarjemput ID
    } catch (e) {
      print('Error updating antarjemput: $e'); // Fixed the print message too!
      rethrow;
    }
  }
}