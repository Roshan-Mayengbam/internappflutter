import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkService {
  Future<bool> isConnected();
  Stream<ConnectivityResult> get onConnectivityChanged;
}
