// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class OrderDetailModel {
  final String? id;
  final String order_id;
  final String service_id;
  final String qty;
  final String subtotal;
  final String? price;

  OrderDetailModel({
    this.id,
    required this.order_id,
    required this.service_id,
    required this.qty,
    required this.subtotal,
    this.price,
  });

  OrderDetailModel copyWith({
    String? id,
    String? order_id,
    String? service_id,
    String? qty,
    String? subtotal,
    String? price,
  }) {
    return OrderDetailModel(
      id: id ?? this.id,
      order_id: order_id ?? this.order_id,
      service_id: service_id ?? this.service_id,
      qty: qty ?? this.qty,
      subtotal: subtotal ?? this.subtotal,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'order_id': order_id,
      'service_id': service_id,
      'quantity': qty, // 👈 CHANGED: Send 'quantity' to match your database column
      'subtotal': subtotal,
    };

    if (id != null) map['id'] = id;
    if (price != null) map['price'] = price;

    return map;
  }

  factory OrderDetailModel.fromMap(Map<String, dynamic> map) {
    return OrderDetailModel(
      id: map['id']?.toString(),
      order_id: map['order_id']?.toString() ?? '',
      service_id: map['service_id']?.toString() ?? '',
      // 👈 Handles 'quantity' from database or 'qty' if present
      qty: (map['quantity'] ?? map['qty'])?.toString() ?? '0',
      subtotal: map['subtotal']?.toString() ?? '0',
      price: map['price']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderDetailModel.fromJson(String source) => 
      OrderDetailModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderDetailModel(id: $id, order_id: $order_id, service_id: $service_id, qty: $qty, subtotal: $subtotal, price: $price)';
  }

  @override
  bool operator ==(covariant OrderDetailModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.order_id == order_id &&
      other.service_id == service_id &&
      other.qty == qty &&
      other.subtotal == subtotal &&
      other.price == price;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      order_id.hashCode ^
      service_id.hashCode ^
      qty.hashCode ^
      subtotal.hashCode ^
      price.hashCode;
  }
}