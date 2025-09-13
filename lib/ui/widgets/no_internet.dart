import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NoInternet {
  static final Connectivity _connectivity = Connectivity();

  static StreamSubscription? connectivityStreamSubscription;

  static Future<List<ConnectivityResult>> initConnectivity() async {
    late List<ConnectivityResult> result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      log('Exception: Failed to get connectivity.');
    }

    return updateConnectionStatus(result);
  }

  static Future<List<ConnectivityResult>> updateConnectionStatus(
      List<ConnectivityResult> result) async {
    List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];

    if (result.isNotEmpty && result.first != ConnectivityResult.none) {
      return result;
    }
    return _connectionStatus;
  }

    static Future<bool> isUserOffline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return true;
    } else {
      final hasConnection = await InternetConnectionChecker().hasConnection;
      return !hasConnection;
    }
  }
}
