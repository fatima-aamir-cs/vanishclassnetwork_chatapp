
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Check current network status
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();

    return result.any(
          (connection) => connection != ConnectivityResult.none,
    );
  }

  // Listen for network changes
  Stream<bool> get connectionStream {
    return _connectivity.onConnectivityChanged.map(
          (results) => results.any(
            (connection) => connection != ConnectivityResult.none,
      ),
    );
  }
}
