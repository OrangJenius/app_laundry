// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class NotaModel {
  final String? id;
  final String ketentuan;
  final String store_id;
  final bool? logo_pelanggan;
  final bool? no_handphone_pelanggan;
  final bool? alamat_pelanggan;
  final bool? logo_produksi;
  final bool? No_handphone_produksi;
  final bool? alamat_produksi;
  NotaModel({
    this.id,
    required this.ketentuan,
    required this.store_id,
    this.logo_pelanggan,
    this.no_handphone_pelanggan,
    this.alamat_pelanggan,
    this.logo_produksi,
    this.No_handphone_produksi,
    this.alamat_produksi,
  });

  NotaModel copyWith({
    String? id,
    String? ketentuan,
    String? store_id,
    bool? logo_pelanggan,
    bool? no_handphone_pelanggan,
    bool? alamat_pelanggan,
    bool? logo_produksi,
    bool? No_handphone_produksi,
    bool? alamat_produksi,
  }) {
    return NotaModel(
      id: id ?? this.id,
      ketentuan: ketentuan ?? this.ketentuan,
      store_id: store_id ?? this.store_id,
      logo_pelanggan: logo_pelanggan ?? this.logo_pelanggan,
      no_handphone_pelanggan: no_handphone_pelanggan ?? this.no_handphone_pelanggan,
      alamat_pelanggan: alamat_pelanggan ?? this.alamat_pelanggan,
      logo_produksi: logo_produksi ?? this.logo_produksi,
      No_handphone_produksi: No_handphone_produksi ?? this.No_handphone_produksi,
      alamat_produksi: alamat_produksi ?? this.alamat_produksi,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ketentuan': ketentuan,
      'store_id': store_id,
      'logo_pelanggan': logo_pelanggan,
      'no_handphone_pelanggan': no_handphone_pelanggan,
      'alamat_pelanggan': alamat_pelanggan,
      'logo_produksi': logo_produksi,
      'No_handphone_produksi': No_handphone_produksi,
      'alamat_produksi': alamat_produksi,
    };
  }

  factory NotaModel.fromMap(Map<String, dynamic> map) {
    return NotaModel(
      id: map['id'] != null ? map['id'] as String : null,
      ketentuan: map['ketentuan'] as String,
      store_id: map['store_id'] as String,
      logo_pelanggan: map['logo_pelanggan'] != null ? map['logo_pelanggan'] as bool : null,
      no_handphone_pelanggan: map['no_handphone_pelanggan'] != null ? map['no_handphone_pelanggan'] as bool : null,
      alamat_pelanggan: map['alamat_pelanggan'] != null ? map['alamat_pelanggan'] as bool : null,
      logo_produksi: map['logo_produksi'] != null ? map['logo_produksi'] as bool : null,
      No_handphone_produksi: map['No_handphone_produksi'] != null ? map['No_handphone_produksi'] as bool : null,
      alamat_produksi: map['alamat_produksi'] != null ? map['alamat_produksi'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotaModel.fromJson(String source) => NotaModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotaModel(id: $id, ketentuan: $ketentuan, store_id: $store_id, logo_pelanggan: $logo_pelanggan, no_handphone_pelanggan: $no_handphone_pelanggan, alamat_pelanggan: $alamat_pelanggan, logo_produksi: $logo_produksi, No_handphone_produksi: $No_handphone_produksi, alamat_produksi: $alamat_produksi)';
  }

  @override
  bool operator ==(covariant NotaModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.ketentuan == ketentuan &&
      other.store_id == store_id &&
      other.logo_pelanggan == logo_pelanggan &&
      other.no_handphone_pelanggan == no_handphone_pelanggan &&
      other.alamat_pelanggan == alamat_pelanggan &&
      other.logo_produksi == logo_produksi &&
      other.No_handphone_produksi == No_handphone_produksi &&
      other.alamat_produksi == alamat_produksi;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      ketentuan.hashCode ^
      store_id.hashCode ^
      logo_pelanggan.hashCode ^
      no_handphone_pelanggan.hashCode ^
      alamat_pelanggan.hashCode ^
      logo_produksi.hashCode ^
      No_handphone_produksi.hashCode ^
      alamat_produksi.hashCode;
  }
}
