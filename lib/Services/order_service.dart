import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/orderModel.dart';
import 'package:intl/intl.dart';

class OrderService {
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

  /// Convert created_at in a dynamic map to local timezone
  Map<String, dynamic> _convertMapToLocal(Map<String, dynamic> data) {
    if (data.containsKey('created_at') && data['created_at'] != null) {
      final localDt = _convertToLocal(data['created_at'].toString());
      data['created_at'] = localDt.toString();
    }
    return data;
  }

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

    // Convert created_at to local timezone
    return (response as List)
        .map((item) => _convertMapToLocal(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<dynamic>> fetchOrderById(String order_id) async {
    final response = await _supabase
        .from('order')
        .select('*, customer(*), duration(duration_name), store(*), profiles(*), parfum(*), antar_jemput(*), diskon(*)')
        .eq('id', order_id);

    // Convert created_at to local timezone
    return (response as List)
        .map((item) => _convertMapToLocal(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<dynamic>> fetchOrderNow(String storeId, DateTime date) async {
    final dateUTC = date.toUtc();
    final startOfDay = DateTime(dateUTC.year, dateUTC.month, dateUTC.day).toIso8601String();
    final endOfDay = DateTime(dateUTC.year, dateUTC.month, dateUTC.day, 23, 59, 59).toIso8601String();

    final response = await _supabase
        .from('order')
        .select('*')
        .eq('store_id', storeId)
        .gte('created_at', startOfDay)
        .lte('created_at', endOfDay);

    // Convert created_at to local timezone
    return (response as List)
        .map((item) => _convertMapToLocal(item as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel?> fetchOrderWithId(String id) async {
    try {
      final data = await _supabase
          .from('order')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;

      var order = OrderModel.fromMap(data);
      // Convert created_at to local timezone
      if (order.created_at != null) {
        order.created_at = _convertToLocal(order.created_at).toString();
      }
      return order;
    } catch (e) {
      print('Error fetching Order: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrdersByStoreAndDate(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startDateUTC = startDate.toUtc();
      final endDateUTC = endDate.toUtc();
      
      final startIso = DateTime(startDateUTC.year, startDateUTC.month, startDateUTC.day, 0, 0, 0).toIso8601String();
      final endIso = DateTime(endDateUTC.year, endDateUTC.month, endDateUTC.day, 23, 59, 59).toIso8601String();

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

      // Convert created_at to local timezone
      return (response as List)
          .map((item) => _convertMapToLocal(item as Map<String, dynamic>))
          .map((item) => item as Map<String, dynamic>)
          .toList();
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
          .select()
          .single();

      var result = OrderModel.fromMap(response);
      // Convert created_at to local timezone
      if (result.created_at != null) {
        result.created_at = _convertToLocal(result.created_at).toString();
      }
      return result;
    } catch (e) {
      print('Error adding Order: $e');
      rethrow;
    }
  }

  Future<void> editOrder(String id, OrderModel order) async {
    try {
      await _supabase
          .from('order')
          .update(order.toMap())
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
      print('Error deleting Order: $e');
      rethrow;
    }
  }
}