import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/addCustomerModel.dart';

class CustomerService {
  final _supabase = Supabase.instance.client;

  // FETCH CUSTOMERS
  Future<List<Customer>> fetchCustomers() async {
    try {
      final List<dynamic> data = await _supabase
          .from('customer') // Your table name
          .select();
          
      return data.map((json) => Customer.fromJson(json)).toList();
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
          .insert(customer.toJson());
    } catch (e) {
      print('Error adding customer: $e');
      rethrow;
    }
  }

// Delete Customer
  Future<void> deleteCustomer(String id) async { // You only need the id to delete
    try {
      await _supabase
          .from('customer')
          .delete()
          .eq('id', id); // <--- Tell Supabase WHICH row to delete
    } catch (e) {
      print('Error deleting customer: $e');
      rethrow;
    }
  }
  
  // Edit Customer
  Future<void> editCustomer(String id, Customer customer) async {
    try {
      await _supabase
          .from('customer')
          .update(customer.toJson()) // <--- Pass the updated data map here
          .eq('id', id);             // <--- Target the specific customer ID
    } catch (e) {
      print('Error updating customer: $e'); // Fixed the print message too!
      rethrow;
    }
  }
}