// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class OrderModel {
  final String? id;
  final String store_id;
  final String? receipt;
  final String duration_id;
  final String customer_id;
  final String total_harga;
  final String? catatan;
  final String? parfum_id;
  final String? antar_jemput_id;
  final String profile_id;
  final String? discount_id;
  final String? created_at;

  OrderModel({
    this.id,
    required this.store_id,
    this.receipt,
    required this.duration_id,
    required this.customer_id,
    required this.total_harga,
    this.catatan,
    required this.parfum_id,
    required this.antar_jemput_id,
    required this.profile_id,
    required this.discount_id,
    this.created_at,
  });

  OrderModel copyWith({
    String? id,
    String? store_id,
    String? receipt,
    String? duration_id,
    String? customer_id,
    String? total_harga,
    String? catatan,
    String? parfum_id,
    String? antar_jemput_id,
    String? profile_id,
    String? discount_id,
    String? created_at,
  }) {
    return OrderModel(
      id: id ?? this.id,
      store_id: store_id ?? this.store_id,
      receipt: receipt ?? this.receipt,
      duration_id: duration_id ?? this.duration_id,
      customer_id: customer_id ?? this.customer_id,
      total_harga: total_harga ?? this.total_harga,
      catatan: catatan ?? this.catatan,
      parfum_id: parfum_id ?? this.parfum_id,
      antar_jemput_id: antar_jemput_id ?? this.antar_jemput_id,
      profile_id: profile_id ?? this.profile_id,
      discount_id: discount_id ?? this.discount_id,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'store_id': store_id,
      'duration_id': duration_id,
      'customer_id': customer_id,
      'total_harga': total_harga,
      'catatan': catatan,
      'parfum_id': parfum_id,
      'antar_jemput_id': antar_jemput_id,
      'profile_id': profile_id,
      'discount_id': discount_id,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] != null ? map['id']?.toString() as String : null,
      store_id: map['store_id'] as String,
      receipt: map['receipt'] as String,
      duration_id: map['duration_id']?.toString() as String,
      customer_id: map['customer_id']?.toString() as String,
      total_harga: map['total_harga']?.toString() as String,
      catatan: map['catatan'] != null ? map['catatan'] as String : null,
      parfum_id: map['parfum_id']?.toString() as String,
      antar_jemput_id: map['antar_jemput_id']?.toString() as String,
      profile_id: map['profile_id'] as String,
      discount_id: map['discount_id']!= null ? map['discount_id']?.toString() as String : null,
      created_at: map['created_at'] != null ? map['created_at']?.toString() as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderModel.fromJson(String source) => OrderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Ordermodel(id: $id, store_id: $store_id, receipt: $receipt, duration_id: $duration_id, customer_id: $customer_id, total_harga: $total_harga, catatan: $catatan, parfum_id: $parfum_id, antar_jemput_id: $antar_jemput_id, profile_id: $profile_id, discount_id: $discount_id, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant OrderModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.store_id == store_id &&
      other.receipt == receipt &&
      other.duration_id == duration_id &&
      other.customer_id == customer_id &&
      other.total_harga == total_harga &&
      other.catatan == catatan &&
      other.parfum_id == parfum_id &&
      other.antar_jemput_id == antar_jemput_id &&
      other.profile_id == profile_id &&
      other.discount_id == discount_id &&
      other.created_at == created_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      store_id.hashCode ^
      receipt.hashCode ^
      duration_id.hashCode ^
      customer_id.hashCode ^
      total_harga.hashCode ^
      catatan.hashCode ^
      parfum_id.hashCode ^
      antar_jemput_id.hashCode ^
      profile_id.hashCode ^
      discount_id.hashCode ^
      created_at.hashCode;
  }
}
