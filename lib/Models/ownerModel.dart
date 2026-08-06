// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class OwnerModel {
  final String? id;
  final String created_at;
  OwnerModel({
    this.id,
    required this.created_at,
  });

  OwnerModel copyWith({
    String? id,
    String? created_at,
  }) {
    return OwnerModel(
      id: id ?? this.id,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'created_at': created_at,
    };
  }

  factory OwnerModel.fromMap(Map<String, dynamic> map) {
    return OwnerModel(
      id: map['id'] != null ? map['id'] as String : null,
      created_at: map['created_at'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OwnerModel.fromJson(String source) => OwnerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'OwnerModel(id: $id, created_at: $created_at)';

  @override
  bool operator ==(covariant OwnerModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.created_at == created_at;
  }

  @override
  int get hashCode => id.hashCode ^ created_at.hashCode;
}
