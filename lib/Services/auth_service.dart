import 'package:app_laundry/Models/ownerModel.dart';
import 'package:app_laundry/Services/owner_service.dart';
import 'package:app_laundry/Services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ownerService = OwnerService();

  // Login normal (Owner) menggunakan Email & Password
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // BARU: Login Kasir menggunakan ID saja
  Future<AuthResponse> signInWithCashierId(String cashierId) async {
    // Ubah "KSR-001" menjadi "ksr001@laundry.com"
    final String cleanId = cashierId.toLowerCase().replaceAll('-', '').trim();
    final String computedEmail = "$cleanId@laundry.com";
    const String systemPassword = "LaundrySecret2026!"; // Sesuai password universal kasir

    return await _supabase.auth.signInWithPassword(
      email: computedEmail,
      password: systemPassword,
    );
  }

  // BARU: Ambil data peran (role) dan store_id dari tabel profiles
  Future<Map<String, dynamic>?> getCurrentUserProfile(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle(); // Returns null safely if row doesn't exist yet
      return data;
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }
  // Ambil semua daftar toko/cabang yang dimiliki oleh owner tertentu
  Future<List<Map<String, dynamic>>> getOwnerStores(String ownerId) async {
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from('store')
          .select('*')
          .eq('owner_id', ownerId);
      return data;
    } catch (e) {
      print("Gagal mengambil data toko: $e");
      return [];
    }
  }

  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    final data =  await _supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'managekos://login-callback',
    );
    final oID = await ownerService.addowner(OwnerModel(created_at: DateTime.now().toIso8601String()));
    await ProfileService().editProfile(data.user!.id, oID, 'owner');
    return data;
  }

  Future<String?> signUpWithoutVerification(String email, String password) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'unverified-user',
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.status == 200) {
        // Parse the JSON data returned from the Edge Function
        final Map<String, dynamic> data = response.data;
        final String? userId = data['user_id'];
        
        print('Unverified user created with ID: $userId');
        
        // // Optional auto-login
        // await Supabase.instance.client.auth.signInWithPassword(
        //   email: email,
        //   password: password,
        // );

        return userId;
      }
      return null;
    } catch (error) {
      print('Failed to create unverified user: $error');
      return null;
    }
  }

  Future<UserResponse> changePassword(String newPass) async {
    return await _supabase.auth.updateUser(
      UserAttributes(
        password: newPass,
      ),
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}