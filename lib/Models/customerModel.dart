class Customer {
  final String? id;
  final String? nama;
  final String? alamat;
  final String? phoneNumber;
  final String? store_id;

  Customer({
    this.id,
    required this.alamat,
    required this.nama,
    required this.phoneNumber,
    this.store_id,
  });

  // Ganti nama dari fromJson ke fromMap agar seragam dengan fungsi Supabase
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id']?.toString(),
      nama: map['nama'] as String?,
      phoneNumber: map['nomor_telepon'] as String?,
      alamat: map['alamat'] as String?, 
      store_id: map['store_id']?.toString(),
    );
  }

  // Gunakan nama toMap() untuk menghasilkan Map<String, dynamic>
  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{
      'nama': nama,
      'nomor_telepon': phoneNumber,
      'alamat': alamat,
      'store_id' : store_id,
    };
    
    if (id != null) {
      result['id'] = id;
    }
    
    return result;
  }
}