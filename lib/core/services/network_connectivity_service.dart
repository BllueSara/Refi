import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  StreamController<bool>? _connectionStatusController;
  Stream<bool> get connectionStatus =>
      _connectionStatusController?.stream ?? const Stream.empty();

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  NetworkConnectivityService() {
    _connectionStatusController = StreamController<bool>.broadcast();
    _init();
  }

  Future<void> _init() async {
    // Check initial connectivity status
    await checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        // Check if controller is still open before updating
        if (_connectionStatusController != null &&
            !_connectionStatusController!.isClosed) {
          _updateConnectionStatus(results);
        }
      },
      onError: (error) {
        debugPrint('❌ Connectivity stream error: $error');
      },
    );
  }

  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      _isConnected = false;

      // Only add if controller is not closed
      if (_connectionStatusController != null &&
          !_connectionStatusController!.isClosed) {
        _connectionStatusController!.add(false);
      }
      return false;
    }
  }

  bool _updateConnectionStatus(List<ConnectivityResult> results) {
    // Check if any of the connectivity results indicate internet access
    final hasConnection = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);

    _isConnected = hasConnection;

    // Only add if controller is not closed
    if (_connectionStatusController != null &&
        !_connectionStatusController!.isClosed) {
      _connectionStatusController!.add(hasConnection);
    }
    return hasConnection;
  }

  void dispose() {
    // Cancel subscription first to prevent new events
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    // Then close the controller
    if (_connectionStatusController != null &&
        !_connectionStatusController!.isClosed) {
      _connectionStatusController!.close();
    }
    _connectionStatusController = null;
  }
}
