// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TransaksiModel {
  final String? id;
  final String order_id;
  String? created_at;
  final String status_pembayaran;
  final String? jenis_pembayaran;
  final String profile_id;
  final String? jumlah_transaksi;

  TransaksiModel({
    this.id,
    required this.order_id,
    this.created_at,
    required this.status_pembayaran,
    this.jenis_pembayaran,
    required this.profile_id,
    this.jumlah_transaksi
  });

  TransaksiModel copyWith({
    String? id,
    String? order_id,
    String? created_at,
    String? status_pembayaran,
    String? jenis_pembayaran,
    String? profile_id,
    String? jumlah_transaksi,
  }) {
    return TransaksiModel(
      id: id ?? this.id,
      order_id: order_id ?? this.order_id,
      created_at: created_at ?? this.created_at,
      status_pembayaran: status_pembayaran ?? this.status_pembayaran,
      jenis_pembayaran: jenis_pembayaran ?? this.jenis_pembayaran,
      profile_id: profile_id ?? this.profile_id,
      jumlah_transaksi: jumlah_transaksi ?? this.jumlah_transaksi,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'order_id': order_id,
      'status_pembayaran': status_pembayaran,
      'jenis_pembayaran': jenis_pembayaran,
      'profile_id': profile_id,
      'jumlah_transaksi': jumlah_transaksi,
    };
  }

  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    return TransaksiModel(
      id: map['id'] != null ? map['id']?.toString() as String : null,
      order_id: map['order_id']?.toString() as String,
      created_at: map['created_at'] != null ? map['created_at']?.toString() as String : null,
      status_pembayaran: map['status_pembayaran'] as String,
      jenis_pembayaran: map['jenis_pembayaran'] != null ? map['jenis_pembayaran'] as String : null,
      profile_id: map['profile_id'] as String,
      jumlah_transaksi: map['jumlah_transaksi']?.toString() as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransaksiModel.fromJson(String source) => TransaksiModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TransaksiModel(id: $id, order_id: $order_id, created_at: $created_at, status_pembayaran: $status_pembayaran, jenis_pembayaran: $jenis_pembayaran, profile_id: $profile_id, jumlah_transaksi: $jumlah_transaksi)';
  }

  @override
  bool operator ==(covariant TransaksiModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.order_id == order_id &&
      other.created_at == created_at &&
      other.status_pembayaran == status_pembayaran &&
      other.jenis_pembayaran == jenis_pembayaran &&
      other.profile_id == profile_id &&
      other.jumlah_transaksi == jumlah_transaksi;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      order_id.hashCode ^
      created_at.hashCode ^
      status_pembayaran.hashCode ^
      jenis_pembayaran.hashCode ^
      profile_id.hashCode ^
      jumlah_transaksi.hashCode;
  }
}
