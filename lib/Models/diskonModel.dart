// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DiskonModel {
  final String? id;
  final String jumlah_diskon;
  final String store_id;
  final String tipe_diskon;

  DiskonModel({
    this.id,
    required this.jumlah_diskon,
    required this.store_id,
    required this.tipe_diskon,
  });

  DiskonModel copyWith({
    String? id,
    String? jumlah_diskon,
    String? store_id,
    String? tipe_diskon,
  }) {
    return DiskonModel(
      id: id ?? this.id,
      jumlah_diskon: jumlah_diskon ?? this.jumlah_diskon,
      store_id: store_id ?? this.store_id,
      tipe_diskon: tipe_diskon ?? this.tipe_diskon,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'jumlah_diskon': jumlah_diskon,
      'store_id': store_id,
      'tipe_diskon': tipe_diskon,
    };
  }

  factory DiskonModel.fromMap(Map<String, dynamic> map) {
    return DiskonModel(
      id: map['id'] != null ? map['id']?.toString() as String : null,
      jumlah_diskon: map['jumlah_diskon']?.toString() as String,
      store_id: map['store_id'] as String,
      tipe_diskon: map['tipe_diskon'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DiskonModel.fromJson(String source) => DiskonModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DiskonModel(id: $id, jumlah_diskon: $jumlah_diskon, store_id: $store_id, tipe_diskon: $tipe_diskon)';
  }

  @override
  bool operator ==(covariant DiskonModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.jumlah_diskon == jumlah_diskon &&
      other.store_id == store_id &&
      other.tipe_diskon == tipe_diskon;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      jumlah_diskon.hashCode ^
      store_id.hashCode ^
      tipe_diskon.hashCode;
  }
}
