import 'dart:io';

import 'package:flutter/material.dart';

enum NetworkErrorType {
  connectionTimeout,
  connectionRefused,
  serverDown,
  networkNotAvailable,
  unauthorized,
  notFound,
  serverError,
  badRequest,
  unknown
}

class NetworkError implements Exception {
  final String message;
  final NetworkErrorType type;
  final dynamic originalError;

  NetworkError({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => message;

  static NetworkError fromException(dynamic exception) {
    if (exception is SocketException) {
      if (exception.message.contains('Connection refused')) {
        return NetworkError(
          message:
              'Impossible de se connecter au serveur. Veuillez vérifier que le service est en ligne.',
          type: NetworkErrorType.connectionRefused,
          originalError: exception,
        );
      } else if (exception.message.contains('Connection timed out')) {
        return NetworkError(
          message:
              'La connexion au serveur a pris trop de temps. Veuillez réessayer.',
          type: NetworkErrorType.connectionTimeout,
          originalError: exception,
        );
      } else {
        return NetworkError(
          message:
              'Pas de connexion internet. Veuillez vérifier votre connexion et réessayer.',
          type: NetworkErrorType.networkNotAvailable,
          originalError: exception,
        );
      }
    } else if (exception is HttpException) {
      return NetworkError(
        message: 'Erreur HTTP: ${exception.message}',
        type: NetworkErrorType.serverError,
        originalError: exception,
      );
    } else if (exception is FormatException) {
      return NetworkError(
        message: 'Format de données incorrect reçu du serveur.',
        type: NetworkErrorType.serverError,
        originalError: exception,
      );
    }

    // Handle generic exceptions
    final message = exception.toString();
    if (message.contains('Connection refused')) {
      return NetworkError(
        message:
            'Impossible de se connecter au serveur. Veuillez vérifier que le service est en ligne.',
        type: NetworkErrorType.connectionRefused,
        originalError: exception,
      );
    }

    return NetworkError(
      message: 'Une erreur inattendue est survenue: ${exception.toString()}',
      type: NetworkErrorType.unknown,
      originalError: exception,
    );
  }

  static NetworkError fromStatusCode(int statusCode, {String? serverMessage}) {
    switch (statusCode) {
      case 400:
        return NetworkError(
          message: serverMessage ?? 'Requête incorrecte',
          type: NetworkErrorType.badRequest,
        );
      case 401:
        return NetworkError(
          message: 'Session expirée. Veuillez vous reconnecter.',
          type: NetworkErrorType.unauthorized,
        );
      case 403:
        return NetworkError(
          message:
              'Accès refusé. Vous n\'avez pas les permissions nécessaires.',
          type: NetworkErrorType.unauthorized,
        );
      case 404:
        return NetworkError(
          message: 'Ressource introuvable.',
          type: NetworkErrorType.notFound,
        );
      case 500:
      case 501:
      case 502:
      case 503:
        return NetworkError(
          message:
              'Le serveur a rencontré un problème. Veuillez réessayer plus tard.',
          type: NetworkErrorType.serverError,
        );
      default:
        return NetworkError(
          message: serverMessage ?? 'Erreur inattendue (Code: $statusCode)',
          type: NetworkErrorType.unknown,
        );
    }
  }
}

class ErrorHandler {
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final NetworkError networkError =
        error is NetworkError ? error : NetworkError.fromException(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(networkError.message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showErrorDialog(BuildContext context, dynamic error) {
    final NetworkError networkError =
        error is NetworkError ? error : NetworkError.fromException(error);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur de connexion'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(networkError.message),
                const SizedBox(height: 16),
                _buildErrorHelpMessage(networkError.type),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            if (_shouldShowRetryButton(networkError.type))
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // The retry callback would be implemented where this is used
                },
                child: const Text('Réessayer'),
              ),
          ],
        );
      },
    );
  }

  static Widget _buildErrorHelpMessage(NetworkErrorType type) {
    String helpMessage;
    switch (type) {
      case NetworkErrorType.connectionRefused:
      case NetworkErrorType.serverDown:
        helpMessage =
            'Le serveur semble être hors ligne. Veuillez réessayer plus tard.';
        break;
      case NetworkErrorType.networkNotAvailable:
        helpMessage =
            'Veuillez vérifier votre connexion Wi-Fi ou données mobiles.';
        break;
      case NetworkErrorType.connectionTimeout:
        helpMessage = 'La connexion est lente ou instable. Veuillez réessayer.';
        break;
      case NetworkErrorType.unauthorized:
        helpMessage = 'Veuillez vous reconnecter à l\'application.';
        break;
      default:
        helpMessage = 'Si le problème persiste, contactez le support.';
    }
    return Text(
      helpMessage,
      style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
    );
  }

  static bool _shouldShowRetryButton(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.connectionTimeout:
      case NetworkErrorType.connectionRefused:
      case NetworkErrorType.networkNotAvailable:
      case NetworkErrorType.serverDown:
        return true;
      default:
        return false;
    }
  }

  static Widget buildNoConnectionWidget(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.signal_wifi_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Pas de connexion Internet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vérifiez votre connexion et réessayez',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
