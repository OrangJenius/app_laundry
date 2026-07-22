import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/orderModel.dart';

class OrderService {
  final _supabase = Supabase.instance.client;
  
  Future<List<OrderModel>> fetchOrder(String store_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('order') // Your table name
          .select()
          .eq('store_id', store_id);
          
      return data.map((json) => OrderModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching Order: $e');
      rethrow; 
    }
  }
  Future<OrderModel?> fetchOrderWithId(String id) async {
    try {
      final data = await _supabase
          .from('order')
          .select()
          .eq('id', id)
          .maybeSingle(); // <--- KUNCINYA DI SINI

      if (data == null) return null;

      // Langsung ubah satu Map tunggal menjadi satu objek OrderModel
      return OrderModel.fromMap(data); 
    } catch (e) {
      print('Error fetching Order: $e');
      rethrow;
    }
  }
  Future<OrderModel> addOrder(OrderModel order) async {
    try {
      final response = await _supabase
          .from('order')
          .insert(order.toMap())
          .select()   // 👈 Tells Supabase to return the created row data
          .single();  // 👈 Converts the returned array into a single map

      // 2. Map the database response (which now includes the auto-generated ID)
      return OrderModel.fromMap(response); 
    } catch (e) {
      print('Error adding Order: $e');
      rethrow;
    }
  }
  Future<void> editOrder(String id, OrderModel Order) async {
    try {
      await _supabase
          .from('order')
          .update(Order.toMap())
          .eq('id', id);
    } catch (e) {
      print('Error updating Order: $e');
      rethrow;
    }
  }
    Future<void> deleteOrder(String id, OrderModel Order) async {
    try {
      await _supabase
          .from('order')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error updating Order: $e');
      rethrow;
    }
  }
}