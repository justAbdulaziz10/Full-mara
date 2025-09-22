import 'package:flutter/material.dart';
import 'package:marafinal/features/auth/presentation/pages/login_page.dart';
import 'package:marafinal/features/auth/presentation/pages/register_page.dart';
// Make sure the path above points to the actual location of register_page.dart where RegisterPage is defined.

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        togglePages: togglePages,
      );
    } else {
      return RegisterPage(
        togglePages: togglePages,
      );
    }
  }
}
