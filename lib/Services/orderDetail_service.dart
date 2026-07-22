import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/orderDetailModel.dart';

class OrderDetailService {
  final _supabase = Supabase.instance.client;
  
  Future<List<OrderDetailModel>> fetchOrderDetail(String store_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('order_detail') // Your table name
          .select()
          .eq('store_id', store_id);
          
      return data.map((json) => OrderDetailModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching Order: $e');
      rethrow; 
    }
  }
  Future<OrderDetailModel?> fetchOrderDetailWithId(String id) async {
    try {
      final data = await _supabase
          .from('order_detail')
          .select()
          .eq('id', id)
          .maybeSingle(); // <--- KUNCINYA DI SINI

      if (data == null) return null;

      // Langsung ubah satu Map tunggal menjadi satu objek OrderModel
      return OrderDetailModel.fromMap(data); 
    } catch (e) {
      print('Error fetching Order: $e');
      rethrow;
    }
  }
  Future<void> addOrderDetail(OrderDetailModel Order) async {
    try {
      await _supabase
          .from('order_detail')
          .insert(Order.toMap());
    } catch (e) {
      print('Error adding Order: $e');
      rethrow;
    }
  }
  Future<void> editOrderDetail(String id, OrderDetailModel Order) async {
    try {
      await _supabase
          .from('order_detail')
          .update(Order.toMap())
          .eq('id', id);
    } catch (e) {
      print('Error updating Order: $e');
      rethrow;
    }
  }
    Future<void> deleteOrderDetail(String id, OrderDetailModel Order) async {
    try {
      await _supabase
          .from('order_detail')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error updating Order: $e');
      rethrow;
    }
  }
}