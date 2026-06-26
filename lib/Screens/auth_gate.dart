import 'package:app_laundry/Screens/loginScreen.dart';
import 'package:app_laundry/Screens/navigationBar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Explicitly typed as <AuthState> to ensure snapshot parses data correctly
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // snapshot.data is now safely recognized as an AuthState object
        final session = snapshot.hasData ? snapshot.data!.session : null;
        
        if (session != null) {
          // Triggers dynamically upon baseline startup OR when email deep link confirms
          return const MainNavigationScreen(currentPageIndex: 0);
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}