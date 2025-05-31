import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../helpers/error_handler.dart';

class ApiService {
  final String baseUrl;
  String? _token;

  ApiService({required this.baseUrl, String? token}) : _token = token;

  void setToken(String? token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Uri _buildUri(String endpoint) {
    final path = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = '$baseUrl/$path';
    if (kDebugMode) {
      print('Building URL: $url');
    }
    return Uri.parse(url);
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final uri = _buildUri(endpoint);
      if (kDebugMode) {
        print('GET Request to: $uri'); // Debug logging
      }

      final response = await http
          .get(
        uri,
        headers: _buildHeaders(),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw NetworkError(
            message: 'La connexion au serveur a expiré. Veuillez réessayer.',
            type: NetworkErrorType.connectionTimeout,
          );
        },
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      return _handleResponse(response);
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('Socket Exception: $e');
      }
      throw NetworkError.fromException(e);
    } on HttpException catch (e) {
      if (kDebugMode) {
        print('HTTP Exception: $e');
      }
      throw NetworkError.fromException(e);
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('Format Exception: $e');
      }
      throw NetworkError.fromException(e);
    } catch (e) {
      if (kDebugMode) {
        print('Unknown GET Error: $e');
      }
      throw NetworkError.fromException(e);
    }
  }

  Future<dynamic> post(String endpoint, dynamic body) async {
    try {
      final uri = _buildUri(endpoint);
      if (kDebugMode) {
        print('Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}');
        print('Connecting to: $uri');
      }

      final response = await http
          .post(
        uri,
        headers: _buildHeaders(),
        body: jsonEncode(body),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw NetworkError(
            message: 'La connexion au serveur a expiré. Veuillez réessayer.',
            type: NetworkErrorType.connectionTimeout,
          );
        },
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      return _handleResponse(response);
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('Socket Exception: $e');
      }
      throw NetworkError.fromException(e);
    } on HttpException catch (e) {
      if (kDebugMode) {
        print('HTTP Exception: $e');
      }
      throw NetworkError.fromException(e);
    } on FormatException catch (e) {
      if (kDebugMode) {
        print('Format Exception: $e');
      }
      throw NetworkError.fromException(e);
    } catch (e) {
      if (kDebugMode) {
        print('Unknown POST Error: $e');
      }
      throw NetworkError.fromException(e);
    }
  }

  Future<dynamic> put(String endpoint, dynamic body) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .put(
        uri,
        headers: _buildHeaders(),
        body: jsonEncode(body),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw NetworkError(
            message: 'La connexion au serveur a expiré. Veuillez réessayer.',
            type: NetworkErrorType.connectionTimeout,
          );
        },
      );
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkError.fromException(e);
    } on HttpException catch (e) {
      throw NetworkError.fromException(e);
    } on FormatException catch (e) {
      throw NetworkError.fromException(e);
    } catch (e) {
      throw NetworkError.fromException(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .delete(
        uri,
        headers: _buildHeaders(),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw NetworkError(
            message: 'La connexion au serveur a expiré. Veuillez réessayer.',
            type: NetworkErrorType.connectionTimeout,
          );
        },
      );
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkError.fromException(e);
    } on HttpException catch (e) {
      throw NetworkError.fromException(e);
    } on FormatException catch (e) {
      throw NetworkError.fromException(e);
    } catch (e) {
      throw NetworkError.fromException(e);
    }
  }

  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } catch (e) {
        print('Error parsing response: ${response.body}');
        throw NetworkError(
          message: 'Format de données incorrect reçu du serveur.',
          type: NetworkErrorType.serverError,
          originalError: e,
        );
      }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final message =
            errorData['message'] ?? 'Erreur du serveur: ${response.statusCode}';
        throw NetworkError.fromStatusCode(
          response.statusCode,
          serverMessage: message,
        );
      } catch (e) {
        // If we can't parse the error message, use a generic one
        throw NetworkError.fromStatusCode(response.statusCode);
      }
    }
  }
}
