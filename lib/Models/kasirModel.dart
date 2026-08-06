import 'dart:convert';

class KasirModel {
  final String? id;
  final String cashier_name;
  final String? created_at;
  final String store_id;

  KasirModel({
    this.id,
    required this.cashier_name,
    this.created_at,
    required this.store_id,
  });
  

  KasirModel copyWith({
    String? id,
    String? cashier_name,
    String? created_at,
    String? store_id,
  }) {
    return KasirModel(
      id: id ?? this.id,
      cashier_name: cashier_name ?? this.cashier_name,
      created_at: created_at ?? this.created_at,
      store_id: store_id ?? this.store_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cashier_name': cashier_name,
      'store_id': store_id,
    };
  }

  factory KasirModel.fromMap(Map<String, dynamic> map) {
    return KasirModel(
      id: map['id'] != null ? map['id']?.toString() as String : null,
      cashier_name: map['cashier_name'] as String,
      created_at: map['created_at'] != null ? map['created_at']?.toString() as String : null,
      store_id: map['store_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory KasirModel.fromJson(String source) => KasirModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'KasirModel(id: $id, cashier_name: $cashier_name, created_at: $created_at, store_id: $store_id)';
  }

  @override
  bool operator ==(covariant KasirModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.cashier_name == cashier_name &&
      other.created_at == created_at &&
      other.store_id == store_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      cashier_name.hashCode ^
      created_at.hashCode ^
      store_id.hashCode;
  }
}
