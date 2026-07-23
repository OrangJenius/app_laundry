import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/orderModel.dart';

class OrderService {
  final _supabase = Supabase.instance.client;
  
  // Future<List<OrderModel>> fetchOrder(String store_id) async {
  //   try {
  //     final List<dynamic> data = await _supabase
  //         .from('order') // Your table name
  //         .select()
  //         .eq('store_id', store_id);
          
  //     return data.map((json) => OrderModel.fromMap(json)).toList();
  //   } catch (e) {
  //     print('Error fetching Order: $e');
  //     rethrow; 
  //   }
  // }

  // Example query inside OrderService:
  Future<List<dynamic>> fetchOrder(String storeId) async {
    final response = await _supabase
        .from('order')
        .select('*, customer(nama), duration(duration_name)')
        .eq('store_id', storeId)
        .order('created_at', ascending: false);
        
    return response;
  }
  // Future<List<dynamic>> fetchOrderNow(String storeId, DateTime time) async {
  //   // 1. Format the target date to 'YYYY-MM-DD'
  //   // Ensure you use UTC or Local time depending on how your DB stores data
  //   final String dateString = "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}";

  //   final response = await _supabase
  //       .from('order')
  //       .select('*, customer(nama), duration(duration_name)')
  //       .eq('store_id', storeId)
  //       // 2. Cast created_at to a date string comparison
  //       .eq('created_at::date', dateString); 
        
  //   return response;
  // }

  // order_service.dart
  Future<List<dynamic>> fetchOrderNow(String storeId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    final response = await _supabase
        .from('order')
        .select('*')
        .eq('store_id', storeId)
        .gte('created_at', startOfDay)
        .lte('created_at', endOfDay);

    return response;
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