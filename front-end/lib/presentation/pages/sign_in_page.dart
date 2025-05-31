import 'package:app_educatif/presentation/pages/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/error_handler.dart';
import '../../helpers/page_transitions.dart';
import '../../helpers/support.dart';
import '../../services/auth_service.dart';
import 'main_navigation_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final nomController = TextEditingController();
  final motDePasseController = TextEditingController();
  bool _isLoading = false;
  bool _hasConnectionError = false;

  @override
  void dispose() {
    nomController.dispose();
    motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (nomController.text.isEmpty || motDePasseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasConnectionError = false;
    });

    try {
      final authService = context.read<AuthService>();
      await authService.login(
        email: nomController.text,
        password: motDePasseController.text,
      );

      if (!mounted) return;

      // Always navigate directly to main navigation after successful login
      // Since age should already be set during signup
      Navigator.pushReplacement(
        context,
        PageTransitions.fadeTransition(const MainNavigationPage()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasConnectionError = e is NetworkError &&
            (e.type == NetworkErrorType.connectionRefused ||
                e.type == NetworkErrorType.networkNotAvailable ||
                e.type == NetworkErrorType.serverDown);
      });

      if (_hasConnectionError) {
      } else {
        ErrorHandler.showErrorDialog(context, e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasConnectionError) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/start_app.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: ErrorHandler.buildNoConnectionWidget(
                () {
                  setState(() {
                    _hasConnectionError = false;
                  });
                  _seConnecter();
                },
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/start_app.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Connexion",
                    style: AppTextStyles.heading1(context).copyWith(
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: nomController,
                    decoration:
                        AppDecorations.textFieldDecoration(context, "Email")
                            .copyWith(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 10)),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: motDePasseController,
                    obscureText: true,
                    decoration: AppDecorations.textFieldDecoration(
                            context, "Mot de passe")
                        .copyWith(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 10)),
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: _isLoading ? null : _seConnecter,
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: AppDecorations.buttonDecoration(context),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                "Se connecter",
                                style: AppTextStyles.buttonText(context),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text(
                      "Pas de compte ? Inscrivez-vous",
                      style: AppTextStyles.bodyText(context).copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
