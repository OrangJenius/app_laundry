// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class NotaModel {
  final String? id;
  final String ketentuan;
  final String store_id;
  NotaModel({
    this.id,
    required this.ketentuan,
    required this.store_id,
  });

  NotaModel copyWith({
    String? id,
    String? ketentuan,
    String? store_id,
  }) {
    return NotaModel(
      id: id ?? this.id,
      ketentuan: ketentuan ?? this.ketentuan,
      store_id: store_id ?? this.store_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ketentuan': ketentuan,
      'store_id': store_id,
    };
  }

  factory NotaModel.fromMap(Map<String, dynamic> map) {
    return NotaModel(
      id: map['id'] != null ? map['id']?.toString() as String : null,
      ketentuan: map['ketentuan'] as String,
      store_id: map['store_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotaModel.fromJson(String source) => NotaModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'NotaModel(id: $id, ketentuan: $ketentuan, store_id: $store_id)';

  @override
  bool operator ==(covariant NotaModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.ketentuan == ketentuan &&
      other.store_id == store_id;
  }

  @override
  int get hashCode => id.hashCode ^ ketentuan.hashCode ^ store_id.hashCode;
}
