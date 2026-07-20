import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/serviceModel.dart';

class ServiceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all services for a specific store, including joined Durasi and Unit data
  Future<List<ServiceModel>> fetchServices(String storeId) async {
    try {
      final response = await _supabase
          .from('service')
          .select('''
            *,
            duration(*),
            unit(*)
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

  Future<List<ServiceModel>> fetchServicesById(String id) async {
    try {
      final response = await _supabase
          .from('service')
          .select('''
            *,
            duration(*),
            unit(*)
          ''')
          .eq('id', id);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => ServiceModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching services: $e');
      rethrow;
    }
  }

  /// Fetch services filtered specifically by a duration selection
  Future<List<ServiceModel>> fetchServicesByDuration(String storeId, String durationId) async {
    try {
      final response = await _supabase
          .from('service')
          .select('''
            *,
            duration(*),
            unit(*)
          ''')
          .eq('store_id', storeId)
          .eq('duration_id', durationId)
          .order('service_name', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => ServiceModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching services: $e');
      rethrow;
    }
  }

  /// Add a new service
  Future<void> addService({required ServiceModel service}) async {
    try {
      await _supabase.from('service').insert(service.toMap());
    } catch (e) {
      print('Error adding service: $e');
      rethrow;
    }
  }

  /// Update service details
  Future<void> updateService(ServiceModel newService, String id) async {
    try {
      await _supabase
          .from('service')
          .update(
            newService.toMap()
          )
          .eq('id', id);
    } catch (e) {
      print('Error updating service: $e');
      rethrow;
    }
  }

  /// Delete a service
  Future<void> deleteService(String id) async {
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