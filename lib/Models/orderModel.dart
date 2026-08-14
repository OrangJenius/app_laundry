// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:app_laundry/Models/antarJemputModel.dart';
import 'package:app_laundry/Models/customerModel.dart';
import 'package:app_laundry/Models/diskonModel.dart';
import 'package:app_laundry/Models/profileModel.dart';

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

  final Customer? customer;
  final AntarJemputModel? antar_jemput;
  final ProfileModel? profiles;
  final DiskonModel? diskon;

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
    this.customer,
    this.antar_jemput,
    this.profiles,
    this.diskon
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
    Customer? customer,
    AntarJemputModel? antar_jemput,
    ProfileModel? profiles,
    DiskonModel? diskon,
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
      customer: customer ?? this.customer,
      antar_jemput: antar_jemput ?? this.antar_jemput,
      profiles: profiles ?? this.profiles,
      diskon: diskon ?? this.diskon,
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
      receipt: map['receipt'] != null ? map['receipt'] as String : null,
      duration_id: map['duration_id']?.toString() as String,
      customer_id: map['customer_id']?.toString() as String,
      total_harga: map['total_harga']?.toString() as String,
      catatan: map['catatan'] != null ? map['catatan'] as String : null,
      parfum_id: map['parfum_id'] != null ? map['parfum_id']?.toString() as String : null,
      antar_jemput_id: map['antar_jemput_id'] != null ? map['antar_jemput_id']?.toString() as String : null,
      profile_id: map['profile_id']?.toString() as String,
      discount_id: map['discount_id'] != null ? map['discount_id']?.toString() as String : null,
      created_at: map['created_at'] != null ? map['created_at']?.toString() as String : null,
      customer: map['customer'] != null ? Customer.fromMap(map['customer'] as Map<String,dynamic>) : null,
      antar_jemput: map['antar_jemput'] != null ? AntarJemputModel.fromMap(map['antar_jemput'] as Map<String,dynamic>) : null,
      profiles: map['profiles'] != null ? ProfileModel.fromMap(map['profiles'] as Map<String,dynamic>) : null,
      diskon: map['diskon'] != null ? DiskonModel.fromMap(map['diskon'] as Map<String,dynamic>) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderModel.fromJson(String source) => OrderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderModel(id: $id, store_id: $store_id, receipt: $receipt, duration_id: $duration_id, customer_id: $customer_id, total_harga: $total_harga, catatan: $catatan, parfum_id: $parfum_id, antar_jemput_id: $antar_jemput_id, profile_id: $profile_id, discount_id: $discount_id, created_at: $created_at, customer: $customer, antar_jemput: $antar_jemput, profiles: $profiles, diskon: $diskon)';
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
      other.created_at == created_at &&
      other.customer == customer &&
      other.antar_jemput == antar_jemput &&
      other.profiles == profiles &&
      other.diskon == diskon;
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
      created_at.hashCode ^
      customer.hashCode ^
      antar_jemput.hashCode ^
      profiles.hashCode ^
      diskon.hashCode;
  }
}
