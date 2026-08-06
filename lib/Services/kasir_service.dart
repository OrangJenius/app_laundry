import 'package:app_laundry/Models/kasirModel.dart';
import 'package:app_laundry/Services/auth_service.dart';
import 'package:app_laundry/Services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KasirService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final profileService = ProfileService();
  final authService = AuthService();

  /// 1. MENAMBAHKAN KASIR BARU
  /// Supabase auto-generates the primary key ID on insert.
  Future<Map<String, dynamic>> addCashier({
    required String cashierName,
    required String storeId,
    String? ownerId,
  }) async {
    try {
      // 1. Insert into cashier table
      final cashierResponse = await _supabase
          .from('cashier')
          .insert({
            'cashier_name': cashierName,
            'store_id': storeId,
          })
          .select()
          .single();

      final String createdCashierUuid = cashierResponse['id'];

      // 2. Format a valid email and strong password
      final String generatedEmail = "$createdCashierUuid@mail.com";
      final String generatedPassword = "Kasir_123!$createdCashierUuid"; 

      final uID = await authService.signUpWithoutVerification(
        generatedEmail, 
        generatedPassword,
      );

      if (uID == null) {
        throw Exception("Gagal membuat user Auth. Cek log Edge Function.");
      }

      // 3. Update the profile row that was auto-created by the Auth trigger
      await _supabase
          .from('profiles')
          .update({
            'cashier_id': createdCashierUuid,
            'cashier_name': cashierName,
            'role': 'kasir',
            'store_id': storeId,
          })
          .eq('id', uID); // Matches auto-generated Auth ID
    
      return cashierResponse;
    } catch (e) {
      print("Error pada KasirService.addCashier: $e");
      rethrow;
    }
  }

  /// 2. MENGAMBIL DAFTAR KASIR BERDASARKAN STORE ID
  Future<List<KasirModel>> getCashiersByStore(String storeId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('cashier')
          .select()
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      return data.map((json) => KasirModel.fromMap(json)).toList();
    } catch (e) {
      print("Error pada KasirService.getCashiersByStore: $e");
      rethrow;
    }
  }
  Future<void> editCashier(String id, KasirModel kasir) async {
    try {
      await _supabase
          .from('cashier')
          .update(kasir.toMap())
          .eq('id', id);

    } catch (e) {
      print("Error pada KasirService.getCashiersByStore: $e");
      rethrow;
    }
  }  
  Future<void> deleteKasir(String id) async { // You only need the id to delete
    try {
      await _supabase
          .from('cashier')
          .delete()
          .eq('id', id); // <--- Tell Supabase WHICH row to delete
    } catch (e) {
      print('Error deleting diskon: $e');
      rethrow;
    }
  }
}