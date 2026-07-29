// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UnitModel {
  final String? id; // Matches the int/int type in your schema
  final String unit_name; // e.g., 'kg', 'm', 'pcs'
  final String unit_type;

  UnitModel({
    this.id,
    required this.unit_name,
    required this.unit_type,
  });


  UnitModel copyWith({
    String? id,
    String? unit_name,
    String? unit_type,
  }) {
    return UnitModel(
      id: id ?? this.id,
      unit_name: unit_name ?? this.unit_name,
      unit_type: unit_type ?? this.unit_type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'unit_name': unit_name,
      'unit_type': unit_type,
    };
  }

  factory UnitModel.fromMap(Map<String, dynamic> map) {
    return UnitModel(
      id: map['id'] != null ? map['id'] as String : null,
      unit_name: map['unit_name'] as String,
      unit_type: map['unit_type'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UnitModel.fromJson(String source) => UnitModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UnitModel(id: $id, unit_name: $unit_name, unit_type: $unit_type)';

  @override
  bool operator ==(covariant UnitModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.unit_name == unit_name &&
      other.unit_type == unit_type;
  }

  @override
  int get hashCode => id.hashCode ^ unit_name.hashCode ^ unit_type.hashCode;
}
