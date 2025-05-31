import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'sign_in_page.dart';

import '../../helpers/api_diagnostics.dart';
import 'level_map_page.dart';
import 'profile_page.dart';
import 'recommendation_page.dart';
import '../../services/api_config.dart';
import '../../services/connectivity_service.dart';
import '../../services/question_service.dart';
import '../widgets/bottom_navbar.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  final TextEditingController _apiUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pages = [
      LevelMapPage(
        questionService: Provider.of<QuestionService>(context, listen: false),
      ),
      ParentRecommendationPage(),
      const ProfilePage(),
    ];

    // Check API connectivity on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivity();
    });
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final authService = context.read<AuthService>();
    await authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  Future<void> _checkConnectivity() async {
    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);
    final status = await connectivityService.checkCurrentConnectivity();

    if (status != NetworkStatus.online) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == NetworkStatus.offline
              ? 'Pas de connexion internet'
              : 'Serveur API inaccessible'),
          action: SnackBarAction(
            label: 'Diagnostiquer',
            onPressed: () => _showDiagnosticsDialog(),
          ),
        ),
      );
    }
  }

  void _showDiagnosticsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Diagnostics API'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Exécuter les diagnostics pour vérifier la connexion avec le serveur backend.'),
              const SizedBox(height: 16),
              TextField(
                controller: _apiUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL API personnalisée',
                  hintText: 'http://192.168.1.3:3000/api',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (_apiUrlController.text.isNotEmpty) {
                  ApiConfig.setCustomApiUrl(_apiUrlController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'URL API mise à jour. Redémarrez l\'application.')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Définir URL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ApiDiagnostics.runAndShowDiagnostics(context);
              },
              child: const Text('Diagnostiquer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
