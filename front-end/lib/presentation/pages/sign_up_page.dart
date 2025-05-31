import 'package:app_educatif/presentation/pages/main_navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/error_handler.dart';
import '../../helpers/page_transitions.dart';
import '../../helpers/support.dart';
import '../../services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = context.read<AuthService>();
        final age = int.parse(_ageController.text);

        // Register user
        await authService.register(
          nom: _nomController.text,
          prenom: _prenomController.text,
          email: _emailController.text,
          password: _passwordController.text,
          age: age,
        );

        // Save age in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('ageChoisi', true);
        await prefs.setInt('ageUtilisateur', age);

        if (!mounted) return;
        Navigator.pushReplacement(context,
            PageTransitions.fadeTransition(const MainNavigationPage()));
      } catch (e) {
        if (!mounted) return;

        // Show user-friendly error message
        if (e is NetworkError) {
          if (e.type == NetworkErrorType.connectionRefused ||
              e.type == NetworkErrorType.serverDown ||
              e.type == NetworkErrorType.networkNotAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  "Impossible de se connecter au serveur. Veuillez vérifier votre connexion internet.",
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Réessayer',
                  textColor: Colors.white,
                  onPressed: () {
                    _register();
                  },
                ),
              ),
            );
          } else {
            ErrorHandler.showErrorDialog(context, e);
          }
        } else {
          ErrorHandler.showErrorDialog(context, e);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.fill,
              child: Image.asset("assets/images/onbording.jpeg"),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.8),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      "Créer un compte",
                      style: AppTextStyles.heading1(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _nomController,
                      decoration: AppDecorations.textFieldDecoration(
                        context,
                        "Nom",
                      ).copyWith(
                        prefixIcon: const Icon(Icons.person),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 10),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _prenomController,
                      decoration: AppDecorations.textFieldDecoration(
                        context,
                        "Prénom",
                      ).copyWith(
                        prefixIcon: const Icon(Icons.person_outline),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 10),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre prénom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: AppDecorations.textFieldDecoration(
                        context,
                        "Email",
                      ).copyWith(
                        prefixIcon: const Icon(Icons.email),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 10),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!value.contains('@')) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      decoration: AppDecorations.textFieldDecoration(
                        context,
                        "Âge",
                      ).copyWith(
                        prefixIcon: const Icon(Icons.cake),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 10),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre âge';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 5 || age > 18) {
                          return 'L\'âge doit être entre 5 et 18 ans';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: AppDecorations.textFieldDecoration(
                        context,
                        "Mot de passe",
                      ).copyWith(
                        prefixIcon: const Icon(Icons.lock),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 10),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _isLoading ? null : _register,
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        decoration: AppDecorations.buttonDecoration(context),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  "S'inscrire",
                                  style: AppTextStyles.buttonText(context),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Déjà un compte ? Se connecter",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
