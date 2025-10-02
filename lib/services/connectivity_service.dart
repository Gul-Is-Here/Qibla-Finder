import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  final InternetConnectionChecker _connectionChecker;

  ConnectivityService() : _connectionChecker = InternetConnectionChecker.createInstance(
    checkInterval: const Duration(seconds: 10), // Check every 10 seconds
    checkTimeout: const Duration(seconds: 5),   // Timeout after 5 seconds
  );

  Future<bool> hasConnection() async {
    return await _connectionChecker.hasConnection;
  }

  Stream<bool> get connectionStream {
    return _connectionChecker.onStatusChange.map(
      (status) => status == InternetConnectionStatus.connected,
    );
  }
}