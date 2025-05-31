
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/error_handler.dart';
import 'main_navigation_page.dart';
import 'sign_in_page.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final authService = context.read<AuthService>();
      final isLoggedIn = await authService.isLoggedIn();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              isLoggedIn ? const MainNavigationPage() : SignInPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
      });
    }
  }

  void _retry() {
    setState(() {
      _hasError = false;
    });
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: ErrorHandler.buildNoConnectionWidget(_retry),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Display splash image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash_page.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
