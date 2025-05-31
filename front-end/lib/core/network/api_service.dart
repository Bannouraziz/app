import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../errors/failures.dart';

class ApiService {
  final http.Client _client;
  final String _baseUrl;

  ApiService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiFailure(message: 'GET request failed: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiFailure(message: 'POST request failed: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiFailure(message: 'PUT request failed: $e');
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      _handleResponse(response);
    } catch (e) {
      throw ApiFailure(message: 'DELETE request failed: $e');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    // TODO: Implement token management
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw ApiFailure(
        message: 'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}
