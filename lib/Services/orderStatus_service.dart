import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/orderStatusModel.dart';
import 'package:intl/intl.dart';

class OrderStatusService {
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
      final localDt = _convertToLocal(data['created_at']);
      data['created_at'] = localDt.toString();
    }
    return data;
  }

  Future<List<OrderStatusModel>> fetchOrderStatus(String order_id) async {
    try {
      final List<dynamic> data = await _supabase
          .from('order_status')
          .select()
          .eq('order_id', order_id);

      return data.map((json) {
        var model = OrderStatusModel.fromMap(json);
        // Convert created_at to local timezone
        if (model.created_at != null) {
          model.created_at = _convertToLocal(model.created_at).toString();
        }
        return model;
      }).toList();
    } catch (e) {
      print('Error fetching Order Status: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchOrderStatus2(String order_id) async {
    try {
      final response = await _supabase
          .from('order_status')
          .select()
          .eq('order_id', order_id)
          .order('created_at', ascending: false)
          .limit(1);

      // Convert created_at to local timezone
      return (response as List)
          .map((item) => _convertMapToLocal(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching Order Status: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchOrderStatusByOrderIds(List<String> orderIds) async {
    if (orderIds.isEmpty) return [];

    final response = await _supabase
        .from('order_status')
        .select('*')
        .inFilter('order_id', orderIds)
        .order('created_at', ascending: true);

    // Convert created_at to local timezone
    return (response as List)
        .map((item) => _convertMapToLocal(item as Map<String, dynamic>))
        .toList();
  }

  Future<OrderStatusModel?> fetchOrderStatusWithId(String id) async {
    try {
      final data = await _supabase
          .from('order_status')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;

      var model = OrderStatusModel.fromMap(data);
      // Convert created_at to local timezone
      if (model.created_at != null) {
        model.created_at = _convertToLocal(model.created_at).toString();
      }
      return model;
    } catch (e) {
      print('Error fetching Order Status: $e');
      rethrow;
    }
  }

  Future<void> addOrderStatus(OrderStatusModel orderStatus) async {
    try {
      await _supabase
          .from('order_status')
          .insert(orderStatus.toMap());
    } catch (e) {
      print('Error adding Order Status: $e');
      rethrow;
    }
  }

  Future<void> editOrderStatus(String id, OrderStatusModel orderStatus) async {
    try {
      await _supabase
          .from('order_status')
          .update(orderStatus.toMap())
          .eq('id', id);
    } catch (e) {
      print('Error updating Order Status: $e');
      rethrow;
    }
  }

  Future<void> deleteOrderStatus(String id) async {
    try {
      await _supabase
          .from('order_status')
          .delete()
          .eq('order_id', id);
    } catch (e) {
      print('Error deleting Order Status: $e');
      rethrow;
    }
  }
}