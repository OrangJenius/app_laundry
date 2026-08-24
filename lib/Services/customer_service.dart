import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/customerModel.dart';
import 'package:intl/intl.dart';

class CustomerService {
  final _supabase = Supabase.instance.client;

  /// Helper: Convert UTC datetime to local timezone
  DateTime _convertToLocal(dynamic dateTimeValue) {
    if (dateTimeValue is String) {
      return DateTime.parse(dateTimeValue).toLocal();
    } else if (dateTimeValue is DateTime) {
      return dateTimeValue.toLocal();
    }
    return DateTime.now();
  }

  /// Helper: Format datetime for display
  String formatDateTime(dynamic dateTimeValue) {
    final localDateTime = _convertToLocal(dateTimeValue);
    return DateFormat('dd MMM yyyy, HH:mm').format(localDateTime);
  }

  /// Convert created_at/updated_at in a dynamic map to local timezone
  Map<String, dynamic> _convertMapToLocal(Map<String, dynamic> data) {
    if (data.containsKey('created_at') && data['created_at'] != null) {
      final localDt = _convertToLocal(data['created_at']);
      data['created_at'] = localDt.toString();
    }
    if (data.containsKey('updated_at') && data['updated_at'] != null) {
      final localDt = _convertToLocal(data['updated_at']);
      data['updated_at'] = localDt.toString();
    }
    return data;
  }

  // FETCH CUSTOMERS
  Future<List<Customer>> fetchCustomers(String? store_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('customer')
          .select()
          .eq('store_id', store_id!);

      return data.map((json) {
        var model = Customer.fromMap(json);
        // Convert created_at/updated_at to local timezone
        if (model.created_at != null) {
          model.created_at = _convertToLocal(model.created_at).toString();
        }
        return model;
      }).toList();
    } catch (e) {
      print('Error fetching customers: $e');
      rethrow;
    }
  }

  // ADD CUSTOMER
  Future<void> addCustomer(Customer customer) async {
    try {
      await _supabase
          .from('customer')
          .insert(customer.toMap());
    } catch (e) {
      print('Error adding customer: $e');
      rethrow;
    }
  }

  // DELETE CUSTOMER
  Future<void> deleteCustomer(String id) async {
    try {
      await _supabase
          .from('customer')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting customer: $e');
      rethrow;
    }
  }

  // EDIT CUSTOMER
  Future<void> editCustomer(String id, Customer customer) async {
    try {
      await _supabase
          .from('customer')
          .update(customer.toMap())
          .eq('id', id);
    } catch (e) {
      print('Error updating customer: $e');
      rethrow;
    }
  }
}