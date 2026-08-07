import 'package:app_laundry/Models/notaModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class NotaService {
  final _supabase = Supabase.instance.client;
  Future<NotaModel> fetchNota(String? id) async {
    try {
      final data = await _supabase
          .from('nota') // Your table name
          .select()
          .eq('id', id!)
          .maybeSingle();
          
      return NotaModel.fromMap(data!);
    } catch (e) {
      print('Error fetching diskons: $e');
      rethrow; 
    }
  }

  // ADD diskon
  Future<void> addNota(NotaModel nota) async {
    try {
      await _supabase
          .from('nota')
          .insert(nota.toMap());
    } catch (e) {
      print('Error adding diskon: $e');
      rethrow;
    }
  }

  Future<void> editNota(String id, NotaModel nota) async {
    try {
      await _supabase
          .from('nota')
          .update(nota.toMap()) // <--- Pass the updated data map here
          .eq('id', id);             // <--- Target the specific diskon ID
    } catch (e) {
      print('Error updating diskon: $e'); // Fixed the print message too!
      rethrow;
    }
  }
}