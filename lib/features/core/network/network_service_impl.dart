import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internappflutter/features/core/network/network_service.dart';

class NetworkServiceImpl implements NetworkService {
  final Connectivity _connectivity;

  NetworkServiceImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    return !connectivityResult.contains(ConnectivityResult.none);
  }

  @override
  Stream<ConnectivityResult> get onConnectivityChanged {
    // Transforms the Stream<List<ConnectivityResult>> to Stream<ConnectivityResult>
    return _connectivity.onConnectivityChanged.map((results) {
      return results.firstWhere(
        (result) => result != ConnectivityResult.none,
        orElse: () => ConnectivityResult.none,
      );
    });
  }
}
