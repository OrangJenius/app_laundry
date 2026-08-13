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
        .select('''
          *,
          customer(nama),
          duration(duration_name),
          store(store_name, address, phone_number)
        ''')
        .eq('store_id', storeId)
        .order('created_at', ascending: false);

    return response;
  }
  Future<List<dynamic>> fetchOrderById(String order_id) async {
    final response = await _supabase
        .from('order')
        .select('*, customer(*), duration(duration_name), store(store_name), profiles(*), parfum(nama_parfum), antar_jemput(jarak)')
        .eq('id', order_id);
        
    return response;
  }
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

  Future<List<Map<String, dynamic>>> fetchOrdersByStoreAndDate(
    String storeId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final startIso = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0).toIso8601String();
      final endIso = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59).toIso8601String();

      final response = await _supabase
          .from('order')
          .select('''
          *,
          customer!customer_id(*),
          antar_jemput!antar_jemput_id(*),
          profiles!profile_id(*)
          ''')
          .eq('store_id', storeId)
          .gte('created_at', startIso)
          .lte('created_at', endIso);
      print("Responseeeeee: $response");

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching orders by date range: $e');
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
    Future<void> deleteOrder(String id) async {
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