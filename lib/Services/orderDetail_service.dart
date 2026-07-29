import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/orderDetailModel.dart';

class OrderDetailService {
  final _supabase = Supabase.instance.client;
  
  Future<List<OrderDetailModel>> fetchOrderDetail(String order_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('order_detail') // Your table name
          .select('*, service(*, duration(*), unit(*))')
          .eq('order_id', order_id);
          
      return data.map((json) => OrderDetailModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching Order: $e');
      rethrow; 
    }
  }
  Future<List<dynamic>> fetchOrderDetail2(String order_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('order_detail') // Your table name
          .select('*, service(*, duration(*), unit(*))')
          .eq('order_id', order_id);
          
      return data;
    } catch (e) {
      print('Error fetching Order: $e');
      rethrow; 
    }
  }
  Future<List<dynamic>> fetchOrderDetailByOrderIds(List<dynamic> orderIds) async {
    if (orderIds.isEmpty) return [];

    return await _supabase
        .from('order_detail')
        .select('''
          *,
          service:service_id (
            id,
            service_name,
            unit:unit_id (
              id,
              unit_name
            )
          )
        ''')
        .inFilter('order_id', orderIds);
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
    Future<void> deleteOrderDetail(String id) async {
    try {
      await _supabase
          .from('order_detail')
          .delete()
          .eq('order_id', id);
    } catch (e) {
      print('Error updating Order: $e');
      rethrow;
    }
  }
}