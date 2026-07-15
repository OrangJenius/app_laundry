// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UnitModel {
  final int id; // Matches the int8/int type in your schema
  final String unit_name; // e.g., 'kg', 'm', 'pcs'

  UnitModel({
    required this.id,
    required this.unit_name,
  });


  UnitModel copyWith({
    int? id,
    String? unit_name,
  }) {
    return UnitModel(
      id: id ?? this.id,
      unit_name: unit_name ?? this.unit_name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'unit_name': unit_name,
    };
  }

  factory UnitModel.fromMap(Map<String, dynamic> map) {
    return UnitModel(
      id: map['id'] as int,
      unit_name: map['unit_name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UnitModel.fromJson(String source) => UnitModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UnitModel(id: $id, unit_name: $unit_name)';

  @override
  bool operator ==(covariant UnitModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.unit_name == unit_name;
  }

  @override
  int get hashCode => id.hashCode ^ unit_name.hashCode;
}
