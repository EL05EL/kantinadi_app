import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  Timer? _timer;

  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _checkConnection();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!_isOnline) {
          _isOnline = true;
          notifyListeners();
        }
      } else {
        if (_isOnline) {
          _isOnline = false;
          notifyListeners();
        }
      }
    } on SocketException catch (_) {
      if (_isOnline) {
        _isOnline = false;
        notifyListeners();
      }
    } on TimeoutException catch (_) {
      if (_isOnline) {
        _isOnline = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
