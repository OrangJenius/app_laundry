class Customer {
  final String? id;
  final String? nama;
  final String? alamat;
  final String? phoneNumber; // Changed to String to preserve leading 0 or +62

  Customer({
    this.id,
    required this.alamat,
    required this.nama,
    required this.phoneNumber,
  });

  // 1. Factory constructor to create a Customer from Supabase data
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString(),
      nama: json['nama'] as String?,
      phoneNumber: json['nomor_telepon'] as String?, // Safely converts to string
      alamat: json['alamat'] as String?,
    );
  }

  // 2. Method to convert Customer data into a Map for Supabase inserts/updates
  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'nomor_telepon': phoneNumber,
      'alamat': alamat,
    };
  }
}