import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../pages/main_screen.dart';
import 'auth_toggle_page.dart'; // New combined page

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFFFF9100)),
            );
          }

          if (snapshot.hasData) {
            return MainScreen();
          }

          return AuthTogglePage();
        },
      ),
    );
  }
}
