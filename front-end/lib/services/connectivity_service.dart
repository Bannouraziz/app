import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../helpers/error_handler.dart';
import 'api_config.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<NetworkStatus>.broadcast();
  Stream<NetworkStatus> get status => _controller.stream;

  // Track last known status to prevent unnecessary updates
  NetworkStatus _lastKnownStatus = NetworkStatus.online;

  // Use a counter to reduce false positives
  int _consecutiveFailures = 0;
  final int _requiredFailures =
      2; // Require multiple failures before showing error

  ConnectivityService() {
    // Initialize with current status, but don't immediately show error
    _connectivity.checkConnectivity().then((result) {
      if (result == ConnectivityResult.none) {
        _lastKnownStatus = NetworkStatus.offline;
        _controller.add(NetworkStatus.offline);
      } else {
        // Don't check API immediately to avoid false alarms
        // Just assume online initially
        _lastKnownStatus = NetworkStatus.online;
        _controller.add(NetworkStatus.online);

        // Check availability after a short delay
        Future.delayed(const Duration(seconds: 3), () {
          checkApiAvailability().then((isAvailable) {
            if (!isAvailable) {
              _consecutiveFailures++;
              if (_consecutiveFailures >= _requiredFailures) {
                _lastKnownStatus = NetworkStatus.serverUnavailable;
                _controller.add(NetworkStatus.serverUnavailable);
              }
            }
          });
        });
      }
    });

    // Listen for network connectivity changes
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // Check API server availability periodically, but less frequently
    Timer.periodic(const Duration(minutes: 2), (_) {
      checkApiAvailability();
    });
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      if (_lastKnownStatus != NetworkStatus.offline) {
        _lastKnownStatus = NetworkStatus.offline;
        _controller.add(NetworkStatus.offline);
      }
    } else {
      // We have connectivity, but device was offline before,
      // so let's check if the API is reachable
      if (_lastKnownStatus == NetworkStatus.offline) {
        final isApiAvailable = await checkApiAvailability();
        if (isApiAvailable) {
          _consecutiveFailures = 0;
          _lastKnownStatus = NetworkStatus.online;
          _controller.add(NetworkStatus.online);
        }
      }
    }
  }

  Future<bool> checkApiAvailability() async {
    try {
      // Use a route that definitely exists instead of /health
      final baseUrl = ApiConfig.baseUrl;
      final testUrl = baseUrl.endsWith('/api')
          ? baseUrl.substring(
              0, baseUrl.length - 4) // Remove /api to reach the server root
          : baseUrl;

      debugPrint('Checking API availability at: $testUrl');

      final response = await http.get(
        Uri.parse(testUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      debugPrint('API health check response: ${response.statusCode}');

      // If we got any response, the server is up
      _consecutiveFailures = 0;
      if (_lastKnownStatus != NetworkStatus.online) {
        _lastKnownStatus = NetworkStatus.online;
        _controller.add(NetworkStatus.online);
        debugPrint('Network status changed to ONLINE');
      }
      return true;
    } catch (e) {
      debugPrint('API availability check failed: $e');
      _consecutiveFailures++;

      // Only change status after multiple consecutive failures
      if (_consecutiveFailures >= _requiredFailures &&
          _lastKnownStatus != NetworkStatus.serverUnavailable) {
        _lastKnownStatus = NetworkStatus.serverUnavailable;
        _controller.add(NetworkStatus.serverUnavailable);
        debugPrint(
            'Network status changed to SERVER_UNAVAILABLE after $_consecutiveFailures failures');
      }
      return false;
    }
  }

  void showConnectivitySnackBar(BuildContext context, NetworkStatus status) {
    if (status == NetworkStatus.offline) {
      ErrorHandler.showErrorSnackBar(
        context,
        NetworkError(
          message: 'Pas de connexion internet',
          type: NetworkErrorType.networkNotAvailable,
        ),
      );
    } else if (status == NetworkStatus.serverUnavailable) {
      ErrorHandler.showErrorSnackBar(
        context,
        NetworkError(
          message: 'Le serveur est actuellement indisponible',
          type: NetworkErrorType.serverDown,
        ),
      );
    }
  }

  Future<NetworkStatus> checkCurrentConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return NetworkStatus.offline;
    } else {
      final isApiAvailable = await checkApiAvailability();
      return isApiAvailable
          ? NetworkStatus.online
          : NetworkStatus.serverUnavailable;
    }
  }

  void dispose() {
    _controller.close();
  }
}

enum NetworkStatus {
  online,
  offline,
  serverUnavailable,
}
