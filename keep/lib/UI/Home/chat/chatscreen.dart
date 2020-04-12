import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:keep/global/global_tool.dart';

import 'package:keep/utils/sputil.dart';
import 'chat_item.dart';

const String URI = "http://192.168.124.15:42300/";

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  TextEditingController textEditingController;
  bool _isobscure = false;
  bool _isComposing = false;
  List<ChatItemWidget> _messages;
  ScrollController scrollController;
  SocketIOManager manager;
  Map<String, SocketIO> sockets = {};
  Map<String, bool> _isProbablyConnected = {};
  String selfName = 'Anonymous';
  int nowTimestamp;
  String _email;
  BuildContext _ctx;

  @override
  void initState() {
    super.initState();
    this._email = SpUtil.getString('email');
    _messages = <ChatItemWidget>[];
    textEditingController = TextEditingController();
    scrollController = ScrollController();
    manager = SocketIOManager();
    initSocket("default");
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    disconnect("default");
    for (ChatItemWidget message in _messages)
      message.animationController.dispose();
    super.dispose();
  }

  initSocket(String identifier) async {
    setState(() => _isProbablyConnected[identifier] = true);
    SocketIO socket = await manager.createInstance(SocketOptions(
        //Socket IO server URI
        URI,
        nameSpace: (identifier == "namespaced") ? "/adhara" : "/",
        //Query params - can be used for authentication
        // query: {
        //   "auth": "--SOME AUTH STRING---",
        //   "info": "new connection from adhara-socketio",
        //   "timestamp": DateTime.now().toString()
        // },
        //Enable or disable platform channel logging
        enableLogging: false,
        transports: [
          Transports.WEB_SOCKET,
          Transports.POLLING
        ] //Enable required transport
        ));
    socket.onConnect((data) {
      pprint("connected...");
      // pprint(data);
      // socket.emit("send_info", [socket.id]);
    });
    socket.onConnectError(pprint);
    socket.onConnectTimeout(pprint);
    socket.onError(pprint);
    socket.onDisconnect(pprint);
    socket.on("new_message", _newMsg);
    socket.connect();
    sockets[identifier] = socket;
  }

  bool isProbablyConnected(String identifier) {
    return _isProbablyConnected[identifier] ?? false;
  }

  disconnect(String identifier) async {
    print('desconnect.....');
    await manager.clearInstance(sockets[identifier]);
    setState(() => _isProbablyConnected[identifier] = false);
  }

  sendMessage(identifier) {
    if (sockets[identifier] != null) {
      // pprint("sending message from '$identifier'...");
      sockets[identifier].emit("send_message", [textEditingController.text]);
      // pprint("Message emitted from '$identifier'...");
    }
  }

  sendMessageWithACK(identifier) {
    pprint("Sending ACK message from '$identifier'...");
    List msg = [
      "Hello world!",
    ];
    sockets[identifier].emitWithAck("ack-message", msg).then((data) {
      // this callback runs when this specific message is acknowledged by the server
      pprint("ACK recieved from '$identifier' for $msg: $data");
    });
  }

  pprint(data) {
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }
      print(data);
    });
  }

  void _newMsg(stream) {
    textEditingController.clear();
    setState(() {
      _isComposing = false;
    });
    // print(stream.toString());
    print('newmsg......');
    // print(stream.runtimeType);
    // print(stream is Map<String, String>);
    // final data = stream as Map<String, String>;
    final data = stream as Map<String, dynamic>;
    // print(data["username"]);
    ChatItemWidget chatMessage = new ChatItemWidget(
      username: data['username'],
      text: data['message'],
      animationController: new AnimationController(
          duration: new Duration(milliseconds: 700), //new
          vsync: this),
      isSelf: (data['username'] == selfName),
      timestampFlag: data['timestampFlag'],
      timestamp: nowTimestamp,
    );
    setState(() {
      print('insert into _messageslist');
      //used to rebuild our widget
      _messages.insert(0, chatMessage);
    });
    // chatMessage.animationController.fling();
    chatMessage.animationController.forward();
  }

  // void _statusToggle() {
  //   setState(() {
  //     _isobscure = !_isobscure;
  //   });
  // }

  Widget buildStatusBar() {
    return _isobscure ? Text(' is typing a message...') : Container();
  }

  Widget buildChatInput() {
    return new Flexible(
        child: new Container(
            // width: MediaQuery.of(context).size.width * 0.7,
            padding: const EdgeInsets.all(2.0),
            child: Container(
              height: 40.0,
              child: Center(
                  child: TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  hintText: "Send a message",
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                controller: textEditingController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                // onSubmitted: _handleSubmitted,
              )),
            )));
  }

  Widget buildFaceTool() {
    return Material(
      child: new Container(
        width: 36.0,
        // margin: new EdgeInsets.symmetric(horizontal: 1.0),
        child: new IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () => {},
          icon: new Icon(Icons.face),
          color: Colors.grey,
        ),
      ),
      color: Colors.white,
    );
  }

  Widget buildLink() {
    return Material(
      child: new Container(
        // margin: new EdgeInsets.symmetric(horizontal: 1.0),
        width: 36.0,
        child: new IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () => {},
          icon: new Icon(Icons.link),
          color: Colors.grey,
        ),
      ),
      color: Colors.white,
    );
  }

  Widget buildSendButton() {
    return new Container(
        // margin: const EdgeInsets.symmetric(horizontal: 20.0),
        height: 45.0,
        child: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          onPressed: _isComposing
              ? () {
                  //Check if the textfield has text or not
                  if (textEditingController.text.isNotEmpty) {
                    //Send the message as JSON data to send_message event
                    print('send msg');
                    nowTimestamp = DateTime.now().millisecondsSinceEpoch;
                    sockets['default'].emit("send_message", [
                      {
                        "message": textEditingController.text,
                        "timestamp": (nowTimestamp / 1000).floor()
                      }
                    ]);
                    textEditingController.text = '';
                    print('send done...');
                    // Scrolldown the list to show the latest message
                    // scrollController.animateTo(
                    //   scrollController.position.maxScrollExtent,
                    //   duration: Duration(milliseconds: 100),
                    //   curve: Curves.ease,
                    // );
                  }
                }
              : null,
          child: Icon(
            Icons.send,
            size: 25,
          ),
        ));
  }

  Widget _textComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: Colors.blue),
      child: new Container(
        // height: 50.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            buildFaceTool(),
            buildLink(),
            buildChatInput(),
            buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
        height: 50.0,
        decoration: BoxDecoration(color: Colors.blueGrey),
        padding: new EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(children: <Widget>[
          Container(
              width: MediaQuery.of(_ctx).size.width * 0.15 - 10.0,
              child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(_ctx).pop();
                  })),
          Container(
              width: MediaQuery.of(_ctx).size.width * 0.3,
              child: Text(capitalize('garvenlee'),
                  style: TextStyle(
                      // color: Colors.white70,
                      fontSize: 18.0))),
          Container(
              height: 40.0,
              width: MediaQuery.of(context).size.width * 0.4,
              padding: const EdgeInsets.all(5.0)),
          Container(
              width: MediaQuery.of(_ctx).size.width * 0.15 - 10.0,
              child: IconButton(icon: Icon(Icons.more_vert), onPressed: () {})),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return new Scaffold(
        // leads input bar not padding
        // resizeToAvoidBottomPadding: false,
        body: SafeArea(
            child: new Column(
      children: <Widget>[
        buildHeader(),
        new Flexible(
          child: new ListView.builder(
            // physics: const NeverScrollableScrollPhysics(),
            controller: scrollController,
            padding: new EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          ),
        ),
        new Divider(
          height: 1.0,
        ),
        new Container(
          height: 54,
          decoration: new BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _textComposerWidget(),
        )
      ],
    )));
  }
}
