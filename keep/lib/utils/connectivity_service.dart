import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:keep/global/connectivity_status.dart';
import 'package:keep/global/config.dart';

class ConnectivityService {
  // Create our public controller
  StreamController<ConnectivityStatus> connectionStatusController = StreamController<ConnectivityStatus>();
  ConnectivityService() {
    // Subscribe to the connectivity Chanaged Steam
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      // Use Connectivity() here to gather more info if you need t
       DataConnectionChecker().addresses = [AddressCheckOptions(InternetAddress(baseIP), port: port)];
      //  print(result);
       if(result != ConnectivityResult.none) {
        await DataConnectionChecker().hasConnection.then((value) => connectionStatusController.add(_getStatusFromResult(value)));
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
        status =  ConnectivityStatus.Available;
        break;
      case false:
        status =  ConnectivityStatus.Unavailable;
        break;
      default:
        status = ConnectivityStatus.Offline;
    }
    return status;
  }
}
