import 'dart:convert';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/settings/config.dart';

class SocketUtil {
  static SocketUtil _instance = new SocketUtil.internal();
  SocketUtil.internal();
  factory SocketUtil() => _instance;

  static SocketIOManager manager = new SocketIOManager();
  static SocketIO _socket;
  static String url = "http://$baseIP:$port/";
  // static String url = httpUrl;
  // static bool isLogout = true;
  Future<SocketIO> get socket async {
    if (_socket != null) {
      // print('_socket is not null........');
      return _socket;
    }
    _socket = await initSocket();
    return _socket;
  }

  initSocket() async {
    print('init socket....................');
    String apiKey = UserProvider.getApiKey();
    SocketIO internalSocket = await manager.createInstance(SocketOptions(
        //Socket IO server URI
        url,
        nameSpace: "/",
        //Query params - can be used for authentication
        query: {
          "auth": apiKey,
          "info": "new connection from adhara-socketio",
          "timestamp": DateTime.now().toString()
        },
        //Enable or disable platform channel logging
        enableLogging: false,
        transports: [
          Transports.WEB_SOCKET,
          Transports.POLLING
        ] //Enable required transport
        ));

    internalSocket.onConnect((data) {
      print('onConnect==============================>');
    });
    internalSocket.onConnectError((data) {
      print('onConnectError=========================>');
      throw Exception(data);
    });
    internalSocket.onConnectTimeout((data) {
      print('onConnectTimeout=======================>');
      throw Exception(data);
    });
    internalSocket.onReconnect(pprint);
    internalSocket.onError((data) {
      print('Error==================================>');
      throw Exception(data);
    });
    internalSocket.onDisconnect(pprint);

    internalSocket.onConnecting((data) {
      print('connecting...................');
      pprint(data);
    });
    internalSocket.onReconnecting((data) {
      print('reconnecting..................');
      pprint(data);
    });
    return internalSocket;
  }

  static disconnect() async {
    // print('I am disconnect static fucntion...............');
    await manager.clearInstance(_socket).then((_) {
      _socket = null;
      UserProvider.clearUser();
    });
  }
}

pprint(data) {
  if (data is Map) {
    data = json.encode(data);
  }
  print(data);
}
