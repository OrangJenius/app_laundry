// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:app_laundry/Models/durasiModel.dart';
import 'package:app_laundry/Models/unitModel.dart';

class ServiceModel {
  final String? id;
  final String service_name;
  final String price; 
  final String duration_id; 
  final String unit_id; 
  final String store_id;

  // Added nested models
  final DurasiModel? duration;
  final UnitModel? unit;

  ServiceModel({
    this.id,
    required this.service_name,
    required this.price,
    required this.duration_id,
    required this.unit_id,
    required this.store_id,
    this.duration,
    this.unit,
  });

  ServiceModel copyWith({
    String? id,
    String? service_name,
    String? price,
    String? duration_id,
    String? unit_id,
    String? store_id,
    DurasiModel? duration,
    UnitModel? unit,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      service_name: service_name ?? this.service_name,
      price: price ?? this.price,
      duration_id: duration_id ?? this.duration_id,
      unit_id: unit_id ?? this.unit_id,
      store_id: store_id ?? this.store_id,
      duration: duration ?? this.duration,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'service_name': service_name,
      'price': price,
      'duration_id': duration_id,
      'unit_id': unit_id,
      'store_id' : store_id,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id']?.toString() as String?,
      service_name: map['service_name'] as String,
      price: map['price'].toString() as String,
      duration_id: map['duration_id']?.toString() as String,
      unit_id: map['unit_id']?.toString() as String,
      store_id: map['store_id'] as String,
      // Safely parse nested foreign relations if they are included in select query
      duration: map['duration'] != null 
          ? DurasiModel.fromMap(map['duration'] as Map<String, dynamic>) 
          : null,
      unit: map['unit'] != null 
          ? UnitModel.fromMap(map['unit'] as Map<String, dynamic>) 
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceModel.fromJson(String source) => ServiceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ServiceModel(id: $id, service_name: $service_name, price: $price, duration_id: $duration_id, unit_id: $unit_id, store_id: $store_id, duration: $duration, unit: $unit)';
  }

  @override
  bool operator ==(covariant ServiceModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.service_name == service_name &&
      other.price == price &&
      other.duration_id == duration_id &&
      other.unit_id == unit_id &&
      other.store_id == store_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      service_name.hashCode ^
      price.hashCode ^
      duration_id.hashCode ^
      unit_id.hashCode ^
      store_id.hashCode;
  }
}