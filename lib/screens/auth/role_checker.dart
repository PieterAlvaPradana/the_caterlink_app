import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main_navigation_shell.dart';
import 'login_screen.dart';

class RoleChecker extends StatelessWidget {
  const RoleChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Jika belum login, tampilkan LoginScreen
      return const LoginScreen();
    }

    return const MainNavigationShell();
  }
}
