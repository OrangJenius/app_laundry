// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AntarJemputModel {
  final String? id;
  final String jarak;
  final String harga;
  final String store_id;

  AntarJemputModel({
    this.id,
    required this.jarak,
    required this.harga,
    required this.store_id,
  });

  AntarJemputModel copyWith({
    String? id,
    String? jarak,
    String? harga,
    String? store_id,
  }) {
    return AntarJemputModel(
      id: id ?? this.id,
      jarak: jarak ?? this.jarak,
      harga: harga ?? this.harga,
      store_id: store_id ?? this.store_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'id': id,
      'jarak': jarak,
      'harga': harga,
      'store_id': store_id,
    };
  }

  factory AntarJemputModel.fromMap(Map<String, dynamic> map) {
    return AntarJemputModel(
      id: map['id'] != null ? map['id']?.toString() as String : null,
      jarak: map['jarak'] as String,
      harga: map['harga']?.toString() as String,
      store_id: map['store_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AntarJemputModel.fromJson(String source) => AntarJemputModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Antarjemputmodel(id: $id, jarak: $jarak, harga: $harga, store_id: $store_id)';
  }

  @override
  bool operator ==(covariant AntarJemputModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.jarak == jarak &&
      other.harga == harga &&
      other.store_id == store_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      jarak.hashCode ^
      harga.hashCode ^
      store_id.hashCode;
  }
}
