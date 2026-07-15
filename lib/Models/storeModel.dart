// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class StoreModel {
  final String? id;
  final String? owner_id;
  final String? store_name;
  final String? address;
  final String? phone_number;

  StoreModel({
    this.id,
    required this.owner_id,
    required this.store_name,
    required this.address,
    required this.phone_number,
  });

  StoreModel copyWith({
    String? id,
    String? owner_id,
    String? store_name,
    String? address,
    String? phone_number,
  }) {
    return StoreModel(
      id: id ?? this.id,
      owner_id: owner_id ?? this.owner_id,
      store_name: store_name ?? this.store_name,
      address: address ?? this.address,
      phone_number: phone_number ?? this.phone_number,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) 'id': id, // Safe check: prevents overwriting database auto-generated UUIDs
      'owner_id': owner_id,
      'store_name': store_name,
      'address': address,
      'phone_number': phone_number,
    };
  }

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      id: map['id'] as String?,
      owner_id: map['owner_id'] as String?,
      store_name: map['store_name'] as String?,
      address: map['address'] as String?,
      phone_number: map['phone_number'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory StoreModel.fromJson(String source) => 
      StoreModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'StoreModel(id: $id, owner_id: $owner_id, store_name: $store_name, address: $address, phone_number: $phone_number)';
  }

  @override
  bool operator ==(covariant StoreModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.owner_id == owner_id &&
      other.store_name == store_name &&
      other.address == address &&
      other.phone_number == phone_number;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      owner_id.hashCode ^
      store_name.hashCode ^
      address.hashCode ^
      phone_number.hashCode;
  }
}