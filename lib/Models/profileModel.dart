// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ProfileModel {
  final String? id;
  final String? owner_id;
  final String? store_id;
  final String? role;
  final String? cashier_id;


  ProfileModel(
    this.id,
    this.owner_id,
    this.store_id,
    this.role,
    this.cashier_id,
  );

  ProfileModel copyWith({
    String? id,
    String? owner_id,
    String? store_id,
    String? role,
    String? cashier_id,
  }) {
    return ProfileModel(
      id ?? this.id,
      owner_id ?? this.owner_id,
      store_id ?? this.store_id,
      role ?? this.role,
      cashier_id ?? this.cashier_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'owner_id': owner_id,
      'store_id': store_id,
      'role': role,
      'cashier_id': cashier_id,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      map['id'] != null ? map['id'] as String : null,
      map['owner_id'] != null ? map['owner_id'] as String : null,
      map['store_id'] != null ? map['store_id'] as String : null,
      map['role'] != null ? map['role'] as String : null,
      map['cashier_id'] != null ? map['cashier_id'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileModel.fromJson(String source) => ProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProfileModel(id: $id, owner_id: $owner_id, store_id: $store_id, role: $role, cashier_id: $cashier_id)';
  }

  @override
  bool operator ==(covariant ProfileModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.owner_id == owner_id &&
      other.store_id == store_id &&
      other.role == role &&
      other.cashier_id == cashier_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      owner_id.hashCode ^
      store_id.hashCode ^
      role.hashCode ^
      cashier_id.hashCode;
  }
}
