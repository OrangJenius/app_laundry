import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/unitModel.dart'; // Adjust path accordingly

class UnitService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all available units for the dropdown menu
  Future<List<UnitModel>> fetchUnits() async {
    try {
      final response = await _supabase
          .from('unit')
          .select()
          .order('unit_name', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => UnitModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching units: $e');
      rethrow;
    }
  }
}