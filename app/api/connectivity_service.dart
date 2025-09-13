import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityServiceSingleton {
  ConnectivityServiceSingleton._internal() {
    Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _timer?.cancel();
        if (results.any((result) => result != ConnectivityResult.none)) {
          hasConnection = true;
          _timer = Timer.periodic(
            const Duration(seconds: 10),
            (_) async => hasConnection = await _checkConnection(),
          );
        } else {
          hasConnection = false;
        }
      },
    );
  }

  static final ConnectivityServiceSingleton instance = ConnectivityServiceSingleton._internal();
  Timer? _timer;
  final RxBool _hasConnection = true.obs;

  bool get hasConnection => _hasConnection.value;

  set hasConnection(bool value) => _hasConnection.value = value;

  Future<bool> _checkConnection() async {
    bool hasConnection;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }
    return hasConnection;
  }

  Future<void> initializeConnection() async {
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    if (results.any((result) => result == ConnectivityResult.mobile || result == ConnectivityResult.wifi)) {
      hasConnection = await _checkConnection();
    } else {
      hasConnection = false;
    }
  }
}
