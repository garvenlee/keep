import 'dart:convert';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:keep/BLoC/message_bloc.dart';
import 'package:keep/utils/event_util.dart';
import 'package:keep/models/message.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/global/config.dart';

class SocketUtil {
  static SocketUtil _instance = new SocketUtil.internal();
  SocketUtil.internal();
  factory SocketUtil() => _instance;

  static SocketIOManager manager = new SocketIOManager();
  static SocketIO _socket;
  static String url = "http://$baseIP:$port/";
  static bool isLogout = true;
  Future<SocketIO> get socket async {
    if (_socket != null) {
      print('_socket is not null........');
      return _socket;
    }
    _socket = await initSocket();
    return _socket;
  }

  initSocket() async {
    print('init socket....................');
    String apiKey = UserProvider.getApiKey();
    print('apikey is .................');
    print(apiKey);
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
      pprint(data);
      bus.emit('login', data);
    });
    internalSocket.onConnectError((data) {
      print('onConnectError=========================>');
      bus.emit('login-error', data);
    });
    internalSocket.onConnectTimeout((data){
      print('onConnectTimeout=======================>');
      pprint(data);
      bus.emit('login-error', data);
    });
    internalSocket.onReconnect(pprint);
    internalSocket.onError((data) {
      print('Error==================================>');
      pprint(data);
      bus.emit('authorized', data);
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
    internalSocket.on('chat', (stream) {
      print('receive new message==============================>');
      // print(stream);
      Message msg = Message.fromMap(stream);
      // save message
      print(msg);
      MessageBloc bloc = MessageBloc();
      bloc.addMessage(msg);
      // local_notification
      bus.emit('new_msg_notification', msg);
    });

    internalSocket.on('friendRequest', (stream) {
      print('received a friend request from ' + stream['userOneId'].toString());
      bus.emit('friendRequest', stream);
    });
    internalSocket.on('friendResponse', (stream) {
      print('check the response of the friend request from userId' +
          stream['userTwoId'].toString());
      bus.emit('friendResponse', stream);
    });
    internalSocket.on('friendDone', (stream) {
      print('update the local friends');
      bus.emit('friendDone', stream);
    });

    internalSocket.connect();
    return internalSocket;
  }

  static disconnect() async {
    print('I am disconnect static fucntion...............');
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
