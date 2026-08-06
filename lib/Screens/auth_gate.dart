import 'package:app_laundry/Screens/dashboardKasir.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Screens/loginScreen.dart';
import 'package:app_laundry/Screens/navigationBar.dart';
import 'package:app_laundry/Screens/startConfigScreen.dart';
import 'package:app_laundry/Services/auth_service.dart';
import 'package:app_laundry/Services/store_service.dart'; // Import service toko Anda

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final outletService = StoreService();

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        // --- GERBANG 1: PEMERIKSAAN SESI ---
        if (session == null) {
          return const LoginScreen();
        }

        // --- GERBANG 2 & 3: PEMERIKSAAN PROFIL & KEPEMILIKAN TOKO ---
        return FutureBuilder<Map<String, dynamic>?>(
          future: authService.getCurrentUserProfile(session.user.id),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (profileSnapshot.hasData && profileSnapshot.data != null) {
              print('Session saat ini: $session.user.id');
              final role = profileSnapshot.data!['role'];
              final storeId = profileSnapshot.data!['store_id'];
              final ownerId = profileSnapshot.data!['owner_id'];

              // JIKA KASIR: Langsung kunci ke dashboard kasir
              if (role == 'kasir') {
                return DashboardKasirScreen(store_id: storeId);
              }

              // JIKA OWNER: Jalankan pengecekan toko via FutureBuilder kedua
              return FutureBuilder<List<dynamic>>(
                future: outletService.fetchStoreWithOwnerId(ownerId ?? ''),
                builder: (context, storeSnapshot) {
                  if (storeSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Jika daftar toko kosong, paksa owner ke halaman AddOutletScreen
                  if (!storeSnapshot.hasData || storeSnapshot.data!.isEmpty) {
                    return StartConfigScreen(owner_id: ownerId); 
                  }

                  // Jika sudah punya minimal 1 toko, izinkan masuk ke dashboard utama
                  return MainNavigationScreen(currentPageIndex: 0, owner_id: ownerId,);
                },
              );
            }else{
              print("Profile data is missing or null! Current Session ID: ${session.user.id}");
            }
            // Fallback default jika terjadi anomali data profil
            // REPLACE THE OLD FALLBACK AT THE VERY BOTTOM:
            // return const LoginScreen();

            // WITH THIS:
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Setting up your profile workspace..."),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Supabase.instance.client.auth.signOut(),
                      child: const Text("Back to Login"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}