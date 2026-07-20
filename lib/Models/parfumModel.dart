// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ParfumModel {
  final String? id;
  final String nama_parfum;
  final String store_id;

  ParfumModel({
    this.id,
    required this.nama_parfum,
    required this.store_id,
  });

  ParfumModel copyWith({
    String? id,
    String? nama_parfum,
    String? store_id,
  }) {
    return ParfumModel(
      id: id ?? this.id,
      nama_parfum: nama_parfum ?? this.nama_parfum,
      store_id: store_id ?? this.store_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'id': id,
      'nama_parfum': nama_parfum,
      'store_id': store_id,
    };
  }

  factory ParfumModel.fromMap(Map<String, dynamic> map) {
    return ParfumModel(
      id: map['id'] != null ? map['id']?.toString() as String : null,
      nama_parfum: map['nama_parfum'] as String,
      store_id: map['store_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ParfumModel.fromJson(String source) => ParfumModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ParfumModel(id: $id, nama_parfum: $nama_parfum, store_id: $store_id)';

  @override
  bool operator ==(covariant ParfumModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.nama_parfum == nama_parfum &&
      other.store_id == store_id;
  }

  @override
  int get hashCode => id.hashCode ^ nama_parfum.hashCode ^ store_id.hashCode;
}
