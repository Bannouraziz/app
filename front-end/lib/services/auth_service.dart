import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import 'api_config.dart';

class AuthService {
  final http.Client _client;
  final SharedPreferences prefs;
  final ApiService apiService;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  AuthService({
    required http.Client client,
    required this.prefs,
    required this.apiService,
  }) : _client = client;

  Future<void> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required int age,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'nom': nom,
        'prenom': prenom,
        'age': age,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Échec de l\'inscription: ${response.body}');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la connexion: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final token = data['token'];
    final userId = data['userId'];

    if (token == null || userId == null) {
      throw Exception('Invalid response format: missing token or userId');
    }

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    apiService.setToken(token);
  }

  Future<void> logout() async {
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    apiService.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      apiService.setToken(token);
    }
    return token != null;
  }

  String? getToken() {
    return prefs.getString(_tokenKey);
  }

  String? getUserId() {
    return prefs.getString(_userIdKey);
  }
}
