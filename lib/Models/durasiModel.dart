// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DurasiModel {
  final String? id; // Matches the int8/int type in your schema
  final String? duration_name;
  final String? store_id;
  final String? hours;

  DurasiModel({
    this.id,
    required this.duration_name,
    this.store_id,
    required this.hours,
  });

  DurasiModel copyWith({
    String? id,
    String? duration_name,
    String? store_id,
    String? hours,
  }) {
    return DurasiModel(
      id: id ?? this.id,
      duration_name: duration_name ?? this.duration_name,
      store_id: store_id ?? this.store_id,
      hours: hours ?? this.hours,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'id': id,
      'duration_name': duration_name,
      'store_id': store_id,
      'hours': hours,
    };
  }

  factory DurasiModel.fromMap(Map<String, dynamic> map) {
    return DurasiModel(
      id: map['id'] != null ? map['id']?.toString() as String : null,
      duration_name: map['duration_name'] != null ? map['duration_name'] as String : null,
      store_id: map['store_id'] != null ? map['store_id'] as String : null,
      hours: map['hours'] != null ? map['hours']?.toString() as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DurasiModel.fromJson(String source) => DurasiModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DurasiModel(id: $id, duration_name: $duration_name, store_id: $store_id, hours: $hours)';
  }

  @override
  bool operator ==(covariant DurasiModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.duration_name == duration_name &&
      other.store_id == store_id &&
      other.hours == hours;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      duration_name.hashCode ^
      store_id.hashCode ^
      hours.hashCode;
  }
}
