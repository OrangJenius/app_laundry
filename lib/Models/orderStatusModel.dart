// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class OrderStatusModel {
  final String? id;
  final String order_id;
  String? created_at;
  final String status_order;
  final String profile_id;

  OrderStatusModel({
    this.id,
    required this.order_id,
    this.created_at,
    required this.status_order,
    required this.profile_id,
  });

  OrderStatusModel copyWith({
    String? id,
    String? order_id,
    String? created_at,
    String? status_order,
    String? profile_id,
  }) {
    return OrderStatusModel(
      id: id ?? this.id,
      order_id: order_id ?? this.order_id,
      created_at: created_at ?? this.created_at,
      status_order: status_order ?? this.status_order,
      profile_id: profile_id ?? this.profile_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'order_id': order_id,
      'status_order': status_order,
      'profile_id': profile_id,
    };
  }

  factory OrderStatusModel.fromMap(Map<String, dynamic> map) {
    return OrderStatusModel(
      id: map['id'] != null ? map['id']?.toString() as String : null,
      order_id: map['order_id']?.toString() as String,
      created_at: map['created_at'] != null ? map['created_at']?.toString() as String : null,
      status_order: map['status_order'] as String,
      profile_id: map['profile_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderStatusModel.fromJson(String source) => OrderStatusModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderStatusModel(id: $id, order_id: $order_id, created_at: $created_at, status_order: $status_order, profile_id: $profile_id)';
  }

  @override
  bool operator ==(covariant OrderStatusModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.order_id == order_id &&
      other.created_at == created_at &&
      other.status_order == status_order &&
      other.profile_id == profile_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      order_id.hashCode ^
      created_at.hashCode ^
      status_order.hashCode ^
      profile_id.hashCode;
  }
}
