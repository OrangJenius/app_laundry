import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Models/ProfileModel.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;
  
  Future<List<ProfileModel>> fetchProfile() async {
     try {
      final List<dynamic> data = await _supabase
          .from('profiles') // Your table name
          .select();
          
      return data.map((json) => ProfileModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching Profile: $e');
      rethrow; 
    }
  }
  Future<ProfileModel?> fetchProfileWithId(String id) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle(); // <--- KUNCINYA DI SINI

      if (data == null) return null;

      // Langsung ubah satu Map tunggal menjadi satu objek ProfileModel
      return ProfileModel.fromMap(data); 
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }
  Future<void> addProfile(ProfileModel profile) async {
    try {
      await _supabase
          .from('profiles')
          .insert(profile.toMap());
    } catch (e) {
      print('Error adding Profile: $e');
      rethrow;
    }
  }
  Future<void> editProfile(String id, ProfileModel profile) async {
    try {
      await _supabase
          .from('profiles')
          .update(profile.toMap())
          .eq('id', id);
    } catch (e) {
      print('Error updating Profile: $e');
      rethrow;
    }
  }
    Future<void> deleteProfile(String id, ProfileModel profile) async {
    try {
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error updating Profile: $e');
      rethrow;
    }
  }
}