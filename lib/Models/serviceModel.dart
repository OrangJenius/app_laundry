// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:app_laundry/Models/durasiModel.dart';
import 'package:app_laundry/Models/unitModel.dart';

class ServiceModel {
  final String? id;
  final String serviceName;
  final String price; // Using int since laundry prices are usually whole numbers in IDR
  final String duration_id; // Nested from your duration table
  final String unit_id;         // Nested from your unit table

  ServiceModel({
    this.id,
    required this.serviceName,
    required this.price,
    required this.duration_id,
    required this.unit_id,
  });

  ServiceModel copyWith({
    String? id,
    String? serviceName,
    String? price,
    String? duration_id,
    String? unit_id,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      duration_id: duration_id ?? this.duration_id,
      unit_id: unit_id ?? this.unit_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'serviceName': serviceName,
      'price': price,
      'duration_id': duration_id,
      'unit_id': unit_id,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] as String,
      serviceName: map['serviceName'] as String,
      price: map['price'] as String,
      duration_id: map['duration_id'] as String,
      unit_id: map['unit_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceModel.fromJson(String source) => ServiceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ServiceModel(id: $id, serviceName: $serviceName, price: $price, duration_id: $duration_id, unit_id: $unit_id)';
  }

  @override
  bool operator ==(covariant ServiceModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.serviceName == serviceName &&
      other.price == price &&
      other.duration_id == duration_id &&
      other.unit_id == unit_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      serviceName.hashCode ^
      price.hashCode ^
      duration_id.hashCode ^
      unit_id.hashCode;
  }
}
