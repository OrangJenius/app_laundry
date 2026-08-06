import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/ownerModel.dart';

class OwnerService {
  final _supabase = Supabase.instance.client;
  Future<List<OwnerModel>> fetchowner(String id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('owner') // Your table name
          .select()
          .eq('id', id);
          
      return data.map((json) => OwnerModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching owners: $e');
      rethrow; 
    }
  }

  // ADD owner
  Future<String> addowner(OwnerModel owner) async {
    try {
      final data = await _supabase
          .from('owner')
          .insert(owner.toMap())
          .select()
          .single();
      final res = OwnerModel.fromMap(data);
      return res.id!;
    } catch (e) {
      print('Error adding owner: $e');
      rethrow;
    }
  }
}