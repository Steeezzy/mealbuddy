import 'package:flutter/material.dart';
import 'package:mealb/screens/admin_create_account.dart';
import 'package:mealb/screens/admin_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final session = snapshot.hasData ? snapshot.data!.session : null; 
        if (session != null) {
          return const AdminLoginPage();
        } else {
          return const AdminCreateAccountPage();
         }
      }
      );
  }
}