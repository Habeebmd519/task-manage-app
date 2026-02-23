import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/features/auth/presentation/screens/welcome_screen.dart';
import 'package:task_manager/features/tasks/presentation/screens/dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // logged in
        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // not logged in
        return const WelcomeScreen();
      },
    );
  }
}
