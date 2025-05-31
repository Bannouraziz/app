import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_config.dart';

class ApiDiagnostics {
  // Test API connection with various URLs
  static Future<Map<String, bool>> testApiConnections() async {
    final Map<String, bool> results = {};

    final testUrls = [
      'http://10.0.2.2:3000',
      'http://10.0.2.2:3000/api',
      'http://localhost:3000',
      'http://localhost:3000/api',
      'http://192.168.1.3:3000',
      'http://192.168.1.3:3000/api',
    ];

    for (final url in testUrls) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 3));

        results[url] = response.statusCode < 500;
        debugPrint('API test: $url - ${response.statusCode}');
      } catch (e) {
        results[url] = false;
        debugPrint('API test failed: $url - $e');
      }
    }

    return results;
  }

  // Test authenticated endpoints
  static Future<Map<String, dynamic>> testAuthenticatedEndpoints() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      return {'error': 'No authentication token found'};
    }

    final Map<String, dynamic> results = {};
    final baseUrl = ApiConfig.baseUrl;

    // Test endpoints
    final endpoints = [
      'eleves/profile',
      'questions',
      'questions/age/10/niveau/1',
      'questions?age=10&niveau=1',
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));

        results[endpoint] = {
          'status': response.statusCode,
          'isSuccess': response.statusCode >= 200 && response.statusCode < 300,
          'contentLength': response.body.length,
          'isEmpty': response.body.isEmpty,
        };

        // Add response data for further analysis
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            results[endpoint]['data'] =
                data is List ? 'Array[${data.length}]' : 'Object';
          } catch (e) {
            results[endpoint]['data'] = 'Not JSON';
          }
        }

        debugPrint('API endpoint test: $endpoint - ${response.statusCode}');
      } catch (e) {
        results[endpoint] = {'error': e.toString()};
        debugPrint('API endpoint test failed: $endpoint - $e');
      }
    }

    return results;
  }

  // Run diagnostics and show results
  static Future<void> runAndShowDiagnostics(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(
      const SnackBar(content: Text('Exécution des diagnostics API...')),
    );

    try {
      // Test basic connections
      final connectionResults = await testApiConnections();
      final hasAnyConnection = connectionResults.values.any((v) => v);

      if (!hasAnyConnection) {
        scaffold.showSnackBar(
          const SnackBar(
            content:
                Text('ERREUR: Aucune connexion aux points de terminaison API'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Test authenticated endpoints
      final endpointResults = await testAuthenticatedEndpoints();

      // Check if any endpoints succeeded
      final anyEndpointSuccess = endpointResults.values.any((v) {
        if (v is Map && v.containsKey('isSuccess')) {
          return v['isSuccess'] == true;
        }
        return false;
      });

      if (anyEndpointSuccess) {
        scaffold.showSnackBar(
          const SnackBar(
            content:
                Text('Certains points de terminaison API sont accessibles'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        scaffold.showSnackBar(
          const SnackBar(
            content:
                Text('ERREUR: Tous les points de terminaison API ont échoué'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // Log detailed results
      debugPrint('API connection diagnostics: $connectionResults');
      debugPrint('API endpoint diagnostics: $endpointResults');
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Erreur de diagnostic: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
