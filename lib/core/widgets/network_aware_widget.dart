import 'dart:async';
import 'package:flutter/material.dart';
import '../services/network_connectivity_service.dart';
import 'no_internet_dialog.dart';

class NetworkAwareWidget extends StatefulWidget {
  final Widget child;
  final bool showDialogOnNoInternet;

  const NetworkAwareWidget({
    super.key,
    required this.child,
    this.showDialogOnNoInternet = true,
  });

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  final NetworkConnectivityService _connectivityService =
      NetworkConnectivityService();
  bool _isConnected = true;
  bool _dialogShown = false;
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _listenToConnectivityChanges();
  }

  Future<void> _checkInitialConnectivity() async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
      });
      
      if (!isConnected && widget.showDialogOnNoInternet && !_dialogShown) {
        _showNoInternetDialog();
      }
    }
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = _connectivityService.connectionStatus.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });

        if (!isConnected && widget.showDialogOnNoInternet && !_dialogShown) {
          _showNoInternetDialog();
        } else if (isConnected && _dialogShown) {
          // Hide dialog when connection is restored
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          _dialogShown = false;
        }
      }
    });
  }

  void _showNoInternetDialog() {
    if (!_dialogShown && mounted) {
      _dialogShown = true;
      NoInternetDialog.show(
        context,
        onRetry: () {
          Navigator.of(context, rootNavigator: true).pop();
          _dialogShown = false;
          _checkInitialConnectivity();
        },
      ).then((_) {
        _dialogShown = false;
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If no internet and we should block access, show a blocking screen
    // The dialog will be shown separately
    if (!_isConnected && widget.showDialogOnNoInternet) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          child: const Center(
            child: SizedBox.shrink(), // Empty widget, dialog will handle the UI
          ),
        ),
      );
    }

    return widget.child;
  }
}
