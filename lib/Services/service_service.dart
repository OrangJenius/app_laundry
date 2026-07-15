import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/serviceModel.dart'; // Adjust path accordingly

class ServiceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all services for a specific store, including nested Duration and Unit data
  Future<List<ServiceModel>> fetchServices(String storeId) async {
    try {
      final response = await _supabase
          .from('service')
          .select('''
            id,
            service_name,
            price,
            duration (
              id,
              duration_name,
              hours
            ),
            unit (
              id,
              unit_name
            )
          ''')
          .eq('store_id', storeId)
          .order('service_name', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => ServiceModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching services: $e');
      rethrow;
    }
  }

  /// Add a new service tied to a specific duration and unit
  Future<ServiceModel> addService({
    required ServiceModel service// From your selected unit dropdown
  }) async {
    try {
      final response = await _supabase
          .from('service')
          .insert({
            service.toMap()
          });

      return ServiceModel.fromMap(response);
    } catch (e) {
      print('Error adding service: $e');
      rethrow;
    }
  }

  /// Update service details
  Future<void> updateService({
    required int id,
    required String serviceName,
    required int price,
    required int durationId,
    required int unitId,
  }) async {
    try {
      await _supabase
          .from('service')
          .update({
            'service_name': serviceName,
            'price': price,
            'duration_id': durationId,
            'unit_id': unitId,
          })
          .eq('id', id);
    } catch (e) {
      print('Error updating service: $e');
      rethrow;
    }
  }

  /// Delete a service
  Future<void> deleteService(int id) async {
    try {
      await _supabase
          .from('service')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting service: $e');
      rethrow;
    }
  }
}