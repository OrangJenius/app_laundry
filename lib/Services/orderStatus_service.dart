import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/orderStatusModel.dart';

class OrderStatusService {
  final _supabase = Supabase.instance.client;
  
  Future<List<OrderStatusModel>> fetchOrderStatus(String order_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('order_status') // Your table name
          .select()
          .eq('order_id', order_id);
          
      return data.map((json) => OrderStatusModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching Order: $e');
      rethrow; 
    }
  }
  Future<List<dynamic>> fetchOrderStatusByOrderIds(List<String> orderIds) async {
    if (orderIds.isEmpty) return [];
    
    // Note: Using 'order_di' as your database column name
    return await _supabase
        .from('order_status')
        .select('*')
        .inFilter('order_id', orderIds) 
        .order('created_at', ascending: true);
  }
  Future<OrderStatusModel?> fetchOrderStatusWithId(String id) async {
    try {
      final data = await _supabase
          .from('order_status')
          .select()
          .eq('id', id)
          .maybeSingle(); // <--- KUNCINYA DI SINI

      if (data == null) return null;

      // Langsung ubah satu Map tunggal menjadi satu objek OrderModel
      return OrderStatusModel.fromMap(data); 
    } catch (e) {
      print('Error fetching Order: $e');
      rethrow;
    }
  }
  Future<void> addOrderStatus(OrderStatusModel Order) async {
    try {
      await _supabase
          .from('order_status')
          .insert(Order.toMap());
    } catch (e) {
      print('Error adding Order: $e');
      rethrow;
    }
  }
  Future<void> editOrderStatus(String id, OrderStatusModel Order) async {
    try {
      await _supabase
          .from('order_status')
          .update(Order.toMap())
          .eq('id', id);
    } catch (e) {
      print('Error updating Order: $e');
      rethrow;
    }
  }
    Future<void> deleteOrderStatus(String id, OrderStatusModel Order) async {
    try {
      await _supabase
          .from('order_status')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error updating Order: $e');
      rethrow;
    }
  }
}