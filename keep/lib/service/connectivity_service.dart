import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:keep/settings/config.dart';
import 'package:keep/utils/utils_class.dart';

final addresses = [
  AddressCheckOptions(InternetAddress(baseIP),
      port: port, timeout: Duration(seconds: 10)),
  AddressCheckOptions(
    InternetAddress('1.1.1.1'),
    port: 53,
    timeout: const Duration(seconds: 10),
  ),
  AddressCheckOptions(
    InternetAddress('8.8.4.4'),
    port: 53,
    timeout: const Duration(seconds: 10),
  ),
  AddressCheckOptions(
    InternetAddress('208.67.222.222'),
    port: 53,
    timeout: const Duration(seconds: 10),
  ),
];

class ConnectivityService {
  // Create our public controller
  StreamController<ConnectivityStatus> connectionStatusController =
      StreamController<ConnectivityStatus>();

  Stream<ConnectivityStatus> get stream => connectionStatusController.stream;
  ConnectivityService() {
    _streamOnListen();
  }

  _streamOnListen() {
    // Subscribe to the connectivity Chanaged Steam
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      DataConnectionChecker().addresses = addresses;
      //  print(DataConnectionChecker().addresses);
      //  print(result);
      if (result != ConnectivityResult.none) {
        await DataConnectionChecker().hasConnection.then((value) =>
            connectionStatusController.add(_getStatusFromResult(value)));
      } else {
        connectionStatusController.add(ConnectivityStatus.Offline);
      }
    });
  }

  // Convert from the third part enum to our own enum
  ConnectivityStatus _getStatusFromResult(bool isConnected) {
    ConnectivityStatus status;
    switch (isConnected) {
      case true:
        status = ConnectivityStatus.Available;
        break;
      case false:
        status = ConnectivityStatus.Unavailable;
        break;
      default:
        status = ConnectivityStatus.Offline;
    }
    return status;
  }
}
