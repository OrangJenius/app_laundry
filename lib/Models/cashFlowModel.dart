// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CashFlowModel {
  final String? id;
  final String? created_at;
  final String jumlah;
  final String keterangan;
  final String tipe;
  final String cara_transaksi;
  final String profile_id;
  final String? order_id;
  final String store_id;

  CashFlowModel({
    this.id,
    this.created_at,
    required this.jumlah,
    required this.keterangan,
    required this.tipe,
    required this.cara_transaksi,
    required this.profile_id,
    this.order_id,
    required this.store_id
  });

  CashFlowModel copyWith({
    String? id,
    String? created_at,
    String? jumlah,
    String? keterangan,
    String? tipe,
    String? cara_transaksi,
    String? profile_id,
    String? order_id,
    String? store_id,
  }) {
    return CashFlowModel(
      id: id ?? this.id,
      created_at: created_at ?? this.created_at,
      jumlah: jumlah ?? this.jumlah,
      keterangan: keterangan ?? this.keterangan,
      tipe: tipe ?? this.tipe,
      cara_transaksi: cara_transaksi ?? this.cara_transaksi,
      profile_id: profile_id ?? this.profile_id,
      order_id: order_id ?? this.order_id,
      store_id: store_id ?? this.store_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'jumlah': jumlah,
      'keterangan': keterangan,
      'tipe': tipe,
      'cara_transaksi': cara_transaksi,
      'profile_id': profile_id,
      'order_id': order_id,
      'store_id': store_id,
    };
  }

  factory CashFlowModel.fromMap(Map<String, dynamic> map) {
    return CashFlowModel(
      id: map['id'] != null ? map['id']?.toString() as String : null,
      created_at: map['created_at'] != null ? map['created_at']?.toString() as String : null,
      jumlah: map['jumlah']?.toString() as String,
      keterangan: map['keterangan'] as String,
      tipe: map['tipe'] as String,
      cara_transaksi: map['cara_transaksi'] as String,
      profile_id: map['profile_id'] as String,
      order_id: map['order_id'] != null ? map['order_id']?.toString() as String : null,
      store_id: map['store_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CashFlowModel.fromJson(String source) => CashFlowModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CashFlowModel(id: $id, created_at: $created_at, jumlah: $jumlah, keterangan: $keterangan, tipe: $tipe, cara_transaksi: $cara_transaksi, profile_id: $profile_id, order_id: $order_id, store_id: $store_id)';
  }

  @override
  bool operator ==(covariant CashFlowModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.created_at == created_at &&
      other.jumlah == jumlah &&
      other.keterangan == keterangan &&
      other.tipe == tipe &&
      other.cara_transaksi == cara_transaksi &&
      other.profile_id == profile_id &&
      other.order_id == order_id &&
      other.store_id == store_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      created_at.hashCode ^
      jumlah.hashCode ^
      keterangan.hashCode ^
      tipe.hashCode ^
      cara_transaksi.hashCode ^
      profile_id.hashCode ^
      order_id.hashCode ^
      store_id.hashCode;
  }
}
